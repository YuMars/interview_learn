//
//  main.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/3/27.
//

import Foundation

// 704
var nums = [-1,0,3,5,9,12] //[-1,0,3,5,9,12]
var target = 9
var index: Int = BinarySearch.search2(nums, target)
print("BinarySearch:" + "\(index)")

// 35
nums = [1,3,5,6]
target = 0
index = SearchInsertPosition.searchInsert(nums, target)
print("SearchInsertPosition:" + "\(index)")

nums = [3,2,2,3]
target = 3
index = RemoveElement.removeElement1(&nums, target)
print("RemoveElement" + "\(index)")

//nums = [0,0,1,1,1,2,2,3,3,4]
nums = [-50,-49,-47,-46,-46,-45,-45,-44,-42,-41,-41,-40,-38,-37,-37,-36,-35,-35,-35,-34,-34,-34,-33,-33,-33,-33,-32,-31,-29,-29,-29,-28,-27,-27,-27,-26,-26,-25,-25,-25,-24,-24,-24,-23,-23,-22,-21,-21,-20,-20,-19,-19,-19,-19,-18,-17,-16,-16,-15,-15,-15,-13,-13,-12,-12,-12,-12,-10,-10,-9,-7,-7,-7,-6,-6,-6,-5,-5,-5,-2,-1,0,0,3,3,4,5,6,8,9,10,10,10,10,12,13,13,16,16,16,17,18,19,19,19,20,22,22,22,23,24,24,25,25,25,27,27,27,27,29,29,31,31,32,34,34,35,36,36,36,36,36,37,38,39,39,40,41,41,42,43,43,43,43,43,44,44,45,45,47,47,47,47,48,48,49]
index = RemoveDuplicates.removeDuplicates(&nums);
print("RemoveDuplicates" + "\(index)")

let string1 = "a#c"
let string2 = "b"
print("BackspaceStringCompare", BackspaceStringCompare.backspaceCompare(string1, string2))

nums = [-4,-1,0,3,10]
print("SquareOfASortArray", SquareOfASortArray.sortedSquares1(nums))

nums = [2,3,1,2,4,3]
target = 7
print("MinimumSizeSubarraySum", MinimumSizeSubarraySum.minSubArrayLen1(target, nums))

nums =  [0,1,2,2]
print("FruitIntoBaskets", FruitIntoBaskets.totalFruit(nums))

print("SpiralMatrix2", SpiralMatrix2.generateMatrix(6))

let linkList = MyLinkedList()
print("MyLinkedList", linkList.addAtHead(1), linkList.addAtTail(3), linkList.addAtIndex(1, 2), linkList.get(1), linkList.deleteAtIndex(0), linkList.get(0))

let head = MyLinkedList()
head.addAtTail(1)
head.addAtTail(2)
head.addAtTail(3)
head.addAtTail(4)
head.addAtTail(5)
head.addAtTail(6)
print("SwapNodesInPairs", (SwapNodesInPairs.swapPairs(head.head)?.val) as Any)

let head2 = MyLinkedList()
head2.addAtTail(1)
head2.addAtTail(2)
//head2.addAtTail(3)
//head2.addAtTail(4)
//head2.addAtTail(5)
//head2.addAtTail(6)
print("RemoveNthNodeFromEndofList", (RemoveNthNodeFromEndofList.removeNthFromEnd(head2.head, 1))?.val as Any)

let head3 = MyLinkedList()
head3.addAtTail(3)
head3.addAtTail(2)
head3.addAtTail(0)
head3.addAtTail(-4)
head3.head?.next?.next?.next = head3.head?.next
print("LinkedListCycle", LinkedListCycle.detectCycle(head3.head)?.val as Any)

let s:String = "anagram"
let t:String = "nagaram"
print("ValidAnagram", ValidAnagram.isAnagram2(s, t))


print("HappyNum", HappyNum.isHappy(19))

