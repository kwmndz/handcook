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
        # DEBUG: calibration info
        # print("Calibration:", cur_cal.__dict__)

        # send to Godot
        data = track.serialize_proc_data(result_proc, smoother)
        conn.send_data(sock, data)
        # output current gesture + hand type
        cam.write_text(frame, result_proc["gesture"], 0)
        cam.write_text(frame, result_proc["hand_type"], 1)
        cam.write_text(frame, f"Coords: {result_proc['hand_position']}", 2)
        cam.write_text(frame, f"Normal: {data['hp']}", 4)

    # UPDATE CV2 + INPUT HANDLING
    cv2.imshow("Hand Tracker", frame)
    key = cv2.waitKey(1) & 0xFF
    if key == ord('q'):
        break
    if key == ord('r'):
        smoother = sm.HandSmoother()
        start_time = time.monotonic()


# cleanup
cam.close_camera(cap)
cv2.destroyAllWindows()