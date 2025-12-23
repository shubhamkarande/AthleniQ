# AthleniQ - AI Fitness Coach

> **Train smarter. Move better. Get coached by AI.**

AthleniQ is a cross-platform AI fitness training app that uses your phone camera to analyze body posture, detect exercise form, and generate personalized workout plans.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)

## ✨ Features

- **🎥 Live Pose Detection** - Real-time body tracking using MediaPipe
- **🧠 AI Workout Feedback** - Instant form corrections and tips
- **🔢 Rep Counting** - Automatic repetition detection
- **📊 Progress Analytics** - Track your fitness journey
- **🔥 Workout Streaks** - Stay motivated with daily goals
- **🌙 Dark Mode** - Beautiful UI in light and dark themes

## 🛠️ Tech Stack

### Mobile App

- **Flutter 3.x** with Dart
- **Material 3** design system
- **Riverpod** for state management
- **Camera API** for live streaming

### Backend

- **FastAPI** (Python 3.11+)
- **MediaPipe Pose** for pose detection
- **OpenCV** for image processing

### Infrastructure

- **Firebase Auth** - User authentication
- **Firestore** - NoSQL database
- **Docker** - Container deployment

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.7+
- Python 3.11+
- Firebase project (optional for development)

### Mobile App Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/AthleniQ.git
cd AthleniQ

# Install Flutter dependencies
flutter pub get

# Run the app
flutter run
```

### Backend Setup

```bash
# Navigate to backend
cd backend

# Create virtual environment
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # macOS/Linux

# Install dependencies
pip install -r requirements.txt

# Run the server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 📁 Project Structure

```
AthleniQ/
├── lib/                      # Flutter app
│   ├── config/               # Theme, routes, constants
│   ├── models/               # Data models
│   ├── providers/            # Riverpod state
│   ├── screens/              # UI screens
│   ├── services/             # API, camera services
│   └── widgets/              # Reusable components
├── backend/                  # FastAPI server
│   └── app/
│       ├── routers/          # API endpoints
│       ├── services/         # Business logic
│       └── models/           # Pydantic schemas
└── assets/                   # Images, fonts, icons
```

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/pose/analyze` | Analyze pose from image |
| POST | `/ai/workout-summary` | Generate workout summary |
| POST | `/ai/next-workout` | Get workout recommendations |
| GET | `/health` | Health check |

## 📄 License

This project is licensed under the MIT License.

---

Made with 💪 by AthleniQ Team
