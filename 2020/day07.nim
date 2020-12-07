import strutils, utils, regex, strformat, sequtils, sets

const inputExp = re"""(?x)
  (?P<outerColor>[[:alpha:]]+\ [[:alpha:]]+)
  \ bags?\ contain
  \ (?:
    (\d+)\ ([[:alpha:]]+\ [[:alpha:]]+)\ bags?
      (?:,\ (\d+)\ ([[:alpha:]]+\ [[:alpha:]]+)\ bags?)*
    |no\ other\ bags)\.
  """

func parseInput(text: string): AdjList[string] =
  result = newAdjList[string]()
  var m: RegexMatch

  for line in text.strip.splitLines:
    assert line.match(inputExp, m)

    assert m.group("outerColor").len == 1
    let outerColor = m.group("outerColor", line)[0]
    assert outerColor notin result

    var innerBags: HashSet[string]
    for col in m.group(2, line) & m.group(4, line):
      innerBags.incl col

    result[outerColor] = innerBags
    #echo fmt"{outerColor}: {$innerColors}"

let allRules = parseInput(readFile("input/day07_input.txt"))

var pt1count = 0
for outer in allRules.keys:
  let path = allRules.dfs(outer, "shiny gold")
  if path.len >= 2: inc pt1count
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
""".parseInput

proc echoParsedInput(g: AdjList[string]) =
  for (outerbag, inner) in g.pairs:
    echo fmt"{outerbag}: {inner}"

#echoParsedInput testRules