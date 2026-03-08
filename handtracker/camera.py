import mediapipe as mp
import cv2
import time

import tracker as track

# start with 720p
RES_WIDTH = 1280
RES_HEIGHT = 720

# write text to N line from top
def write_text(frame, text, line, color = (0,0,0)):
    cv2.putText(
         frame,
         text,
         (10, 40 + line*40),
         cv2.FONT_HERSHEY_SIMPLEX,
         1,
         color,
         2
     )

def debug_landmarks(frame, proc):
    #mark the global position of the hand
    g_x, g_y, _ = proc["hand_position"]
    cv2.circle(frame, (int(g_x*RES_WIDTH), int(g_y*RES_HEIGHT)), 6, (255,255,0), -1)
    # mark each landmark
    for x, y, _ in proc["hand_landmarks"]:
        cv2.circle(frame, (int(x*RES_WIDTH),int(y*RES_HEIGHT)), 4, (0,255,0), -1)


def init_camera():
    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, RES_WIDTH)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, RES_HEIGHT)
    return cap


# if returns None then cooked
def get_frame(cap):
    # READ + PREP THE FRAME
    success, frame = cap.read()
    if not success:
        return None
    frame = cv2.flip(frame, 1) # flip to mirror (better for game)
    frame = cv2.flip(frame, 0)
    return frame


def convert_frame_mediapipe(frame):
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    # convert from numpy -> mediapipe image format
    mp_image = mp.Image(
        image_format=mp.ImageFormat.SRGB,
        data=rgb_frame
    )
    return mp_image


def close_camera(cap):
    cap.release()