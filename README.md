
# ✅ SmartList - Todo List App

SmartList là một ứng dụng quản lý công việc đa nền tảng tích hợp các tính năng hiện đại như xác thực bằng Firebase, phân tích hiệu suất, cộng tác nhóm, nhập liệu bằng giọng nói, và hỗ trợ chế độ offline.

---

## 📁 Cấu trúc dự án

```
todo_list_app/
├── frontend/                  # Flutter project (UI)
│   ├── android/               # Android configuration
│   ├── lib/                   # Flutter source code
│   │   ├── core/              # Core utilities and shared resources
│   │   │   ├── constants/     # Constants (colors, sizes, strings)
│   │   │   │   ├── colors.dart
│   │   │   │   ├── sizes.dart
│   │   │   │   └── strings.dart
│   │   │   ├── themes/        # App themes
│   │   │   │   ├── app_theme.dart
│   │   │   │   └── contextual_theme.dart
│   │   │   ├── utils/         # Utility functions
│   │   │   │   ├── date_utils.dart
│   │   │   │   └── validation_utils.dart
│   │   │   └── networking/
│   │   │       └── hive/
│   │   │           ├── hive_init.dart        # Khởi tạo Hive và adapter
│   │   │           ├── hive_service.dart     # Dịch vụ Hive để quản lý cache và hàng đợi thao tác
│   │   │           └── models/
│   │   │           	└── operation.dart    # Model cho hàng đợi thao tác
│   │   ├── routing/
│   │   │   ├── app_router.dart
│   │   │   ├── route_paths.dart
│   │   │   └── navigation_observer.dart
│   │   ├── features/          # App features (UI and state management)
│   │   │   ├── auth/          # Authentication feature
│   │   │   │   ├── domain/    # State management and entities
│   │   │   │   │   ├── entities/
│   │   │   │   │   │   └── user.dart
│   │   │   │   │   └── providers/
│   │   │   │   │       └── auth_provider.dart
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   ├── login_screen.dart
│   │   │   │       │   └── register_screen.dart
│   │   │   │       └── widgets/
│   │   │   │           ├── login_form.dart
│   │   │   │           └── register_form.dart
│   │   │   ├── setting/
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   ├── help_center_screen.dart
│   │   │   │       │   ├── privacy_policy_screen.dart
│   │   │   │       │   ├── terms_of_service_screen.dart
│   │   │   │       │   └── settings_screen.dart
│   │   │   │       └── widgets/
│   │   │   │            ├── about_help_card.dart
│   │   │   │            ├── account_settings_card.dart
│   │   │   │            ├── appearance_card.dart
│   │   │   │            ├── calendar_preferences_card.dart
│   │   │   │            ├── note_management_card.dart
│   │   │   │            └── notifications_card.dart
│   │   │   ├── Notes/         # Note management feature
│   │   │   │   ├── domain/    # State management and entities
│   │   │   │   │   ├── entities/
│   │   │   │   │   │   └── note.dart
│   │   │   │   │   └── providers/
│   │   │   │   │       └── note_provider.dart
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   ├── note_list_screen.dart
│   │   │   │       │   ├── add_note_screen.dart
│   │   │   │       ├── widgets/
│   │   │   │       │   ├── note_card.dart
│   │   │   │       │   └── note_form.dart
│   │   │   │       └── components/
│   │   │   │           └── priority_dropdown.dart
│   │   │   └── analytics/     # Analytics feature
│   │   │       ├── domain/
│   │   │       │   └── analytics_provider.dart
│   │   │       └── presentation/
│   │   │           ├── screens/
│   │   │           │   └── analytics_screen.dart
│   │   │           └── widgets/
│   │   │               ├── monthly_overview.dart
│   │   │               ├── calendar_view.dart
│   │   │               └── productivity_chart.dart
│   │   ├── localization/      # Localization support
│   │   │   ├── app_localizations.dart
│   │   │   └── locale_provider.dart
│   │   ├── app.dart           # App initialization
│   │   └── main.dart          # Entry point
│   ├── test/                  # Tests
│   │   ├── unit/
│   │   │   └── Note_provider_test.dart
│   │   └── widget/
│   │       └── Note_card_test.dart
│   ├── pubspec.yaml           # Dependencies
│   └── README.md              # Frontend documentation
├── backend/                   # DotNet project (Firebase API proxy)
│   ├── SmartList.API/         # ASP.NET Core project
│   │   ├── Controllers/       # API controllers
│   │   │   ├── NoteController.cs
│   │   │   ├── AuthController.cs
│   │   │   ├── AnalyticsController.cs
│   │   ├── Domain/            # Data models
│   │   │   └── Entities/
│   │   │       ├── Note.cs
│   │   │       ├── User.cs
│   │   │       ├── Analytics.cs
│   │   ├── Application/          # Firebase integration
│   │   |	 ├── Interface/
│   │   │   │   ├── INoteService.cs
│   │   │   │   ├── IAuthService.cs
│   │   │   │   ├── IAnalyticsService.cs
│   │   │	 └── Services/
│   │   │        ├── NoteService.cs
│   │   │        ├── AuthService.cs
│   │   │        ├── AnalyticsService.cs
│   │   ├── Infrastructure/          # Firebase integration
│   │   |	 ├── Interface/
│   │   │   │   ├── INoteRepository.cs
│   │   │   │   ├── IAuthRepository.cs
│   │   │   │   ├── IAnalyticsRepository.cs
│   │   │	 └── Firebase/
│   │   │        ├── FirebaseNoteRepository.cs
│   │   │        ├── FirebaseAuthRepository.cs
│   │   │        ├── FirebaseAnalyticsRepository.cs
│   │   ├── Program.cs         # Entry point
│   │   └── SmartList.API.csproj # Project file
│   ├── tests/                 # Backend tests
│   │   ├── Controllers/
│   │   │    └── NoteControllerTests.cs
│   │   ├── Application/
│   │   │   ├── NoteServiceTests.cs
│   │   │   └── AuthServiceTests.cs
│   │   └── Infrastructure/
│   │    	 └── FirebaseNoteRepositoryTests.cs
│   └── README.md              # Backend documentation
└── README.md                  # Overall project documentation
```

