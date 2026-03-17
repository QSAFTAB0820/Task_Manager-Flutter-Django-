# Task Manager (Flutter + Django)

This workspace contains a full-stack Task Management application built with **Flutter** (Frontend) and **Django REST Framework** (Backend).

## Project Structure

```text
Task-Manager(Flutter-Django)APP/
├── learning_app_backend/      # Django REST API Backend
│   ├── learning_app_backend/  # Core Django project settings & config
│   ├── tasks/                 # Tasks app (models, views, serializers, urls)
│   ├── manage.py              # Django CLI utility
│   ├── requirements.txt       # Python dependencies
│   └── db.sqlite3             # SQLite Database
│
├── learning_app_frontend/     # Flutter Mobile/Web/Desktop Frontend
│   ├── lib/                   # Main Dart source code
│   │   ├── models/            # Data models (task_item.dart)
│   │   ├── screens/           # UI Screens (login_screen.dart, tasks_screen.dart)
│   │   ├── services/          # API & Storage services (api_service.dart, auth_storage.dart)
│   │   └── main.dart          # Flutter app entry point
│   ├── pubspec.yaml           # Flutter dependencies
│   └── android/, ios/, web/   # Platform-specific native directories
│
└── README.md                  # Project documentation (this file)
```

## Backend Setup (Django)

The backend is a Django REST API featuring JWT authentication and CRUD operations for tasks.

1. Navigate to the backend directory:
   ```bash
   cd learning_app_backend
   ```
2. Create and activate a virtual environment (optional but recommended):
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Run database migrations:
   ```bash
   python manage.py migrate
   ```
5. Start the development server:
   ```bash
   python manage.py runserver
   ```

### API Endpoints
- `POST /api/auth/register/` - Register a new user
- `POST /api/auth/login/` - Login and get JWT token (Access/Refresh)
- `GET /api/tasks/` - Retrieve all tasks for the logged-in user
- `POST /api/tasks/` - Create a new task
- `GET /api/tasks/<id>/` - Retrieve a specific task by ID
- `PATCH /api/tasks/<id>/` - Update a task status or details
- `DELETE /api/tasks/<id>/` - Delete a task

All responses are JSON, and request/response details are logged in the console.

## Frontend Setup (Flutter)

The frontend is a Flutter application that provides a user interface for login and task management capabilities.

1. Navigate to the frontend directory:
   ```bash
   cd learning_app_frontend
   ```
2. *(If needed)* Ensure the Flutter project structure is fully initialized:
   ```bash
   flutter create .
   ```
3. Fetch Flutter dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

### Configuration Note
The app currently uses `http://10.0.2.2:8000/api` by default, which maps to localhost for Android emulators. 
If you are running the app on a physical device, iOS simulator, or a web browser, please ensure you update the API base URL in `learning_app_frontend/lib/services/api_service.dart` to match your backend's host IP/URL.
