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

# Part 1

var pt1count = 0
for pp in batch:
  if pp.isValid: inc pt1count
doAssert pt1count == 206
echo pt1count

# Part 2

type
  Validator = proc(s: string): bool {.noSideEffect.}
  VTable = TableRef[string, seq[Validator]]

func rangeCheckFactory(a, b: int): Validator =
  func check(s: string): bool =
    let x = parseInt(s)
    x >= a and x <= b
  check

func reMatchFactory(pat: static[string]): Validator =
  func c(s: string): bool =
    s.match(re((pat)))
  c

func validateHgt(hgt: string): bool =
  let pat = re"(\d\d\d?)(cm|in)"
  var m: RegexMatch
  if not hgt.match(pat, m):
    return false
  else:
    let unit: string = m.group(1, hgt)[0]
    let hgtInt: int = m.group(0, hgt)[0].parseInt
    var rng: (int, int)

    case unit:
    of "cm":
      rng = (150, 193)
    of "in":
      rng = (59, 76)

    return hgtInt >= rng[0] and hgtInt <= rng[1]

let validators = newTable[string, seq[Validator]]()

validators["byr"] = @[]
validators["byr"].add reMatchFactory(r"\d{4}")
validators["byr"].add rangeCheckFactory(1920, 2002)

validators["iyr"] = @[]
validators["iyr"].add reMatchFactory(r"\d{4}")
validators["iyr"].add rangeCheckFactory(2010, 2020)

validators["eyr"] = @[]
validators["eyr"].add reMatchFactory(r"\d{4}")
validators["eyr"].add rangeCheckFactory(2020, 2030)

validators["hcl"] = @[]
validators["hcl"].add reMatchFactory("#[0-9a-f]{6}")

validators["ecl"] = @[]
validators["ecl"].add reMatchFactory("(amb)|(blu)|(brn)|(gry)|(grn)|(hzl)|(oth)")

validators["pid"] = @[]
validators["pid"].add reMatchFactory(r"\d{9}")

validators["hgt"] = @[]
validators["hgt"].add validateHgt

func isValidpt2(pp: Passport, validators: VTable): bool =
  for f in passportFields:
    if f notin validators: continue
    for vl in validators[f]:
      if f notin pp or not vl(pp[f]):
        return false
  return true

var pt2count = 0
for pp in batch:
  if pp.isValidpt2(validators): inc pt2count
echo pt2count
doAssert pt2count == 123

# Test cases for part 2

let testInputInvalid = """
eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007
""".parseBatch

let testInputValid = """
pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
""".parseBatch

for pp in testInputInvalid:
  doAssert not pp.isValidpt2(validators)
for pp in testInputValid:
  doAssert pp.isValidpt2(validators)