using Google.Cloud.Firestore;
using SmartList.API.Domain.Entities;
using SmartList.API.Infrastructure.Interface;
using System;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace SmartList.API.Infrastructure.Firebase
{
    public class FirebaseAuthRepository : IAuthRepository
    {
        private readonly FirestoreDb _firestoreDb;

        public FirebaseAuthRepository(FirestoreDb firestoreDb)
        {
            _firestoreDb = firestoreDb ?? throw new ArgumentNullException(nameof(firestoreDb));
        }

        public async Task<User> GetUserAsync(string userId)
        {
            if (string.IsNullOrEmpty(userId))
            {
                throw new ArgumentException("User ID cannot be null or empty", nameof(userId));
            }

            var docRef = _firestoreDb.Collection("users").Document(userId);
            var snapshot = await docRef.GetSnapshotAsync();
            if (!snapshot.Exists)
            {
                throw new Exception($"User not found for ID: {userId}");
            }

            var data = snapshot.ToDictionary();
            return new User
            {
                Id = snapshot.Id,
                Email = (string)data.GetValueOrDefault("email", ""),
                CreatedAt = DateTime.Parse((string)data.GetValueOrDefault("createdAt", DateTime.UtcNow.ToString("o"))),
                UpdatedAt = DateTime.Parse((string)data.GetValueOrDefault("updatedAt", DateTime.UtcNow.ToString("o"))),
                DisplayName = data.GetValueOrDefault("displayName", null) as string,
                PhotoUrl = data.GetValueOrDefault("photoUrl", null) as string
            };
        }

        public async Task SaveUserAsync(User user)
        {
            if (user == null || string.IsNullOrEmpty(user.Id))
            {
                throw new ArgumentException("User or User ID cannot be null or empty", nameof(user));
            }

            var docRef = _firestoreDb.Collection("users").Document(user.Id);
            var data = new
            {
                email = user.Email,
                createdAt = user.CreatedAt.ToString("o"),
                updatedAt = DateTime.UtcNow.ToString("o"), // Always update the timestamp
                displayName = user.DisplayName,
                photoUrl = user.PhotoUrl
            };
            await docRef.SetAsync(data, SetOptions.MergeAll);
        }

        public async Task UpdateUserMetadataAsync(string userId, UserMetadata metadata)
        {
            if (string.IsNullOrEmpty(userId))
            {
                throw new ArgumentException("User ID cannot be null or empty", nameof(userId));
            }

            if (metadata == null)
            {
                throw new ArgumentNullException(nameof(metadata));
            }

            var docRef = _firestoreDb.Collection("users").Document(userId);
            var snapshot = await docRef.GetSnapshotAsync();
            if (!snapshot.Exists)
            {
                throw new Exception($"User not found for ID: {userId}");
            }

            // Convert the metadata to a Dictionary<string, object>
            var data = new Dictionary<string, object>
            {
                ["updatedAt"] = metadata.UpdatedAt.ToString("o"),
                ["lastPasswordChange"] = metadata.LastPasswordChange?.ToString("o") ?? FieldValue.Delete // Handle null case
            };
            await docRef.UpdateAsync(data);
        }
    }
}