---

## 📱 Frontend (Flutter)

**Đường dẫn:** `todo_list_app/frontend/`

### 🔧 Công nghệ sử dụng:
- **Flutter 3.x**
- **Provider** – State management
- **Firebase Auth & Firestore** – Đăng nhập, lưu trữ dữ liệu
- **Localization** – Đa ngôn ng
- **Custom Routing System** – Định tuyến có quản lý
- **Hive** – Lưu trữ dữ liệu offline
- **Connectivity Plus** – Theo dõi trạng thái kết nối mạng

### 🧩 Tính năng chính:
- Đăng nhập / Đăng ký (Email & Google)
- Thêm, chỉnh sửa, xóa công việc
- Phân loại công việc theo độ ưu tiên
- Biểu đồ hiệu suất công việc
- Giao diện đẹp, dễ sử dụng, hỗ trợ đa ngôn ngữ
- **💾 Chế độ offline:** công việc được lưu cục bộ (bằng Hive) khi mất kết nối
- **🔁 Đồng bộ tự động:** dữ liệu sẽ được đồng bộ với server khi thiết bị kết nối lại Internet

### ▶️ Khởi chạy Flutter app:
```bash
cd frontend
flutter pub get
flutter run
```

> ⚠️ Đảm bảo đã cấu hình Firebase (google-services.json / GoogleService-Info.plist)

---

## 🔙 Backend (ASP.NET Core)

**Đường dẫn:** `todo_list_app/backend/`

### 🔧 Công nghệ sử dụng:
- **.NET 8 (ASP.NET Core Web API)**
- **Firebase Admin SDK** – Xác thực và tương tác với Firestore
- **JWT Validation** – Bảo mật token từ client
- **Service & Repository Pattern** – Cấu trúc dễ mở rộng
- **XUnit** – Unit test

### 🧩 Tính năng chính:
- Xác thực người dùng (qua Firebase)
- API quản lý công việc (CRUD)
- API thống kê công việc (analytics)
- **📡 Xử lý đồng bộ dữ liệu:** nhận và xử lý các thay đổi từ client sau khi kết nối lại mạng

### ▶️ Khởi chạy API backend:
```bash
cd backend/SmartList.API
dotnet restore
dotnet run
```

> ⚠️ Bạn cần cấu hình file `appsettings.json` với Firebase Credentials.

---

## 🔗 Kết nối frontend ↔ backend

- Flutter sử dụng `http` để gọi API từ ASP.NET Core
- Token đăng nhập từ Firebase sẽ được gửi kèm `Authorization: Bearer <token>`
- Backend sẽ xác thực token và ủy quyền thao tác tương ứng với người dùng
- **Dữ liệu offline** sẽ được đẩy lên backend khi có lại mạng thông qua API đồng bộ

---

## 🧪 Testing

### ✅ Frontend:
```bash
flutter test
```

### ✅ Backend:
```bash
cd backend/tests
dotnet test
```

---

## 🚀 Triển khai

- **Frontend**: có thể build cho Android
- **Backend**: triển khai dễ dàng lên bất kỳ dịch vụ hỗ trợ .NET

---

## 📌 Mục tiêu dự án

- Trải nghiệm học tập xây dựng hệ thống full-stack hiện đại
- Thực hành kiến trúc rõ ràng: Clean Architecture, Tiers
- Triển khai các tính năng phổ biến trong ứng dụng thực tế
- **Phát triển ứng dụng hoạt động ổn định cả khi offline**
