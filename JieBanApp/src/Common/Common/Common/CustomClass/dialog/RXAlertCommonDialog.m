//
//  HYTAlertCommonDialog.m
//  HIYUNTON
//
//  Created by yuxuanpeng on 14-11-2.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import "RXAlertCommonDialog.h"
#import "UIView+Ext.h"
#import "UIButton+Ext.h"
@implementation RXAlertCommonDialog

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.textColor = Color66B243;
    self.separationLine.frame = CGRectMake(0, self.separationLine.originY + 0.5, self.separationLine.width, 0.5);
    [self.bottomButton setTitle:languageStringWithKey(@"确定") forState:UIControlStateNormal];
    [self.bottomButton setTitle:languageStringWithKey(@"确定") forState:UIControlStateHighlighted];
    [self.bottomButton setTitle:languageStringWithKey(@"确定") forState:UIControlStateSelected];
    [self.bottomButton setBackgroundImage:[UIColor createImageWithColor:[UIColor whiteColor] andSize:self.bottomButton.size] forState:UIControlStateNormal];
    [self.bottomButton setBackgroundImage:[UIColor createImageWithColor:[UIColor grayColor] andSize:self.bottomButton.size] forState:UIControlStateSelected];
}

- (IBAction)actionHandle:(id)sender {
    
   __weak RXAlertCommonDialog *RXSelf =self;
    if(self.didSelected){
        self.didSelected();
    }
    [RXSelf dismissModalDialogWithAnimation:YES];
}

@end
