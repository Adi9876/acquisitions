#!/bin/bash

# Development startup script for Acquisition App with Neon Local
# This script starts the application in development mode with Neon Local

echo "🚀 Starting Acquisition App in Development Mode"
echo "================================================"

# Check if .env.development exists
if [ ! -f .env.development ]; then
    echo "❌ Error: .env.development file not found!"
    echo "   Please copy .env.development from the template and update with your Neon credentials."
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running!"
    echo "   Please start Docker Desktop and try again."
    exit 1
fi

# Create .neon_local directory if it doesn't exist
mkdir -p .neon_local

# Add .neon_local to .gitignore if not already present
if ! grep -q ".neon_local/" .gitignore 2>/dev/null; then
    echo ".neon_local/" >> .gitignore
    echo "✅ Added .neon_local/ to .gitignore"
fi

echo "📦 Building and starting development containers..."
echo "   - Neon Local proxy will create an ephemeral database branch"
echo "   - Application will run with hot reload enabled"
echo ""

# Compose file name
COMPOSE_FILE=docker-compose.dev.yaml

# Start Neon Local first (detached)
echo "🧰 Starting Neon Local (Postgres proxy) ..."
docker compose -f "$COMPOSE_FILE" up -d neon-local

# Wait for Neon Local to become healthy
echo "⏳ Waiting for the database to be ready..."
for i in {1..30}; do
    if docker compose -f "$COMPOSE_FILE" exec -T neon-local pg_isready -h localhost -p 5432 -U neon >/dev/null 2>&1; then
        echo "✅ Database is ready"
        break
    fi
    sleep 2
done

# Run migrations with Drizzle (from host against Neon Local)
echo "📜 Applying latest schema with Drizzle..."
npm run db:migrate

# Start the full development environment (foreground)
docker compose -f "$COMPOSE_FILE" up --build

echo ""
echo "🎉 Development environment started!"
echo "   Application: http://localhost:3000"
echo "   Database: postgres://neon:npg@localhost:5432/neondb"
echo ""
echo "To stop the environment, press Ctrl+C or run: docker compose down"