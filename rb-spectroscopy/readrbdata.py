"""
The idea of this file is to standardize how we read the data in. (i.e. so we all do the same cropping)
"""

from dataclasses import dataclass

from fabryperotcalibration import transform

import numpy as np
import pandas as pd

@dataclass
class TrialData():
    time: np.ndarray
    gen: np.ndarray
    fp: np.ndarray
    signal: np.ndarray
    frequency: np.ndarray

def load(sat: bool, mag: bool) -> TrialData:
    root = "data/"
    
    if not sat: root += "un"
    root += "saturated/"

    if not mag: root += "no_"
    root += "magnet/"

    read_csv = lambda name, col : pd.read_csv(root + name, usecols=[col], skiprows=15)[col].values

    signal_gen = read_csv("signal_gen.CSV", "CH1")
    low = np.argmin(signal_gen)
    high = np.argmax(signal_gen)

    time = read_csv("signal_gen.CSV", "TIME")[low:high]

    return TrialData(
        time,
        signal_gen[low:high],
        read_csv("fabry_perot.CSV", "CH2")[low:high],
        read_csv("data.CSV", "CH4")[low:high],
        transform(time, sat, mag)
    )

def main():
    print(load(False, False))

if __name__ == "__main__": main()