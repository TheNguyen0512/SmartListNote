using SmartList.API.Domain.Entities;

namespace SmartList.API.Infrastructure.Interface
{
    public interface IAuthRepository
    {
        Task<User> GetUserAsync(string userId);
        Task SaveUserAsync(User user);
    }
}