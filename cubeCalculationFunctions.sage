from sage.graphs.connectivity import connected_components
from sage.graphs.independent_sets import IndependentSets
import math

# functions for computing bae morton values of different cube types

def bae_morton_break_matches(g):
    if g.order() == 0:
            return 1

    comp = g.connected_components()
    if len(comp[-1]) == 1:
        return 0
    elif len(comp) > 1:
        prod = 1
        for c in comp:
            if prod == 0:
                return 0
            else:
                prod = prod*bae_morton_break_matches(g.subgraph(vertices=c))
        return prod

    matchingEdges = []
    # Q_n is a code graph, all vertices are binary strings
    # Q_n is comprised of two Q_n-1's connected by a perfect matching
    # The edges in the matching are between 1XXX and 0XXX: 100 to 000, 101 to 100, 1101 to 0101, etc.
    # Therefore, if labels of the edge endpoints differ in the first character only, they are part of the matching
    for e in g.edges():
        if e[0][0] != e[1][0] and e[0][1:] == e[1][1:]:
            matchingEdges.append(e)
    if matchingEdges != []:
        to_remove_edge = matchingEdges[0]
    else:
        min_degree_vertex = g.vertices()[0]
        for v in g.vertices():
            if g.degree(v) < g.degree(min_degree_vertex):
                min_degree_vertex = v

        # select an edge of the vertex with the lowest degree, and save the neighborhoods of both endpoints
        to_remove_edge =  g.edges_incident(min_degree_vertex)[0]

    to_remove_vertices =[to_remove_edge[0], to_remove_edge[1]]
    to_remove_vertices.extend(g.neighbors(to_remove_edge[0]))
    to_remove_vertices.extend(g.neighbors(to_remove_edge[1]))

    # delete duplicate vertices in neighborhood list
    to_remove_vertices = list(set(to_remove_vertices))

    # make a copy of the graph and remove the selected neighborhoods
    without_neighborhoods = copy(g)
    without_edge = copy(g)
    without_neighborhoods.delete_vertices(to_remove_vertices)

    # delete the selected edge from g
    without_edge.delete_edge(to_remove_edge)
    # recurse using formula B(G) = B(G - e) - B(G - {N(v1) u v1 u N(v2) u v2})
    return bae_morton_break_matches(without_edge) - bae_morton_break_matches(without_neighborhoods)

#idea: any independent set from the next smaller cube * 2
# plus any independent set from "bottom" smaller cube and disjoint independet set from "top" smaller cube
def bae_morton_cube(n): #defined for n>=2
    g=graphs.CubeGraph(n-1)
    V = Set(g.vertices())
    icount=1 #for the empty set
    for Iset in IndependentSets(g):
        if len(Iset)>0:
            icount += 2*(-1)^len(Iset)
            HV = V.difference(Set(Iset))
            h=g.subgraph(HV)
            J=IndependentSets(h)
            SI = Set(Iset)
            for Jset in J:
                if(len(Jset)>0):
                    SJ=Set(Jset)
                    if len(SI.intersection(SJ))==0:
                        icount += (-1)^len(SJ.union(SI))
    return icount

def recurse(g):
    if g.order() == 0:
            return 1
    comp = g.connected_components()
    if len(comp[-1]) == 1:
        return 0
    elif len(comp) > 1:
        prod = 1
        for c in comp:
            if prod == 0:
                return 0
            else:
                prod = prod*recurse(g.subgraph(vertices=c))
        return prod
    min_degree_vertex = g.vertices()[0]
    for v in g.vertices():
        if g.degree(v) < g.degree(min_degree_vertex):
            min_degree_vertex = v
    to_remove_edge =  g.edges_incident(min_degree_vertex)[0]
    to_remove_vertices = [to_remove_edge[0], to_remove_edge[1]]
    to_remove_vertices.extend(g.neighbors(to_remove_edge[0]))
    to_remove_vertices.extend(g.neighbors(to_remove_edge[1]))
    to_remove_vertices = list(set(to_remove_vertices))
    without_neighborhoods = copy(g)
    without_edge = copy(g)
    without_neighborhoods.delete_vertices(to_remove_vertices)
    without_edge.delete_edge(to_remove_edge)
    return recurse(without_edge) - recurse(without_neighborhoods)

