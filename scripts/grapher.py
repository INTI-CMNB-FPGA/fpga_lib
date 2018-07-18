#!/usr/bin/python
#
# Graph
#
# Authors:
# * Bruno Valinoti
# * Rodrigo A. Melo
#
# Copyright (c) 2018 Authors and INTI
# Distributed under the BSD 3-Clause License
#

import numpy as np
import matplotlib.pyplot as plt
import sys

filename=sys.argv[1]
data = np.loadtxt(filename)

plt.plot(data)

plt.xlabel("sample")
plt.ylabel("value")

plt.show()
