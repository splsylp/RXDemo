//
//  NSMutableDictionary+Ext.h
//  Lafaso
//
//  Created by yuxuanpeng MINA on 14-7-11.
//  Copyright (c) 2014年 Lafaso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@interface NSMutableDictionary (value)

/**
 *  添加布尔值
 *
 *  @param value true,false; YES, NO
 *  @param key   关键字
 */
- (void)setBoolValue:(BOOL)value forKey:(NSString *)key;

/**
 *  添加整型值
 *
 *  @param value 整型值
 *  @param key   关键字
 */
- (void)setIntValue:(int)value forKey:(NSString *)key;
- (void)setIntegerValue:(NSInteger)value forKey:(NSString *)key;

/**
 *  添加长整型
 *
 *  @param value 长整型值
 *  @param key   关键字
 */
- (void)setLongValue:(long)value forKey:(NSString *)key;

/**
 *  添加超长整型
 *
 *  @param value 超长整型值
 *  @param key   关键字
 */
- (void)setLongLongValue:(long long)value forKey:(NSString *)key;

/**
 *  添加浮点型
 *
 *  @param value 浮点型值
 *  @param key   关键字
 */
- (void)setFloatValue:(float)value forKey:(NSString *)key;

/**
 *  添加双精度浮点型
 *
 *  @param value 双精度浮点型值
 *  @param key   关键字
 */
- (void)setDoubleValue:(double)value forKey:(NSString *)key;

@end

@interface NSMutableDictionary (Data)

/**
 *  添加矩形
 *
 *  @param value 矩形
 *  @param key   关键
 */
- (void)setRectValue:(CGRect)value forKey:(NSString *)key;

/**
 *  添加点
 *
 *  @param value 点
 *  @param key   关键字
 */
- (void)setPointValue:(CGPoint)value forKey:(NSString *)key;

/**
 *  添加大小
 *
 *  @param value 大小
 *  @param key   关键字
 */
- (void)setSizeValue:(CGSize)value forKey:(NSString *)key;

/**
 *  添加C字符串
 *
 *  @param cString C字符串
 *  @param key     关键字
 */
- (void)setCString:(const char*)cString forKey:(NSString *)key;

/**
 *  添加SEL
 *
 *  @param selector SEL
 *  @param key      关键字
 */
- (void)setSelector:(SEL)selector forKey:(NSString *)key;

@end
