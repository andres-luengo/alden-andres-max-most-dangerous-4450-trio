import numpy as np

def transform(times: np.ndarray, sat: bool, mag: bool):
    path = "data/fabry_perot_fits/_"

    if not sat: path += "un"
    path += "saturated/_"

    if not mag: path += "no_"
    path += "magnet/"

    th = np.load(path + "theta.npy")
    coeff_variances = np.diag(np.load(path + "X.npy"))

    poly = np.polynomial.Polynomial(th)

    #TODO: handle uncertainties. i think there's a matrix multiplication here i am missing
    
    return poly(times)