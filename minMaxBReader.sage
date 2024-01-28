import pickle
with open('minMaxB.pkl', 'rb') as fromPickle:
    results = pickle.load(fromPickle)

maxG6 = results[0]
minG6 = results[1]
maxB = results[2]
minB = results[3]

print(maxB)
print(minB)

import numpy as np
import matplotlib.pyplot as plt

posDatapoints = maxB
negDatapoints = minB

x1 = np.array([t[0] for t in posDatapoints if t[1] > 0])
y1 = np.array([t[1] for t in posDatapoints if t[1] > 0])

x2 = np.array([t[0] for t in negDatapoints])
y2 = np.array([-t[1] for t in negDatapoints])

plt.scatter(x1,y1)
plt.scatter(x2,-y2)
plt.show()

fit1 = np.polyfit(x1, np.log2(y1), 1)
fit2 = np.polyfit(x2, np.log2(y2), 1)

print(f'For positive B:\n\tlog_2(y) = {fit1[0]} + {fit1[1]}x\n\ty = {pow(2,fit1[0])} * 2^{fit1[1]}x\n')
print(f'For negative B:\n\t-log_2(y) = {fit2[0]} + {fit2[1]}x\n\ty = -{pow(2,fit2[0])} * 2^{fit2[1]}x')