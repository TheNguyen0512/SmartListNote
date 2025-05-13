using SmartList.API.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SmartList.API.Infrastructure.Interface
{
    public interface INoteRepository
    {
        Task<List<Note>> GetNotesAsync(string userId);
        Task<Note> AddNoteAsync(string userId, Note note);
        Task UpdateNoteAsync(string userId, Note note);
        Task<Note> ToggleNoteStatusAsync(string userId, string noteId);
        Task DeleteNoteAsync(string userId, string noteId);
        Task<List<Note>> GetNotesByDateRangeAsync(string userId, DateTime startDate, DateTime endDate);
    }
}