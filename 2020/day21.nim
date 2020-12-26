import regex, strutils, tables, sets, sequtils, utils, algorithm

type MenuEntry = object
  ingredients: HashSet[string]
  allergens: HashSet[string]

func parseInput(text: string): seq[MenuEntry] =
  var m: RegexMatch
  for line in text.strip.splitLines:
    doAssert line.match(re"(?:(\w+) )+\(contains (?:(\w+), )*(\w+)\)", m)
    var entry: MenuEntry
    entry.ingredients = m.group(0, line).toHashSet
    entry.allergens = (m.group(1, line) & m.group(2, line)).toHashSet
    result.add entry

func identifyAllergens(menu: seq[MenuEntry]): Table[string, string] =
  var
    foundStack: seq[string]
    inters: Table[string, HashSet[string]]
  for entry in menu:
    let ings = entry.ingredients
    for aller in entry.allergens:
      inters[aller] = if aller notin inters: ings else: inters[aller] * ings

      if inters[aller].len == 1:
        foundStack.add inters[aller].peek

  while foundStack.len > 0:
    let cur = foundStack.pop
    for aller, ings in inters.mpairs:
      if not ings.missingOrExcl(cur):
        if ings.len == 0:
          result[aller] = cur
        if ings.len == 1:
          foundStack.add ings.peek

func findAllergenFree(menu: seq[MenuEntry]): HashSet[string] =
  let
    allIngredients = menu.mapIt(it.ingredients).foldl(a+b)
    allergenMap = menu.identifyAllergens
    ingredWithAllerg = toSeq(allergenMap.values).toHashSet
  return allIngredients - ingredWithAllerg

let
  menu = readFile("./input/day21_input.txt").parseInput
  ingsNoAllerg = menu.findAllergenFree

let pt1 = block:
  var count = 0
  for ingr in ingsNoAllerg:
    count.inc menu.countIt(ingr in it.ingredients)
  count
echo pt1
doAssert pt1 == 2428

# Part 2
let
  allergenMap = menu.identifyAllergens
  pt2 = toSeq(allergenMap.keys).sorted.mapIt(allergenMap[it]).join(",")
echo pt2
doAssert pt2 == "bjq,jznhvh,klplr,dtvhzt,sbzd,tlgjzx,ctmbr,kqms"
