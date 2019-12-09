import strutils, arraymancer, sequtils

type DsnImage = Tensor[uint8]

func decodeImage(s: string): DsnImage =
    let
        irows = 6
        icols = 25
        numlayers = s.len div (irows * icols)
    result = toSeq(s)
        .mapIt(parseUInt($it).uint8)
        .toTensor
        .reshape(numlayers, irows, icols)
        .permute(1, 2, 0)

let input = readFile("input/day08.txt").strip.decodeImage

func oneIfEqualFactory[T](x: T): proc(a: T): int =
    func f(a: T): int =
        if a == x: 1 else: 0
    result = f

func argmin[T: SomeNumber](s: openArray[T]): int =
    var minval = s[0]
    result = 0
    for (i, e) in s.pairs:
        if e < minval:
            minval = e
            result = i

func checksum(img: DsnImage): int =
    let zeroCounts = toSeq(img.map(oneIfEqualFactory(0'u8)).axis(2)).map(sum)
    let layIdxMinZeros = zeroCounts.argmin
    let
        layer = img[_, _, layIdxMinZeros].reshape(img.shape[0]*img.shape[1])
        countOnes = layer.map(oneIfEqualFactory(1'u8)).sum
        countTwos = layer.map(oneIfEqualFactory(2'u8)).sum
    result = countOnes * countTwos

echo input.checksum

func flatten(img: DsnImage): DsnImage =
    doAssert img.rank == 3
    func combinePixels(a, b: uint8): uint8 =
        if a == 2: b else: a
    func combineLayers(a, b: DsnImage): DsnImage = 
        a.map2(combinePixels, b)
    let init = newTensorWith[uint8](img.shape[0], img.shape[1], 1, 2'u8)
    result = img.fold(init, combineLayers, 2)[_,_,0]

proc show(img: DsnImage) =
    const blk = "█"
    func toDisplayChar(a: uint8): string =
        if a == 1'u8: blk else: " "
    for row in img.axis(0):
        echo toSeq(row).map(toDisplayChar).join

let flattened = input.flatten
flattened.show