import json

from django.http import JsonResponse
from django.test import RequestFactory, SimpleTestCase

from learning_app_backend.middleware import RequestResponseLogMiddleware


class RequestResponseLogMiddlewareTests(SimpleTestCase):
    def setUp(self):
        self.factory = RequestFactory()

    def test_logs_metadata_without_logging_request_or_response_bodies(self):
        secret = "sensitive-test-token-never-log"
        request = self.factory.post(
            "/api/auth/login/",
            data=json.dumps({"password": secret}),
            content_type="application/json",
        )
        response = JsonResponse({"access": secret, "success": True})
        middleware = RequestResponseLogMiddleware(lambda request: response)

        with self.assertLogs(
            "learning_app_backend.middleware", level="INFO"
        ) as captured:
            result = middleware(request)

        self.assertIs(result, response)
        logged = "\n".join(captured.output)

        self.assertIn("POST", logged)
        self.assertIn("/api/auth/login/", logged)
        self.assertIn("status=200", logged)
        self.assertNotIn(secret, logged)
        self.assertNotIn("Request Body", logged)
        self.assertNotIn("Response Body", logged)
