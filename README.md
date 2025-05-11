✅ SmartList - Todo List App
SmartList là một ứng dụng quản lý công việc đa nền tảng tích hợp các tính năng hiện đại như xác thực bằng Firebase, phân tích hiệu suất, cộng tác nhóm, và nhập liệu bằng giọng nói.

📁 Cấu trúc dự án
bash
Sao chép
Chỉnh sửa
todo_list_app/
├── frontend/     # Flutter app: giao diện người dùng
├── backend/      # ASP.NET Core API: xử lý và proxy Firebase
└── README.md     # Tài liệu tổng
📱 Frontend (Flutter)
Đường dẫn: todo_list_app/frontend/

🔧 Công nghệ sử dụng:
Flutter 3.x

Provider – State management

Firebase Auth & Firestore – Đăng nhập, lưu trữ dữ liệu

Localization – Đa ngôn ngữ

Voice Input – Nhập liệu bằng giọng nói

Custom Routing System – Định tuyến có quản lý

🧩 Tính năng chính:
Đăng nhập / Đăng ký (Email & Google)

Thêm, chỉnh sửa, xóa công việc

Phân loại công việc theo độ ưu tiên

Biểu đồ hiệu suất công việc

Giao việc theo nhóm (collaboration)

Giao diện đẹp, dễ sử dụng, hỗ trợ đa ngôn ngữ

▶️ Khởi chạy Flutter app:
bash
Sao chép
Chỉnh sửa
cd frontend
flutter pub get
flutter run
⚠️ Đảm bảo đã cấu hình Firebase (google-services.json / GoogleService-Info.plist)

🔙 Backend (ASP.NET Core)
Đường dẫn: todo_list_app/backend/

🔧 Công nghệ sử dụng:
.NET 8 (ASP.NET Core Web API)

Firebase Admin SDK – Xác thực và tương tác với Firestore

JWT Validation – Bảo mật token từ client

Service & Repository Pattern – Cấu trúc dễ mở rộng

XUnit – Unit test

🧩 Tính năng chính:
Xác thực người dùng (qua Firebase)

API quản lý công việc (CRUD)

API thống kê công việc (analytics)

API cho cộng tác nhóm

API hỗ trợ nhập liệu bằng giọng nói

▶️ Khởi chạy API backend:
bash
Sao chép
Chỉnh sửa
cd backend/SmartList.API
dotnet restore
dotnet run
⚠️ Bạn cần cấu hình file appsettings.json với Firebase Credentials.

🔗 Kết nối frontend ↔ backend
Flutter sử dụng http để gọi API từ ASP.NET Core

Token đăng nhập từ Firebase sẽ được gửi kèm Authorization: Bearer <token>

Backend sẽ xác thực token và ủy quyền thao tác tương ứng với người dùng

🧪 Testing
✅ Frontend:
bash
Sao chép
Chỉnh sửa
flutter test
✅ Backend:
bash
Sao chép
Chỉnh sửa
cd backend/tests
dotnet test
🚀 Triển khai
Frontend: có thể build cho Android, iOS, Web

Backend: triển khai dễ dàng lên bất kỳ dịch vụ hỗ trợ .NET (Azure, Render, Heroku, v.v.)

📌 Mục tiêu dự án
Trải nghiệm học tập xây dựng hệ thống full-stack hiện đại

Thực hành kiến trúc rõ ràng: Clean Architecture, Tiers

Triển khai các tính năng phổ biến trong ứng dụng thực tế
