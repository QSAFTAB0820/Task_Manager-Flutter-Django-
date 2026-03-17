from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Task

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)#write_only=True means the password will not be included in the serialized output, and min_length=6 ensures that the password must be at least 6 characters long.

    class Meta: #Meta class is used to specify metadata for the serializer, such as which model it is based on and which fields to include.
        model = User
        fields = ('id', 'username', 'email', 'password')
        extra_kwargs = {'email': {'required': False, 'allow_blank': True}}

    def create(self, validated_data): #self represents the current serializer object
        return User.objects.create_user(**validated_data)#** operator unpacks the dictionary into keyword arguments


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)


class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ('id', 'user', 'title', 'description', 'completed', 'created_at', 'updated_at')
        read_only_fields = ('user', 'created_at', 'updated_at')
