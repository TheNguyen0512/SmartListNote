using Google.Cloud.Firestore;
using SmartList.API.Domain.Entities;
using SmartList.API.Infrastructure.Interface;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SmartList.API.Infrastructure.Firebase
{
    public class FirebaseNoteRepository : INoteRepository
    {
        private readonly FirestoreDb _firestoreDb;

        public FirebaseNoteRepository(FirestoreDb firestoreDb)
        {
            _firestoreDb = firestoreDb ?? throw new ArgumentNullException(nameof(firestoreDb));
        }

        public async Task<List<Note>> GetNotesAsync(string userId)
        {
            try
            {
                if (string.IsNullOrEmpty(userId))
                {
                    throw new ArgumentException("User ID cannot be null or empty", nameof(userId));
                }

                Console.WriteLine($"Querying notes for userId: {userId}");
                var collection = _firestoreDb
                    .Collection("users")
                    .Document(userId)
                    .Collection("notes");

                var snapshot = await collection.GetSnapshotAsync();

                var notes = snapshot.Documents.Select(doc => new Note
                {
                    Id = doc.Id,
                    Title = doc.GetValue<string>("title") ?? "",
                    Description = doc.GetValue<string>("description") ?? "",
                    IsCompleted = doc.GetValue<bool>("isCompleted"),
                    DueDate = doc.GetValue<DateTime?>("dueDate"),
                    Priority = doc.GetValue<string>("priority") ?? "medium",
                    CreatedAt = doc.GetValue<DateTime>("createdAt"),
                    UpdatedAt = doc.GetValue<DateTime>("updatedAt")
                }).ToList();

                Console.WriteLine($"Found {notes.Count} notes for userId: {userId}");
                return notes;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error querying notes for userId: {userId}, Message: {ex.Message}");
                throw new Exception($"Failed to load notes for user {userId}", ex);
            }
        }

        public async Task<Note> AddNoteAsync(string userId, Note note)
        {
            try
            {
                if (string.IsNullOrEmpty(userId))
                {
                    throw new ArgumentException("User ID cannot be null or empty", nameof(userId));
                }
                if (string.IsNullOrEmpty(note.Title))
                {
                    throw new ArgumentException("Note title cannot be null or empty", nameof(note.Title));
                }

                Console.WriteLine($"Adding note for userId: {userId}, title: {note.Title}");
                var collection = _firestoreDb
                    .Collection("users")
                    .Document(userId)
                    .Collection("notes");

                var noteData = new
                {
                    title = note.Title,
                    description = note.Description ?? "",
                    isCompleted = note.IsCompleted,
                    dueDate = note.DueDate?.ToUniversalTime(), // Ensure UTC
                    priority = note.Priority,
                    createdAt = note.CreatedAt.ToUniversalTime(), // Ensure UTC
                    updatedAt = note.UpdatedAt.ToUniversalTime() // Ensure UTC
                };

                Console.WriteLine($"Note data to be written: {System.Text.Json.JsonSerializer.Serialize(noteData)}");

                var docRef = await collection.AddAsync(noteData);

                var snapshot = await docRef.GetSnapshotAsync();
                if (!snapshot.Exists)
                {
                    throw new Exception($"Failed to add note to Firestore: Document {docRef.Id} does not exist after creation.");
                }

                var addedNote = new Note
                {
                    Id = docRef.Id,
                    Title = snapshot.GetValue<string>("title") ?? "",
                    Description = snapshot.GetValue<string>("description") ?? "",
                    IsCompleted = snapshot.GetValue<bool>("isCompleted"),
                    DueDate = snapshot.GetValue<DateTime?>("dueDate"), // Nullable, no ToLocal()
                    Priority = snapshot.GetValue<string>("priority") ?? "medium",
                    CreatedAt = snapshot.GetValue<DateTime?>("createdAt") ?? DateTime.MinValue, // Handle null with default
                    UpdatedAt = snapshot.GetValue<DateTime?>("updatedAt") ?? DateTime.MinValue // Handle null with default
                };

                Console.WriteLine($"Added note {addedNote.Id} for userId: {userId}");
                return addedNote;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error adding note for userId: {userId}, Message: {ex.Message}, StackTrace: {ex.StackTrace}");
                throw new Exception($"Failed to add note for user {userId}", ex);
            }
        }

        public async Task UpdateNoteAsync(string userId, Note note)
        {
            try
            {
                if (string.IsNullOrEmpty(userId))
                {
                    throw new ArgumentException("User ID cannot be null or empty", nameof(userId));
                }
                if (string.IsNullOrEmpty(note.Id))
                {
                    throw new ArgumentException("Note ID cannot be null or empty", nameof(note.Id));
                }
                if (string.IsNullOrEmpty(note.Title))
                {
                    throw new ArgumentException("Note title cannot be null or empty", nameof(note.Title));
                }

                Console.WriteLine($"Updating note {note.Id} for userId: {userId}");
                var docRef = _firestoreDb
                    .Collection("users")
                    .Document(userId)
                    .Collection("notes")
                    .Document(note.Id);

                await docRef.SetAsync(new
                {
                    title = note.Title,
                    description = note.Description,
                    isCompleted = note.IsCompleted,
                    dueDate = note.DueDate,
                    priority = note.Priority,
                    createdAt = note.CreatedAt,
                    updatedAt = note.UpdatedAt
                }, SetOptions.Overwrite);

                Console.WriteLine($"Updated note {note.Id} for userId: {userId}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating note {note.Id} for userId: {userId}, Message: {ex.Message}");
                throw new Exception($"Failed to update note {note.Id} for user {userId}", ex);
            }
        }

        public async Task<Note> ToggleNoteStatusAsync(string userId, string noteId)
        {
            try
            {
                if (string.IsNullOrEmpty(userId))
                {
                    throw new ArgumentException("User ID cannot be null or empty", nameof(userId));
                }
                if (string.IsNullOrEmpty(noteId))
                {
                    throw new ArgumentException("Note ID cannot be null or empty", nameof(noteId));
                }

                Console.WriteLine($"Toggling note {noteId} status for userId: {userId}");
                var docRef = _firestoreDb
                    .Collection("users")
                    .Document(userId)
                    .Collection("notes")
                    .Document(noteId);

                var snapshot = await docRef.GetSnapshotAsync();
                if (!snapshot.Exists)
                {
                    throw new ArgumentException($"Note {noteId} not found for user {userId}");
                }

                var currentStatus = snapshot.GetValue<bool>("isCompleted");
                var updates = new Dictionary<string, object>
                {
                    { "isCompleted", !currentStatus },
                    { "updatedAt", DateTime.UtcNow }
                };

                await docRef.UpdateAsync(updates);

                // Retrieve the updated document
                snapshot = await docRef.GetSnapshotAsync();
                var updatedNote = new Note
                {
                    Id = snapshot.Id,
                    Title = snapshot.GetValue<string>("title") ?? "",
                    Description = snapshot.GetValue<string>("description") ?? "",
                    IsCompleted = snapshot.GetValue<bool>("isCompleted"),
                    DueDate = snapshot.GetValue<DateTime?>("dueDate"),
                    Priority = snapshot.GetValue<string>("priority") ?? "medium",
                    CreatedAt = snapshot.GetValue<DateTime>("createdAt"),
                    UpdatedAt = snapshot.GetValue<DateTime>("updatedAt")
                };

                Console.WriteLine($"Toggled note {noteId} status for userId: {userId} to {!currentStatus}");
                return updatedNote;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error toggling note {noteId} status for userId: {userId}, Message: {ex.Message}");
                throw new Exception($"Failed to toggle note {noteId} status for user {userId}", ex);
            }
        }

        public async Task DeleteNoteAsync(string userId, string noteId)
        {
            try
            {
                if (string.IsNullOrEmpty(userId))
                {
                    throw new ArgumentException("User ID cannot be null or empty", nameof(userId));
                }
                if (string.IsNullOrEmpty(noteId))
                {
                    throw new ArgumentException("Note ID cannot be null or empty", nameof(noteId));
                }

                Console.WriteLine($"Deleting note {noteId} for userId: {userId}");
                var docRef = _firestoreDb
                    .Collection("users")
                    .Document(userId)
                    .Collection("notes")
                    .Document(noteId);

                await docRef.DeleteAsync();
                Console.WriteLine($"Deleted note {noteId} for userId: {userId}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting note {noteId} for userId: {userId}, Message: {ex.Message}");
                throw new Exception($"Failed to delete note {noteId} for user {userId}", ex);
            }
        }
    }
}