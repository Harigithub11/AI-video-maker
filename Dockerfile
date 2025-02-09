FROM python:3.9-slim

# Install system dependencies for Coqui TTS
RUN apt-get update && apt-get install -y \
    espeak \
    libespeak1 \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m appuser && mkdir -p /data && chown appuser:appuser /data
USER appuser

# Set working directory
WORKDIR /app

# Copy only necessary files
COPY ./backend/requirements.txt .
COPY ./backend ./backend

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Create data directories
RUN mkdir -p /data/models /data/uploads /data/audio /data/videos /data/cache

# Download models during build
RUN python -c "import os, gdown; \
    os.makedirs('/data/models', exist_ok=True); \
    gdown.download('https://drive.google.com/uc?id=17XArguEHT4BD84VQt_S-W5KdE_CyzIiP', '/data/models/tacotron2-DDC.pth', quiet=False); \
    gdown.download('https://drive.google.com/uc?id=14EzYU1_scEItpxO4_IAk6g1_IMSO7t6-', '/data/models/vits_model.pth', quiet=False); \
    gdown.download('https://drive.google.com/uc?id=1R_FCiBo_E1N1xvrqf15wyBcWGFOtiRou', '/data/models/hifigan_v2.pth', quiet=False)"

# Expose FastAPI port
EXPOSE 8000

# Run FastAPI with Uvicorn
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]