from enum import Enum
import cv2
import mediapipe as mp
import time

import calibration as cal
import tracker as track
import camera as cam
import conn
import smoother as sm

DEBUG_INTERVAL = 100 # 10 FPS <-- not implemented

# state management
class State(Enum):
    FIND_BOTTOM_LEFT = 0
    FIND_TOP_RIGHT = 1
    CALIBRATED = 2
    # add hand size cal

cur_state = State.FIND_BOTTOM_LEFT
cur_cal = cal.Calibration()
smoother = sm.HandSmoother() # base values
# TODO: add debouncer for in_bounds

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
            cam.write_text(frame, "Place bottom left", 0, color=(0,0,255))
        
        elif cur_state == State.FIND_TOP_RIGHT:
            cam.write_text(frame, "Place top right", 0, color=(255,0,0))

        elif cur_state == State.CALIBRATED:
            # DEBUG: calibration info
            # print("Calibration:", cur_cal.__dict__)
            
            # send to Godot
            data = track.serialize_proc_data(result_proc, cur_cal, smoother)
            conn.send_data(sock, data)
            # output current gesture + hand type
            cam.write_text(frame, result_proc["gesture"], 0)
            cam.write_text(frame, result_proc["hand_type"], 1)
            cam.write_text(frame, f"Coords: {result_proc['hand_position']}", 2)
            cam.write_text(frame, f"In bounds: {bool(data["ib"])}", 3)
            cam.write_text(frame, f"Normal: {data['hp']}", 4)

    # UPDATE CV2 + INPUT HANDLING
    cv2.imshow("Hand Tracker", frame)
    key = cv2.waitKey(1) & 0xFF

    if key == ord('q'):
        break

    elif key == ord('r'):
        cur_state = State.FIND_BOTTOM_LEFT
        # reset these as well
        cur_cal = cal.Calibration() # also sets calibrated to false
        smoother = sm.HandSmoother() # base values


    elif key == ord(' '):
        if cur_state == State.FIND_BOTTOM_LEFT:
            cur_cal.update_min(*result_proc["hand_position"])
            cur_state = State.FIND_TOP_RIGHT
            
        elif cur_state == State.FIND_TOP_RIGHT:
            cur_cal.update_max(*result_proc["hand_position"])
            cur_cal.calibrated = True
            cur_state = State.CALIBRATED


# cleanup
cam.close_camera(cap)
cv2.destroyAllWindows()