using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Google.Cloud.Firestore;
using Google.Cloud.Firestore.V1;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.IO;

namespace SmartList.API.Infrastructure.Firebase
{
    public static class FirebaseInitializer
    {
        public static void Initialize(IServiceCollection services)
        {
            try
            {
                var serviceAccountPath = Path.Combine(AppContext.BaseDirectory, "service-account.json");
                if (!File.Exists(serviceAccountPath))
                {
                    throw new FileNotFoundException("Service account JSON file not found.", serviceAccountPath);
                }

                var credential = GoogleCredential.FromFile(serviceAccountPath);

                // Initialize FirebaseApp if not already created
                if (FirebaseApp.DefaultInstance == null)
                {
                    FirebaseApp.Create(new AppOptions
                    {
                        Credential = credential,
                        ProjectId = "smart-list-7e746"
                    });
                }

                // Create FirestoreClient and FirestoreDb
                var firestoreClient = new FirestoreClientBuilder
                {
                    Credential = credential
                }.Build();

                var firestoreDb = FirestoreDb.Create("smart-list-7e746", firestoreClient);

                // Register FirestoreDb in DI container
                services.AddSingleton(firestoreDb);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Failed to initialize Firebase/Firestore: {ex.Message}");
                if (ex.InnerException != null)
                {
                    Console.WriteLine($"🔍 Inner exception: {ex.InnerException.Message}");
                }
                throw;
            }
        }
    }
    
}