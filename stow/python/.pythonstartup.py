import datetime
import itertools
import importlib
import os
import sys

try:
    import numpy as np
except ImportError:
    pass

try:
    import scipy as sp
except ImportError:
    pass

try:
    import pandas as pd
except ImportError:
    pass

try:
    import matplotlib.pyplot as plt
except ImportError:
    pass
else:
    plt.style.use("bmh")
