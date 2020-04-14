//
//  HYTBaseDialog.m
//  HIYUNTON
//
//  Created by chaizhiyong on 14-10-16.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import "HYTBaseDialog.h"
#import "UIView+Ext.h"

@implementation HYTBaseDialog

+ (id)presentModalDialogFromNibWidthDelegate:(id<HYTBaseDialogDelegate>)delegate withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus
{
    HYTBaseDialog* dialog = [HYTBaseDialog classFromNib:NSStringFromClass([self class])];
    [dialog setDelegate:delegate];
   
    [dialog showModalDialogWithAnimation:YES withPos:pos withTapAtBackground:tapStatus];
    return dialog;
}

+ (id)presentModalDialogWithRect:(CGRect)rect  WidthDelegate:(id<HYTBaseDialogDelegate>)delegate withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus
{
    HYTBaseDialog* dialog = [[[self class] alloc]initWithFrame:rect];
    [dialog setDelegate:delegate];
    [dialog showModalDialogWithAnimation:YES withPos:pos withTapAtBackground:tapStatus];
    return dialog;
}

+ (id)presentModalDialogWithRect:(CGRect)rect  WidthDelegate:(id<HYTBaseDialogDelegate>)delegate withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus maskColor:(UIColor *)maskColor
{
    HYTBaseDialog* dialog = [[[self class] alloc]initWithFrame:rect];
    [dialog setDelegate:delegate];
    [dialog showModalDialogWithAnimation:YES withPos:pos withTapAtBackground:tapStatus maskColor:maskColor];
    return dialog;
}

- (void)tapGestureListener:(id)sender
{
   [self dismissModalDialogWithAnimation:YES];
}

- (void)cancelTapGesture
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (window == nil) {
        window = [UIApplication sharedApplication].windows.lastObject;
    }
    UIView* maskView = [window viewWithTag:KKMaskViewTagValue];
    for (int i = 0; i < maskView.gestureRecognizers.count; i++) {
        UITapGestureRecognizer* tapGesture = (UITapGestureRecognizer*)[maskView.gestureRecognizers objectAtIndex:i];
        [maskView  removeGestureRecognizer:tapGesture];
    }
     ;
    
}

- (void)addTapGesture
{
    [self cancelTapGesture];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (window == nil) {
        window = [UIApplication sharedApplication].windows.lastObject;
    }
    UIView* maskView = [window viewWithTag:KKMaskViewTagValue];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureListener:)];
    [maskView addGestureRecognizer:tapGesture];
}


- (void)showModalDialogWithAnimation:(BOOL)animation withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus maskColor:(UIColor *) maskColor{
    [HYTBaseDialog removeSubviews];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (window == nil) {
        window = [UIApplication sharedApplication].windows.lastObject;
    }
    HYTBaseDialog* dialog = self;
    
    // 遮罩 [[UIColor blackColor] colorWithAlphaComponent:0.5]
    UIView* maskView = [[UIView alloc] initWithFrame:window.bounds];
    maskView.alpha           = 0.0;
    maskView.tag             = KKMaskViewTagValue;
    
    UIView * blackView = [[UIView alloc] initWithFrame:window.bounds];
    
    blackView.backgroundColor = maskColor;
    [maskView addSubview:blackView];
    
    switch (pos) {
        case EContentPosTOPWithNaviK:
        {
            //blackView.backgroundColor = [UIColor colorWithPatternImage:ThemeImage(@"bg.png")];
//            blackView.backgroundColor = [UIColor clearColor];//[[UIColor blackColor] colorWithAlphaComponent:0.2];
            
            maskView.backgroundColor = [UIColor clearColor];
            blackView.originY = kTotalBarHeight;
            blackView.frameHight = window.frameHight - kTotalBarHeight;
            
        }
            break;
        default:
            break;
    }
    [window addSubview:maskView];
    if (tapStatus) {
        // 点击事件
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:dialog action:@selector(tapGestureListener:)];
        [maskView addGestureRecognizer:tapGesture];
    }
    // 内容区域
    [dialog setAlpha:0.0];
    switch (pos) {
        case EContentPosTOPWithNaviK:
            [dialog setOrigin:CGPointMake((window.frameWidth-dialog.frameWidth)/2.0, 0)];
            break;
        case EContentPosTOPk:
            [dialog setOrigin:CGPointMake((window.frameWidth-dialog.frameWidth)/2.0, 98)];
            break;
        case EContentPosButtomk:
            [dialog setOrigin:CGPointMake((window.frameWidth-dialog.frameWidth)/2.0, window.frameHight-dialog.frameHight)];
            break;
        case EContentPosunconditionalK:
            
            [dialog setOrigin:CGPointMake(dialog.originX, dialog.originY)];
            break;
        default:
            [dialog setOrigin:CGPointMake((window.frameWidth-dialog.frameWidth)/2.0, (window.frameHight-dialog.frameHight)/2.0)];
            break;
    }
    dialog.tag =kKDialogObjTagValue;
    [window addSubview:dialog];
    
    // 动态显示
    [UIView animateWithDuration:0.3 animations:^{
        dialog.alpha   = 1.0;
        maskView.alpha = 1.0;
    } completion:^(BOOL finished) {
        //dialog.backgroundColor = [UIColor colorWithIntRed:255 green:127 blue:0 alpha:1.0];
    }];
}


- (void)showModalDialogWithAnimation:(BOOL)animation withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus
{
    [self showModalDialogWithAnimation:animation withPos:pos withTapAtBackground:tapStatus maskColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
}

- (void)dismissModalDialogWithAnimation:(BOOL)animation
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (window == nil) {
        window = [UIApplication sharedApplication].windows.lastObject;
    }    // 遮罩
    UIView *maskView = [window viewWithTag:KKMaskViewTagValue];
    [UIView animateWithDuration:animation?0.3:0 animations:^{
        self.alpha = 0.0;
        maskView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [maskView removeFromSuperview];
        [self removeFromSuperview];
    }];
    
}

+ (void)removeSubviews
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (window == nil) {
        window = [UIApplication sharedApplication].windows.lastObject;
    }
    
    UIView* maskView = [window viewWithTag:KKMaskViewTagValue];
    UIView* dialogObj = [window viewWithTag:kKDialogObjTagValue];
  
    if (maskView) {
        [maskView removeFromSuperview];
    }
    if (dialogObj) {
        [dialogObj removeFromSuperview];
    }
}

@end
