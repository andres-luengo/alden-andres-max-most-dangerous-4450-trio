import numpy as np

def gaussian(x, center, sigma, amplitude, baseline):
    exp = -0.5*((x - center)/sigma)**2
    return baseline + amplitude * np.exp(exp)