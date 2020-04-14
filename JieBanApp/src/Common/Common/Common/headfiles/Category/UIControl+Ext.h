//
//  UIControl+Ext.h
//  objectAssociation
//
//  Created by yuxuanpeng on 14-7-18.
//  Copyright (c) 2014年 yuxuanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (Ext)

+ (NSString*)controlEventName:(UIControlEvents)controlEvent;
- (void)removeAllTargets;

@end
