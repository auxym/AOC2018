import strutils, algorithm, options, sequtils

type
    Grid = array[150, array[150, char]]
    Direction = enum north, east, south, west
    IntersectionOption = enum left, straight, right
    Cart = ref object
        x, y: int
        facing: Direction
        nextTurn: IntersectionOption
        isDead: bool
    Collision = tuple[a, b: Cart]

func newCart(x, y: int, facing: Direction): Cart =
    result = new Cart
    result.x = x
    result.y = y
    result.facing = facing
    result.nextTurn = left
    result.isDead = false

var
    g: Grid
    carts: seq[Cart]
    x, y: int

for line in readFile("./day13_input.txt").splitLines():
    x = 0
    for c in line:
        case c:
            of '-', '|', '/', '\\', '+':
                g[x][y] = c
            of '>':
                g[x][y] = '-'
                carts.add newCart(x, y, east)
            of '<':
                g[x][y] = '-'
                carts.add newCart(x, y, west)
            of 'v':
                g[x][y] = '|'
                carts.add newCart(x, y, south)
            of '^':
                g[x][y] = '|'
                carts.add newCart(x, y, north)
            of ' ':
                g[x][y] = ' '
            else:
                raise newException(ValueError, "Unexpected char "&c)
        inc x
    inc y

func cmp(a,b: Cart): int =
    result = cmp(a.y, b.y)
    if result == 0:
        result = cmp(a.x, b.x)

func filterDead(carts: seq[Cart]): seq[Cart] =
    carts.filterIt(not it.isDead)

proc tickCart(cart: var Cart, tile: char) =
    case tile:
        of '/':
            case cart.facing:
                of north:
                    cart.facing = east
                of south:
                    cart.facing = west
                of east:
                    cart.facing = north
                of west:
                    cart.facing = south
        of '\\':
            case cart.facing:
                of north:
                    cart.facing = west
                of south:
                    cart.facing = east
                of east:
                    cart.facing = south
                of west:
                    cart.facing = north
        of '+':
            case cart.nextTurn:
                of left:
                    if cart.facing == north:
                        cart.facing = west
                    else:
                        dec cart.facing
                    cart.nextTurn = straight
                of straight:
                    cart.nextTurn = right
                of right:
                    if cart.facing == west:
                        cart.facing = north
                    else:
                        inc cart.facing
                    cart.nextTurn = left
        else:
            discard
    case cart.facing:
        of north:
            cart.y -= 1
        of east:
            cart.x += 1
        of south:
            cart.y += 1
        of west:
            cart.x -= 1

func checkCollision(carts: seq[Cart]): Option[Collision] =
    result = none(Collision)
    let activeCarts = carts.filterDead()
    for i, cart1 in activeCarts[activeCarts.low..<activeCarts.high]:
        for cart2 in activeCarts[i+1..activeCarts.high]:
            if cart1.x == cart2.x and cart1.y == cart2.y:
                cart1.isDead = true
                cart2.isDead = true
                return (cart1, cart2).some

proc showCarts(g: Grid, carts: seq[Cart]) =
    var lines = newSeqOfCap[string](g.len)
    for y in g.low..g.high:
        var line = ""
        for x in g.low..g.high:
            line = line & g[x][y]
        lines.add(line)
    
    for c in carts.filterDead():
        var cartChr: char
        case c.facing:
            of north:
                cartChr = '^'
            of east:
                cartChr = '>'
            of south:
                cartChr = 'v'
            of west:
                cartChr = '<'
        lines[c.y][c.x] = cartChr
    
    for line in lines:
        echo line

while carts.filterDead().len > 1:
    #showCarts(g, carts)
    carts.sort(cmp)
    for i in carts.low..carts.high:
        var cart = carts[i]
        let tile = g[cart.x][cart.y]

        if cart.isDead:
            continue

        cart.tickCart(tile)
        let collision = checkCollision(carts)
        try:
            let colliders = collision.get()
            echo "Collision ", colliders.a.x, ",", colliders.a.y 
            echo carts.filterDead().len
        except UnpackError:
            discard

let lastCart = carts.filterDead()[0]
echo "Last cart: ", lastCart.x, ",", lastCart.y