//
//  Sword_002_BinaryPlus.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/30.
//

import Foundation

public class SwordBinaryPlus {
    
    public class func addBinary(_ a: String, _ b: String) -> String {
        //var result:[Int] = [Int]()
        var result: String = ""
        let arrA = Array(a)
        let arrB = Array(b)
        var indexA = arrA.count - 1
        var indexB = arrB.count - 1
        var carrtBit: Int = 0
        while indexA >= 0 || indexB >= 0 {
            let numA: Int = Int(indexA >= 0 ? arrA[indexA].asciiValue! - ("0" as Character).asciiValue! : 0)
            let numB: Int = Int(indexB >= 0 ? arrB[indexB].asciiValue! - ("0" as Character).asciiValue! : 0)
            var sum = numA + numB + carrtBit
            carrtBit = sum >= 2 ? 1 : 0
            sum = sum >= 2 ? sum - 2 : sum
            result.append("\(sum)")
            
            if indexA >= 0 { indexA -= 1 }
            if indexB >= 0 { indexB -= 1 }
        }
        
        if carrtBit == 1 {
            result.append("1")
        }
        
        return String(result.reversed())
    }
    
    public class func addBinary2(_ a: String, _ b: String) -> String {
        var result:[Int] = [Int]()
        let arrA = Array(a)
        let arrB = Array(b)
        var indexA = arrA.count - 1
        var indexB = arrB.count - 1
        var carrtBit: Int = 0
        while indexA >= 0 || indexB >= 0 {
            let numA: Int = Int(indexA >= 0 ? arrA[indexA].asciiValue! - ("0" as Character).asciiValue! : 0)
            let numB: Int = Int(indexB >= 0 ? arrB[indexB].asciiValue! - ("0" as Character).asciiValue! : 0)
            var sum = numA + numB + carrtBit
            carrtBit = sum >= 2 ? 1 : 0
            sum = sum >= 2 ? sum - 2 : sum
            result.append(sum)
            
            if indexA >= 0 { indexA -= 1 }
            if indexB >= 0 { indexB -= 1 }
        }
        
        if carrtBit == 1 {
            result.append(carrtBit)
        }
        
        var string = String()
        for i in result.reversed() {
            string.append(String(i))
        }
        
        return string
    }
}
