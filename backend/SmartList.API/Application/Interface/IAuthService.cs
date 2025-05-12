using SmartList.API.Domain.Entities;
using System.Threading.Tasks;

namespace SmartList.API.Application.Interface
{
    public interface IAuthService
    {
        Task<(User, string)> LoginAsync(string email, string idToken);
        Task<(User, string)> RegisterAsync(string email, string password, string fullName);
        Task<(User, string)> SignInWithGoogleAsync(string idToken, string accessToken);
        Task LogoutAsync(string userId);
        Task<User> GetUserAsync(string userId);
        Task ChangePasswordAsync(string userId, string currentPassword, string newPassword);
        Task SendPasswordResetEmailAsync(string email);
    }
}