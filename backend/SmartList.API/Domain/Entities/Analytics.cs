using System;
using System.Collections.Generic;

namespace SmartList.API.Domain.Entities
{
    public class Analytics
    {
        public string? Id { get; set; }
        public string UserId { get; set; } = string.Empty;
        public DateTime Date { get; set; }
        public int HighPriorityCount { get; set; }
        public int MediumPriorityCount { get; set; }
        public int LowPriorityCount { get; set; }
        public List<Note> Tasks { get; set; } = new List<Note>();
    }
}