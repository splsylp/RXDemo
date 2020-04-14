//
//  HYTAlertCommonDialog.h
//  HIYUNTON
//
//  Created by yuxuanpeng on 14-11-2.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import "HYTBaseDialog.h"

@interface RXAlertCommonDialog : HYTBaseDialog
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleLine;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *separationLine;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (assign,nonatomic)NSInteger isAlterPass;//0为不是,1为修改密码
@property (nonatomic, copy) void (^didSelected)(void); //点击事件

@end
