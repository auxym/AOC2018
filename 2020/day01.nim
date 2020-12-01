import utils

let input = readFile("./input/day01_input.txt").getInts

func find2sum(nums: seq[int], sum: int): int =
    for i, a in nums.pairs:
        for b in nums[i+1 ..< nums.high]:
            if a + b == sum:
                return a * b

func find3sum(nums: seq[int], sum: int): int =
    for i, a in nums.pairs:
        for j in (i + 1) ..< (nums.high):
            let b = nums[j]
            if a + b >= sum:
                continue
            else:
                for c in nums[j + 1 ..< nums.high]:
                    if a + b + c == sum: return a * b * c

let part1ans = find2sum(input, 2020)
doAssert part1ans == 1014171
echo part1ans

let part2ans = find3sum(input, 2020)
doAssert part2ans == 46584630
echo part2ans