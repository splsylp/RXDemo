//
//  RXConverseMenuView.h
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/8/15.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "KitBaseDialog.h"

@interface RXConverseMenuView : KitBaseDialog
@property(nonatomic,assign)BOOL isCanVoice;
@property(nonatomic,assign)BOOL isBackDial;
@property(nonatomic,assign)BOOL isDirectDial;

@property(nonatomic,copy)NSArray *(^fetchTitleArray)(void);//响应事件的tittle
@property(nonatomic,copy)void(^didclickBtn)(RXConverseMenuView *converseMenuView,NSInteger index);
- (void)updateSubViewLayout:(CGRect)rect;
@end
