//
//  NSMutableArray+Ext.h
//  Lafaso
//
//  Created by wj on 14-7-11.
//  Copyright (c) 2014年 Lafaso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSMutableArray (value)

/**
 *  添加布尔值
 *
 *  @param value 布尔值
 */
- (void)addBoolValue:(BOOL)value;

/**
 *  添加整型值
 *
 *  @param value 整型值
 */
- (void)addIntValue:(int)value;
- (void)addIntegerValue:(NSInteger)value;

/**
 *  添加长整型
 *
 *  @param value 长整型值
 */
- (void)addLongValue:(long)value;

/**
 *  添加超长整型
 *
 *  @param value 超长整型
 */
- (void)addLongLongValue:(long long)value;

/**
 *  添加浮点型
 *
 *  @param value 浮点型值
 */
- (void)addFloatValue:(float)value;

/**
 *  添加双精度值
 *
 *  @param value 双精度值
 */
- (void)addDoubleValue:(double)value;

@end

@interface NSMutableArray (Data)

/**
 *  添加矩形
 *
 *  @param value 矩形
 */
- (void)addRectValue:(CGRect)value;

/**
 *  添加点
 *
 *  @param point 点
 */
- (void)addPointValue:(CGPoint)point;

/**
 *  添加大小
 *
 *  @param size 大小
 */
- (void)addSizeValue:(CGSize)size;

/**
 *  添加C字符串
 *
 *  @param cString C字符串
 */
- (void)addCString:(const char*)cString;

/**
 *  添加SEL
 *
 *  @param selector SEL
 */
- (void)addSelector:(SEL)selector;

@end
