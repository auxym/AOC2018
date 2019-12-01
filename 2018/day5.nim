import strUtils
import seqUtils
import regex

let input = readFile("./day5_input.txt").strip()

func switchCase(c: char): char =
    if isLowerAscii(c): return c.toUpperAscii
    else: return c.toLowerAscii

func react(chain: string): string =
    for c in chain:
        if result.len > 0 and c == switchCase(result[result.high]):
            result.delete result.high, result.high
        else:
            result.add c

let part1 = react(input)
echo part1.len

var part2 = part1
for poly in {'a'..'z'}:
    let pat = toPattern("(?i:" & poly & ")")
    let trial = react(replace(input, pat, ""))
    if trial.len < part2.len: part2 = trial

echo part2.len