nums = [3,2,4]
target = 6
print("TwoSum", TwoSum.twoSum2(nums, target))

print("RansomNote", RansomNote.canConstruct2("aa", "ab"))

print("ThreeSum", ThreeSum.threeSum([-4,2,1]))

print("ReplaceSpace", ReplaceSpace.replaceSpace("We are happy."))

print("ReverseWordsInAString", ReverseWordsInAString.reverseWords("the sky is blue"))

print("LeftRotateString",LeftRotateString.reverseLeftWords("abcdefg", 2))

print("ImplementStrStr", ImplementStrStr.strStr("hllallollb", "llo"))

print("SlidingWindowMaximum ",SlidingWindowMaximum.maxSlidingWindow([1,3,-1,-3,5,3,6,7], 3))

print("TopKFrequentElement ",TopKFrequentElement.topKFrequent([1,1,1,2,2,3], 2))

print("CombinationSum3 ",CombinationSum3.combinationSum3(9, 45))

print("LetterCombinationsOfAPhoneNumber ",LetterCombinationsOfAPhoneNumber.letterCombinations("123"))

print("CombinationSum ",CombinationSum.combinationSum([2,3,6,7], 7))
print("CombinationSum2 ",CombinationSum2.combinationSum2([10,1,2,7,6,1,5], 8))
print("ValidPalindrome ",ValidPalindrome.isPalindrome("race a car"))
print("PalindromePartitioning ",PalindromePartitioning.partition("abccba"))
print("RestoreIPAddresses ",RestoreIPAddresses.restoreIpAddresses("101023"))
print("SubSets ",SubSets.subsets([1,2,3]))
print("SubSets2 ",Subsets2.subsetsWithDup([1,2,2]))
print("IncreasingSubsequences ",IncreasingSubsequences.findSubsequences2([4,7,6,7]))
print("RecontructItinerary ",RecontructItinerary.findItinerary([["AXA","EZE"],["EZE","AUA"],["ADL","JFK"],["ADL","TIA"],["AUA","AXA"],["EZE","TIA"],["EZE","TIA"],["AXA","EZE"],["EZE","ADL"],["ANU","EZE"],["TIA","EZE"],["JFK","ADL"],["AUA","JFK"],["JFK","EZE"],["EZE","ANU"],["ADL","AUA"],["ANU","AXA"],["AXA","ADL"],["AUA","JFK"],["EZE","ADL"],["ANU","TIA"],["AUA","JFK"],["TIA","JFK"],["EZE","AUA"],["AXA","EZE"],["AUA","ANU"],["ADL","AXA"],["EZE","ADL"],["AUA","ANU"],["AXA","EZE"],["TIA","AUA"],["AXA","EZE"],["AUA","SYD"],["ADL","JFK"],["EZE","AUA"],["ADL","ANU"],["AUA","TIA"],["ADL","EZE"],["TIA","JFK"],["AXA","ANU"],["JFK","AXA"],["JFK","ADL"],["ADL","EZE"],["AXA","TIA"],["JFK","AUA"],["ADL","EZE"],["JFK","ADL"],["ADL","AXA"],["TIA","AUA"],["AXA","JFK"],["ADL","AUA"],["TIA","JFK"],["JFK","ADL"],["JFK","ADL"],["ANU","AXA"],["TIA","AXA"],["EZE","JFK"],["EZE","AXA"],["ADL","TIA"],["JFK","AUA"],["TIA","EZE"],["EZE","ADL"],["JFK","ANU"],["TIA","AUA"],["EZE","ADL"],["ADL","JFK"],["ANU","AXA"],["AUA","AXA"],["ANU","EZE"],["ADL","AXA"],["ANU","AXA"],["TIA","ADL"],["JFK","ADL"],["JFK","TIA"],["AUA","ADL"],["AUA","TIA"],["TIA","JFK"],["EZE","JFK"],["AUA","ADL"],["ADL","AUA"],["EZE","ANU"],["ADL","ANU"],["AUA","AXA"],["AXA","TIA"],["AXA","TIA"],["ADL","AXA"],["EZE","AXA"],["AXA","JFK"],["JFK","AUA"],["ANU","ADL"],["AXA","TIA"],["ANU","AUA"],["JFK","EZE"],["AXA","ADL"],["TIA","EZE"],["JFK","AXA"],["AXA","ADL"],["EZE","AUA"],["AXA","ANU"],["ADL","EZE"],["AUA","EZE"]]))

