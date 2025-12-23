"""
Application Configuration
"""

from pydantic_settings import BaseSettings
from functools import lru_cache
import os


class Settings(BaseSettings):
    # App
    app_name: str = "AthleniQ API"
    debug: bool = True
    
    # Firebase
    firebase_project_id: str = ""
    firebase_credentials_path: str = "firebase-credentials.json"
    
    # OpenAI (Optional)
    openai_api_key: str = ""
    
    # Pose Detection
    pose_confidence_threshold: float = 0.5
    
    class Config:
        env_file = ".env"
        extra = "ignore"


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
