//
//  UIButton+Utils.h
//  Common
//
//  Created by keven on 2018/9/11.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ButtonImageTitleStyle ) {
    ButtonImageTitleStyleDefault = 0,
    ButtonImageTitleStyleLeft  = 1,
    ButtonImageTitleStyleRight     = 2,
    ButtonImageTitleStyleTop  = 3,
    ButtonImageTitleStyleBottom    = 4,
    ButtonImageTitleStyleCenterTop = 5,
    ButtonImageTitleStyleCenterBottom = 6,
    ButtonImageTitleStyleCenterUp = 7,
    ButtonImageTitleStyleCenterDown = 8,
    ButtonImageTitleStyleRightLeft = 9,
    ButtonImageTitleStyleLeftRight = 10,
};


@interface UIButton (Utils)

@property (nonatomic, assign) UIEdgeInsets hitEdgeInsets;

/**
 @brief  调整按钮的文本和image的布局
 @param style 布局样式
 @param padding 调整布局时整个按钮和图文的间隔。
 */
- (void)setButtonImageTitleStyle:(ButtonImageTitleStyle)style padding:(CGFloat)padding;


@end
