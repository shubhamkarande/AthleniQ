"""
AI Coach Router - Workout summaries and recommendations
"""

from fastapi import APIRouter, HTTPException
from app.models.schemas import (
    WorkoutSummaryRequest, WorkoutSummaryResponse,
    NextWorkoutRequest, NextWorkoutResponse
)
from app.services.ai_service import AICoachService

router = APIRouter()
ai_service = AICoachService()


@router.post("/workout-summary", response_model=WorkoutSummaryResponse)
async def get_workout_summary(request: WorkoutSummaryRequest):
    """
    Generate an AI-powered summary of a completed workout session.
    
    Analyzes performance metrics and provides:
    - Overall summary
    - Highlights of the session
    - Tips for improvement
    - Performance rating
    """
    try:
        result = await ai_service.generate_workout_summary(request)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/next-workout", response_model=NextWorkoutResponse)
async def get_next_workout(request: NextWorkoutRequest):
    """
    Generate personalized workout recommendations for the next session.
    
    Takes into account:
    - User's fitness goals
    - Recent workout history
    - Performance trends
    - Recovery needs
    """
    try:
        result = await ai_service.generate_next_workout(request)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/motivational-quote")
async def get_motivational_quote():
    """
    Get a random motivational fitness quote.
    """
    quotes = [
        "The only bad workout is the one that didn't happen.",
        "Your body can stand almost anything. It's your mind you have to convince.",
        "The pain you feel today will be the strength you feel tomorrow.",
        "Don't stop when you're tired. Stop when you're done.",
        "Fitness is not about being better than someone else. It's about being better than you used to be.",
        "The harder you work for something, the greater you'll feel when you achieve it.",
        "Success starts with self-discipline.",
        "Your health is an investment, not an expense.",
        "Sweat is just fat crying.",
        "Wake up with determination. Go to bed with satisfaction."
    ]
    import random
    return {"quote": random.choice(quotes)}


@router.post("/analyze-progress")
async def analyze_progress(user_id: str, days: int = 30):
    """
    Analyze user's workout progress over a specified period.
    """
    # This would integrate with Firestore to fetch workout history
    return {
        "user_id": user_id,
        "period_days": days,
        "analysis": {
            "total_workouts": 0,
            "average_form_score": 0.0,
            "improvement_trend": "neutral",
            "consistency_score": 0.0,
            "recommendations": []
        }
    }
