import json
import logging
import time

logger = logging.getLogger(__name__)

class RequestResponseLogMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        start_time = time.time()

        # Log request
        logger.info(f"Incoming Request: {request.method} {request.path}")
        if request.body:
            try:
                logger.info(f"Request Body: {json.loads(request.body)}")
            except json.JSONDecodeError:
                logger.info(f"Request Body: {request.body.decode('utf-8')}")

        response = self.get_response(request)

        # Log response
        process_time = time.time() - start_time
        logger.info(f"Outgoing Response: {response.status_code} {request.path} (Processed in {process_time:.2f}s)")
        content_type = response.headers.get('Content-Type', '')
        if hasattr(response, 'content') and 'application/json' in content_type:
            try:
                logger.info(f"Response Body: {json.loads(response.content)}")
            except json.JSONDecodeError:
                logger.info(f"Response Body: {response.content.decode('utf-8')}")
        
        return response
