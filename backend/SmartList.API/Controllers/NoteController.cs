using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartList.API.Application.Interface;
using SmartList.API.Domain.Entities;
using System;
using System.Security.Claims;
using System.Threading.Tasks;

namespace SmartList.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class NoteController : ControllerBase
    {
        private readonly INoteService _noteService;

        public NoteController(INoteService noteService)
        {
            _noteService = noteService;
        }

        [HttpGet]
        public async Task<IActionResult> GetNotes()
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { error = "User not authenticated", details = "No user ID found in token" });
                }

                Console.WriteLine($"Fetching notes for userId: {userId}");
                var notes = await _noteService.GetNotesAsync(userId);
                Console.WriteLine($"Retrieved {notes.Count} notes for userId: {userId}");
                return Ok(notes);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = "Invalid request", details = ex.Message });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching notes: {ex.Message}");
                return StatusCode(500, new { error = "Failed to load notes", details = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> AddNote([FromBody] NoteRequest request)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { error = "User not authenticated", details = "No user ID found in token" });
                }

                if (string.IsNullOrEmpty(request.Title))
                {
                    return BadRequest(new { error = "Invalid request", details = "Title is required" });
                }

                var note = new Note
                {
                    Title = request.Title,
                    Description = request.Description,
                    IsCompleted = request.IsCompleted,
                    DueDate = request.DueDate?.ToUniversalTime(), // Safe for nullable
                    Priority = request.Priority,
                    CreatedAt = request.CreatedAt.ToUniversalTime(), // Safe for nullable
                    UpdatedAt = request.UpdatedAt.ToUniversalTime() // Safe for nullable
                };

                Console.WriteLine($"Adding note for userId: {userId}, title: {note.Title}");
                var addedNote = await _noteService.AddNoteAsync(userId, note);
                if (addedNote == null || string.IsNullOrEmpty(addedNote.Id))
                {
                    throw new Exception("Failed to add note: Returned note is invalid.");
                }

                return StatusCode(201, addedNote);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = "Invalid request", details = ex.Message });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error adding note: {ex.Message}, StackTrace: {ex.StackTrace}");
                return StatusCode(500, new { error = "Failed to add note", details = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateNote(string id, [FromBody] NoteRequest request)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { error = "User not authenticated", details = "No user ID found in token" });
                }

                if (string.IsNullOrEmpty(id) || string.IsNullOrEmpty(request.Title))
                {
                    return BadRequest(new { error = "Invalid request", details = "ID and title are required" });
                }

                var note = new Note
                {
                    Id = id,
                    Title = request.Title,
                    Description = request.Description,
                    IsCompleted = request.IsCompleted,
                    DueDate = request.DueDate?.ToUniversalTime(), // Safe for nullable
                    Priority = request.Priority,
                    CreatedAt = request.CreatedAt.ToUniversalTime(),
                    UpdatedAt = request.UpdatedAt.ToUniversalTime() 
                };

                Console.WriteLine($"Updating note {id} for userId: {userId}");
                await _noteService.UpdateNoteAsync(userId, note);
                return Ok(note);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = "Invalid request", details = ex.Message });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating note: {ex.Message}");
                return StatusCode(500, new { error = "Failed to update note", details = ex.Message });
            }
        }

        [HttpPatch("{id}/toggle")]
        public async Task<IActionResult> ToggleNoteStatus(string id)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { error = "User not authenticated", details = "No user ID found in token" });
                }

                if (string.IsNullOrEmpty(id))
                {
                    return BadRequest(new { error = "Invalid request", details = "ID is required" });
                }

                Console.WriteLine($"Toggling note {id} status for userId: {userId}");
                var updatedNote = await _noteService.ToggleNoteStatusAsync(userId, id);
                return Ok(updatedNote);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = "Invalid request", details = ex.Message });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error toggling note status: {ex.Message}");
                return StatusCode(500, new { error = "Failed to toggle note status", details = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteNote(string id)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { error = "User not authenticated", details = "No user ID found in token" });
                }

                if (string.IsNullOrEmpty(id))
                {
                    return BadRequest(new { error = "Invalid request", details = "ID is required" });
                }

                Console.WriteLine($"Deleting note {id} for userId: {userId}");
                await _noteService.DeleteNoteAsync(userId, id);
                return NoContent();
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = "Invalid request", details = ex.Message });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting note: {ex.Message}");
                return StatusCode(500, new { error = "Failed to delete note", details = ex.Message });
            }
        }
    }
}