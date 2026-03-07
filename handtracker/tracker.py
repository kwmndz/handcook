import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
from camera import RES_WIDTH, RES_HEIGHT

import time

# load gesture tracking model
MODEL_PATH = "gesture_recognizer.task"
# params
MAX_HANDS = 1
CAMERA = 0

# PROCESS RESULT OUTPUT
process_result_out = {
    "valid": True,
    "gesture": "THUMBS_UP",
    "gesture_score": .67,
    "hand_type": "LEFT",

    # TODO: have to add this calculation
    "hand_position": (0, 0), # (x,y)

    # maybe necessary?
    # size of this list will be 21
    "hand_landmarks": [
        (.5, .5),
    ]
}

def init_recognizer():
    # configure the model
    BaseOptions = mp.tasks.BaseOptions
    GestureRecognizer = vision.GestureRecognizer
    # gesture classes
    GestureRecognizerOptions = vision.GestureRecognizerOptions
    GestureRecognizerResult = vision.GestureRecognizerResult
    VisionRunningMode = vision.RunningMode
    # configure the settings + build recognizer
    options = GestureRecognizerOptions(
        base_options=BaseOptions(model_asset_path=MODEL_PATH),
        num_hands = MAX_HANDS,
        min_hand_detection_confidence=0.5,
        min_hand_presence_confidence=0.5,
        min_tracking_confidence=0.5,
        running_mode=VisionRunningMode.VIDEO
    )
    recognizer = GestureRecognizer.create_from_options(options)
    return recognizer



# TODO: add hand position calc
def process_result(result):
    result_proc = {}
    # TRANSLATE RESULTS
    if result.hand_landmarks:
        result_proc["valid"] = True
        # PROCESS HANDS
        for hand_index, hand_landmarks in enumerate(result.hand_landmarks):
            hl_pos = []
            # HAND LANDMARKS
            for landmark in hand_landmarks:
                x = float(landmark.x * RES_WIDTH)
                y = float(landmark.y * RES_HEIGHT)
                hl_pos.append( (x,y,) )

            result_proc["hand_landmarks"] = hl_pos

            # GESTURES
            if result.gestures and len(result.gestures) > hand_index:
                # check what gestures
                top_gesture = result.gestures[hand_index][0]
                gesture_name = top_gesture.category_name
                score = top_gesture.score

                result_proc["gesture"] = gesture_name
                result_proc["gesture_score"] = score

            # HANDEDNESS
            if result.handedness and len(result.handedness) > hand_index and result.handedness[hand_index]:
                hand_label = result.handedness[hand_index][0].category_name
                result_proc["hand_type"] = hand_label
    else:
        result_proc["valid"] = False

    # DEBUG show current processed frame
    print("DEBUG:\n", result_proc, end="\n\n", sep="")
    return result_proc