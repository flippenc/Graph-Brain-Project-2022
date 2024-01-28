from sage.graphs.connectivity import connected_components
from random import sample
load("baeMorton.sage")

# a(n) = 4*a(n-5) for n>=16
# a(1) = 1
# a(2) = 2
# max(B(G on n vertices)) = a(n-1) where a(n) = OEIS-A178715(n)
# https://oeis.org/A178715
def maxAbsBVals(n):
    small =[1,2,3,4,5,6,9,12,16,20,27,36,48,64,81]
    if n <= len(small) + 1:
        return small[n-2]
    else:
        return 4*maxAbsBVals(n-5)

# Bae-Morton value is maximized by disjoint union of K6, K5, and K4s
# Given a maximum Bae-Morton value, find the corresponding graph that attains it
def decomposeAbsBVal(n):
    Bval = maxAbsBVals(n)
    B = Bval
    comp = []
    while B != 1:
        if B % 5 == 0:
            comp.append(6)
            B = B/5
        if B % 4 == 0:
            comp.append(5)
            B = B/4
        if B % 3 == 0:
            comp.append(4)
            B = B/3
    return sorted(comp, reverse = True)#, Bval

# given a list of integers, create the corresponding graph with complete components of those sizes
# Ex: [3,4,5] would return the graph K3 + K4 + K5 where + is disjoint union
def disjointPartitionedGraph(partition, verbose = True):
    G = Graph()
    for p in partition:
        G = G.disjoint_union(graphs.CompleteGraph(p))
    if verbose:
        prod = 1
        for c in connected_components(G):
            prod = prod*(len(c)-1)
        n = sum(partition)
        print(f'The graph with disjoint  complete components {partition} has |B| = {prod}')
    return G

# given a list of integers, create a ``necklace" graph
# Ex: [3,4,5] would return a graph consisting of a K3, K4, and K5 connected by a cycle
def partitionedGraph(partition, verbose = False):
    G = disjointPartitionedGraph(partition, verbose)
    connectingVertices = []
    for c in connected_components(G):
        connectingVertices.append(sample(c,2))
    i = 0
    while i < len(connectingVertices):
        if i + 1 < len(connectingVertices):
            G.add_edge(connectingVertices[i][0], connectingVertices[i+1][1])
        i += 1
    G.relabel()
    if verbose:
        n = sum(partition)
        print(f'The graph with connected complete components {partition} has |B| = {abs(bae_morton(G))}\n')
    return G

# create a graph consisting of two blocks of size as equal as possible
def pairGraph(n):
    return partitionedGraph([floor(n/2), ceil(n/2)],verbose = True)

def randomlyConnectedK5(n):
    G = disjointPartitionedGraph(decomposeAbsBVal(n), verbose = False)
    G.relabel()
    while not G.is_connected():
        comps = sample(connected_components(G),2)
        v1 = sample(comps[0],1)[0]
        v2 = sample(comps[1],1)[0]
        G.add_edge(v1,v2)
    return G

def starK5(n):
    G = disjointPartitionedGraph(decomposeAbsBVal(n), verbose = False)
    G.relabel()
    G.add_vertex(-1)
    for c in connected_components(G):
        if -1 not in c:
            G.add_edge(-1, c[0])
    G.contract_edge(-1,0)
    return G

def dominatingStarK5(n):
    G = starK5(n)
    print(f'Star on {n} vertices has B={bae_morton(G)}')
    for v in G.vertices():
        if v != -1:
            G.add_edge(-1,v)
    print(f'Dominating star on {n} vertices has B={bae_morton(G)}')
    return G

def K5tree(n):
    K5part = disjointPartitionedGraph(decomposeAbsBVal(n), verbose = False)
    K5part.relabel()
    return K5part.union(graphs.RandomTree(n))

# Code from: https://jeromekelleher.net/generating-integer-partitions.html
# generate all partitions of integer n
def accel_asc(n):
    a = [0 for i in range(n + 1)]
    k = 1
    y = n - 1
    while k != 0:
        x = a[k - 1] + 1
        k -= 1
        while 2 * x <= y:
            a[k] = x
            y -= x
            k += 1
        l = k + 1
        while x <= y:
            a[k] = x
            a[l] = y
            yield a[:k + 2]
            x += 1
            y -= 1
        a[k] = x + y
        y = x + y - 1
        yield a[:k + 1]

def goodParts(n):
    for part in accel_asc(n):
        good = True
        if len(part) % 2 == 1 and len(part) > 11:
            for comp in part:
                if comp < 4:
                    good = False
        else:
            good = False
        if good:
            yield part

# find the maximum and minimum BaeMorton values out of all graphs with n vertices
def minAndMaxB(n):
    minB = 0
    minG6 = []
    maxB = 0
    maxG6 = []
    for part in accel_asc(n):
        currentB = 1
        for comp in part:
            currentB = currentB*(1-int(comp))
        if currentB > maxB:
            maxB = currentB
            maxG6 = [partToGraph(part).graph6_string()]
        elif currentB < minB:
            minB = currentB
            minG6 = [partToGraph(part).graph6_string()]
        elif currentB == maxB:
            maxG6.append(partToGraph(part).graph6_string())
        elif currentB == minB:
            minG6.append(partToGraph(part).graph6_string())
    print(f'For n={n}, highest B value is {maxB}, achieved by {maxG6} and lowest B value is {minB}, achieved by {minG6}')
    return [maxG6, minG6]

# turn an integer partition into a graph consisting of complete components of those sizes
def partToGraph(part):
    G = Graph()
    for comp in part:
        G = G.disjoint_union(graphs.CompleteGraph(int(comp)))
    return G