def cubeBaeMorton(n):
    if n == 0:
        return recurse(graphs.CompleteGraph(1))
    else:
        return recurse(graphs.CubeGraph(n))
    
def halfCubeBaeMorton(n):
    if n == 1:
        return recurse(graphs.CompleteGraph(1))
    else:
        return recurse(graphs.HalfCube(n))

def foldedCubeBaeMorton(n):
    if n == 1:
        return recurse(graphs.CompleteGraph(1))
    else:
        return recurse(graphs.FoldedCubeGraph(n))
    
# functions for counting independent set sizes

def set_counter(g):
    c = g.complement()
    max_size = sage.graphs.cliquer.clique_number(c)
    set_counts = [0] * (max_size + 1)
    even_odd = [0, 0]
    for Iset in IndependentSets(g):
        set_counts[len(Iset)] += 1
        even_odd[len(Iset)%2] += 1
    print_sets(g, set_counts, even_odd)
for n in range(1,7):
    set_counter(graphs.CubeGraph(n))

def halfCubeIndependentSetSizes(n):
    if n == 1:
        g = graphs.CompleteGraph(1)
        setCounts = [0, 0]
    else:
        g = graphs.HalfCube(n)
        setList = [1,1,1,2,2,4,8,16,20,40,72,144,256,512,1024,2048]
        setCounts = [0] * (setList[n-1] + 1)
    for Iset in IndependentSets(g):
        setCounts[len(Iset)] += 1
    return setCounts

def foldedCubeIndependentSets(n):
    g = graphs.FoldedCubeGraph(n)
    if n % 2 == 0:
        setCounts = [0] * (pow(2, n-2) + 1)
    else:
        size = int(pow(2, n-2) - 1/4 * (1-pow(-1,n)) * math.comb(n-1, 1/2 * (n-1)) + 1)
        setCounts = [0] * size
    for Iset in IndependentSets(g):
        setCounts[len(Iset)] += 1
    return setCounts

def print_sets(g, set_counts, even_odd):
    g.show()
    print("Cube of size " + str(int(math.log2(g.order()))) + ":")
    print("Even sets: " + str(even_odd[0]))
    print("Odd sets:  " + str(even_odd[1]))
    for i in range(0, len(set_counts)):
        print("Sets of size " + str(i) + ": " + str(set_counts[i]))  
    print("")

def set_counts(g):
    c = g.complement()
    max_size = sage.graphs.cliquer.clique_number(c)
    set_counts = [0] * (max_size + 1)
    for Iset in IndependentSets(g):
        set_counts[len(Iset)] += 1
    return set_counts

def cubeRow(n):
    if n == 0:
        g = graphs.CompleteGraph(1)
        setCounts = [0, 0]
    else:
        g = graphs.CubeGraph(n)
        setCounts = [0] * (pow(2,n - 1) + 1)
    for Iset in IndependentSets(g):
        setCounts[len(Iset)] += 1
    return setCounts

def foldedCoeffRow(n):
    g = graphs.FoldedCubeGraph(n)
    if n % 2 == 0:
        setCounts = [0] * (pow(2, n-2) + 1)
    else:
        size = int(pow(2, n-2) - 1/4 * (1-pow(-1,n)) * math.comb(n-1, 1/2 * (n-1)) + 1)
        setCounts = [0] * size
    for Iset in IndependentSets(g):
        setCounts[len(Iset)] += 1
    return setCounts

def halfCoeffRow(n):
    if n == 1:
        g = graphs.CompleteGraph(1)
        setCounts = [0, 0]
    else:
        g = graphs.HalfCube(n)
        setList = [1,1,1,2,2,4,8,16,20,40,72,144,256,512,1024,2048]
        setCounts = [0] * (setList[n-1] + 1)
    for Iset in IndependentSets(g):
        setCounts[len(Iset)] += 1
    return setCounts