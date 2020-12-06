import regex, sequtils, strutils, terminal, utils

proc groupAnswersToSet(groupAnswers: string): set[char] =
  groupAnswers.replace("\n", "").toBitSet

let allGroups = readFile("./input/day06_input.txt").strip.split(re"\n{2}")

# Part 1
let pt1sum = allGroups.mapIt(groupAnswersToSet(it).card).foldl(a+b)
echo pt1sum
doAssert pt1sum == 6885

# Part 2
func personAnsToSets(groupAnwers: string): seq[set[char]] =
  result = groupAnwers.splitLines.map(toBitSet)

func intersectSets[T](sets: seq[set[T]]): set[T] =
  sets.foldl(a*b)

let pt2count = allGroups
  .map(personAnsToSets)
  .mapIt(intersectSets(it).card)
  .foldl(a+b)
echo pt2count
doAssert pt2count == 3550

# Debugging stuff

let testGroups = """
abc

a
b
c

ab
ac

a
a
a
a

b
""".strip.split(re"\n{2}")

proc debugPrint(groups: seq[string]) =
  var sm = 0
  for g in groups:
    echo " "
    let commonSet = g.personAnsToSets.intersectSets
    echo $commonSet & " " & $(commonSet.card)
    for pp in g.splitLines:
      for c in pp:
        if c in commonSet: stdout.setForegroundColor(fgGreen)
        stdout.write(c)
        stdout.resetAttributes
      stdout.write("\n")
    echo ""
  echo sm

#debugPrint(allGroups)