"""
Firebase Service - Authentication and token verification
"""

from app.models.schemas import TokenVerifyResponse
from app.config import settings


async def verify_firebase_token(id_token: str) -> TokenVerifyResponse:
    """
    Verify a Firebase ID token.
    
    In production, this would use Firebase Admin SDK.
    For development/testing, this provides a mock implementation.
    """
    try:
        # For production, uncomment and configure Firebase Admin:
        # import firebase_admin
        # from firebase_admin import credentials, auth
        # 
        # if not firebase_admin._apps:
        #     cred = credentials.Certificate(settings.firebase_credentials_path)
        #     firebase_admin.initialize_app(cred)
        # 
        # decoded_token = auth.verify_id_token(id_token)
        # return TokenVerifyResponse(
        #     valid=True,
        #     uid=decoded_token['uid'],
        #     email=decoded_token.get('email'),
        #     message="Token verified successfully"
        # )
        
        # Development mock - accepts any non-empty token
        if not id_token or len(id_token) < 10:
            return TokenVerifyResponse(
                valid=False,
                message="Invalid token format"
            )
        
        # Mock successful verification for development
        return TokenVerifyResponse(
            valid=True,
            uid="dev_user_" + id_token[:8],
            email="dev@athleniq.com",
            message="Token verified (development mode)"
        )
        
    except Exception as e:
        return TokenVerifyResponse(
            valid=False,
            message=f"Token verification failed: {str(e)}"
        )
