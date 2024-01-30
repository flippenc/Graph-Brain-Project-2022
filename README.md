# Graph Brain Project 2022 - Bae-Morton Invariant

**General Research Information:**

-   This research was conducted during the summer of 2022 under the
    leadership of Drs. Neal Bushaw, Craig Larson, and Allison Moore. This
    research was conducted by a group of undergraduate and graduate
    students in the Math and Computer Science departments at Virginia
    Commonwealth University

-   The purpose of this research was to better understand properties of
    Bae-Morton numbers. The students in this research chose which areas
    of the problem they wanted to study. A paper compiling the results
    of this project is currently being written by members of the
    research project. The code and data in this repository is the work
    of Christopher Flippen unless otherwise stated

**Theory Explanation:**

-   In graph theory, an independent set is a collection of vertices in a
    graph such that no two vertices in the collection share an edge. The
    maximum size of an independent set in a graph *G* is the
    independence number, denoted *α*(*G*). The independence polynomial
    of a graph *G* is a polynomial *I*(*x*) defined by
    $$I(x) = \sum\_{k=0}^{\alpha(G)} a_k x^k$$
    where *a*<sub>*k*</sub> is the number of different independent sets
    of size *k* in *G*. Notice that we start the sum at *k* = 0 since
    the empty set is a valid independent set

-   One use of the independence polynomial appears in Knot Theory when
    studying the Jones polynomial. In their paper “The Spread and
    Extreme Terms of Jones Polynomials," Bae and Morton examine the
    invariant *β*<sub>*M*</sub> which is defined by evaluating the
    independence polynomial of a graph at  − 1. This paper can be found
    on [arXiv](https://arxiv.org/abs/math/0012089) and is published in
    the [Journal of Knot Theory and Its
    Ramifications](https://www.worldscientific.com/doi/10.1142/S0218216503002512)

**Code Explanation:**

-   The three main goals that I worked on for this research were:

    -   implementing efficient methods of computing the Bae-Morton
        number of general graphs

    -   determining which graphs have the largest and smallest
        Bae-Morton numbers (the extremal Bae-Morton values)

    -   studying patterns in the Bae-Morton values of various graph
        classes

-   More information about these goals appears in the following sections

**Computing Bae-Morton Numbers Efficiently**

The naive ways to compute the Bae-Morton number for a graph *G* are to
either compute the independence polynomial and evaluate it at  − 1:
$$\beta_M(G) = I(-1) = \sum\_{k=0}^{\alpha(G)} a_k(-1)^k$$
or to find the collection $\mathcal{C}$ of every independent set in *G* and take the
following sum:
$$\beta_M(G) = \sum_{C \in \mathcal{C}}(-1)^{|C|}.$$
Both of these methods are very inefficient for general graphs since even
determining the size of a maximum size independent set in a general
graph is known to be an NP-hard problem. Other students in this research
project found more efficient recursive formulas for computing Bae-Morton
numbers. For a non-cut vertex *v* with neighborhood *N*(*v*), the
Bae-Morton number satisfies
$$\beta_M(G) = \beta_M(G - \\{v\\}) - \beta_M(G - \\{v \cup N(v)\\}).$$
For edge *e* with endpoints *u* and *v* (which have neighborhoods
*N*(*u*) and *N*(*v*)), the Bae-Morton number satisfies
$$\beta_M(G) = \beta_M(G - e) - \beta_M(G - \\{ N(u) \cup \\{u\\} \cup N(v) \cup \\{v\\} \\} ).$$
The file `baeMorton.sage` contains various functions which implement
these formulas in different ways in order to more quickly compute
Bae-Morton numbers for general graphs

**Finding Graphs with Extremal Bae-Morton Numbers**

When studying invariants in graph theory, a common goal is to determine
which graphs, on a given number of vertices, have the largest and
smallest values of that invariant. Computational results found that the
absolute values of the extremal Bae-Morton numbers follow the sequence
[A178715](https://oeis.org/A178715). One way to attain these values is
with graphs consisting of disjoint unions of complete graphs.

-   The file `maxAndMinFunctions.sage` contains various functions for
    computing the extremal values of the Bae-Morton numbers and
    generating graphs that attain these values

-   Other files, such as `minMaxComputation.sage` and the files in the
    `MaxMin` folder contain code and numerical results into this
    question of which graphs achieve these extremal values

**Finding Bae-Morton Numbers for Graph Classes**

When studying invariants in graph theory, a common goal is to see if it
is possible to find formulas which describe the pattern of the invariant
for certain graph classes. Some graph classes, such as those listed
[here](https://mathworld.wolfram.com/IndependencePolynomial.html), have
known formulas for their independence polynomials which make finding
formulas for their Bae-Morton numbers easy. However, many graph classes
don’t have known formulas for their independence polynomials and other
methods for studying their Bae-Morton values are needed. Three classes
of graphs whose Bae-Morton values ended up being very interesting were
hypercube graphs, folded cube graphs, and half-cube graphs.

-   The file `cubeCalculationFunctions.sage` contains various functions
    for studying patterns in the Bae-Morton number for hypercube, folded
    cube, and half cube graphs.

-   Other files, such as `cubeSetSizes.py` and the files in the
    `BaeMorton Data` folder contain code and numerical results related
    to these types of cube graphs and some other miscellaneous graph
    classes

I worked with Scott Taylor to write functions which computed the
Bae-Morton numbers and independence polynomials of these graphs. The
sequences that we found were not yet in the OEIS, so I submitted our
results and they are now in the OEIS as the following sequences:

-   [A354802](https://oeis.org/A354802): Irregular triangle read by rows
    where *T*(*n*,*k*) is the number of independent sets of size *k* in
    the *n*-hypercube graph

-   [A355226](https://oeis.org/A355226): Irregular triangle read by rows
    where *T*(*n*,*k*) is the number of independent sets of size *k* in
    the *n*-halved cube graph

-   [A355227](https://oeis.org/A355227): Irregular triangle read by rows
    where *T*(*n*,*k*) is the number of independent sets of size *k* in
    the *n*-folded cube graph

-   [A355558](https://oeis.org/A355558): The independence polynomial of
    the *n*-halved cube graph evaluated at  − 1

-   [A355559](https://oeis.org/A355559): The independence polynomial of
    the *n*-folded cube graph evaluated at -1

-   [A354082](https://oeis.org/A354082): The independence polynomial of
    the *n*-hypercube evaluated at  − 1
