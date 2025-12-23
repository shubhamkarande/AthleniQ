"""
Pydantic Models and Schemas
"""

from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


class FitnessGoal(str, Enum):
    FAT_LOSS = "fat_loss"
    MUSCLE = "muscle"
    FLEXIBILITY = "flexibility"
    ENDURANCE = "endurance"
    GENERAL = "general"


class ExerciseType(str, Enum):
    SQUAT = "squat"
    PUSHUP = "pushup"
    LUNGE = "lunge"
    PLANK = "plank"
    JUMPING_JACK = "jumping_jack"
    DEADLIFT = "deadlift"
    BICEP_CURL = "bicep_curl"


# Auth Schemas
class TokenVerifyRequest(BaseModel):
    id_token: str


class TokenVerifyResponse(BaseModel):
    valid: bool
    uid: Optional[str] = None
    email: Optional[str] = None
    message: str


# User Schemas
class UserProfile(BaseModel):
    uid: str
    email: str
    height: float = Field(..., ge=100, le=250, description="Height in cm")
    weight: float = Field(..., ge=30, le=300, description="Weight in kg")
    age: int = Field(..., ge=13, le=100)
    goal: FitnessGoal
    created_at: Optional[datetime] = None


class UserProfileUpdate(BaseModel):
    height: Optional[float] = None
    weight: Optional[float] = None
    age: Optional[int] = None
    goal: Optional[FitnessGoal] = None


# Pose Detection Schemas
class Landmark(BaseModel):
    x: float
    y: float
    z: float
    visibility: float


class PoseAnalyzeRequest(BaseModel):
    image_base64: str
    exercise_type: ExerciseType
    frame_number: int = 0


class JointAngle(BaseModel):
    name: str
    angle: float
    is_correct: bool
    feedback: Optional[str] = None


class PoseAnalyzeResponse(BaseModel):
    success: bool
    landmarks: Optional[List[Landmark]] = None
    joint_angles: List[JointAngle] = []
    form_score: float = 0.0
    rep_counted: bool = False
    feedback: List[str] = []
    error: Optional[str] = None


# Workout Schemas
class WorkoutSession(BaseModel):
    id: Optional[str] = None
    user_id: str
    exercise: ExerciseType
    reps: int = 0
    sets: int = 0
    form_score: float = 0.0
    calories: float = 0.0
    duration_seconds: int = 0
    timestamp: Optional[datetime] = None


class WorkoutSummaryRequest(BaseModel):
    session: WorkoutSession
    user_profile: Optional[UserProfile] = None


class WorkoutSummaryResponse(BaseModel):
    summary: str
    highlights: List[str]
    improvement_tips: List[str]
    calories_burned: float
    performance_rating: str


class NextWorkoutRequest(BaseModel):
    user_id: str
    recent_workouts: List[WorkoutSession] = []
    user_profile: Optional[UserProfile] = None


class WorkoutRecommendation(BaseModel):
    exercise: ExerciseType
    sets: int
    reps: int
    rest_seconds: int
    notes: str


class NextWorkoutResponse(BaseModel):
    recommendations: List[WorkoutRecommendation]
    focus_area: str
    estimated_duration_minutes: int
    motivational_message: str
