using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Microsoft.Extensions.DependencyInjection;
using FirebaseAdmin;
using SmartList.API.Infrastructure.Firebase;
using SmartList.API.Application.Interface;
using SmartList.API.Application.Services;
using SmartList.API.Infrastructure.Interface;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Initialize Firebase and Firestore
FirebaseInitializer.Initialize(builder.Services);

// Register services and repositories
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IAuthRepository, FirebaseAuthRepository>();
builder.Services.AddScoped<INoteRepository, FirebaseNoteRepository>();
builder.Services.AddScoped<INoteService, NoteService>();
builder.Services.AddScoped<IAnalyticsService, AnalyticsService>();

// Configure JWT Authentication for Firebase
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.Authority = "https://securetoken.google.com/smart-list-7e746";
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidIssuer = "https://securetoken.google.com/smart-list-7e746",
        ValidateAudience = true,
        ValidAudience = "smart-list-7e746",
        ValidateLifetime = true,
        ValidateIssuerSigningKey = false, // Let Firebase Admin SDK handle signature validation
    };
    options.Events = new JwtBearerEvents
    {
        OnAuthenticationFailed = context =>
        {
            Console.WriteLine($"JWT validation failed: {context.Exception.Message}");
            return Task.CompletedTask;
        },
        // Remove OnTokenValidated since we're relying on Firebase Admin SDK
    };
});

builder.Services.AddAuthorization();



var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
else
{
    app.UseHttpsRedirection();
}

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();