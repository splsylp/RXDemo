//
//  HYTCommonContactsTableViewCell.m
//  HIYUNTON
//
//  Created by yuxuanpeng on 15-1-12.
//  Copyright (c) 2015年 hiyunton.com. All rights reserved.
//

#import "HYTCommonContactsTableViewCell.h"
#import "UIView+Ext.h"
#import "UIButton+Ext.h"
@implementation HYTCommonContactsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
    // 分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.headPortraitImageVIew.left, self.frame.size.height-1, self.frame.size.width-self.headPortraitImageVIew.left, 0.5)];
    lineView.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    [self.contentView addSubview:lineView];
    self.headPortraitImageVIew.layer.cornerRadius=self.headPortraitImageVIew.frame.size.width/2;
    self.headPortraitImageVIew.layer.masksToBounds=YES;
//    self.headPortraitImageVIew.layer.borderWidth=2;
//    self.headPortraitImageVIew.layer.borderColor=[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f].CGColor;
 
//    [[self.invitationBtn titleLabel] setFont:ThemeFontSmall];
//    [[self.invitationBtn titleLabel] setTextAlignment:NSTextAlignmentCenter];
//    [self.invitationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.invitationBtn setBackgroundImage:[UIColor createImageWithColor:Color66B243 andSize:self.invitationBtn.size] forState:UIControlStateNormal];
//    [self.invitationBtn setBackgroundImage:[UIColor createImageWithColor:[UIColor grayColor] andSize:self.invitationBtn.size] forState:UIControlStateSelected];
//    [self.invitationBtn addTarget:self action:@selector(tapInvitationBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)tapInvitationBtn:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(HYTCommonContactsTableViewCell:indexPath:)]) {
        [self.delegate HYTCommonContactsTableViewCell:self indexPath:_indexPath];
    }
}

@end

