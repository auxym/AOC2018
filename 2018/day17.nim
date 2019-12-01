import strutils, strscans, sequtils

type
    Slice2D = tuple[xs, ys: Slice[int]]
    Point = tuple[x, y: int]
    Grid = seq[seq[char]]

proc `[]=`(g: var Grid, p: Point, v: char) =
    g[p.y][p.x] = v

func `[]`(g: Grid, p: Point): char =
    g[p.y][p.x]

proc initGrid(veins: seq[Slice2D]): Grid =
    var
        ul: Point = (int.high, int.high)
        lr: Point = (int.low, int.low)
    for sl in veins:
        if sl.xs.a < ul.x:
            ul.x = sl.xs.a
        if sl.xs.b > lr.x:
            lr.x = sl.xs.b
        if sl.ys.a < ul.y:
            ul.y = sl.ys.a
        if sl.ys.b > lr.y:
            lr.y = sl.ys.b

    ul = (ul.x - 10, ul.y)
    lr = (lr.x + 10, lr.y)

    let
        height = lr.y - ul.y + 1
        width = lr.x - ul.x + 1

    result = newSeqOfCap[seq[char]](height)
    for i in 0..<height:
        result.add newSeqWith(width, '.')

    for sl in veins:
        let
            rx = (sl.xs.a - ul.x) .. (sl.xs.b - ul.x)
            ry = (sl.ys.a - ul.y) .. (sl.ys.b - ul.y)
        for i in rx:
            for j in ry:
                result[j][i] = '#'

    let source: Point = (500-ul.x, 0)
    result[source] = '|'

proc readInput(fname: string): Grid =
    let
        input = readFile(fname).strip().splitLines()
    const
        scany = "x=$i, y=$i..$i"
        scanx = "y=$i, x=$i..$i"
    var
        x1, x2, y1, y2: int
        claylist: seq[Slice2D]

    for line in input:
        if scanf(line, scany, x1, y1, y2):
            claylist.add ((x1..x1), (y1..y2))
        elif scanf(line, scanx, y1, x1, x2):
            claylist.add ((x1..x2), (y1..y1))

    return initGrid(claylist)

proc show(g: Grid) =
    for line in g:
        echo line.join("")

func above(p: Point): Point = (p.x, p.y - 1)
func below(p: Point): Point = (p.x, p.y + 1)
func left(p: Point): Point = (p.x-1, p.y)
func right(p: Point): Point = (p.x+1, p.y)

func peekright(g: Grid, p: Point): char =
    if p.x == g[0].len:
        return '0'
    else:
        return g[p.right]

func peekleft(g: Grid, p: Point): char =
    if p.x == 0:
        return '0'
    else:
        return g[p.left]

func peekabove(g: Grid, p: Point): char =
    if p.y == 0:
        return '0'
    else:
        return g[p.above]

func peekbelow(g: Grid, p: Point): char =
    if p.y == g.len:
        return '0'
    else:
        return g[p.below]

proc isContainedLR(p: Point, g: Grid): bool =
    var c = p.right
    while c.x <= g[0].high and g[c] == '|':
        c = c.right
    result = g[c] == '#'

    c = p.left
    while c.x >= 0 and g[c] == '|':
        c = c.left
    result = result and (g[c] == '#')

proc isSupported(g: Grid, p:Point): bool =
    if p.y >= g.high:
        return false
    else:
        return g[p.below] in {'#', '~'}

proc flow(grid: var Grid): (int, int) =
    var
        stack = newSeqOfCap[Point](1024)
        cur: Point
        niter, totalCount, settleCount = 0

    for i, c in grid[0]:
        if c == '|':
            stack.add (i, 1)
            inc totalCount
            break

    while stack.len > 0 and niter < 100_000_000:
        let p = stack.pop()

        if p.x < 0 or p.y < 0 or
            p.x > grid[0].high or
            p.y > grid.high:
                continue

        let curtile = grid[p]

        if curtile == '.':
            if grid.peekabove(p) == '|' or
               (grid.isSupported(p.left) and grid.peekleft(p) == '|') or
               (grid.isSupported(p.right) and grid.peekright(p) == '|'):
                    grid[p] = '|'
                    inc totalCount
                    stack.add p
                    stack.add p.left
                    stack.add p.right
                    stack.add p.below

        elif curtile == '|':
            if grid.peekright(p) == '~' or grid.peekleft(p) == '~' or isContainedLR(p, grid):
                grid[p] = '~'
                inc settleCount
                stack.add p.above
                stack.add p.left
                stack.add p.right

        inc niter
    #echo niter
    return (totalCount, settleCount)

var grid = readInput("./day17_input.txt")
#grid.show()
echo grid.flow()
