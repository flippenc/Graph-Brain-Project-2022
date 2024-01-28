load('baeMorton.sage')
load('maxAndMinFunctions.sage')

minG6 = []
minB = []
for n in range(3,89):
    results = minAndMaxB(n)
    #maxG6.extend(results[0])
    minG6.extend(results[1])
    maxB = results[2]
    minB.append((n,results[3]))
    
for G6 in minG6:
    G = Graph(G6)
    print(f'MinB Graph with {G.order()} vertices and components of sizes: {connected_components_sizes(G)}')

from sage.graphs.connectivity import connected_components_sizes

for G6 in minG6:
    G = Graph(G6)
    prod = 1
    comp = connected_components_sizes(G)
    for c in comp:
        prod = prod*(c-1)
    print(f'MinB Graph with {G.order()} vertices and ({comp},{prod})')

# the pattern seems to be something close to Bmax(n) = 16*Bmax(n-10) and Bmin(n) = 16*Bmin(n-10)
for n in range(3,42):
    print(16*maxB[n][1] == maxB[n+10][1])
    print(16*minB[n][1] == minB[n+10][1])

# In this section, I tried to find any other recurrence relations for min and max B
maxBVals = [t[1] for t in maxB]
minBVals = [t[1] for t in minB]

for B in maxB:
    for n in range(2,125):
        factor = B[1]/n
        if factor in maxBVals and B[1] != 0:
            for d in maxB:
                if d[1] == factor:
                    div = d[0]
                    break
            print(f'Since {B[1]} and {B[1]/n} both in maxBVals, then B({B[0]}) = {n}*B({div})')