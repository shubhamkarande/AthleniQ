"""
Authentication Router - Firebase Token Verification
"""

from fastapi import APIRouter, HTTPException, status
from app.models.schemas import TokenVerifyRequest, TokenVerifyResponse
from app.services.firebase_service import verify_firebase_token

router = APIRouter()


@router.post("/verify-token", response_model=TokenVerifyResponse)
async def verify_token(request: TokenVerifyRequest):
    """
    Verify a Firebase ID token and return user information.
    """
    try:
        result = await verify_firebase_token(request.id_token)
        return result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token verification failed: {str(e)}"
        )


@router.get("/status")
async def auth_status():
    """
    Check if authentication service is operational.
    """
    return {"status": "operational", "service": "firebase-auth"}
