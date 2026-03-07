import mediapipe as mp
import cv2

# start with 720p
RES_WIDTH = 1280
RES_HEIGHT = 720


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