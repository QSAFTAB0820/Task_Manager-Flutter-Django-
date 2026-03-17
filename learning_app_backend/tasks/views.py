from django.contrib.auth import authenticate #used to verify user credentials during login
from rest_framework import status #contains HTTP status codes for API responses
from rest_framework.permissions import AllowAny, IsAuthenticated #These control who can access an API
from rest_framework.response import Response #used to create HTTP responses in API views
from rest_framework.views import APIView #APIView is the base class for building API endpoints in Django REST Framework.
from rest_framework_simplejwt.tokens import RefreshToken #used to generate JWT tokens for authenticated users

from .models import Task #importing the Task model to interact with task data in the database
from .serializers import LoginSerializer, RegisterSerializer, TaskSerializer
# These serializers are used to convert complex data types (like Django models) into JSON format and vice versa, making it easier to handle API requests and responses.

def api_response(success, message, data=None, errors=None, status_code=status.HTTP_200_OK):
    return Response(
        {
            'success': success,
            'message': message,
            'data': data,
            'errors': errors,
        },
        status=status_code,
    )


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if not serializer.is_valid():
            return api_response(
                False,
                'Registration failed.',
                errors=serializer.errors,
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        user = serializer.save()
        return api_response(
            True,
            'User registered successfully.',
            data={
                'user': {
                    'id': user.id,
                    'username': user.username,
                    'email': user.email,
                }
            },
            status_code=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if not serializer.is_valid():
            return api_response(
                False,
                'Login failed.',
                errors=serializer.errors,
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        user = authenticate(
            username=serializer.validated_data.get('username', ''),
            password=serializer.validated_data.get('password', ''),
        )
        if user is None:
            return api_response(
                False,
                'Invalid username or password.',
                errors={'credentials': ['Invalid username or password.']},
                status_code=status.HTTP_401_UNAUTHORIZED,
            )

        refresh = RefreshToken.for_user(user)
        return api_response(
            True,
            'Login successful.',
            data={
                'access': str(refresh.access_token),
                'refresh': str(refresh),
                'user': {
                    'id': user.id,
                    'username': user.username,
                    'email': user.email,
                },
            },
        )


class TaskListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        tasks = Task.objects.filter(user=request.user).order_by('-created_at')
        serializer = TaskSerializer(tasks, many=True)
        return api_response(True, 'Tasks fetched successfully.', data={'tasks': serializer.data})

    def post(self, request):
        serializer = TaskSerializer(data=request.data)
        if not serializer.is_valid():
            return api_response(
                False,
                'Task creation failed.',
                errors=serializer.errors,
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        serializer.save(user=request.user)
        return api_response(
            True,
            'Task created successfully.',
            data={'task': serializer.data},
            status_code=status.HTTP_201_CREATED,
        )


class TaskRetrieveUpdateDestroyView(APIView):
    permission_classes = [IsAuthenticated]

    def get_task(self, request, pk):
        return Task.objects.filter(user=request.user, pk=pk).first()

    def get(self, request, pk):
        task = self.get_task(request, pk)
        if task is None:
            return api_response(False, 'Task not found.', status_code=status.HTTP_404_NOT_FOUND)

        serializer = TaskSerializer(task)
        return api_response(True, 'Task fetched successfully.', data={'task': serializer.data})

    def put(self, request, pk):
        task = self.get_task(request, pk)
        if task is None:
            return api_response(False, 'Task not found.', status_code=status.HTTP_404_NOT_FOUND)

        serializer = TaskSerializer(task, data=request.data)
        if not serializer.is_valid():
            return api_response(
                False,
                'Task update failed.',
                errors=serializer.errors,
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        serializer.save(user=request.user)
        return api_response(True, 'Task updated successfully.', data={'task': serializer.data})

    def patch(self, request, pk):
        task = self.get_task(request, pk)
        if task is None:
            return api_response(False, 'Task not found.', status_code=status.HTTP_404_NOT_FOUND)

        serializer = TaskSerializer(task, data=request.data, partial=True)
        if not serializer.is_valid():
            return api_response(
                False,
                'Task update failed.',
                errors=serializer.errors,
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        serializer.save(user=request.user)
        return api_response(True, 'Task updated successfully.', data={'task': serializer.data})

    def delete(self, request, pk):
        task = self.get_task(request, pk)
        if task is None:
            return api_response(False, 'Task not found.', status_code=status.HTTP_404_NOT_FOUND)

        task.delete()
        return api_response(True, 'Task deleted successfully.', data={'task_id': pk})
