from sage.graphs.independent_sets import IndependentSets
def row(n):
    g = graphs.FoldedCubeGraph(n)
    if n % 2 == 0:
        setCounts = [0] * (pow(2, n-2) + 1)
    else:
        size = int(pow(2, n-2) - 1/4 * (1-pow(-1,n)) * math.comb(n-1, 1/2 * (n-1)) + 1)
        setCounts = [0] * size
    for Iset in IndependentSets(g):
        setCounts[len(Iset)] += 1
    return setCounts

n = 8
rowOut = row(8)
with open('foldedCoeff2.txt', 'a+') as outFile:
    outFile.write(f'Row {n}: {rowOut}\n')
