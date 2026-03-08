from collections import deque

def get_avg(pos_list):
    ax = sum([i[0] for i in pos_list]) / len(pos_list)
    ay = sum([i[1] for i in pos_list]) / len(pos_list)
    az = sum([i[2] for i in pos_list]) / len(pos_list)
    return (ax, ay, az,)

class HandSmoother:
    def __init__(self, window=5):
        self.window = deque(maxlen=window)
    def update(self, x, y, z):
        self.window.append((x, y, z))
        return get_avg(list(self.window))

# converts mediapipe to Godot
# top left is 0,0
# bottom right is 1,1
# z is inverted
def normalize(x, y, z):
    x = max(0, min(1, x))
    y = 1-max(0, min(1, y))
    z = -1 * z
    return (x,y,z,)
