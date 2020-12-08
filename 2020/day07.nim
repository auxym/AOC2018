import strutils, utils, regex, strformat, sequtils

const inputExp = re"""(?x)
  (?P<outerColor>[[:alpha:]]+\ [[:alpha:]]+)
  \ bags?\ contain
  \ (?:
    (\d+)\ ([[:alpha:]]+\ [[:alpha:]]+)\ bags?
      (?:,\ (\d+)\ ([[:alpha:]]+\ [[:alpha:]]+)\ bags?)*
    |no\ other\ bags)\.
  """

func parseInput(text: string): WeightedAdjList[string] =
  result = newWeightedAdjList[string]()
  var m: RegexMatch

  for line in text.strip.splitLines:
    assert line.match(inputExp, m)

    assert m.group("outerColor").len == 1
    let outerColor = m.group("outerColor", line)[0]
    assert outerColor notin result
    result.addnode(outerColor)

    for (n, col) in zip(m.group(1, line), m.group(2, line)):
      result.addEdge(outerColor, col, n.parseInt)
    for (n, col) in zip(m.group(3, line), m.group(4, line)):
      result.addEdge(outerColor, col, n.parseInt)

let allRules = parseInput(readFile("input/day07_input.txt"))
const ourBag = "shiny gold"

var pt1count = 0
for outer in allRules.keys:
  if outer == ourBag: continue
  for visited in allRules.traverseDfs(outer):
    if visited.elem == ourBag:
      inc pt1count
      break
echo pt1count
doAssert pt1count == 287

let testRules = """
light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.
mirrored magenta bags contain 4 shiny turquoise bags, 2 bright gold bags, 4 plaid fuchsia bags, 4 wavy lime bags.
""".parseInput

proc echoParsedInput(g: WeightedAdjList[string]) =
  for (outerbag, edgeTable) in g.pairs:
    var contains = ""
    for (incol, n) in edgeTable.pairs:
      contains = contains & fmt"{n} {incol}, "
    echo fmt"{outerbag}: {contains}"

#echoParsedInput testRules