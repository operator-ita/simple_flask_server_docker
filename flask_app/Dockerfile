FROM python:3.8-alpine

WORKDIR /usr/src/app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# Use the line bellow just on production, in dev use bind mount in docker-compose.yml instead
# COPY . .