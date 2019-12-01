import strscans, strUtils, intsets

const ARRAY_SIZE = 1024
type
    PlantArray = ref object
        pots : array[-ARRAY_SIZE..ARRAY_SIZE, bool]
        bounds: Bounds
    RuleInput = range[0..31]
    Bounds = tuple[a, b: int]

proc parseInput: (PlantArray, IntSet) =
    let inputLines = readFile("./day12_input.txt").strip().splitLines()

    let initStateString = inputLines[0].split(": ")[^1].strip()

    var plants = new PlantArray
    plants.bounds = (0, initStateString.high)
    for i, c in initStateString:
        if c == '#':
            plants.pots[i] = true

    var growRules = initIntSet()
    for line in inputLines[2..inputLines.high]:
        let parts = line.split(" => ")
        var inp: RuleInput
        for i in 0..4:
            if parts[0][i] == '#':
                inp = inp or (1 shl (4-i))
        assert not growRules.contains(inp)
        if parts[1][0] == '#':
            growRules.incl inp

    result = (plants, growRules)

proc advance(plants: PlantArray, rules: IntSet): PlantArray =
    result = new PlantArray
    result.bounds = plants.bounds

    if result.bounds.a - 4 < result.pots.low or result.bounds.b + 4 > result.pots.high:
        raise newException(ResourceExhaustedError, "")

    var
        neighborCode: RuleInput = 0
        curPlant: bool

    for j in 0..3:
        if plants.pots[plants.bounds.a - 4 + j]:
            neighborCode = neighborCode or (1 shl j)

    for i in (plants.bounds.a) .. (plants.bounds.b + 4):
        neighborCode = (neighborCode shl 1) and 31
        if plants.pots[i]:
            neighborCode = neighborCode + 1

        curPlant = rules.contains neighborCode
        result.pots[i-2] = curPlant
        
        if curPlant:
            if i-2 < result.bounds.a:
                result.bounds.a = i-2
            elif i-2 > result.bounds.b:
                result.bounds.b = i-2

func score(plants: PlantArray): (int64, int64) =
    for i in plants.pots.low .. plants.pots.high:
        if plants.pots[i]:
            result[0] += i
            result[1] += 1

let (initial, rules) = parseInput()
var newPlants = deepCopy(initial)

for i in 1..20:
    newPlants = newPlants.advance(rules)
echo newPlants.score[0]

const PT2GENS = 50_000_000_000
newPlants = deepCopy(initial)
var
    curScore, curPlants, previousScore, previousPlants: int64
for i in 1..PT2GENS:
    newPlants = newPlants.advance(rules)
    (curScore, curPlants) = newPlants.score
    if curPlants == previousPlants and curScore == previousScore + curPlants:
        curScore = curScore + (PT2GENS - i)*curPlants
        echo "Stop at gen ", i
        break
    previousPlants = curPlants
    previousScore = curScore
echo curScore
