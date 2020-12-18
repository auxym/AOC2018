import arraymancer, utils, sequtils, strutils

type
  PocketGrid = Tensor[bool]

func getAt[T](t: Tensor[T], coords: Tensor[int]): T =
  if toSeq(coords).anyIt(it < 0):
    raise newException(ValueError, "Invalid negative coord")
  t[coords[0], coords[1], coords[2]]


proc putAt[T](t: var Tensor[T], coords: Tensor[int], val: T) =
  if toSeq(coords).anyIt(it < 0):
    raise newException(ValueError, "Invalid negative coord")
  t[coords[0], coords[1], coords[2]] = val


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
    let an = grid.countActiveNeighbors(coords.toTensor)
    #debugEcho an
    let future =
      if cur and an in {2, 3}:
        true
      elif (not cur) and an == 3:
        true
      else:
        false
    result.putAt(coords.toTensor, future)


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