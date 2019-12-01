import tables
import strutils
import sequtils

let input = readFile("./day2_input.txt").strip.splitLines

type FrequencyTable = Table[char, Natural]

func countFreqs(s: string): FrequencyTable  =
    var freqs = initTable[char, Natural](32)
    for c in s:
        if not freqs.contains(c):
            freqs[c] = s.count(c)

    return freqs

func containsValue[A, B](t: Table[A, B], v: B) : bool =
    for e in t.values:
        if e == v: return true
    return false

func checkSum(labels: openArray[string]): uint =
    var
        count2 = 0'u
        count3 = 0'u
    for freqs in labels.map(countFreqs):
        if freqs.containsValue(2): inc count2
        if freqs.containsValue(3): inc count3
    return count2*count3

func isSingleCharDifference(a, b: string): int =
    result = -1
    for pos, pair in zip(a, b):
        if pair[0] != pair[1]:
            if result >= 0: 
                # Previously found a difference, so more than 1 difference
                return -1
            result = pos

for idx, label in input:
    for other in input[idx+1..input.high]:
        let pos = isSingleCharDifference(label, other)
        if pos >= 0:
            echo label
            echo other
            echo repeat(' ', pos), "^ ", pos


echo "Checksum: ", checkSum(input)