public class NoteRequest
{
    public required string Title { get; set; }
    public required string Description { get; set; }
    public bool IsCompleted { get; set; }
    public DateTime? DueDate { get; set; }
    public required string Priority { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string? audioUrl { get; set; }

    public void NormalizeDates()
    {
        DueDate = DueDate?.ToUniversalTime();
        CreatedAt = CreatedAt.ToUniversalTime();
        UpdatedAt = UpdatedAt.ToUniversalTime();
    }
}