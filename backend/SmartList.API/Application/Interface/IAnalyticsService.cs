using SmartList.API.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SmartList.API.Application.Interface
{
    public interface IAnalyticsService
    {
        Task<Analytics> GetAnalyticsForMonthAsync(string userId, DateTime month);
        Task<List<Note>> GetTasksForDateAsync(string userId, DateTime date);
    }
}