//
//  HYTModifPasswordDialog.h
//  HIYUNTON
//
//  Created by yuxuanpeng on 14-11-3.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import "HYTBaseDialog.h"

@interface RXModifPasswordDialog : HYTBaseDialog<UITextFieldDelegate>

@property (nonatomic, copy) void (^didSelected)(NSString* text); //点击事件

@end
