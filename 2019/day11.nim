import utils, intcode, tables, sequtils, unicode

type
    Point2D = tuple[x, y: int]

    Robot = object
        loc: Point2D
        dir: Compass
        process: IntcodeProcess

func initRobot(program: IntcodeProgram, loc: Point2D): Robot =
    result.loc = loc
    result.process = initIntCode(program, 2048)
    result.dir = North

proc move(r: var Robot) =
    case r.dir:
    of North: r.loc = (r.loc.x, r.loc.y + 1)
    of East: r.loc = (r.loc.x + 1, r.loc.y)
    of South: r.loc = (r.loc.x, r.loc.y - 1)
    of West: r.loc = (r.loc.x - 1, r.loc.y)

let
    prog = readIntCodeProgram("./input/day11.txt")

func paintPanels(prog: IntcodeProgram, first: int8): TableRef[Point2D, int8] =
    var 
        panels = newTable[Point2D, int8](256)
        rbt = initRobot(prog, (0, 0))

    panels[(0, 0)] = first

    while rbt.process.getStatus() != icsHalted:
        let color = panels.getOrDefault(rbt.loc, 0)

        rbt.process.write(color)
        rbt.process.execute()

        let
            newColor = rbt.process.read()
            turnDir = rbt.process.read()

        panels[rbt.loc] = newColor.toInt64.int8
        rbt.dir = if turndir == 1: rbt.dir.cw else: rbt.dir.ccw

        rbt.move()

    result = panels

let pt1Panels = paintPanels(prog, 0)
doAssert pt1Panels.len == 2226
echo pt1Panels.len

let pt2Panels = paintPanels(prog, 1)

proc showPanels(panels: TableRef[Point2D, int8]) =
    var
        minX, minY = int.high
        maxX, maxY = int.low

    for pan in panels.keys:
        if pan.x < minX: minX = pan.x
        elif pan.x > maxX: maxX = pan.x
        if pan.y < minY: minY = pan.y
        elif pan.y > maxY: maxY = pan.y

    let
        xlen = maxX - minX
        ylen = maxY - minY

    for j in countdown(ylen, 0):
        var line = sequtils.repeat(" ".runeAt(0), xlen+1)
        for i in 0..xlen:
            let
                coord = (i + minX, j + minY)
                color = panels.getOrDefault(coord, 0)
            if color == 1: line[i] = "\u2588".runeAt(0)
        echo $line


showPanels pt2Panels