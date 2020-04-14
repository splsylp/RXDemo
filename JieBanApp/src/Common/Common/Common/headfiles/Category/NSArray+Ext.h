//
//  NSArray+Ext.h
//  Lafaso
//
//  Created by wj on 14-7-11.
//  Copyright (c) 2014年 Lafaso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSArray (value)

/**
 *  获取布尔值
 *
 *  @param index 索引值
 *
 *  @return
 */
- (BOOL)boolValueForIndex:(NSInteger)index;

/**
 *  获取整型值
 *
 *  @param index 索引值
 *
 *  @return
 */
- (int)intValueForIndex:(NSInteger)index;
- (NSInteger)integerValueForIndex:(NSInteger)index;

/**
 *  获取长整型值
 *
 *  @param index 索引值
 *
 *  @return
 */
- (long)longValueForIndex:(NSInteger)index;

/**
 *  获取超长整型值
 *
 *  @param index 索引值
 *
 *  @return
 */
- (long long)longlongValueForIndex:(NSInteger)index;

/**
 *  获取浮点值
 *
 *  @param index 索引值
 *
 *  @return
 */
- (float)floatValueForIndex:(NSInteger)index;

/**
 *  获取双精度浮点值
 *
 *  @param index 索引值
 *
 *  @return
 */
- (double)doubleValueForIndex:(NSInteger)index;

@end

@interface NSArray (Data)

/**
 *  获取矩形
 *
 *  @param index 索引值
 *
 *  @return
 */
- (CGRect)rectValueForIndex:(NSInteger)index;

/**
 *  获取大小
 *
 *  @param index 索引值
 *
 *  @return
 */
- (CGSize)sizeValueForIndex:(NSInteger)index;

/**
 *  获取点
 *
 *  @param index 索引值
 *
 *  @return 
 */
- (CGPoint)pointValueForIndex:(NSInteger)index;

/**
 *  获取C字符串
 *
 *  @param index 索引值
 *
 *  @return
 */
- (const char*)cstringForIndex:(NSInteger)index;

/**
 *  获取selector
 *
 *  @param index 索引值
 *
 *  @return
 */
- (SEL)selectorForIndex:(NSInteger)index;

/**
 *  数组转json
 *
 *  @param
 *
 *  @return
 */
- (NSString *)arrayToString;


/**
 json 字符串转成数组

 @param jsonStr jsonStr
 @return array
 */
+ (id)toArrayWithString:(NSString *)jsonStr;

@end
