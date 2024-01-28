from itertools import combinations
from sage.graphs.independent_sets import IndependentSets
from sage.graphs.connectivity import connected_components
from collections import defaultdict
import pprint as pp

# naive algorithm
def bae_morton(g):
    """
    from: Bae, Yongju, and Hugh R. Morton. "The spread and extreme terms of Jones polynomials." Journal of Knot Theory and its ramifications 12, no. 03 (2003): 359-373.
    """
    icount=0
    for Iset in IndependentSets(g):
        icount += (-1)^len(Iset)
    return icount

# find non cut vertex, delete it and its neighborhood:
# B(G) = B(G - {v}) - B(G - {v union N(v)})
def bae_morton_recursive_vertex(g):
    if g.num_edges() == 0:
        if g.order() == 0:
            return 1
        else:
            return 0
    maxDegree = -1
    toRemoveVertex = g.vertices()[0]
    for v in g.vertices():
        deg = g.degree(v)
        if deg > maxDegree:
            maxDegree = deg
            toRemoveVertex = v

    toRemoveList = [toRemoveVertex]
    toRemoveList.extend(g.neighbors(toRemoveVertex))

    withoutV = copy(g)
    withoutNeighborhood = copy(g)

    withoutV.delete_vertex(toRemoveVertex)
    withoutNeighborhood.delete_vertices(toRemoveList)

    return bae_morton_recursive_vertex(withoutV) - bae_morton_recursive_vertex(withoutNeighborhood)

def getDegreeData(g):
    degreeData = defaultdict(Integer)
    for v in g.vertices():
        degreeData[v] = g.degree(v)
    return degreeData

def subgraphBaeMorton(g, sub, show = False, returnCondition = None):
    returnList = []
    iso = []
    for p in g.subgraph_search_iterator(sub):
        iso.append(p)
    while iso != []:
        edges = combinations(iso[0], 2)
        g.delete_edges(edges)
        B = bae_morton(g)
        g6 = g.graph6_string()
        if returnCondition is not None and B == returnCondition:
            returnList.append(g6)
        print(f'Graph {g6} has {g.order()} vertices, {g.size()} edges, and B={B}')
        if show:
            g.show()
        iso = []
        for p in g.subgraph_search_iterator(sub):
            iso.append(p)
    if returnList != []:
        return returnList

# B(G) = B(G - e) - B(G - {N(v1) u v1 u N(v2) u v2})
def bae_morton_recursive_edge(g):
    g.show()
    if g.num_edges() == 0:
        if g.order() == 0:
            return 1
        else:
            return 0
    maxDegree = -1
    toRemoveEdge = g.edges()[0]
    degreeData = getDegreeData(g)
    for e in g.edges():
        edgeDegree = degreeData[e[0]] + degreeData[e[1]]
        if edgeDegree > maxDegree:
            maxDegree = edgeDegree
            toRemoveEdge = e

    toRemoveList = [toRemoveEdge[0], toRemoveEdge[1]]
    toRemoveList.extend(g.neighbors(toRemoveEdge[0]))
    toRemoveList.extend(g.neighbors(toRemoveEdge[1]))
    toRemoveList = list(set(toRemoveList))

    withoutE = copy(g)
    withoutNeighborhoods = copy(g)

    withoutE.delete_edge(toRemoveEdge)
    withoutNeighborhoods.delete_vertices(toRemoveList)

    return bae_morton_recursive_edge(withoutE) - bae_morton_recursive_edge(withoutNeighborhoods)

#Poset Invariants

def number_maximal_independent_sets(g):
    gcomp = g.complement()
    return len(g.cliques_maximal())

def independence_poset_cardinality(g):
    I=IndependentSets(g)
    S=[Set(ind) for ind in I]
    P=Poset((S,lambda x,y:x.issubset(y)))
    return P.cardinality()

def has_star_center(g):
    return (g.order() - 1) in g.degree()

def independence_polymonial(g):
    gc = g.complement()
    return gc.clique_polynomial()

