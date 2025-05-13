
# ✅ SmartList - Todo List App

SmartList là một ứng dụng quản lý công việc đa nền tảng tích hợp các tính năng hiện đại như xác thực bằng Firebase, phân tích hiệu suất, cộng tác nhóm, nhập liệu bằng giọng nói, và hỗ trợ chế độ offline.

---

## 📁 Cấu trúc dự án

```
todo_list_app/
├── frontend/     # Flutter app: giao diện người dùng
├── backend/      # ASP.NET Core API: xử lý và proxy Firebase
└── README.md     # Tài liệu tổng
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
