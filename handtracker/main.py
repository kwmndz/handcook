import cv2
import mediapipe as mp
import time

import tracker as track
import camera as cam
import conn

recognizer = track.init_recognizer()
cap = cam.init_camera()
start_time = time.monotonic()
sock = conn.init_connection()

# DEBUG: timing tests (not implemented)
# millisecond period between intervals
DEBUG_INTERVAL = 100 # 10 FPS
last_debug_timestamp = int(start_time * 1000)


while True:
    # READ + PREP THE FRAME
    frame = cam.get_frame(cap)
    mp_image = cam.convert_frame_mediapipe(frame)

    # update time interval
    # time elapsed in milliseconds
    frame_timestamp = int((time.monotonic() - start_time) * 1000)

    # PROCESS THE FRAME (this is where ML magic is)
    result = recognizer.recognize_for_video(mp_image, frame_timestamp)
    result_proc = track.process_result(result)

    # SEND TO GODOT (if got data)
    data = track.serialize_proc_data(result_proc)
    if data:
        conn.send_data(sock, data)

    # DEBUG
    # if (frame_timestamp - last_debug_timestamp) > DEBUG_INTERVAL and result_proc["valid"]:
    if True and result_proc["valid"]:
        # mark the global position of the hand
        # g_x, g_y = result_proc["hand_position"]
        # cv2.circle(frame, (int(g_x*cam.RES_WIDTH), int(g_y*cam.RES_HEIGHT)), 4, (0,0,255), -1)
        g_x, g_y = result_proc["hand_position1"]
        cv2.circle(frame, (int(g_x*cam.RES_WIDTH), int(g_y*cam.RES_HEIGHT)), 6, (255,255,0), -1)
        # g_x, g_y = result_proc["hand_position2"]
        # cv2.circle(frame, (int(g_x*cam.RES_WIDTH), int(g_y*cam.RES_HEIGHT)), 4, (128,0,128), -1)

        # mark each landmark
        for x, y in result_proc["hand_landmarks"]:
            cv2.circle(frame, (int(x*cam.RES_WIDTH),int(y*cam.RES_HEIGHT)), 4, (0,255,0), -1)
        # output current gesture
        cv2.putText(
             frame,
             result_proc["gesture"],
             (10, 40), # + hand_index*40),
             cv2.FONT_HERSHEY_SIMPLEX,
             1,
             (0,255,0),
             2
         )
        # output handedness
        cv2.putText(
            frame,
            result_proc["hand_type"],
            (10, 70), # + hand_index * 40),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.8,
            (255, 255, 0),
            2
        )
        # cv2.putText(
        #     frame,
        #     f"SIM FPS: {sim_fps:.1f}",
        #     (10, 110),
        #     cv2.FONT_HERSHEY_SIMPLEX,
        #     0.8,
        #     (0, 255, 255),
        #     2
        # )

        # cv2.putText(
        #     frame,
        #     f"DEBUG FPS: {debug_fps:.1f}",
        #     (10, 140),
        #     cv2.FONT_HERSHEY_SIMPLEX,
        #     0.8,
        #     (255, 0, 255),
        #     2
        # )
        last_debug_timestamp = frame_timestamp

    # UPDATE CV2
    cv2.imshow("Hand Tracker", frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# cleanup
cam.close_camera(cap)
cv2.destroyAllWindows()