import socket
import json
import time

UDP_IP = "127.0.0.1"
UDP_PORT = 5005


def init_connection():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return sock


# prolly need to block in main to not spam Godot
def send_data(sock, data):
    message = json.dumps(data).encode("utf-8")
    sock.sendto(message, (UDP_IP, UDP_PORT))
    

# test script for sending
if __name__ == "__main__":
    # PROCESS RESULT OUTPUT
    fake_data = {
        "gesture": 0,
        "hand_type": 1,
        "hand_position": (0, 0), # (x,y)
    }
    sock = init_connection()
    while True:
        send_data(sock, fake_data)
        time.sleep(.1)
    