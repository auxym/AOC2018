import sequtils

const smin = 382345
const smax = 843167

func reverse[T](s: seq[T]): seq[T] =
    result = newSeqUninitialized[T](s.len)
    var j = 0
    for i in countdown(s.high, s.low):
        result[j] = s[i]
        inc j

func digits(i: int): seq[int] =
    result = @[]
    var
        j = i
    while j > 0:
        result.add j mod 10
        j = j div 10
    result = result.reverse

func hasDouble(s: seq[int]): bool =
    result = false
    for i in 0..<s.high:
        if s[i] == s[i+1]:
            return true

func isMonotonic(s: seq[int]): bool =
    result = true
    for i in 0..<s.high:
        if s[i] > s[i+1]:
            #debugEcho s
            return false

func getAllRepeats(s: seq[int]): seq[seq[int]] =
    result = @[]
    var group: seq[int] = @[s[0]]
    for i in 1..s.high:
        if s[i] == group[0]:
            group.add s[i]
        else:
            if group.len > 1:
                result.add group
            group = @[s[i]]
    if group.len > 1:
        result.add group

var
    part1count = 0
    part2count = 0
    passwdGuess = smin
while passwdGuess <= smax:
    let
        dig = passwdGuess.digits
        part1crit = dig.hasDouble and dig.isMonotonic
    if part1crit:
        inc part1count
        if dig.getAllRepeats.any(proc(x: seq[int]): bool = x.len == 2):
            inc part2count
    inc passwdGuess

echo part1count
echo part2count
