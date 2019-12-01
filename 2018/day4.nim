import times
import strUtils
import regex
import strscans
import seqUtils
import algorithm
import tables

type
    Action = enum FallAsleep, WakeUp, BeginShift
    Record = tuple[time: DateTime, guardId: int, action: Action]
    MinuteArray = array[60, int]

proc parseInput(line: string): Record =
    let pat = re"\[([^\]]+)\] (falls asleep|wakes up|Guard #\d+ begins shift)"
    var mtc: RegexMatch
    assert match(line.strip, pat, mtc)

    let rtime: DateTime = parse(line[mtc.group(0)[0]], "yyyy-MM-dd HH:mm")

    let actionStr = line[mtc.group(1)[0]]
    var guardId: int = -1
    var action: Action = BeginShift

    if actionStr == "falls asleep":
        action = FallAsleep
    elif actionStr == "wakes up":
        action = WakeUp
    elif scanf(actionStr, "Guard #$i begins shift", guardId):
        action = BeginShift
    else:
        raise newException(ValueError, "Could not parse action " & actionStr)
    
    result = (rtime, guardId, action)

func cmp(a, b: Record): int =
    if a.time == b.time:
        return 0
    elif a.time < b.time:
        return -1
    else:
        return 1

proc processRecords(sortedRecords: seq[Record]): Table[int, MinuteArray] =
    result = initTable[int, MinuteArray](64)

    proc addSleep(arr: var MinuteArray, begin, wake: DateTime) =
        for i in begin.minute..<wake.minute:
            inc arr[i]

    var guardOnDuty = -1
    var fellAsleepAt: DateTime = now()
    for entry in sortedRecords:
        case entry.action:
            of BeginShift:
                guardOnDuty = entry.guardId
            of FallAsleep:
                fellAsleepAt = entry.time
            of WakeUp:
                if not result.contains(guardOnDuty):
                    var a: MinuteArray
                    result.add guardOnDuty, a
                addSleep(result[guardOnDuty], fellAsleepAt, entry.time)

func keymax[A, B](key: proc(x: A): B, arr: openArray[A]): A =
    var 
        maxval = key(arr[arr.low])
        idx = 0
        fv: B
    for i, v in arr:
        fv = key(v)
        if fv > maxval:
            maxval = fv
            idx = i
    result = arr[idx]

func argmax[T](arr: openArray[T]): int =
    let p = toSeq arr.pairs
    func getval(x: tuple[key:int, val:T]): T = x[1]
    result = keymax(getval, p).key

var rawinput = readFile("./day4_input.txt").strip().splitLines()
var input = rawinput.map(parseInput)
sort(input, cmp)

let guardSleepTotals = processRecords input

# Part 1
func findMostAsleep(guardTotals: Table[int, MinuteArray]): int =
    func sumSleep(id: int): int = foldl(guardTotals[id], a+b)
    return keymax(sumSleep, toSeq(guardTotals.keys))

let sleepiestGuard = findMostAsleep guardSleepTotals
let sleepiestMinute = guardSleepTotals[sleepiestGuard].argmax
echo "Part 1: Guard ", sleepiestGuard, ", Minute ", sleepiestMinute, ": ", sleepiestGuard*sleepiestMinute

# Part 2
func findMaxAsleep(guardTotals: Table[int, MinuteArray]): int =
    func maxSleep(id: int): int = max(guardTotals[id])
    return keymax(maxSleep, toSeq(guardTotals.keys))
let p2SleepiestGuard = findMaxAsleep guardSleepTotals
let p2SleepiestMinute = guardSleepTotals[p2SleepiestGuard].argmax
echo "Part 2: Guard ", p2SleepiestGuard, ", Minute ", p2SleepiestMinute, ": ", p2SleepiestGuard*p2SleepiestMinute
