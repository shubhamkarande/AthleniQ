"""
AthleniQ Backend - FastAPI Application
AI-powered fitness coaching with pose detection
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, pose, ai
from app.config import settings

app = FastAPI(
    title="AthleniQ API",
    description="AI Fitness Coach Backend with Pose Detection",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/auth", tags=["Authentication"])
app.include_router(pose.router, prefix="/pose", tags=["Pose Detection"])
app.include_router(ai.router, prefix="/ai", tags=["AI Coach"])


@app.get("/")
async def root():
    return {"message": "Welcome to AthleniQ API", "version": "1.0.0"}


@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "athleniq-backend"}
