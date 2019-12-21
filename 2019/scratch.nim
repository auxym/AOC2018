import bigints

let a = initBigInt(-4567827638765)
echo a.limbs

var b: int64 = 0
b = a.limbs[0].int64
b = b or (a.limbs[1].int64 shl 32)

b = not b + 1

echo a
echo b