var arr: [[Character]]! = [
    ["5","3",".",".","7",".",".",".","."],
    ["6",".",".","1","9","5",".",".","."],
    [".","9","8",".",".",".",".","6","."],
    ["8",".",".",".","6",".",".",".","3"],
    ["4",".",".","8",".","3",".",".","1"],
    ["7",".",".",".","2",".",".",".","6"],
    [".","6",".",".",".",".","2","8","."],
    [".",".",".","4","1","9",".",".","5"],
    [".",".",".",".","8",".",".","7","9"]]
print("SudokuSolver ",SudokuSolver.solveSudoku2(&arr))
print("AssignCookies ",AssignCookies.findContentChildren([1,2,3], [3]))
print("WiggleSubsequence ",WiggleSubsequence.wiggleMaxLength2([2,2,2,]))

print("MaximumSubarray ",MaximumSubarray.maxSubArray([-2,1,-3,4,-1,2,1,-5,4]))
print("JumpGame ",JumpGame.canJump([1,0,0,2,3]))
//print("JumpGame2 ",JumpGame2.jump([1,1,1,1]))
print("JumpGame2 ",JumpGame2.jump([2,3,1,1,4]))
print("MaximizeSumOfArrayAfterKNegations ",MaximizeSumOfArrayAfterKNegations.largestSumAfterKNegations([-4,-6,9,-2,2], 2))
//print("GasStation ",GasStation.canCompleteCircuit([2,3,4], [3,4,3]))
print("GasStation ",GasStation.canCompleteCircuit([1,1,1,100,5,2], [3,5,5,1,2,3]))
//print("Candy ",Candy.candy([1,0,2,4,6,5,5,2,5]))
//print("Candy ",Candy.candy([29,51,87,99,99,87,72,12]))
//print("Candy ",Candy.candy([1,3,4,5,2]))
print("Candy ",Candy.candy([1,2,3,1,0]))

//print("Candy ",Candy.candy([1,2,0,3,0,3,0,2,1,]))
print("LemonadeChange ",LemonadeChange.lemonadeChange([5,5,10,10,20]))
print("QueueReconstructionbyHeight ",QueueReconstructionbyHeight.reconstructQueue([[7,0],[4,4],[7,1],[5,0],[6,1],[5,2]]))

print("MinimumNumberofArrowstoBurstBalloons ",MinimumNumberofArrowstoBurstBalloons.findMinArrowShots([[1,2],[2,3],[3,4],[4,5]]))
print("PartitionLabels ",PartitionLabels.partitionLabels("ababcbacadefegdehijhklij"))
print("MergeIntervals ",MergeIntervals.merge([[4,5],[1,4],[0,1]]))
print("MonotoneIncreasingDigits ",MonotoneIncreasingDigits.monotoneIncreasingDigits(17743))

print("BestTimeToBuyAndSellStockWithTransactionFee ",BestTimeToBuyAndSellStockWithTransactionFee.maxProfit([1,3,7,1,5,10,3], 3))
print("BestTimeToBuyAndSellStock ",BestTimeToBuyAndSellStock.maxProfit([7,1,5,3,6,4]))
print("CustomSortString ",CustomSortString.customSortString("cbafg", "abcd"))
print("FibonacciNumber ",FibonacciNumber.fib(2))
print("ClimbingStairs ",ClimbingStairs.climbStairs(8))
