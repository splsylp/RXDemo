//
//  NSObject+Ext.h
//  Rongxin
//
//  Created by yuxuanpeng MINA on 14-11-1.
//  Copyright (c) 2014年 Rongxin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Ext)

/**
 *  调用系统打电话功能
 *
 *  @param phonenumber 电话号码
 */
+ (void)callPhoneNumber:(NSString *)phonenumber;

/**
 *  调用系统发送短信功能
 *
 *  @param phonenumber 电话号码
 */
+ (void)smsPhoneNumber:(NSString *)phonenumber;

// 中文转拼音，firstCharFinishBlock，汉字首字母；allCharFinishBlock，汉字全拼
+ (void)convertFromChineseToPinyin:(NSString *)chineseSource
                   firstCharString:(NSMutableString *)firstCharString
                     allCharString:(NSMutableString *)firstCharString;

// 传入汉字，返回拼音首字母
+ (NSString *)quickConvert:(NSString *)hzString;

// 中文转拼音，返回全拼
+ (NSString *)pinyinFromChiniseString:(NSString *)hzString;
// 富文本
- (NSMutableAttributedString *)changeAttrString:(NSString *)string text:(NSString *)text color:(UIColor *)color;

@end
