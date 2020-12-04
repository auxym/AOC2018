import strutils, tables, regex

type Passport = TableRef[string, string]

const passportFields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid"]

func parseBatch(text: string): seq[Passport] =
  let text = text.strip.replace(re"\n(\n*)", " $1") # 1 passport per line
  var m: RegexMatch
  for line in text.splitLines:
    let pp = newTable[string, string](passportFields.len)
    for k in passportFields:
      if line.find(re(k & r":([^ \n]+)"), m):
        pp[k] = m.group(0, line)[0]
    result.add pp

func isValid(p: Passport): bool =
  for f in passportFields:
    if f == "cid": continue
    if f notin p:
      return false
  return true

let batch = parseBatch(readFile("./input/day04_input.txt"))

var pt1count = 0
for pp in batch:
  if pp.isValid: inc pt1count
echo pt1count