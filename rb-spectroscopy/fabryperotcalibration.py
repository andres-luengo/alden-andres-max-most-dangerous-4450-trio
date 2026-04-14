import numpy as np

class TimeFrequencyConverter:
    def __init__(self, sat: bool, mag: bool):
        path = "data/fabry_perot_fits/_"
        
        if not sat: path += "un"
        path += "saturated/_"

        if not mag: path += "no_"
        path += "magnet/"

        self._th = np.load(path + "theta.npy")
        self._cov = np.load(path + "X.npy")
    