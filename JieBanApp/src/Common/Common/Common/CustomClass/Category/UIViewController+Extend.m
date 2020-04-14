//
//  UIViewController+Extend.m
//  Common
//
//  Created by 高源 on 2018/8/3.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "UIViewController+Extend.h"

@implementation UIViewController (Extend)

#pragma mark getCurrentView
+ (UIViewController*)windowCurrentViewController{
    UIViewController* vc = [UIViewController rootViewController];
    
    while (1) {
        
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}

//获取rootViewController
+ (UIViewController *)rootViewController{
    UIWindow* window =[UIApplication sharedApplication].delegate.window;
    return window.rootViewController;
}
//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        return nil;
    }
    UIView *tempView;
    for (UIView *subview in window.subviews) {
        if ([[subview.classForCoder description] isEqualToString:@"UILayoutContainerView"]) {
            tempView = subview;
            break;
        }
    }
    if (!tempView) {
        tempView = [window.subviews lastObject];
    }

    id nextResponder = [tempView nextResponder];
    while (![nextResponder isKindOfClass:[UIViewController class]] || [nextResponder isKindOfClass:[UINavigationController class]] || [nextResponder isKindOfClass:[UITabBarController class]]) {
        tempView =  [tempView.subviews firstObject];

        if (!tempView) {
            return nil;
        }
        nextResponder = [tempView nextResponder];
    }
    return  (UIViewController *)nextResponder;
}

@end