# evaluates the function 'funcString' using the input 'param'
def evalFuncString(funcString, param):
    try:
        try:
            result = getattr(param, funcString)()
        except:
            func = globals()[funcString]
            result = func(param)
    except:
        param = param.relabel(inplace = False)
        return evalFuncString(funcString, param)
    return result

# returns True if G DOES NOT satisfy any properties in noProps
def checkNoProperties(G, noProps):
    if isinstance(G, str):
        G = Graph(G)
    for prop in noProps:
        if isinstance(prop, str):
            result = evalFuncString(prop, G)
        else:
            result = prop(G)
        if result:
            return False
    return True

# returns True if G DOES satisfy every property in yesProps
def checkYesProperties(G, yesProps):
    if isinstance(G, str):
        G = Graph(G)
    for prop in yesProps:
        if isinstance(prop, str):
            result = evalFuncString(prop, G)
        else:
            result = prop(G)
        if not result:
            return False
    return True

# checks if G satisfies EVERYTHING in yesProps and NOTHING in noProps
def yesAndNoProperties(G, yesProps, noProps):
    if not checkYesProperties(G, yesProps):
        return False
    else:
        if checkNoProperties(G, noProps):
            return True
        return False

# same as yesAndNoProperties but for a list of graphs
# returns a list of graphs which satisfy yesProps but fail noProps
def yesAndNoPropertiesList(gList, yesProps, noProps):
    goodGraphs = []
    for G in gList:
        if yesAndNoProperties(G, yesProps, noProps):
            goodGraphs.append(G)
    return goodGraphs

def checkWhichProperties(G, props):
    results = []
    for prop in props:
        if isinstance(prop, str):
            result = f'Property: {prop} is {evalFuncString(prop,G)}'
        else:
            result = f'Property: {prop} is {prop(G)}'
        results.append(result)
    return results

def checkWhichPropertiesList(gList, props):
    for G in gList:
        if isinstance(G, str):
            G = Graph(G)
        print(f'Graph {G.graph6_string()} has the following invarient values:')
        pp.pprint(checkWhichProperties(G, props))

def bae_morton_break_components(g):
    """
    Takes in a graph, returns the graph's Bae-Morton number.
    This algorithm aims to recursively break down the graph, removing an edge from the lowest degree vertex each call until a vertex is isolated.
    """

    # first stopping condition (check for empty graph)
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
                prod = prod*bae_morton_break_components(g.subgraph(vertices=c))
        return prod

    # find lowest degree vertex
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
    return bae_morton_break_components(without_edge) - bae_morton_break_components(without_neighborhoods)

def posBaeMorton(g):
    return bae_morton_break_components(g) > 0

def negBaeMorton(g):
    return bae_morton_break_components(g) < 0

def zeroBaeMorton(g):
    return bae_morton_break_components(g) == 0

def bae_morton_minimize_degree(g):
    """
    Takes in a graph, returns the graph's Bae-Morton number.
    This algorithm aims to recursively break down the graph, removing an edge from the lowest degree vertex each call until a vertex is isolated.
    """

    # first stopping condition (check for empty graph)
    if g.order() == 0:
            return 1

    # find lowest degree vertex
    min_degree_vertex = g.vertices()[0]
    for v in g.vertices():
        if g.degree(v) < g.degree(min_degree_vertex):
            min_degree_vertex = v

    # second stopping condition relies on bae-morton value of disconnected components being their product
    # bae-morton value of an isolated vertex is 0, so any graph containing it will also have a value of 0
    if g.degree(min_degree_vertex) == 0:
        return 0

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
    return bae_morton_minimize_degree(without_edge) - bae_morton_minimize_degree(without_neighborhoods)

def bae_morton_vertex_cover_polynomial(g):
    if g.order() >= 2:
        min_degree_vertex = g.vertices()[0]
        for v in g.vertices():
            if g.degree(v) < g.degree(min_degree_vertex):
                min_degree_vertex = v

        without_v = copy(g)
        without_v.delete_vertex(min_degree_vertex)

        return -1 - bae_morton_vertex_cover_polynomial(without_v)
    else:
        return bae_morton_minimize_degree(g)