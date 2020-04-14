//
//  RXDeptSelectTableViewCell.m
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/8/21.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "RXDeptSelectTableViewCell.h"

@implementation RXDeptSelectTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectDept.hidden = YES;//默认隐藏
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [self.contentView addGestureRecognizer:tap];
    self.deptLab.font = ThemeFontLarge;
    [self.selectDept setImage:ThemeImage(@"choose_icon_on") forState:UIControlStateSelected];
    [self.selectDept setImage:ThemeImage(@"choose_icon") forState:UIControlStateNormal];
    self.enterImageV.image = ThemeImage(@"enter_icon_02");
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithRGB:0xC8C7CC];
    // 分割线
    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-1, kScreenWidth, 1)];
    self.lineView.backgroundColor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
    [self.contentView addSubview:self.lineView];
}

- (void)tapClick:(UITapGestureRecognizer *)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectDeptCell:)]) {
        [self.delegate didSelectDeptCell:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)actionHandle:(id)sender{

    UIButton* button = (UIButton*)sender;
    if (button.selected) {
        button.selected = !button.selected;
        //[button setSelected:NO];
    }else{
        button.selected = !button.selected;
        //[button setSelected:YES];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedDeptCell:selected:)]) {
        [self.delegate selectedDeptCell:self selected:button.selected];
    }
    
}

- (void)setIsSelectBtn:(BOOL)isSelectBtn{

    if (isSelectBtn) {
        self.selectDept.hidden = NO;
    }else{
        self.selectDept.hidden = YES;
    }
}

@end
