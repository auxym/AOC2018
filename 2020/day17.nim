import arraymancer, utils, sequtils, strutils

type
  PocketGrid = Tensor[bool]

func getAt[T](t: Tensor[T], coords: Tensor[int]): T =
  assert t.rank == coords.shape[0]
  case t.rank:
  of 3:
    t[coords[0], coords[1], coords[2]]
  of 4:
    t[coords[0], coords[1], coords[2], coords[3]]
  else:
    raise newException(ValueError, "Unsupported rank " & $(t.rank))


proc putAt[T](t: var Tensor[T], coords: Tensor[int], val: T) =
  assert t.rank == coords.shape[0]
  case t.rank:
  of 3:
    t[coords[0], coords[1], coords[2]] = val
  of 4:
    t[coords[0], coords[1], coords[2], coords[3]] = val
  else:
    raise newException(ValueError, "Unsupported rank " & $(t.rank))


func initGrid(input: string, gridSize: int): PocketGrid =
  result = newTensor[bool]([gridSize, gridSize, gridSize])
  let
    inputLines = input.strip.splitLines
    inputSize = inputLines[0].len
    inputCenter = inputSize div 2
    gridCenter = gridSize div 2
    input2grid = @[1, 1, 0].toTensor() * (gridCenter - inputCenter) + @[0, 0, gridCenter].toTensor

  for (irow, line) in inputLines.pairs:
    for (icol, cr) in line.pairs:
      let gridCoords = @[irow, icol, 0].toTensor + input2grid
      result.putAt(gridCoords, (cr == '#'))


iterator getNeighborIndices(coords: Tensor[int]): Tensor[int] =
  for p in product(@[-1, 0, 1], coords.shape[0]):
    if not p.allIt(it == 0):
      yield p.toTensor + coords


func countActiveNeighbors(grid: PocketGrid, coords: Tensor[int]): Natural =
  for nidx in coords.getNeighborIndices:
    if toSeq(nidx).anyIt(it < 0 or it >= grid.shape[0]):
      continue # off-grid = inactive
    elif grid.getAt(nidx):
      inc result


func doCycle(grid: PocketGrid): PocketGrid =
  result = grid.clone()
  for (coords, cur) in grid.pairs:
    let
      ct = coords.toTensor
      an = grid.countActiveNeighbors(ct)
    let future =
      if cur and an in {2, 3}:
        true
      elif (not cur) and an == 3:
        true
      else:
        false
    result.putAt(ct, future)


func countActive(grid: PocketGrid): Natural =
  for x in grid:
    if x: inc result


proc showSlice(g: PocketGrid, z: int) =
  let za = z + g.shape[0] div 2
  echo "\nz = " & $z
  for row in g[_, _, za].axis(0):
    echo row.squeeze.mapIt(if it: "#" else: ".").join()


const input = """
##...#.#
#..##..#
..#.####
.#..#...
########
######.#
.####..#
.###.#..
"""

var pgrid = input.initGrid(20)
for i in 0..<6:
  pgrid = pgrid.doCycle
let pt1 = pgrid.countActive
echo pt1
doAssert pt1 == 295

# Part 2
# Not fast but it works...
# (about 40 seconds on my modest laptop with a release build)
func initGrid4d(input: string, gridSize: int): PocketGrid =
  result = newTensor[bool]([gridSize, gridSize, gridSize, gridSize])
  let
    inputLines = input.strip.splitLines
    inputSize = inputLines[0].len
    inputCenter = inputSize div 2
    gridCenter = gridSize div 2
    input2grid = @[1, 1, 0, 0].toTensor() * (gridCenter - inputCenter) + @[0, 0, gridCenter, gridCenter].toTensor

  for (irow, line) in inputLines.pairs:
    for (icol, cr) in line.pairs:
      let gridCoords = @[irow, icol, 0, 0].toTensor + input2grid
      result.putAt(gridCoords, (cr == '#'))

var pgrid2 = input.initGrid4d(20)
for i in 0..<6:
  pgrid2 = pgrid2.doCycle
let pt2 = pgrid2.countActive
echo pt2
doAssert pt2 == 1972
