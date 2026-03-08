import statistics

class HandSmoother:
    def __init__(self, alpha: float = 0.5):
        self.history = []  # Store up to 5 coordinates
        self.max_history = 5
        self.smoothed = None  # Store the exponentially smoothed value
        self.alpha = alpha  # Smoothing factor (0 < alpha <= 1)

    def update(self, x: float, y: float, z: float):
        # Add the new coordinate to the history
        self.history.append((x, y, z))

        # Ensure the history does not exceed the maximum size
        if len(self.history) > self.max_history:
            self.history.pop(0)

        # Calculate the median of the stored coordinates
        median_x = statistics.median(coord[0] for coord in self.history)
        median_y = statistics.median(coord[1] for coord in self.history)
        median_z = statistics.median(coord[2] for coord in self.history)

        median = (median_x, median_y, median_z)

        # Apply exponential smoothing
        if self.smoothed is None:
            self.smoothed = median  # Initialize smoothed value
        else:
            self.smoothed = tuple(
                self.alpha * m + (1 - self.alpha) * s
                for m, s in zip(median, self.smoothed)
            )

        return self.smoothed