import regex, sequtils, strutils, algorithm

func getInts*(s: string): seq[int] =
    let expint = re"-?\d+"
    result = s.findAndCaptureAll(expint).map(parseInt)

func digits*(i: int): seq[int] =
    result = @[]
    var
        j = i
    while j > 0:
        result.add j mod 10
        j = j div 10
    result = result.reversed
