from enum import Enum
import cv2
import mediapipe as mp
import time

import tracker as track
import camera as cam
import conn


DEBUG_INTERVAL = 100 # 10 FPS <-- not implemented

# state management
class State(Enum):
    FIND_BOTTOM_LEFT = 0
    FIND_TOP_RIGHT = 1
    CALIBRATED = 2
    # add hand size cal

class Calibration:
    min_x = 0
    min_y = 0
    min_z = 0
    max_x = 0
    max_y = 0
    max_z = 0

cur_cal = Calibration()
cur_state = State.CALIBRATED


# init model, camera, and socket
recognizer = track.init_recognizer()
cap = cam.init_camera()
sock = conn.init_connection()

# time stamps
start_time = time.monotonic()

while True:
    # process livestream for all
    # READ + PREP THE FRAME
    frame = cam.get_frame(cap)
    mp_image = cam.convert_frame_mediapipe(frame)

    # UPDATE TIME INTERVAL
    frame_timestamp = int((time.monotonic() - start_time) * 1000)

    # PROCESS THE FRAME (this is where ML magic is)
    result = recognizer.recognize_for_video(mp_image, frame_timestamp)
    result_proc = track.process_result(result)

    # if no landmark data, skip
    if result_proc["valid"]:
        # output landmark points for all states
        cam.debug_landmarks(frame, result_proc)

        if cur_state == State.FIND_BOTTOM_LEFT:
            pass
        
        elif cur_state == State.FIND_TOP_RIGHT:
            pass

        elif cur_state == State.CALIBRATED:
            # send to Godot
            data = track.serialize_proc_data(result_proc)
            conn.send_data(sock, data)
            # output current gesture + hand type
            cam.write_text(frame, result_proc["gesture"], 0)
            cam.write_text(frame, result_proc["hand_type"], 1)


    # UPDATE CV2 (UI for hand-tracker)
    cv2.imshow("Hand Tracker", frame)
    key = cv2.waitKey(1) & 0xFF
    if key == ord('q'):
        break
    elif key == ord('r'):
        cur_state = State.FIND_BOTTOM_LEFT
        cur_cal = Calibration()


# cleanup
cam.close_camera(cap)
cv2.destroyAllWindows()