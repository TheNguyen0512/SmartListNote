using SmartList.API.Application.Interface;
using SmartList.API.Domain.Entities;
using SmartList.API.Infrastructure.Interface;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SmartList.API.Application.Services
{
    public class AnalyticsService : IAnalyticsService
    {
        private readonly INoteRepository _noteRepository;

        public AnalyticsService(INoteRepository noteRepository)
        {
            _noteRepository = noteRepository ?? throw new ArgumentNullException(nameof(noteRepository));
        }

        public async Task<Analytics> GetAnalyticsForMonthAsync(string userId, DateTime month)
        {
            if (string.IsNullOrEmpty(userId))
            {
                throw new ArgumentException("User ID cannot be null or empty", nameof(userId));
            }

            var startOfMonth = new DateTime(month.Year, month.Month, 1);
            var endOfMonth = startOfMonth.AddMonths(1).AddDays(-1);

            var notes = await _noteRepository.GetNotesByDateRangeAsync(userId, startOfMonth, endOfMonth);

            var analytics = new Analytics
            {
                UserId = userId,
                Date = startOfMonth,
                HighPriorityCount = notes.Count(n => n.Priority.ToLower() == "high"),
                MediumPriorityCount = notes.Count(n => n.Priority.ToLower() == "medium"),
                LowPriorityCount = notes.Count(n => n.Priority.ToLower() == "low"),
                Tasks = notes
            };

            return analytics;
        }

        public async Task<List<Note>> GetTasksForDateAsync(string userId, DateTime date)
        {
            if (string.IsNullOrEmpty(userId))
            {
                throw new ArgumentException("User ID cannot be null or empty", nameof(userId));
            }

            var startOfDay = date.Date;
            var endOfDay = startOfDay.AddDays(1).AddTicks(-1);

            return await _noteRepository.GetNotesByDateRangeAsync(userId, startOfDay, endOfDay);
        }
    }
}