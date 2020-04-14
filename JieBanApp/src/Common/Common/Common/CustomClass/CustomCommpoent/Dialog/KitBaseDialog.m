//
//  KitBaseDialog.m
//  guodiantong
//
//  Created by yuxuanpeng on 14-10-16.
//  Copyright (c) 2014年 guodiantong. All rights reserved.
//
//弹出框的父类
#import "KitBaseDialog.h"
#import "UIView+Ext.h"
#import "UIButton+Ext.h"
@implementation KitBaseDialog
//xib创建 tapStatus点击背景是否消失
+ (id)presentModalDialogFromNibWidthDelegate:(id<KitBaseDialogDelegate>)delegate withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus
{
    KitBaseDialog* dialog = [UIView classFromNib:NSStringFromClass([self class])];
    [dialog setDelegate:delegate];
   
    [dialog showModalDialogWithAnimation:YES withPos:pos withTapAtBackground:tapStatus];
    return dialog;
}
//代码创建
+ (id)presentModalDialogWithRect:(CGRect)rect  WidthDelegate:(id<KitBaseDialogDelegate>)delegate withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus
{
    KitBaseDialog* dialog = [[[self class] alloc]initWithFrame:rect];
    [dialog setDelegate:delegate];
    [dialog showModalDialogWithAnimation:YES withPos:pos withTapAtBackground:tapStatus];
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
    UIView* maskView = [window viewWithTag:kMaskViewTagValue];
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
    UIView* maskView = [window viewWithTag:kMaskViewTagValue];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureListener:)];
    [maskView addGestureRecognizer:tapGesture];
}

- (void)showModalDialogWithAnimation:(BOOL)animation withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus
{
    [KitBaseDialog removeSubviews];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (window == nil) {
        window = [UIApplication sharedApplication].windows.lastObject;
    }
    KitBaseDialog* dialog = self;
    
    // 遮罩
    UIView* maskView = [[UIView alloc] initWithFrame:window.bounds];
    maskView.alpha           = 0.0;
    maskView.tag             = kMaskViewTagValue;
    maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

    UIView * blackView = [[UIView alloc] initWithFrame:window.bounds];
    blackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [maskView addSubview:blackView];
    
    switch (pos) {
        case EContentPosTOPWithNaviK:
        {
//            maskView.backgroundColor = [UIColor clearColor];
//            CGRect frame = CGRectMake(maskView.frame.origin.x, 64, maskView.frame.size.width, window.frame.size.height-64);
//            maskView.frame = frame;
            
            blackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
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
            self.frame = CGRectMake((window.frame.size.width - dialog.frame.size.width)/2.0,0 , self.frame.size.width, self.frame.size.height);        
            break;
        case EContentPosTOPk:
            self.frame = CGRectMake((window.frame.size.width - dialog.frame.size.width)/2.0 , 98 , self.frame.size.width, self.frame.size.height);
            break;
        case EContentPosButtomk:
            self.frame = CGRectMake((window.frame.size.width - dialog.frame.size.width)/2.0, (window.frame.size.height - dialog.frame.size.height) , self.frame.size.width, self.frame.size.height);
            break;
        case EContentPosunconditionalK:
            
            break;
        default:
            self.frame = CGRectMake((window.frame.size.width - dialog.frame.size.width)/2.0, ((window.frame.size.height - dialog.frame.size.height)/2.0) , self.frame.size.width, self.frame.size.height*FitThemeFont);
            break;
    }
    
    dialog.tag = kDialogObjTagValue;
    [window addSubview:dialog];
    
    // 动态显示
    [UIView animateWithDuration:0.3 animations:^{
        dialog.alpha   = 1.0;
        maskView.alpha = 1.0;
    } completion:^(BOOL finished) {
        //dialog.backgroundColor = [UIColor colorWithIntRed:255 green:127 blue:0 alpha:1.0];
    }];
}
- (void)dismissModalDialogWithAnimation:(BOOL)animation
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (window == nil) {
        window = [UIApplication sharedApplication].windows.lastObject;
    }    // 遮罩
    UIView* maskView = [window viewWithTag:kMaskViewTagValue];
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
    
    UIView* maskView = [window viewWithTag:kMaskViewTagValue];
    UIView* dialogObj = [window viewWithTag:kDialogObjTagValue];
  
    if (maskView) {
        [maskView removeFromSuperview];
    }
    if (dialogObj) {
        [dialogObj removeFromSuperview];
    }
}

@end
