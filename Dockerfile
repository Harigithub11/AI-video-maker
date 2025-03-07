FROM python:3.9-slim

# Install system dependencies
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

# Copy requirements first to leverage Docker cache
COPY ./backend/requirements.txt /app/requirements.txt

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY ./backend ./backend

# Download models
RUN mkdir -p /data/models && \
    pip install gdown && \
    gdown "17XArguEHT4BD84VQt_S-W5KdE_CyzIiP" -O /data/models/tacotron2-DDC.pth && \
    gdown "14EzYU1_scEItpxO4_IAk6g1_IMSO7t6-" -O /data/models/vits_model.pth && \
    gdown "1R_FCiBo_E1N1xvrqf15wyBcWGFOtiRou" -O /data/models/hifigan_v2.pth

# Runtime config
EXPOSE 8000
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]