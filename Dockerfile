#FROM python:3.9-slim
FROM python:alpine

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY webhook-validate-registries.py .

CMD ["python", "webhook-validate-registries.py"]
