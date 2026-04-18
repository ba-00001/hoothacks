#!/bin/bash
# HomePilot AI — Quick Start
# Prerequisites: Docker, Java 17+, Flutter SDK

echo "🐘 Starting PostgreSQL..."
docker compose up -d postgres
sleep 3

echo "☕ Starting Spring Boot backend..."
cd backend
./mvnw spring-boot:run &
BACKEND_PID=$!
cd ..
sleep 10

echo "🌱 Seeding database..."
curl -X POST http://localhost:8080/admin/reset-and-seed
echo ""

echo "📱 Starting Flutter (web on port 3000)..."
cd frontend
flutter pub get
flutter run -d chrome --web-port 3000 &
cd ..

echo ""
echo "✅ HomePilot AI is running!"
echo "   Backend:  http://localhost:8080"
echo "   Frontend: http://localhost:3000"
echo ""
echo "📋 Useful Postman routes:"
echo "   POST http://localhost:8080/admin/reset-and-seed  (reset & seed DB)"
echo "   POST http://localhost:8080/admin/reset           (clear all tables)"
echo "   POST http://localhost:8080/admin/seed            (seed mock data)"
echo "   POST http://localhost:8080/auth/signup           {email, password}"
echo "   POST http://localhost:8080/auth/login            {email, password}"
echo "   GET  http://localhost:8080/listings"
echo "   POST http://localhost:8080/ai/affordability?userId=1"
echo "   POST http://localhost:8080/ai/grants?userId=1"
echo "   POST http://localhost:8080/ai/recommendations?userId=1"
echo "   POST http://localhost:8080/ai/mortgage-estimate?userId=1"

wait $BACKEND_PID
