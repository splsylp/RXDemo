//
//  UINavigationItem+MRCBackBarButtonItem.m
//  BaseComponent
//
//  Created by 王明哲 on 16/10/19.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "UINavigationItem+MRCBackBarButtonItem.h"
#import <objc/runtime.h>

@implementation UINavigationItem (MRCBackBarButtonItem)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(backBarButtonItem);
        SEL swizzledSelector = @selector(mrc_backBarButtonItem);
        
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        class_replaceMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    });
}

#pragma mark - Method Swizzling

- (UIBarButtonItem *)mrc_backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
}

@end
