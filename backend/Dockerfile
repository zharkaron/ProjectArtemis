# Use official Python image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app code
COPY . .

# Expose the internal Flask port
EXPOSE 5000

# Run Flask in production mode (use gunicorn for stability)
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:create_app()"]
