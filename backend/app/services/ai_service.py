"""
AI Coach Service - Workout summaries and recommendations
"""

from typing import List
from app.models.schemas import (
    WorkoutSummaryRequest, WorkoutSummaryResponse,
    NextWorkoutRequest, NextWorkoutResponse,
    WorkoutRecommendation, ExerciseType, FitnessGoal
)
from app.config import settings


class AICoachService:
    """
    Service for generating AI-powered workout feedback and recommendations.
    Uses OpenAI API when available, falls back to template-based generation.
    """
    
    def __init__(self):
        self.openai_available = bool(settings.openai_api_key)
        
        # Template-based feedback for each exercise
        self.EXERCISE_TIPS = {
            ExerciseType.SQUAT: [
                "Focus on keeping your knees tracking over your toes",
                "Engage your core throughout the movement",
                "Drive through your heels as you stand up",
                "Keep your chest up and back straight",
                "Try to reach parallel depth for full range of motion"
            ],
            ExerciseType.PUSHUP: [
                "Keep your body in a straight line from head to heels",
                "Lower your chest all the way down for full range",
                "Keep your elbows at a 45-degree angle from your body",
                "Engage your core to prevent hip sagging",
                "Exhale as you push up, inhale as you lower"
            ],
            ExerciseType.LUNGE: [
                "Keep your front knee directly above your ankle",
                "Lower your back knee towards the ground",
                "Maintain an upright torso throughout",
                "Push through your front heel to return to standing",
                "Alternate legs for balanced development"
            ],
            ExerciseType.PLANK: [
                "Keep your body in a straight line",
                "Engage your core and squeeze your glutes",
                "Don't let your hips sag or pike up",
                "Look at the floor to maintain neutral neck",
                "Breathe steadily throughout the hold"
            ],
            ExerciseType.JUMPING_JACK: [
                "Land softly on the balls of your feet",
                "Fully extend arms overhead",
                "Keep a steady rhythm",
                "Engage your core for stability",
                "Start slow and build speed gradually"
            ],
            ExerciseType.DEADLIFT: [
                "Keep the bar close to your body throughout",
                "Hinge at the hips, not the lower back",
                "Keep your back straight and core engaged",
                "Drive through your heels as you stand",
                "Squeeze glutes at the top of the movement"
            ],
            ExerciseType.BICEP_CURL: [
                "Keep your elbows pinned to your sides",
                "Control the movement both up and down",
                "Don't swing the weights - use strict form",
                "Fully extend at the bottom, fully contract at top",
                "Keep your wrists neutral throughout"
            ],
        }
        
        # Goal-based workout templates
        self.GOAL_WORKOUTS = {
            FitnessGoal.FAT_LOSS: {
                "exercises": [
                    (ExerciseType.JUMPING_JACK, 3, 30),
                    (ExerciseType.SQUAT, 3, 15),
                    (ExerciseType.PUSHUP, 3, 12),
                    (ExerciseType.LUNGE, 3, 12),
                ],
                "focus": "Cardio and Full Body",
                "rest": 30
            },
            FitnessGoal.MUSCLE: {
                "exercises": [
                    (ExerciseType.SQUAT, 4, 10),
                    (ExerciseType.PUSHUP, 4, 12),
                    (ExerciseType.DEADLIFT, 4, 8),
                    (ExerciseType.BICEP_CURL, 3, 12),
                ],
                "focus": "Strength Building",
                "rest": 60
            },
            FitnessGoal.FLEXIBILITY: {
                "exercises": [
                    (ExerciseType.LUNGE, 3, 10),
                    (ExerciseType.SQUAT, 3, 12),
                    (ExerciseType.PLANK, 3, 30),
                ],
                "focus": "Mobility and Flexibility",
                "rest": 45
            },
            FitnessGoal.ENDURANCE: {
                "exercises": [
                    (ExerciseType.JUMPING_JACK, 4, 40),
                    (ExerciseType.SQUAT, 4, 20),
                    (ExerciseType.PUSHUP, 4, 15),
                    (ExerciseType.PLANK, 3, 45),
                ],
                "focus": "Endurance Training",
                "rest": 20
            },
            FitnessGoal.GENERAL: {
                "exercises": [
                    (ExerciseType.SQUAT, 3, 12),
                    (ExerciseType.PUSHUP, 3, 10),
                    (ExerciseType.LUNGE, 3, 10),
                    (ExerciseType.PLANK, 3, 30),
                ],
                "focus": "General Fitness",
                "rest": 45
            },
        }
    
    async def generate_workout_summary(
        self, request: WorkoutSummaryRequest
    ) -> WorkoutSummaryResponse:
        """Generate a summary for a completed workout."""
        session = request.session
        
        # Calculate performance rating
        if session.form_score >= 0.9:
            rating = "Excellent"
        elif session.form_score >= 0.75:
            rating = "Great"
        elif session.form_score >= 0.6:
            rating = "Good"
        elif session.form_score >= 0.4:
            rating = "Needs Improvement"
        else:
            rating = "Keep Practicing"
        
        # Generate highlights
        highlights = []
        if session.reps > 0:
            highlights.append(f"Completed {session.reps} reps of {session.exercise.value}")
        if session.form_score >= 0.8:
            highlights.append("Maintained excellent form throughout")
        if session.duration_seconds > 300:
            highlights.append(f"Great endurance - {session.duration_seconds // 60} minutes of work!")
        if session.calories > 100:
            highlights.append(f"Burned approximately {session.calories:.0f} calories")
        
        if not highlights:
            highlights.append("Great effort showing up for your workout!")
        
        # Get improvement tips
        tips = self.EXERCISE_TIPS.get(session.exercise, [])[:3]
        if session.form_score < 0.7:
            tips.insert(0, "Focus on slower, more controlled movements")
        
        # Generate summary text
        summary = self._generate_summary_text(session, rating)
        
        return WorkoutSummaryResponse(
            summary=summary,
            highlights=highlights,
            improvement_tips=tips,
            calories_burned=session.calories,
            performance_rating=rating
        )
    
    def _generate_summary_text(self, session, rating: str) -> str:
        """Generate human-readable summary text."""
        exercise_name = session.exercise.value.replace("_", " ").title()
        
        if rating in ["Excellent", "Great"]:
            opener = "Amazing workout! 🔥"
        elif rating == "Good":
            opener = "Solid session! 💪"
        else:
            opener = "Keep pushing! Every workout counts."
        
        summary = f"{opener} You completed {session.reps} reps of {exercise_name}"
        
        if session.form_score >= 0.8:
            summary += " with excellent form"
        elif session.form_score >= 0.6:
            summary += " with good form"
        
        summary += f". Your form score was {session.form_score * 100:.0f}%."
        
        if session.calories > 0:
            summary += f" Estimated calorie burn: {session.calories:.0f} kcal."
        
        return summary
    
    async def generate_next_workout(
        self, request: NextWorkoutRequest
    ) -> NextWorkoutResponse:
        """Generate personalized workout recommendations."""
        goal = FitnessGoal.GENERAL
        if request.user_profile:
            goal = request.user_profile.goal
        
        workout_template = self.GOAL_WORKOUTS.get(goal, self.GOAL_WORKOUTS[FitnessGoal.GENERAL])
        
        # Generate recommendations
        recommendations = []
        for exercise, sets, reps in workout_template["exercises"]:
            # Adjust based on recent performance
            adjusted_reps = reps
            if request.recent_workouts:
                recent_scores = [
                    w.form_score for w in request.recent_workouts 
                    if w.exercise == exercise
                ]
                if recent_scores and sum(recent_scores) / len(recent_scores) > 0.85:
                    adjusted_reps = int(reps * 1.1)  # Progress 10%
            
            recommendations.append(WorkoutRecommendation(
                exercise=exercise,
                sets=sets,
                reps=adjusted_reps,
                rest_seconds=workout_template["rest"],
                notes=f"Focus on form for {exercise.value.replace('_', ' ')}"
            ))
        
        # Calculate estimated duration
        total_reps = sum(r.sets * r.reps for r in recommendations)
        rest_time = sum(r.sets * r.rest_seconds for r in recommendations)
        work_time = total_reps * 3  # ~3 seconds per rep
        estimated_duration = (work_time + rest_time) // 60
        
        # Generate motivational message
        messages = [
            "Let's crush this workout! 💪",
            "Time to get stronger! 🔥",
            "Your future self will thank you!",
            "Consistency is key - let's go!",
            "One workout closer to your goals!"
        ]
        import random
        
        return NextWorkoutResponse(
            recommendations=recommendations,
            focus_area=workout_template["focus"],
            estimated_duration_minutes=max(15, estimated_duration),
            motivational_message=random.choice(messages)
        )
