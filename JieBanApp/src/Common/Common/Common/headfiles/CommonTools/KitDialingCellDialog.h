//
//  KitDialingCellDialog.h
//  guodiantong
//
//  Created by yuxuanpeng on 14-10-31.
//  Copyright (c) 2014年 guodiantong. All rights reserved.
//

#import "KitBaseDialog.h"

@interface KitDialingCellDialog : KitBaseDialog<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, copy) void (^selectIndex)(NSInteger index); //点击事件
@property (nonatomic, copy) NSArray* (^totalItems)(void);
- (void)resetResource;
@end
