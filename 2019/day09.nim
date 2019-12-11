import intcode

let input = readIntCodeProgram("input/day09.txt")
echo "Read program of length " & $input.len

when false:
    block:
        let tcode = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99".getBigInts
        echo tcode
        echo runAndGetOutput(tcode, @[])

    block:
        let tcode = "1102,34915192,34915192,7,4,7,99,0".getBigInts
        let outp = runAndGetOutput(tcode, @[])
        echo outp
        echo ($outp[0]).len

    block:
        let tcode = "104,1125899906842624,99".getBigInts
        echo runAndGetOutput(tcode, @[])

let pt1out = runAndGetOutput(input, @[1])
echo pt1out