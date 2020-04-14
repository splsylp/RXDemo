//
//  UIButton+Ext.h
//  objectAssociation
//
//  Created by yuxuanpeng on 14-7-18.
//  Copyright (c) 2014年 yuxuanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^buttonControlEventBlock)(id sender);

@interface UIButton (Ext)

- (void)handleControlEvent:(UIControlEvents)event withBlock:(buttonControlEventBlock)block;
- (void)removeHandleControlEvent:(UIControlEvents)controlEvent;
// 用来扩大点击区域
- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;

- (void)setEnlargeEdge:(CGFloat) size;
@end
