//
//  ViewController.m
//  ArithMetic
//
//  Created by Red-Fish on 2021/9/13.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *arr = @[@2,@10,@6,@5,@3,@1,@4,@2,@9].mutableCopy;
//    NSMutableArray *arr = @[@2,@10,@6,@5,].mutableCopy;
//    [self josephCircleWithTotalNum:10 start:3 count:5];
    
//    [self bubblingSort:@[@1,@2,@10,@6,@5,@3,@4,@2].mutableCopy];
//    [self chooseSort:@[@1,@2,@10,@6,@5,@3,@4,@2].mutableCopy];
//    [self mergeSort:@[@1,@2,@10,@6,@5,@3,@4,@2,@9].mutableCopy];
    
    
    [self quickSort:arr leftIndex:0 rightIndex:arr.count - 1];
}

/// 约瑟夫环
- (void)josephCircleWithTotalNum:(NSInteger)m start:(NSInteger)k count:(NSInteger)n {
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < m; i++) {
        [array addObject:@(i)];
    }
    
    NSInteger index = k - 1;
    while (array.count > 0) {
        index = (index + n - 1) % array.count;
        NSLog(@"%@", array[index]);
        [array removeObjectAtIndex:index];
    }
}

#pragma mark - 冒泡排序

/// 冒泡排序
- (void)bubblingSort:(NSMutableArray *)array {
    
    // 1.比较相邻的元素。如果第一个比第二个大，就交换他们两个。
    // 2.对每一对相邻元素作同样的工作，从开始第一对到结尾的最后一对。这步做完后，最后的元素会是最大的数。
    // 3.针对所有的元素重复以上的步骤，除了最后一个。
    // 4.持续每次对越来越少的元素重复上面的步骤，直到没有任何一对数字需要比较。
    
    NSMutableArray *array1 = array.mutableCopy;
    NSMutableArray *array2 = array.mutableCopy;
    for (NSInteger i = array1.count; i > 0; i--) {
        for (int j = 0; j < i - 1; j++) {
            NSInteger num1 = [array1[j] integerValue];
            NSInteger num2 = [array1[j + 1] integerValue];
            if (num1 > num2) {
                [array1 exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
            }
            
            NSLog(@"array1%@", array1);
        }
    }
    
    for (int i = 0; i < array2.count; i++) {
        for (int j = 0; j < array2.count - i - 1; j++) {
            NSInteger num1 = [array2[j] integerValue];
            NSInteger num2 = [array2[j + 1] integerValue];
            if (num1 > num2) {
                [array2 exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
            }
            
            NSLog(@"array2%@", array2);
        }
    }
}

#pragma mark - 选择排序

/// 选择排序
- (void)chooseSort:(NSMutableArray *)array {
    
    // 1.首先在未排序序列中找到最小（大）元素，存放到排序序列的起始位置
    // 2.再从剩余未排序元素中继续寻找最小（大）元素，然后放到已排序序列的末尾。
    // 3.重复第二步，直到所有元素均排序完毕。
    
    for (int i = 0; i < array.count ; i++) {
        for (int j = i + 1; j < array.count; j ++) {
            int num1 = [array[i] intValue];
            int num2 = [array[j] intValue];
            
            if (num1 > num2) {
                [array exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
            
            NSLog(@"i:%dj:%d%@", i, j, array);
        }
    }
}

#pragma mark - 归并排序

/// 归并排序
- (void)mergeSort:(NSMutableArray *)array {
    // 1.申请空间，使其大小为两个已经排序序列之和，该空间用来存放合并后的序列
    // 2.设定两个指针，最初位置分别为两个已经排序序列的起始位置
    // 3.比较两个指针所指向的元素，选择相对小的元素放入到合并空间，并移动指针到下一位置
    // 4.重复步骤3直到某一指针达到序列尾
    // 5.将另一序列剩下的所有元素直接复制到合并序列尾
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1];
    for (NSNumber *num in array) {
        NSMutableArray *subArray = [NSMutableArray array];
        [subArray addObject:num];
        [tempArray addObject:subArray];
    }
    
    // 分解
    // 每一次归并操作 tempArray的个数为:
    // （当数组个数为偶数时tempArray.count/2;当数组个数为奇数时tempArray.count/2+1）
    // 当tempArray.count == 1时，归并排序完成
    NSLog(@"before - %@", tempArray);
    while (tempArray.count != 1) {
        NSInteger i = 0;
        
        // 当数组个数为偶数 进行合并操作，当数组个数为奇数，最后一轮空
        while (i < tempArray.count - 1) {
            
            // 将i 与 i+1 进行合并操作 将合并结果放入i位置上，将i+1位置上的元素删除
            tempArray[i] = [self mergeArrayFirstList:tempArray[i] secondList:tempArray[i + 1]];
            [tempArray removeObjectAtIndex:i + 1];
            i++;
            NSLog(@"step %ld arrayCount:%ld - %@", i, tempArray.count, tempArray );
        }
    }
    
    NSLog(@"merge result %@", tempArray[0]);
}

- (NSArray *)mergeArrayFirstList:(NSArray *)array1 secondList:(NSArray *)array2 {
    // 合并序列数组
    NSMutableArray *resultArray = [NSMutableArray array];
    
    // firstIndex是第一段数组的下标， secondIndex是第二段数组的下标
    NSInteger firstIndex = 0, secondIndex = 0;
    
    // 扫描第一段和第二段数组，知道有一个扫描结果
    while (firstIndex < array1.count && secondIndex < array2.count) {
        // 判断第一段和第二段取出来的数字哪个更小，将其存入合并序列，并继续向下扫描
        if ([array1[firstIndex] floatValue] < [array2[secondIndex] floatValue]) {
            [resultArray addObject:array1[firstIndex]];
            firstIndex++;
        } else {
            [resultArray addObject:array2[secondIndex]];
            secondIndex++;
        }
    }
    
    NSLog(@"merge step 1 - %@", resultArray);
    
    // 若第一段数组还没扫描完，将其全部复制到合并序列
    while (firstIndex < array1.count) {
        [resultArray addObject:array1[firstIndex]];
        firstIndex++;
    }
    
    NSLog(@"merge step 2 - %@", resultArray);
    
    // 若第二段数组还没扫描完，将其全部复制到合并序列
    while (secondIndex < array2.count) {
        [resultArray addObject:array2[secondIndex]];
        secondIndex++;
    }
    
    NSLog(@"merge result - %@", resultArray);
    
    // 返回合并后的数组
    return resultArray.copy;
}

#pragma mark - 快速排序

/// 快速排序
- (void)quickSort:(NSMutableArray *)array leftIndex:(NSInteger)left rightIndex:(NSInteger)right {
    // 1.从数列中挑出一个元素，称为 “基准”（pivot），
    // 2.重新排序数列，所有元素比基准值小的摆放在基准前面，所有元素比基准值大的摆在基准的后面（相同的数可以到任一边）。在这个分区退出之后，该基准就处于数列的中间位置。这个称为分区（partition）操作。
    // 3.递归地（recursive）把小于基准值元素的子数列和大于基准值元素的子数列排序。
    
    NSLog(@"新一轮开始：%@ 左边:%ld 右边:%ld", [self printArrayInline:array], left, right);
    
    if (left > right) {
        
        NSLog(@"失败");
        
        return;
    }
    
    NSInteger i = left;
    NSInteger j = right;
    
    NSLog(@"基数:%@", array[i]);
    // 记录基准数
    id key = array[i];
    while (i < j) {
        
        // 首先从右边j开始查找（从最右边往左找）比基数（key）小的值
        while (i < j && [key floatValue] <= [array[j] floatValue]) {
            NSLog(@"从右边查找: i:%ld j:%ld array[%ld]:%@ 比基数大了", i, j, j, array[j]);
            j--;
            NSLog(@"j->%ld",j);
        }
        
        // 如果从右边j开始查找的值array[j] 比基数小，将查找的小值换到i的位置
        if (i < j) {
            NSLog(@"后面大的数换到前面：查找的小值换到i的位置 array[%ld]:%@ = array[%ld]:%@", i, array[i], j, array[j]);
            array[i] = array[j];
            NSLog(@"%@", [self printArrayInline:array]);
        }
        
        // 从i的右边往右查找一个比基准数小的值时，就从i开始往后找比基准数大的值
        while (i < j && [array[i] floatValue] <= [key floatValue]) {
            NSLog(@"从左查找: i:%ld j:%ld array[%ld]:%@ 比基数小了", i, j, i, array[i]);
            i++;
            NSLog(@"i->%ld",i);
        }
        
        // 如果从i的右边往左查找的值array[i] 比基数大，则将查找的大值调换到j的位置
        if (i < j) {
            NSLog(@"前面大的数换到后面：将查找的大值调换到j的位置 array[%ld]:%@ = array[%ld]:%@", j, array[j], i, array[i]);
            array[j] = array[i];
            NSLog(@"%@",[self printArrayInline:array]);
        }
        
    }
    
    // 将基数放到正确的位置，改变的是基数的位置
    NSLog(@"将基数放到正确的位置，改变的是基数的位置 array[%ld]:%@ = 基数:%@", i, array[i], key);
    array[i] = key;
    
    NSLog(@"%@",[self printArrayInline:array]);
    
    // 递归排序
    // 将i左边的数重新排序
    NSLog(@"将i:%ld左边的数重新排序 left:%ld right:%ld", i, left, i - 1);
    [self quickSort:array leftIndex:left rightIndex:i - 1];
    // 将i右边的数重新排序
    NSLog(@"将i:%ld右边的数重新排序 left:%ld right:%ld", i, i + 1, right);
    [self quickSort:array leftIndex:i + 1 rightIndex:right];
    
    NSLog(@"最终结果: %@", [self printArrayInline:array]);
}

- (NSString *)printArrayInline:(NSArray *)array {
    NSString *string = @"";
    for (NSNumber *num in array) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%@-",num]];
    }
    return string;
    
}

@end
