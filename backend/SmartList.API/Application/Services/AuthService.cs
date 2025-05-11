using FirebaseAdmin;
using FirebaseAdmin.Auth;
using Google.Apis.Auth;
using SmartList.API.Application.Interface;
using SmartList.API.Domain.Entities;
using SmartList.API.Infrastructure.Interface;
using System;
using System.Threading.Tasks;

namespace SmartList.API.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly IAuthRepository _authRepository;

        public AuthService(IAuthRepository authRepository)
        {
            _authRepository = authRepository ?? throw new ArgumentNullException(nameof(authRepository));
        }

        public async Task<(User, string)> LoginAsync(string email, string idToken)
        {
            try
            {
                Console.WriteLine($"Verifying ID token for email: {email}");
                var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(idToken);
                Console.WriteLine($"Decoded token audience: {decodedToken.Audience}");
                if (decodedToken.Claims["email"]?.ToString() != email)
                {
                    throw new Exception("invalid-token");
                }

                var userRecord = await FirebaseAuth.DefaultInstance.GetUserByEmailAsync(email);
                var user = new User
                {
                    Id = userRecord.Uid,
                    Email = userRecord.Email,
                    DisplayName = userRecord.DisplayName,
                    PhotoUrl = userRecord.PhotoUrl,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                await _authRepository.SaveUserAsync(user);

                var token = await FirebaseAuth.DefaultInstance.CreateCustomTokenAsync(userRecord.Uid);
                Console.WriteLine($"Login successful for user: {user.Id}");
                return (user, token);
            }
            catch (FirebaseAuthException ex)
            {
                Console.WriteLine($"FirebaseAuthException in Login: ErrorCode={ex.ErrorCode}, Message={ex.Message}, Inner={ex.InnerException?.Message}");
                throw MapFirebaseAuthException(ex);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Unexpected exception in Login: Message={ex.Message}, Inner={ex.InnerException?.Message}");
                throw new Exception("auth-error", ex);
            }
        }

        public async Task<(User, string)> RegisterAsync(string email, string password, string fullName)
        {
            try
            {
                Console.WriteLine($"Registering user: {email}");
                var userRecordArgs = new UserRecordArgs
                {
                    Email = email,
                    Password = password,
                    DisplayName = fullName
                };
                var userRecord = await FirebaseAuth.DefaultInstance.CreateUserAsync(userRecordArgs);
                var user = new User
                {
                    Id = userRecord.Uid,
                    Email = email,
                    DisplayName = fullName,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                await _authRepository.SaveUserAsync(user);
                var token = await FirebaseAuth.DefaultInstance.CreateCustomTokenAsync(userRecord.Uid);
                Console.WriteLine($"Registration successful for user: {user.Id}");
                return (user, token);
            }
            catch (FirebaseAuthException ex)
            {
                Console.WriteLine($"FirebaseAuthException in Register: ErrorCode={ex.ErrorCode}, Message={ex.Message}, Inner={ex.InnerException?.Message}");
                throw MapFirebaseAuthException(ex);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Unexpected exception in Register: Message={ex.Message}, Inner={ex.InnerException?.Message}");
                throw new Exception("auth-error", ex);
            }
        }

        public async Task<(User, string)> SignInWithGoogleAsync(string idToken, string accessToken)
        {
            try
            {
                Console.WriteLine($"Verifying Google ID token: {idToken.Substring(0, Math.Min(20, idToken.Length))}...");
                var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(idToken);
                Console.WriteLine($"Decoded token audience: {decodedToken.Audience}");
                var uid = decodedToken.Uid;
                Console.WriteLine($"Google token verified, UID: {uid}, Claims: {System.Text.Json.JsonSerializer.Serialize(decodedToken.Claims)}");

                UserRecord userRecord;
                try
                {
                    userRecord = await FirebaseAuth.DefaultInstance.GetUserAsync(uid);
                    Console.WriteLine($"Existing user found: {uid}");
                }
                catch (FirebaseAuthException ex) when (ex.ErrorCode.ToString() == "USER_NOT_FOUND")
                {
                    Console.WriteLine($"Creating new user for UID: {uid}");
                    userRecord = await FirebaseAuth.DefaultInstance.CreateUserAsync(new UserRecordArgs
                    {
                        Uid = uid,
                        Email = decodedToken.Claims["email"]?.ToString(),
                        DisplayName = decodedToken.Claims["name"]?.ToString(),
                        PhotoUrl = decodedToken.Claims["picture"]?.ToString()
                    });
                }

                var user = new User
                {
                    Id = userRecord.Uid,
                    Email = userRecord.Email,
                    DisplayName = userRecord.DisplayName,
                    PhotoUrl = userRecord.PhotoUrl,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                await _authRepository.SaveUserAsync(user);

                var token = await FirebaseAuth.DefaultInstance.CreateCustomTokenAsync(userRecord.Uid);
                Console.WriteLine($"Google Sign-In successful for user: {user.Id}");
                return (user, token);
            }
            catch (FirebaseAuthException ex)
            {
                Console.WriteLine($"FirebaseAuthException in Google Sign-In: ErrorCode={ex.ErrorCode}, Message={ex.Message}, Inner={ex.InnerException?.Message}");
                throw MapFirebaseAuthException(ex);
            }
            catch (InvalidJwtException ex)
            {
                Console.WriteLine($"InvalidJwtException in Google Sign-In: Message={ex.Message}, Inner={ex.InnerException?.Message}");
                throw new Exception("invalid-google-token");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Unexpected exception in Google Sign-In: Message={ex.Message}, Inner={ex.InnerException?.Message}");
                throw new Exception("auth-error", ex);
            }
        }

        public async Task LogoutAsync(string userId)
        {
            try
            {
                Console.WriteLine($"Logging out user: {userId}");
                await FirebaseAuth.DefaultInstance.RevokeRefreshTokensAsync(userId);
                Console.WriteLine($"Logout successful for user: {userId}");
            }
            catch (FirebaseAuthException ex)
            {
                Console.WriteLine($"FirebaseAuthException in Logout: ErrorCode={ex.ErrorCode}, Message={ex.Message}, Inner={ex.InnerException?.Message}");
                throw MapFirebaseAuthException(ex);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Unexpected exception in Logout: Message={ex.Message}, Inner={ex.InnerException?.Message}");
                throw new Exception("auth-error", ex);
            }
        }

        public async Task<User> GetUserAsync(string userId)
        {
            try
            {
                Console.WriteLine($"Fetching user: {userId}");
                var user = await _authRepository.GetUserAsync(userId);
                Console.WriteLine($"User fetched: {userId}");
                return user;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching user {userId}: Message={ex.Message}, Inner={ex.InnerException?.Message}");
                throw new Exception("user-not-found", ex);
            }
        }

        private Exception MapFirebaseAuthException(FirebaseAuthException ex)
        {
            Console.WriteLine($"Mapping Firebase error: {ex.ErrorCode}");
            switch (ex.ErrorCode.ToString())
            {
                case "INVALID_EMAIL":
                    return new Exception("invalid-email");
                case "USER_NOT_FOUND":
                    return new Exception("wrongCredentials");
                case "EMAIL_EXISTS":
                    return new Exception("email-already-in-use");
                case "INVALID_PASSWORD":
                    return new Exception("weak-password");
                case "TOO_MANY_ATTEMPTS":
                    return new Exception("too-many-requests");
                case "INVALID_ID_TOKEN":
                    return new Exception("invalid-google-token");
                case "InvalidArgument":
                    return new Exception("invalid-audience: Ensure the ID token is from the correct Firebase project.");
                default:
                    return new Exception("auth-error");
            }
        }
    }
}