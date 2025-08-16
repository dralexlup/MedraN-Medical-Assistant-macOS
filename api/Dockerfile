FROM python:3.11-slim

# system deps for PDF/image parsing and OCR model
RUN apt-get update && apt-get install -y \
    poppler-utils libgl1 libglib2.0-0 tesseract-ocr ffmpeg \
    git curl wget build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
# If torch install fails on your Mac's Docker (arm64), lower the version in requirements.txt per the note below.
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app
EXPOSE 8080
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
