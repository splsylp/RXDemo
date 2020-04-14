//
//  RXNaviMenuView.h
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/8/8.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "HYTBaseDialog.h"

@interface RXNaviMenuView : HYTBaseDialog

@property(nonatomic,copy)void (^selectRowAtIndex)(RXNaviMenuView *naviMenuView, NSInteger index);//点击事件

@property(nonatomic,copy)NSArray *(^fetchTitleArray)(void);  //获取items的title

@property(nonatomic,copy)NSArray *(^fetchImageArray)(void);  //获取items的图片
- (void)updateSubViewLayout:(CGRect)rect;
@end
