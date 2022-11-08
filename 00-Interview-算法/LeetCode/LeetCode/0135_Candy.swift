//
//  0135_Candy.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/3.
//

import Foundation

/*
 n个孩子站成一排。给你一个整数数组ratings表示每个孩子的评分。
 你需要按照以下要求，给这些孩子分发糖果：
 每个孩子至少分配到 1 个糖果。
 相邻两个孩子评分更高的孩子会获得更多的糖果。
 请你给每个孩子分发糖果，计算并返回需要准备的 最少糖果数目 。
 示例 1：
 输入：ratings = [1,0,2] 输出：5
 解释：你可以分别给第一个、第二个、第三个孩子分发 2、1、2 颗糖果。
 示例 2：
 输入：ratings = [1,2,2] 输出：4
 解释：你可以分别给第一个、第二个、第三个孩子分发 1、2、1 颗糖果。
      第三个孩子只得到 1 颗糖果，这满足题面中的两个条件。
 */

public class Candy {
    public class func candy(_ ratings: [Int]) -> Int {
        var candies = [Int](repeating: 1, count: ratings.count)
        for i in 1 ..< ratings.count {
            if ratings[i - 1] < ratings[i] {
                candies[i] = candies[i - 1] + 1;
            }
        }
        
        for i in (0 ..< ratings.count-1).reversed() {
            if ratings[i] > ratings[i + 1] {
                candies[i] = max(candies[i], candies[i + 1] + 1)
            }
        }
        
        var sumCandies = 0
        for i in 0 ..< candies.count {
            sumCandies += candies[i]
        }
        return sumCandies
    }
}
