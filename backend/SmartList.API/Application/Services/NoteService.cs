using SmartList.API.Application.Interface;
using SmartList.API.Domain.Entities;
using SmartList.API.Infrastructure.Interface;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SmartList.API.Application.Services
{
    public class NoteService : INoteService
    {
        private readonly INoteRepository _noteRepository;

        public NoteService(INoteRepository noteRepository)
        {
            _noteRepository = noteRepository;
        }

        public async Task<List<Note>> GetNotesAsync(string userId)
        {
            return await _noteRepository.GetNotesAsync(userId);
        }

        public async Task<Note> AddNoteAsync(string userId, Note note)
        {
            return await _noteRepository.AddNoteAsync(userId, note);
        }

        public async Task UpdateNoteAsync(string userId, Note note)
        {
            await _noteRepository.UpdateNoteAsync(userId, note);
        }

        public async Task<Note> ToggleNoteStatusAsync(string userId, string noteId)
        {
            return await _noteRepository.ToggleNoteStatusAsync(userId, noteId);
        }

        public async Task DeleteNoteAsync(string userId, string noteId)
        {
            await _noteRepository.DeleteNoteAsync(userId, noteId);
        }
    }
}