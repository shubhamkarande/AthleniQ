"""
Pose Detection Service - MediaPipe-based pose analysis
"""

import base64
import math
import numpy as np
from typing import Optional, List, Tuple
from app.models.schemas import (
    PoseAnalyzeResponse, Landmark, JointAngle, ExerciseType
)

# MediaPipe imports (lazy loaded)
_mp_pose = None
_pose_detector = None


def get_pose_detector():
    """Lazy load MediaPipe pose detector."""
    global _mp_pose, _pose_detector
    if _pose_detector is None:
        try:
            import mediapipe as mp
            _mp_pose = mp.solutions.pose
            _pose_detector = _mp_pose.Pose(
                static_image_mode=False,
                model_complexity=1,
                smooth_landmarks=True,
                min_detection_confidence=0.5,
                min_tracking_confidence=0.5
            )
        except ImportError:
            print("MediaPipe not installed. Using mock pose detection.")
            return None
    return _pose_detector


class PoseDetectionService:
    """
    Service for analyzing exercise poses using MediaPipe.
    Provides real-time feedback on form and counts repetitions.
    """
    
    def __init__(self):
        self.rep_count = 0
        self.is_in_rep = False
        self.last_phase = "neutral"
        self.form_scores = []
        
        # Landmark indices for key body parts
        self.LANDMARKS = {
            "nose": 0,
            "left_shoulder": 11,
            "right_shoulder": 12,
            "left_elbow": 13,
            "right_elbow": 14,
            "left_wrist": 15,
            "right_wrist": 16,
            "left_hip": 23,
            "right_hip": 24,
            "left_knee": 25,
            "right_knee": 26,
            "left_ankle": 27,
            "right_ankle": 28,
        }
        
        # Exercise-specific angle thresholds
        self.EXERCISE_THRESHOLDS = {
            ExerciseType.SQUAT: {
                "knee_angle_bottom": (70, 100),  # Bottom of squat
                "knee_angle_top": (160, 180),     # Standing
                "hip_angle_bottom": (70, 110),
                "back_angle": (60, 90),           # Back should be relatively upright
            },
            ExerciseType.PUSHUP: {
                "elbow_angle_bottom": (70, 100),
                "elbow_angle_top": (160, 180),
                "body_alignment": (160, 180),     # Body should be straight
            },
            ExerciseType.LUNGE: {
                "front_knee_angle": (80, 100),
                "back_knee_angle": (80, 110),
            },
            ExerciseType.PLANK: {
                "body_alignment": (160, 180),
                "elbow_angle": (85, 95),
            },
        }
    
    def reset_session(self):
        """Reset the session state for a new workout."""
        self.rep_count = 0
        self.is_in_rep = False
        self.last_phase = "neutral"
        self.form_scores = []
    
    async def analyze_frame(
        self,
        image_base64: str,
        exercise_type: ExerciseType,
        frame_number: int
    ) -> PoseAnalyzeResponse:
        """
        Analyze a single frame for pose detection.
        """
        try:
            # Decode base64 image
            image = self._decode_image(image_base64)
            if image is None:
                return PoseAnalyzeResponse(
                    success=False,
                    error="Failed to decode image"
                )
            
            # Get pose detector
            detector = get_pose_detector()
            
            if detector is None:
                # Return mock data for development
                return self._generate_mock_response(exercise_type)
            
            # Process with MediaPipe
            import cv2
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            results = detector.process(image_rgb)
            
            if not results.pose_landmarks:
                return PoseAnalyzeResponse(
                    success=True,
                    landmarks=[],
                    feedback=["No pose detected. Please position yourself in frame."]
                )
            
            # Extract landmarks
            landmarks = self._extract_landmarks(results.pose_landmarks)
            
            # Calculate joint angles based on exercise
            joint_angles = self._calculate_joint_angles(landmarks, exercise_type)
            
            # Evaluate form
            form_score, feedback = self._evaluate_form(joint_angles, exercise_type)
            
            # Check for rep completion
            rep_counted = self._check_rep(joint_angles, exercise_type)
            
            return PoseAnalyzeResponse(
                success=True,
                landmarks=landmarks,
                joint_angles=joint_angles,
                form_score=form_score,
                rep_counted=rep_counted,
                feedback=feedback
            )
            
        except Exception as e:
            return PoseAnalyzeResponse(
                success=False,
                error=str(e)
            )
    
    def _decode_image(self, image_base64: str) -> Optional[np.ndarray]:
        """Decode base64 image to numpy array."""
        try:
            import cv2
            # Remove data URL prefix if present
            if "," in image_base64:
                image_base64 = image_base64.split(",")[1]
            
            image_data = base64.b64decode(image_base64)
            nparr = np.frombuffer(image_data, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            return image
        except Exception:
            return None
    
    def _extract_landmarks(self, pose_landmarks) -> List[Landmark]:
        """Extract landmarks from MediaPipe results."""
        landmarks = []
        for lm in pose_landmarks.landmark:
            landmarks.append(Landmark(
                x=lm.x,
                y=lm.y,
                z=lm.z,
                visibility=lm.visibility
            ))
        return landmarks
    
    def _calculate_angle(
        self,
        a: Tuple[float, float],
        b: Tuple[float, float],
        c: Tuple[float, float]
    ) -> float:
        """Calculate angle between three points (in degrees)."""
        ba = (a[0] - b[0], a[1] - b[1])
        bc = (c[0] - b[0], c[1] - b[1])
        
        dot_product = ba[0] * bc[0] + ba[1] * bc[1]
        magnitude_ba = math.sqrt(ba[0]**2 + ba[1]**2)
        magnitude_bc = math.sqrt(bc[0]**2 + bc[1]**2)
        
        if magnitude_ba * magnitude_bc == 0:
            return 0.0
        
        cos_angle = dot_product / (magnitude_ba * magnitude_bc)
        cos_angle = max(-1, min(1, cos_angle))  # Clamp to [-1, 1]
        angle = math.degrees(math.acos(cos_angle))
        
        return angle
    
    def _calculate_joint_angles(
        self,
        landmarks: List[Landmark],
        exercise_type: ExerciseType
    ) -> List[JointAngle]:
        """Calculate relevant joint angles for the exercise."""
        joint_angles = []
        
        if len(landmarks) < 29:
            return joint_angles
        
        def get_point(idx: int) -> Tuple[float, float]:
            return (landmarks[idx].x, landmarks[idx].y)
        
        if exercise_type == ExerciseType.SQUAT:
            # Left knee angle
            left_knee_angle = self._calculate_angle(
                get_point(self.LANDMARKS["left_hip"]),
                get_point(self.LANDMARKS["left_knee"]),
                get_point(self.LANDMARKS["left_ankle"])
            )
            thresholds = self.EXERCISE_THRESHOLDS[ExerciseType.SQUAT]
            is_correct = thresholds["knee_angle_bottom"][0] <= left_knee_angle <= thresholds["knee_angle_top"][1]
            
            joint_angles.append(JointAngle(
                name="left_knee",
                angle=left_knee_angle,
                is_correct=is_correct,
                feedback="Keep knees tracking over toes" if not is_correct else None
            ))
            
            # Right knee angle
            right_knee_angle = self._calculate_angle(
                get_point(self.LANDMARKS["right_hip"]),
                get_point(self.LANDMARKS["right_knee"]),
                get_point(self.LANDMARKS["right_ankle"])
            )
            joint_angles.append(JointAngle(
                name="right_knee",
                angle=right_knee_angle,
                is_correct=is_correct
            ))
            
            # Hip angle (for back position)
            hip_angle = self._calculate_angle(
                get_point(self.LANDMARKS["left_shoulder"]),
                get_point(self.LANDMARKS["left_hip"]),
                get_point(self.LANDMARKS["left_knee"])
            )
            hip_correct = thresholds["hip_angle_bottom"][0] <= hip_angle
            joint_angles.append(JointAngle(
                name="hip",
                angle=hip_angle,
                is_correct=hip_correct,
                feedback="Keep your chest up" if not hip_correct else None
            ))
            
        elif exercise_type == ExerciseType.PUSHUP:
            # Elbow angle
            elbow_angle = self._calculate_angle(
                get_point(self.LANDMARKS["left_shoulder"]),
                get_point(self.LANDMARKS["left_elbow"]),
                get_point(self.LANDMARKS["left_wrist"])
            )
            thresholds = self.EXERCISE_THRESHOLDS[ExerciseType.PUSHUP]
            is_correct = thresholds["elbow_angle_bottom"][0] <= elbow_angle <= thresholds["elbow_angle_top"][1]
            
            joint_angles.append(JointAngle(
                name="elbow",
                angle=elbow_angle,
                is_correct=is_correct,
                feedback="Lower your chest more" if elbow_angle > 120 else None
            ))
            
            # Body alignment (shoulder-hip-ankle)
            body_angle = self._calculate_angle(
                get_point(self.LANDMARKS["left_shoulder"]),
                get_point(self.LANDMARKS["left_hip"]),
                get_point(self.LANDMARKS["left_ankle"])
            )
            body_correct = body_angle > 160
            joint_angles.append(JointAngle(
                name="body_alignment",
                angle=body_angle,
                is_correct=body_correct,
                feedback="Keep your body in a straight line" if not body_correct else None
            ))
        
        return joint_angles
    
    def _evaluate_form(
        self,
        joint_angles: List[JointAngle],
        exercise_type: ExerciseType
    ) -> Tuple[float, List[str]]:
        """Evaluate overall form and generate feedback."""
        if not joint_angles:
            return 0.0, ["Position yourself in frame for analysis"]
        
        correct_count = sum(1 for ja in joint_angles if ja.is_correct)
        form_score = correct_count / len(joint_angles)
        
        feedback = []
        for ja in joint_angles:
            if ja.feedback:
                feedback.append(ja.feedback)
        
        if form_score >= 0.9:
            feedback.insert(0, "Excellent form! 💪")
        elif form_score >= 0.7:
            feedback.insert(0, "Good form, keep it up!")
        elif form_score >= 0.5:
            feedback.insert(0, "Okay form, focus on corrections")
        else:
            feedback.insert(0, "Focus on proper form")
        
        return form_score, feedback
    
    def _check_rep(
        self,
        joint_angles: List[JointAngle],
        exercise_type: ExerciseType
    ) -> bool:
        """Check if a rep has been completed based on movement phase."""
        if not joint_angles:
            return False
        
        # Get primary angle for the exercise
        if exercise_type == ExerciseType.SQUAT:
            primary_angle = next((ja.angle for ja in joint_angles if ja.name == "left_knee"), None)
            if primary_angle is None:
                return False
            
            # Detect squat phases
            if primary_angle < 100:  # Bottom of squat
                current_phase = "down"
            elif primary_angle > 160:  # Standing
                current_phase = "up"
            else:
                current_phase = "transition"
            
        elif exercise_type == ExerciseType.PUSHUP:
            primary_angle = next((ja.angle for ja in joint_angles if ja.name == "elbow"), None)
            if primary_angle is None:
                return False
            
            if primary_angle < 100:  # Bottom of pushup
                current_phase = "down"
            elif primary_angle > 160:  # Top of pushup
                current_phase = "up"
            else:
                current_phase = "transition"
        else:
            return False
        
        # Count rep when transitioning from down to up
        rep_counted = False
        if self.last_phase == "down" and current_phase == "up":
            self.rep_count += 1
            rep_counted = True
        
        self.last_phase = current_phase
        return rep_counted
    
    def _generate_mock_response(self, exercise_type: ExerciseType) -> PoseAnalyzeResponse:
        """Generate mock response for development/testing."""
        import random
        
        # Simulate occasional rep counting
        rep_counted = random.random() < 0.1
        if rep_counted:
            self.rep_count += 1
        
        # Generate mock landmarks
        mock_landmarks = [
            Landmark(x=0.5 + random.uniform(-0.1, 0.1), y=0.2 + random.uniform(-0.05, 0.05), z=0, visibility=0.99)
            for _ in range(33)
        ]
        
        # Generate mock joint angles
        mock_angles = [
            JointAngle(name="knee", angle=90 + random.uniform(-20, 20), is_correct=True),
            JointAngle(name="hip", angle=85 + random.uniform(-15, 15), is_correct=True),
        ]
        
        form_score = 0.75 + random.uniform(0, 0.25)
        
        feedback = ["Great form!" if form_score > 0.85 else "Keep your back straight"]
        
        return PoseAnalyzeResponse(
            success=True,
            landmarks=mock_landmarks,
            joint_angles=mock_angles,
            form_score=form_score,
            rep_counted=rep_counted,
            feedback=feedback
        )
