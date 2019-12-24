import sequtils, strutils, utils, strformat
from math import sum

type
    Vector3D[T: SomeNumber] = tuple[x, y, z: T]
    Moon = object
        id: int
        position: Vector3D[int]
        velocity: Vector3D[int]

func parseInput(s: string): seq[Moon] =
    result = @[]
    var i = 0
    for ln in s.strip.splitLines:
        var m: Moon
        let ints = ln.getInts
        m.position = (ints[0], ints[1], ints[2])
        m.velocity = (0, 0, 0)
        m.id = i
        result.add m
        inc i

func toSeq[T](v: Vector3D[T]): seq[T] =
    @[v.x, v.y, v.z]

func applygravity(on: Moon, other: Moon): Moon =
    result = on
    if on.position.x < other.position.x: inc result.velocity.x
    if on.position.x > other.position.x: dec result.velocity.x
    if on.position.y < other.position.y: inc result.velocity.y
    if on.position.y > other.position.y: dec result.velocity.y
    if on.position.z < other.position.z: inc result.velocity.z
    if on.position.z > other.position.z: dec result.velocity.z

func applyvelocity(m: Moon): Moon =
    result = m
    result.position.x += result.velocity.x
    result.position.y += result.velocity.y
    result.position.z += result.velocity.z

func step(moons: seq[Moon]): seq[Moon] =
    result = @[]
    for m in moons:
        var rep = m
        for other in moons:
            if rep.id == other.id: continue
            rep = applygravity(rep, other)
        result.add rep
    result = result.map(applyvelocity)

func potentialenergy(m: Moon): int =
    toSeq(m.position).mapIt(abs(it)).sum()

func kineticenergy(m: Moon): int =
    toSeq(m.velocity).mapIt(abs(it)).sum()

func totalenergy(m: Moon): int =
    m.potentialenergy * m.kineticenergy

func totalenergy(moons: seq[Moon]): int =
    moons.map(totalenergy).sum()

let moonlist = """
<x=-6, y=-5, z=-8>
<x=0, y=-3, z=-13>
<x=-15, y=10, z=-11>
<x=-3, y=-8, z=3>
""".parseInput

let testMoons = """
<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>
""".parseInput

var future = moonlist
for i in 1..1000:
    future = future.step()
    echo fmt"After {i} steps"
    for m in future:
        echo m
    echo fmt"Total energy: {future.totalenergy}"
