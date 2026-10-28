FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app/learning_app_backend

COPY requirements.txt /tmp/requirements.txt

RUN pip install --no-cache-dir -r /tmp/requirements.txt \
    && groupadd --gid 1000 app \
    && useradd --uid 1000 --gid app \
       --create-home --home-dir /home/app \
       --shell /usr/sbin/nologin app \
    && mkdir -p /data /app/learning_app_backend/staticfiles \
    && chown -R 1000:1000 /data /app/learning_app_backend

COPY --chown=1000:1000 . .

USER 1000:1000

EXPOSE 8000

CMD ["gunicorn", "--workers", "2", "--bind", "0.0.0.0:8000", "learning_app_backend.wsgi:application"]
