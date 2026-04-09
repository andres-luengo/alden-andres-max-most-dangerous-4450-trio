import numpy as np

"""
if you want a proper gaussian, amplitude = 1/sqrt(2pi * sigma**2), baseline = 0
"""
def gaussian(x, center, sigma, amplitude, baseline):
    exp = -0.5*((x - center)/sigma)**2
    return baseline + amplitude * np.exp(exp)

"""
if you want a proper lorentzian, amplitude = 1/(pi * gamma), baseline = 0
"""
def lorentzian(x, center, gamma, amplitude, baseline):
    denom = 1 + ((x - center) / gamma)**2
    return baseline + amplitude / denom