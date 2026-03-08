# Process Result Data Format
- hand_id (hi) | int
    - Number of hand
- gesture (g) | GESTURE_ENUM <-- only 2
    - NONE: 0
    - PINCH: 1
    - FIST: 2
    - OPEN: 3
- hand_type (ht) | HAND_TYPE_ENUM <-- left or right (we can add 2)
    - LEFT_HAND: 0
    - RIGHT_HAND: 1
- hand_position (hp) <-- just send media pipe no processing
    - Vector3(float, float, float)
        - x, y coordinates

- in_bounds (ib) | IN_BOUNDS_ENUM
    - OUT | 0
    - IN | 1
- valid | int | dont need
    - 0 for valid packet 1 for not valid
- hand_landmarks | Vector3[] | dont need
    - positions for each landmark

# HASH FOR GOOD VERSION
e481edf3461e0419ef90465a33360ec5dcb932c4

## Example:
```py
process_result_out = {
    "valid": True,
    "gesture": "THUMBS_UP",
    "gesture_score": .67,
    "hand_type": "LEFT",
    "hand_position": (0, 0), # (x,y)

    # NOT NECESSARY FOR GODOT?
    "hand_landmarks": [
        (.5, .5),
    ]
}
```

# Notes on Params
```py
    # Minimum confidence for hand detection
    min_hand_detection_confidence=0.5,

    # Minimum confidence for tracking
    min_hand_presence_confidence=0.5,

    # Minimum confidence for gesture classification
    min_tracking_confidence=0.5,

    # Use video mode for webcam streams
    # IMAGE = single image
    # VIDEO = sequential frames
    # LIVE_STREAM = async webcam
    running_mode=VisionRunningMode.VIDEO
```

# Hand Landmarks
![alt text](img/image.png)


# Used sources
- ChatGPT
- https://ai.google.dev/edge/mediapipe/solutions/vision/hand_landmarker/index#models
- https://medium.com/@florian-trautweiler/real-time-hand-tracking-in-python-e2bcdd0feace
    - Not using this, we are using gesture since this alr bundled

Gesture:
- https://medium.com/@odil.tokhirov/how-i-built-a-hand-gesture-recognition-model-in-python-part-1-db378cf196e6

