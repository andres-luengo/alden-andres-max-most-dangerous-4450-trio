import numpy as np

def transform(times: np.ndarray, sat: bool, mag: bool):
    path = "data/fabry_perot_fits/_"

    if not sat: path += "un"
    path += "saturated/_"

    if not mag: path += "no_"
    path += "magnet/"

    th = np.load(path + "theta.npy")
    cov = np.load(path + "X.npy")

    print(f"th =\n{th}")
    print(f"cov =\n{cov}")

    poly = np.polynomial.Polynomial(th)
    freqs = poly(times)

    param_samples = np.random.multivariate_normal(th, cov, 1024)
    print(f"{param_samples.shape = }")
    model_samples = np.empty((param_samples.shape[0], freqs.size))
    for i in range(model_samples.shape[0]):
        model_samples[i] = np.polynomial.Polynomial(param_samples[i])(times)
    print(f"{model_samples.shape = }")
    u_freqs = np.std(model_samples, axis=0)
    
    return freqs, u_freqs