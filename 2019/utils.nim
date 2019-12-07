import regex, sequtils, strutils

func getInts*(s: string): seq[int] =
    let expint = re"-?\d+"
    result = s.findAndCaptureAll(expint).map(parseInt)

func reverse*[T](s: seq[T]): seq[T] =
    result = newSeqUninitialized[T](s.len)
    var j = 0
    for i in countdown(s.high, s.low):
        result[j] = s[i]
        inc j

func digits*(i: int): seq[int] =
    result = @[]
    var
        j = i
    while j > 0:
        result.add j mod 10
        j = j div 10
    result = result.reverse
