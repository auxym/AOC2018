import strutils, strformat

const INPUT = 880751

var recipes = newSeqOfCap[int8](1 shl 25)
recipes.add 3
recipes.add 7

var
    elf1 = 0
    elf2 = 1

func combine(a, b: int8): seq[int8] =
    let sum = a + b
    if sum > 9:
        result.add(sum div 10)
    result.add(sum mod 10)

proc show(r: seq[int8], e1, e2: int) =
    var line = ""
    for i, elem in r:
        if i == e1:
            line.add fmt" ({r[i]:d})"
        elif i == e2:
            line.add fmt" [{r[i]:d}]"
        else:
            line.add fmt"  {r[i]:d} "
    echo line

func toDigits(i: int): seq[int8] =
    var j = i
    while j != 0:
        result.insert cast[int8](j mod 10)
        j = j div 10

var 
    part1: string
    part2: int
let input_digits = toDigits INPUT
while part1 == "" or part2 == 0:
    for r in combine(recipes[elf1], recipes[elf2]):
        recipes.add r

        # part 2
        let mostRecent = recipes[recipes.len-input_digits.len .. recipes.high]
        if mostRecent == input_digits:
            part2 = recipes.len - input_digits.len
            echo part2
    
    elf1 = (elf1 + 1 + recipes[elf1]) mod recipes.len
    elf2 = (elf2 + 1 + recipes[elf2]) mod recipes.len

    # part 1
    if (part1 == "") and (recipes.len >= INPUT + 10):
        part1 = recipes[INPUT..<INPUT+10].join("")
        echo part1
