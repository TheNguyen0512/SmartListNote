using Microsoft.AspNetCore.Mvc;
using SmartList.API.Application.Interface;
using SmartList.API.Domain.Entities;
using System.Threading.Tasks;

namespace SmartList.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            try
            {
                // For simplicity, assume the client sends the email and ID token
                // In a production app, verify the ID token
                var (user, token) = await _authService.LoginAsync(request.Email, request.IdToken);
                return Ok(new { user, token });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = new { message = ex.Message } });
            }
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            try
            {
                var (user, token) = await _authService.RegisterAsync(request.Email, request.Password, request.FullName);
                return StatusCode(201, new { user, token });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = new { message = ex.Message } });
            }
        }

        [HttpPost("google")]
        public async Task<IActionResult> SignInWithGoogle([FromBody] GoogleSignInRequest request)
        {
            try
            {
                var (user, token) = await _authService.SignInWithGoogleAsync(request.IdToken, request.AccessToken);
                return Ok(new { user, token });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = new { message = ex.Message } });
            }
        }

        [HttpPost("logout")]
        public async Task<IActionResult> Logout([FromBody] LogoutRequest request)
        {
            try
            {
                await _authService.LogoutAsync(request.UserId);
                return Ok();
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = new { message = ex.Message } });
            }
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUser(string userId)
        {
            try
            {
                var user = await _authService.GetUserAsync(userId);
                return Ok(user);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = new { message = ex.Message } });
            }
        }
    }

    public class LoginRequest
{
    public required string Email { get; init; }
    public required string IdToken { get; init; }
}

    public class RegisterRequest
    {
        public required string Email { get; init; }
        public required string Password { get; init; }
        public required string FullName { get; init; }
    }

    public class GoogleSignInRequest
    {
        public required string IdToken { get; init; }
        public required string AccessToken { get; init; }
    }

    public class LogoutRequest
    {
        public required string UserId { get; init; }
    }
}