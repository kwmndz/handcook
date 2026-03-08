import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision

import calibration as cal
import smoother as sm

# load gesture tracking model
MODEL_PATH = "gesture_recognizer.task"
# params
MAX_HANDS = 1
CAMERA = 0

# modify this as gestures are added
def serialize_gesture(top_gesture, score):
    mapper = {
        "Open_Palm": 3,
        "Closed_Fist": 2,
        "None": 0,
    }
    if top_gesture in mapper:
        return mapper[top_gesture]
    return 0

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

def process_result(result):
    result_proc = {}
    # TRANSLATE RESULTS
    if result.hand_landmarks:
        result_proc["valid"] = True
        # PROCESS HANDS
        for hand_index, hand_landmarks in enumerate(result.hand_landmarks):
            # HAND LANDMARKS
            hl_pos = []
            for landmark in hand_landmarks:
                x = float(landmark.x)
                y = float(landmark.y)
                z = float(landmark.z)
                hl_pos.append( (x,y,z,) )
            
            # test a few hand pos to see what is best
            result_proc["hand_landmarks"] = hl_pos
            result_proc["hand_position"] = cal.get_avg([hl_pos[i] for i in [0, 5, 9, 13, 17]]) # purple, avg palm landmarks
            # other methods for hand pos
            # result_proc["hand_position"] = hl_pos[0]
            # result_proc["hand_position"] = get_avg([i for i in range])

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
    # print("DEBUG:\n", result_proc, end="\n\n", sep="")
    return result_proc


# make process data smaller for easier send
# look at the doc for format of the data
def serialize_proc_data(proc, c: cal.Calibration, s: sm.HandSmoother):
    if not proc["valid"]:
        return None
    res = {}
    res["g"] = serialize_gesture(proc["gesture"], proc["gesture_score"])
    res["ht"] = 0 if proc["hand_type"] == "Left" else 1

    res["ib"] = 1
    res["hp"] = proc["hand_position"]

    # updated handposition and bound checker
    # res["hp"], res["ib"] = c.normalize_and_check(*proc["hand_position"])

    # no smoother for now
    # res["hp"] = s.update(*res["hp"])
    return res
