//
//  UICustomAlertView.h
//  ccp_ios_kit
//
//  Created by 张济航 on 15/8/19.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^JMWhenClickedBlock)();
@interface UICustomAlertView : UIAlertView
+ (id)showAlertView:(NSString *)title message:(NSString *)message click:(JMWhenClickedBlock)click cancel:(JMWhenClickedBlock)cancel;
+ (id)showAlertView:(NSString *)title message:(NSString *)message click:(JMWhenClickedBlock)click onText:(NSString *)okText cancel:(JMWhenClickedBlock)cancel cancelText:(NSString *)cancelText;
+ (id)showAlertView:(NSString *)title message:(NSString *)message click:(JMWhenClickedBlock)click cancelText:(NSString *)cancelText okText:(NSString *)okText;
+ (id)showAlertView:(NSString *)title message:(NSString *)message click:(JMWhenClickedBlock)click  okText:(NSString *)okText;
@end
