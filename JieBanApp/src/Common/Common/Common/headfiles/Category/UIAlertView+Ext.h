//
//  UIAlertView+Ext.h
//  golf-brothers
//
//  Created by huangtony on 14-9-13.
//  Copyright (c) 2014年 Nick Lious. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^JMWhenClickedBlock)();
@interface UIAlertView (Ext)

+ (id)showAlertView:(NSString *)title message:(NSString *)message click:(JMWhenClickedBlock)click cancel:(JMWhenClickedBlock)cancel;
+ (id)showAlertView:(NSString *)title message:(NSString *)message click:(JMWhenClickedBlock)click onText:(NSString *)okText cancel:(JMWhenClickedBlock)cancel cancelText:(NSString *)cancelText;
+ (id)showAlertView:(NSString *)title message:(NSString *)message click:(JMWhenClickedBlock)click cancelText:(NSString *)cancelText okText:(NSString *)okText;
+ (id)showAlertView:(NSString *)title message:(NSString *)message click:(JMWhenClickedBlock)click  okText:(NSString *)okText;
@end
