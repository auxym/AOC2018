import tables, strutils, deques, sets

type
    AdjList[T] = TableRef[T, HashSet[T]]

func newAdjList[T](i: int) : AdjList[T] =
    newTable[T, HashSet[T]](i)

proc addEdge[T](graph: var AdjList[T], src, dst: T) =
    if src notin graph:
        graph[src] = initHashSet[T](16)
    if dst notin graph:
        graph[dst] = initHashSet[T](16)
    graph[src].incl dst

func toUndirected[T](g: AdjList[T]): AdjList[T] =
    result = g.deepCopy
    for (elem, c) in result.pairs:
        let children = g[elem]
        for child in children:
            result.addEdge(child, elem)

proc readInput(f: string): AdjList[string] =
    result = newAdjList[string](1 shl 16)
    for line in f.readFile().strip.splitLines:
        let parts = line.strip.split(")")
        let (sun, planet) = (parts[0], parts[1])
        result.addEdge(sun, planet)

let orbits = "input/day06.txt".readInput

func countDepthSum[T](graph: AdjList[T], root: T): int =
    result = 0
    var srStack: seq[tuple[it: T, depth: int]] = @[(root, 0)]
    while srStack.len > 0:
        let (sun, sunDepth) = srStack.pop
        if sun notin graph:
            continue
        let
            planets = graph[sun]
            planetDepth = sunDepth + 1
        for p in planets:
            result.inc planetDepth
            srStack.add (p, planetDepth)

let orbitCount = orbits.countDepthSum("COM")
echo orbitCount
doAssert orbitCount == 254447

func getShortestPath[T](graph: AdjList[T], src, dst: T): int =
    result = -1
    var
        q = initDeque[(T, int)]()
        visited = initHashSet[T](sets.rightSize(graph.len))
    visited.incl src
    q.addLast (src, 0)
    while q.len > 0:
        let (cur, hops) = q.popFirst
        if cur == dst:
            return hops
        for elem in graph[cur]:
            if elem notin visited:
                visited.incl elem
                q.addLast (elem, hops+1)

let hopsToSanta = orbits.toUndirected.getShortestPath("YOU", "SAN") - 2
doAssert hopsToSanta == 445
echo hopsToSanta