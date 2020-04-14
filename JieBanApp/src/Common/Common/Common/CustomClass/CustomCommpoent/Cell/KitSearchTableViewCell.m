//
//  KitSearchTableViewCell.m
//  ccp_ios_kit
//
//  Created by yuxuanpeng on 16/3/1.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "KitSearchTableViewCell.h"
#import "KCConstants_string.h"

@implementation KitSearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _titleLable.font = ThemeFontMiddle;
    _subTitleLable.font = ThemeFontSmall;
    _locationLable.font = ThemeFontSmall;
    _searchShowTitle.font = ThemeFontSmall;
    
    [self.enterBtn setImage:ThemeImage(@"enter_icon_01") forState:UIControlStateNormal];
    [self.enterBtn setImage:ThemeImage(@"enter_icon_01") forState:UIControlStateHighlighted];
    self.lineImageView.frame =CGRectMake(self.lineImageView.frame.origin.x, self.frame.size.height - 0.5, kScreenWidth, 0.5);
    self.lineImageView.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.00f];
    
    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHandle)];
    tap.numberOfTapsRequired = 1;
    [self.tapView addGestureRecognizer:tap];}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)tapHandle
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(tapSearchTableViewCell:)]){
        [self.delegate tapSearchTableViewCell:self];
    }
}
- (IBAction)actionHandle:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(searchTableViewCell:selectedIndex:)]){
        [self.delegate searchTableViewCell:self selectedIndex:self.tag];
    }
}

@end
