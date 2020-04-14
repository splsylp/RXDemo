//
//  NSDictionary+Ext.h
//  Lafaso
//
//  Created by wj on 14-7-11.
//  Copyright (c) 2014年 Lafaso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 *  从字典中获取一般数据类型值
 */
@interface NSDictionary (value)

/**
 *  是否存在关键字
 *
 *  @param key 关键字
 *
 *  @return false,true
 */
- (BOOL)hasValueForKey:(NSString *)key;

/**
 *  布尔值
 *
 *  @param key 关键字
 *
 *  @return
 */
- (BOOL)boolValueForKey:(NSString *)key;

/**
 *  整型值
 *
 *  @param key 关键字
 *
 *  @return
 */
- (int)intValueForKey:(NSString *)key;
- (NSInteger)integerValueForKey:(NSString *)key;

/**
 *  长整型
 *
 *  @param key 关键字
 *
 *  @return
 */
- (long)longValueForKey:(NSString *)key;

/**
 *  超长整型
 *
 *  @param key 关键字
 *
 *  @return
 */
- (long long)longlongValueForKey:(NSString *)key;

/**
 *  浮点型
 *
 *  @param key 关键字
 *
 *  @return
 */
- (float)floatValueForKey:(NSString *)key;

/**
 *  双精度浮点型
 *
 *  @param key 关键字
 *
 *  @return
 */
- (double)doubleValueForKey:(NSString *)key;


@end

/**
 *  从字典中获取一般
 */
@interface NSDictionary (Data)

/**
 *  矩形
 *
 *  @param key 关键字
 *
 *  @return
 */
- (CGRect)rectForKey:(NSString *)key;

/**
 *  点
 *
 *  @param key 关键字
 *
 *  @return
 */
- (CGPoint)pointForKey:(NSString *)key;

/**
 *  大小
 *
 *  @param key 关键字
 *
 *  @return
 */
- (CGSize)sizeForKey:(NSString *)key;

/**
 *  C字符串
 *
 *  @param key 关键字
 *
 *  @return 返回C字符串，自动释放，因此如果需要使用，需要拷贝存储
 */
- (const char*)cStringForKey:(NSString *)key;

/**
 *  selector
 *
 *  @param key 关键字
 *
 *  @return
 */
- (SEL)selectorForKey:(NSString *)key;

@end

//字典深拷贝
@interface NSDictionary (MutableDeepCopy)

- (NSMutableDictionary *)mutableDeepCopy;
- (NSString *)coverString;
- (NSString *)convertToString;
- (NSString *)jsonEncodedKeyValueString;
@end
