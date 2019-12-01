import strformat

const SERIAL = 7672

type
    CellGrid = array[1..300, array[1..300, int]]
    Coord = tuple[x, y: int]

func createGrid: CellGrid = 
    var
        rackId: int
        power: int

    for x in result.low .. result.high:
        for y in result.low .. result.high:
            rackId = x + 10
            power = (rackId*y + SERIAL) * rackId
            power = (power mod 1000) div 100
            power -= 5
            result[x][y] = power

func squarePower(grid: CellGrid, x, y, sz: int): int =
    for i in x .. (x + sz - 1):
        for j in y .. (y + sz - 1):
            result += grid[i][j]

func findMaxSquare(grid: CellGrid, sz: int): (Coord, int) =
    var maxPower = int.low

    for x in grid.low .. (grid.high - sz + 1):
        for y in grid.low .. (grid.high - sz + 1):
            let totalPow = grid.squarePower(x, y, sz)
            if totalPow > maxPower:
                maxPower = totalPow
                result = ((x, y), totalPow)

let grid = createGrid()
echo grid.findMaxSquare(3)[0]

var
    maxPower = int.low
    bestSize: int
    bestCoords: Coord

for size in 1..300:
    let (c, pow) = grid.findMaxSquare(size)
    if pow > maxPower:
        bestSize = size
        maxPower = pow
        bestCoords = c

echo fmt"{bestCoords.x:d}, {bestCoords.y:d}, {bestSize:d}"