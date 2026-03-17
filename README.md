# Django + Flutter Learning App

This workspace contains:

- `learning_app_backend` - Django REST API with JWT auth and task CRUD.
- `learning_app_frontend` - Flutter app source for login and task management.

## Backend

Run from `learning_app_backend`:

```bash
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

API routes:

- `POST /api/auth/register/`
- `POST /api/auth/login/`
- `GET /api/tasks/`
- `POST /api/tasks/`
- `GET /api/tasks/<id>/`
- `PATCH /api/tasks/<id>/`
- `DELETE /api/tasks/<id>/`

All responses are JSON and request/response details are logged in the console.

## Frontend

Flutter is not installed in this environment, so the source files were created manually.

To finish local Flutter setup from `learning_app_frontend` on a machine with Flutter installed:

```bash
flutter create .
flutter pub get
flutter run
```

The app uses `http://10.0.2.2:8000/api` by default for Android emulators. Update `learning_app_frontend/lib/services/api_service.dart` if you run against a different host.
