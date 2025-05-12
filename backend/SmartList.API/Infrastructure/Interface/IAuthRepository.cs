using SmartList.API.Domain.Entities;
using System.Threading.Tasks;

namespace SmartList.API.Infrastructure.Interface
{
    public interface IAuthRepository
    {
        Task<User> GetUserAsync(string userId);
        Task SaveUserAsync(User user);
        Task UpdateUserMetadataAsync(string userId, UserMetadata metadata);
    }

    public class UserMetadata
    {
        public DateTime UpdatedAt { get; set; }
        public DateTime? LastPasswordChange { get; set; }
    }
}