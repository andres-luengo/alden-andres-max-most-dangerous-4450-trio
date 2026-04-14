import numpy as np

def estimate_fwhm(x, y, baseline=0.):
        y = y - baseline
        
        max_idx = np.argmax(y)
        max_y = y[max_idx]

        i = max_idx
        while (i >= 0 and y[i] > max_y/2):
            i -= 1
        left_max = x[i]

        i = max_idx
        while (i < len(y) and y[i] > max_y / 2):
            i += 1
        right_max  = x[i]

        return right_max - left_max

"""
if you want a proper gaussian, amplitude = 1/sqrt(2pi * sigma**2), baseline = 0
"""
class _Gaussian:
    def gaussian(self, x, center, sigma, amplitude, baseline):
        exp = -0.5*((x - center)/sigma)**2
        return baseline + amplitude * np.exp(exp)
    
    def __call__(self, x, center, sigma, amplitude, baseline):
        return self.gaussian(x, center, sigma, amplitude, baseline)
    
    def proper(self, x, center, sigma):
        return self.gaussian(x, center, sigma, 1/np.sqrt(2*np.pi*sigma**2), 0.)
    
    def guess_sigma(self, x, y, baseline=np.nan):
        return estimate_fwhm(x, y, baseline)/(2*np.sqrt(2*np.log(2)))


Gaussian = _Gaussian()
del _Gaussian

# i guess the proper pattern here would've been to make fittingutils a folder, and then lorentzian.py and gaussian.py but it's ok...
class _Lorentzian:
    def lorentzian(self, x, center, gamma, amplitude, baseline):
        denom = 1 + ((x - center) / gamma)**2
        return baseline + amplitude / denom
    
    def __call__(self, x, center, gamma, amplitude, baseline):
        return self.lorentzian(x, center, gamma, amplitude, baseline)
    
    def proper(self, x, center, gamma):
        return self.lorentzian(x, center, gamma, 1/(np.pi*gamma), 0.)
    
    """
    The full-width, half max
    """
    def guess_gamma(self, x, y, baseline=0.):
        return estimate_fwhm(x, y, baseline)/2.
    

Lorentzian = _Lorentzian()
del _Lorentzian