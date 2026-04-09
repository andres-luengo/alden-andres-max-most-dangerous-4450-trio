"""
The idea of this file is to standardize how we read the data in. (i.e. so we all do the same cropping)
"""

from dataclasses import dataclass

import numpy as np
import pandas as pd

@dataclass
class TrialData():
    time: np.ndarray
    gen: np.ndarray
    fp: np.ndarray
    signal: np.ndarray

def load(sat: bool, mag: bool) -> TrialData:
    root = "data/"
    
    if not sat: root += "un"
    root += "saturated/"

    if not mag: root += "no_"
    root += "magnet/"

    read_csv = lambda name, col : pd.read_csv(root + name, usecols=[col], skiprows=15)[col].values

    return TrialData(
        read_csv("signal_gen.CSV", "TIME"),
        read_csv("signal_gen.CSV", "CH1"),
        read_csv("fabry_perot.CSV", "CH2"),
        read_csv("data.CSV", "CH4")
    )

def main():
    print(load(False, False))

if __name__ == "__main__": main()