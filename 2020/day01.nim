import utils, intsets

let input = readFile("./input/day01_input.txt").getInts.toIntSet

func find2sum(nums: IntSet, sum: int): int =
    for a in nums:
        if a * 2 == sum:
            continue
        if nums.contains(sum - a):
            return(a * (sum - a))

func find3sum(nums: IntSet, sum: int): int =
    for a in nums:
        for b in nums:
            if a == b: continue

            let c = sum - a - b
            if c == a or c == b: continue

            if nums.contains(c):
                return a * b * c

let part1ans = find2sum(input, 2020)
doAssert part1ans == 1014171
echo part1ans

let part2ans = find3sum(input, 2020)
doAssert part2ans == 46584630
echo part2ans