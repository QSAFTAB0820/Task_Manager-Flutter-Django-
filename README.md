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
4. Create a repository-root `.env` based on [`.env.example`](.env.example) and replace every placeholder. The root `.env` is ignored by Git; never commit it. Production should use a separately created `.env` on EC2.
5. Run database migrations:
   ```bash
   python manage.py migrate
   ```
6. Start the development server:
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

All responses are JSON. Debug builds log request paths and response status codes; credentials and response bodies are not logged.

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
The app defaults to `http://127.0.0.1:8000/api` for local development. For production, build the Flutter app with `--dart-define=API_BASE_URL=https://YOUR_API_HOST/api`, replacing the placeholder with the real HTTPS API URL. Configure that same API host in Django's `ALLOWED_HOSTS`, and configure the frontend's origin in `CORS_ALLOWED_ORIGINS` when the frontend and API use different origins. Do not put a real deployment host in tracked source code.

## AWS EC2 production configuration

Create `.env` at the repository root on the EC2 instance, alongside `.gitignore`. Do not copy a real secret into the repository or commit `.env`. Use these variable names and set values for the actual deployment:

```dotenv
SECRET_KEY=replace-with-a-unique-long-random-secret
DEBUG=False
ALLOWED_HOSTS=YOUR_EC2_DNS_NAME,YOUR_API_DOMAIN
CORS_ALLOWED_ORIGINS=https://YOUR_FRONTEND_DOMAIN
SECURE_SSL_REDIRECT=True
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
SECURE_HSTS_SECONDS=0
```

`ALLOWED_HOSTS` and `CORS_ALLOWED_ORIGINS` accept comma-separated values. Use host names without schemes for `ALLOWED_HOSTS`; use full origins including `https://` for CORS. Keep the existing SQLite database file backed up and persistent on the instance. The backend WSGI application for Gunicorn is `learning_app_backend.wsgi:application` when run from `learning_app_backend/`; bind Gunicorn to localhost and configure Nginx to proxy to it. Nginx must pass `X-Forwarded-Proto $scheme` so Django can recognize HTTPS. Leave `SECURE_HSTS_SECONDS=0` until HTTPS has been tested on the final domain; then set a positive value (commonly one year) and verify the domain and all subdomains are HTTPS-ready before enabling HSTS. Nginx should also serve the built Flutter web files. For the frontend build, run from `learning_app_frontend/`:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://YOUR_API_HOST/api
```

Replace each placeholder with the deployment's actual host before deployment. Enable HTTPS at Nginx before publishing the frontend or API.
