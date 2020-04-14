//
//  UIViewController+Extend.h
//  Common
//
//  Created by 高源 on 2018/8/3.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Extend)

+ (UIViewController *)windowCurrentViewController;
//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC;

@end
