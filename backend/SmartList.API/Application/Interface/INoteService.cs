using SmartList.API.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SmartList.API.Application.Interface
{
    public interface INoteService
    {
        Task<List<Note>> GetNotesAsync(string userId);
        Task<Note> AddNoteAsync(string userId, Note note);
        Task UpdateNoteAsync(string userId, Note note);
        Task<Note> ToggleNoteStatusAsync(string userId, string noteId);
        Task DeleteNoteAsync(string userId, string noteId);
    }
}