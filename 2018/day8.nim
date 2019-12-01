import strUtils
import seqUtils

type
    Node = ref object
        children: seq[Node]
        metadata: seq[int]

let stream = readFile("day8_input.txt").strip().splitWhitespace().map(parseInt)

func readNode(stream: seq[int], pos: int) : (Node, int) =
    let
        numChildren = stream[pos]
        numMeta = stream[pos+1]

    let n = new(Node)
    var newPos =  pos + 1

    for i in 0..<numChildren:
        let readResult = readNode(stream, newPos+1)
        newPos = readResult[1]
        n.children.add readResult[0]

    for i in 0..<numMeta:
        inc newPos
        n.metadata.add stream[newPos]

    return (n, newPos)

func sumOfMeta(tree: Node): int =
    result += foldl(tree.metadata, a+b)
    for c in tree.children:
        result += sumOfMeta(c)

func valueOfNode(tree: Node): int =
    if tree.children.len == 0:
        result = tree.metadata.foldl(a+b)
    else:
        for m in tree.metadata:
            if m > 0 and m <= tree.children.len:
                result += valueOfNode(tree.children[m-1])

let tree = readNode(stream, 0)[0]
echo sumOfMeta(tree)
echo valueOfNode(tree)
