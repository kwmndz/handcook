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

