import regex, sequtils

proc groupAnswersToSet(groupAnswers: string): set[char] =
  for c in groupAnswers:
    if c == '\n': continue
    result.incl c

let allGroups = readFile("./input/day06_input.txt")
  .split(re"\n{2}")

# Part 1
echo allGroups.mapIt(groupAnswersToSet(it).len).foldl(a+b)