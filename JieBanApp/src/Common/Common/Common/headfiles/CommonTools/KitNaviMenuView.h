//
//  KitNaviMenuView.h
//  guodiantong
//
//  Created by yuxuanpeng on 14-10-16.
//  Copyright (c) 2014年 guodiantong. All rights reserved.
//

#import "KitBaseDialog.h"

@interface KitNaviMenuView : KitBaseDialog

@property (nonatomic, copy) void (^selectRowAtIndex)(KitNaviMenuView* naviMenuView,  NSInteger index); //点击事件

@property (nonatomic , copy) NSArray *(^fetchTitleArray)(void);  //获取items的title

@property(nonatomic,copy)NSArray *(^fetchImageArray)(void);  //获取items的图片

- (void)updateSubViewLayout:(CGRect)rect;
- (void)updateData;
@end
