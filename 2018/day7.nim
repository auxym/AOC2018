import strUtils
import seqUtils
import tables
import strscans
import hashes
import algorithm
import sets

type
    Node = ref object
        dependencies: HashSet[Node]
        label: char
        time: int

    Graph = Table[char, Node]

    Worker = ref object
        workingOn: Node
        timeRemaining: Natural

func hash(x: Node): Hash = x.label.hash
func `==`(a, b: Node): bool = a.label == b.label
func cmp(a, b: Node): int = cmp(a.label, b.label)
func `$`(n: Node): string = result.add n.label

proc getOrCreateNode(g: var Graph, label: char): Node = 
    if g.contains(label): return g[label]
    result = new(Node)
    result.label = label
    result.dependencies = initSet[Node](16)
    g[label] = result

proc parseInput(): Graph =
    result = initTable[char, Node](32)
    var childLabel, parentLabel: string
    const pat = "Step $w must be finished before step $w can begin."

    for line in readFile("day7_input.txt").strip.splitLines:
        if not scanf(line, pat, parentLabel, childLabel):
            raise newException(ValueError, line)
        let
            parent = result.getOrCreateNode parentLabel[0]
            child = result.getOrCreateNode childLabel[0]
        child.dependencies.incl parent

func children(g: Graph, n: Node): seq[Node] =
    toSeq(g.values()).filter do (v: Node) -> bool: v.dependencies.contains(n)

func hasNoDeps(n: Node): bool = n.dependencies.len == 0

proc toposort(g: Graph): seq[Node] =
    var ready = toSeq(g.values).filter(hasNoDeps)

    while ready.len > 0:
        ready.sort(cmp, Descending)
        let n = ready.pop()
        result.add(n)
        for child in g.children(n):
            child.dependencies.excl n
            if hasNoDeps(child):
                ready.add child

# Part 1
echo parseInput().toposort().map(`$`).join("")

# Part 2
func timeRequired(n: Node): int = int(n.label) - 4

func isIdle(w: Worker): bool = w.timeRemaining == 0

func createWorkers(n: Natural): seq[Worker] =
    for i in 0..n:
        result.add(new(Worker))

proc decAllWorkers(workers: seq[Worker]): seq[Node] = 
    for w in workers:
        if w.timeRemaining == 1:
            w.timeRemaining = 0 
            result.add w.workingOn
            w.workingOn = nil
        elif w.timeRemaining > 1:
            dec w.timeRemaining

proc parallelBuild(g: Graph, workers: int): int = 
    var 
        ready, done: seq[Node]
        clock = 0
        workers = createWorkers(5)

    ready = toSeq(g.values).filter(hasNoDeps)

    while done.len < g.len:
        for justFinished in decAllWorkers(workers):
            done.add justFinished
            for child in children(g, justFinished):
                child.dependencies.excl justFinished
                if hasNoDeps(child):
                    ready.add child

        var idleWorkers = workers.filter(isIdle)
        ready.sort(cmp, Descending)
        while idleWorkers.len > 0 and ready.len > 0:
            let w = idleWorkers.pop()
            w.workingOn = ready.pop()
            w.timeRemaining = timeRequired w.workingOn

        inc clock

    return clock - 1

echo parseInput().parallelBuild(5)