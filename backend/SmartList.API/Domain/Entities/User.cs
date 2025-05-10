namespace SmartList.API.Domain.Entities
{
    public class User
    {
        public string Id { get; set; }
        public string Email { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public string? DisplayName { get; set; }
        public string? PhotoUrl { get; set; }

        public User()
        {
            Id = string.Empty;
            Email = string.Empty;
            CreatedAt = DateTime.UtcNow;
            UpdatedAt = DateTime.UtcNow;
        }
    }
}