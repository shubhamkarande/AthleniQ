"""
Pose Detection Router - Real-time exercise analysis
"""

from fastapi import APIRouter, HTTPException, status
from app.models.schemas import PoseAnalyzeRequest, PoseAnalyzeResponse
from app.services.pose_service import PoseDetectionService

router = APIRouter()
pose_service = PoseDetectionService()


@router.post("/analyze", response_model=PoseAnalyzeResponse)
async def analyze_pose(request: PoseAnalyzeRequest):
    """
    Analyze a single frame for pose detection and form feedback.
    
    - **image_base64**: Base64 encoded image frame
    - **exercise_type**: Type of exercise being performed
    - **frame_number**: Sequential frame number for rep counting
    """
    try:
        result = await pose_service.analyze_frame(
            image_base64=request.image_base64,
            exercise_type=request.exercise_type,
            frame_number=request.frame_number
        )
        return result
    except Exception as e:
        return PoseAnalyzeResponse(
            success=False,
            error=str(e)
        )


@router.post("/analyze-batch")
async def analyze_batch(frames: list[PoseAnalyzeRequest]):
    """
    Analyze multiple frames in batch for improved performance.
    """
    results = []
    for frame in frames:
        result = await pose_service.analyze_frame(
            image_base64=frame.image_base64,
            exercise_type=frame.exercise_type,
            frame_number=frame.frame_number
        )
        results.append(result)
    return {"results": results}


@router.get("/supported-exercises")
async def get_supported_exercises():
    """
    Get list of exercises supported by the pose detection system.
    """
    return {
        "exercises": [
            {"id": "squat", "name": "Squats", "muscle_groups": ["quads", "glutes", "core"]},
            {"id": "pushup", "name": "Push-ups", "muscle_groups": ["chest", "triceps", "shoulders"]},
            {"id": "lunge", "name": "Lunges", "muscle_groups": ["quads", "glutes", "hamstrings"]},
            {"id": "plank", "name": "Plank", "muscle_groups": ["core", "shoulders", "back"]},
            {"id": "jumping_jack", "name": "Jumping Jacks", "muscle_groups": ["full_body", "cardio"]},
            {"id": "deadlift", "name": "Deadlift", "muscle_groups": ["back", "glutes", "hamstrings"]},
            {"id": "bicep_curl", "name": "Bicep Curls", "muscle_groups": ["biceps", "forearms"]},
        ]
    }


@router.get("/reset-session")
async def reset_session():
    """
    Reset the pose detection session (clears rep counter, etc.)
    """
    pose_service.reset_session()
    return {"message": "Session reset successfully"}
