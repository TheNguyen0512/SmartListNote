using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartList.API.Application.Interface;
using System;
using System.Security.Claims;
using System.Threading.Tasks;

namespace SmartList.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class AnalyticsController : ControllerBase
    {
        private readonly IAnalyticsService _analyticsService;

        public AnalyticsController(IAnalyticsService analyticsService)
        {
            _analyticsService = analyticsService ?? throw new ArgumentNullException(nameof(analyticsService));
        }

        [HttpGet("month/{year}/{month}")]
        public async Task<IActionResult> GetAnalyticsForMonth(int year, int month)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { error = "User not authenticated", details = "No user ID found in token" });
                }

                if (year < 1900 || year > 9999 || month < 1 || month > 12)
                {
                    return BadRequest(new { error = "Invalid request", details = "Invalid year or month" });
                }

                Console.WriteLine($"Fetching analytics for userId: {userId}, year: {year}, month: {month}");
                var monthDate = new DateTime(year, month, 1);
                var analytics = await _analyticsService.GetAnalyticsForMonthAsync(userId, monthDate);
                Console.WriteLine($"Retrieved analytics for userId: {userId}, {analytics.Tasks.Count} tasks");
                return Ok(analytics);
            }
            catch (ArgumentException ex)
            {
                Console.WriteLine($"Error fetching analytics: {ex.Message}");
                return BadRequest(new { error = "Invalid request", details = ex.Message });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching analytics: {ex.Message}");
                return StatusCode(500, new { error = "Failed to load analytics", details = ex.Message });
            }
        }

        [HttpGet("date/{year}/{month}/{day}")]
        public async Task<IActionResult> GetTasksForDate(int year, int month, int day)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { error = "User not authenticated", details = "No user ID found in token" });
                }

                if (year < 1900 || year > 9999 || month < 1 || month > 12 || day < 1 || day > 31)
                {
                    return BadRequest(new { error = "Invalid request", details = "Invalid date" });
                }

                try
                {
                    var date = new DateTime(year, month, day);
                    Console.WriteLine($"Fetching tasks for userId: {userId}, date: {date}");
                    var tasks = await _analyticsService.GetTasksForDateAsync(userId, date);
                    Console.WriteLine($"Retrieved {tasks.Count} tasks for userId: {userId}");
                    return Ok(tasks);
                }
                catch (ArgumentOutOfRangeException)
                {
                    return BadRequest(new { error = "Invalid request", details = "Invalid date" });
                }
            }
            catch (ArgumentException ex)
            {
                Console.WriteLine($"Error fetching tasks: {ex.Message}");
                return BadRequest(new { error = "Invalid request", details = ex.Message });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching tasks: {ex.Message}");
                return StatusCode(500, new { error = "Failed to load tasks", details = ex.Message });
            }
        }
    }
}