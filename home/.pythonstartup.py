import datetime
import itertools
import importlib
import os
import sys

try:
    import numpy as np
    import scipy as sp
    import matplotlib.pyplot as plt
    import pandas as pd
except ImportError:
    pass
else:
    plt.style.use("bmh")
