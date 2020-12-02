import regex, strutils, sequtils, strformat

type PasswEntry = object
    chr: char
    hi: Natural
    lo: Natural
    password: string

func parseInputLine(line: string): PasswEntry =
    const exp_entry = re"(\d+)-(\d+) ([a-z]): ([a-z]+)"
    var m: RegexMatch
    let found = line.match(exp_entry, m)
    doAssert found == true

    let pol_lo: int = m.group(0, line)[0].parseInt
    let pol_hi: int = m.group(1, line)[0].parseInt
    let polchar: char = m.group(2, line)[0][0]
    let passw: string = m.group(3, line)[0]

    return PasswEntry(chr: polchar, lo: pol_lo, hi: pol_hi, password: passw)

func parseInput(text: string): seq[PasswEntry] =
    text.strip.splitLines.map(parseInputLine)

func checkPassword(p: PasswEntry): bool =
    let chrCount = p.password.count(p.chr)
    chrCount >= p.lo and chrCount <= p.hi

func checkPasswordPart2(p: PasswEntry): bool =
    var included: int = 0
    for i in @[p.lo, p.hi]:
        if p.password.high < i - 1:
            continue
        else:
            if p.password[i - 1] == p.chr:
                inc included
    included == 1

proc checkAll(entries: seq[PasswEntry]) =
    var validCount1 = 0
    var validCount2 = 0
    for e in entries:
        if checkPassword(e): inc validCount1
        if checkPasswordPart2(e): inc validCount2

    doAssert validCount1 == 538
    echo validCount1
    echo validCount2

echo "1-3 a: abcde".parseInputLine.checkPasswordPart2
echo "1-3 b: cdefg".parseInputLine.checkPasswordPart2
echo "2-9 c: ccccccccc".parseInputLine.checkPasswordPart2

let input = readFile("./input/day02_input.txt").parseInput
checkAll(input)