//
//  CodecSetCell.m
//  Chat
//
//  Created by yongzhen on 2018/5/9.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "CodecSetCell.h"

@implementation CodecSetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}
#pragma mark createUI
-(void)createUI{
//    self.userInteractionEnabled = NO;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 30)];
    self.nameLabel.font = ThemeFontLarge;
    [self.contentView addSubview:self.nameLabel];
    
    self.selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectedBtn setImage:ThemeImage(@"kit_check") forState:UIControlStateNormal];
    [self.selectedBtn setImage:ThemeImage(@"kit_check_on") forState:UIControlStateHighlighted];
    self.selectedBtn.frame = CGRectMake(self.width - 50, (self.height - 30)/2.0,30.0f,30.0f);
//    [self.selectedBtn addTarget:self action:@selector(selectedBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.selectedBtn.enabled = NO;
    [self.contentView addSubview:self.selectedBtn];
    
    

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 39, kScreenWidth-10, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];;
    [self.contentView addSubview:lineView];
}
-(void)selectedBtnClicked{
    self.selectedBtn.selected  = !self.selectedBtn.selected;
    if (self.selectedBtn.selected) {
        [self.selectedBtn setImage:ThemeImage(@"kit_check_on") forState:UIControlStateNormal];
    }else{
        [self.selectedBtn setImage:ThemeImage(@"kit_check") forState:UIControlStateNormal];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (self.selectedBtn.selected) {
         [self.selectedBtn setImage:ThemeImage(@"kit_check_on") forState:UIControlStateNormal];
    }else{
         [self.selectedBtn setImage:ThemeImage(@"kit_check") forState:UIControlStateNormal];
    }
    // Configure the view for the selected state
}
-(void)setValeWithDic:(NSDictionary *)dic{
    if ([dic hasValueForKey:@"codeName"]) {
        self.nameLabel.text = dic[@"codeName"];
    }
    
    if ([dic hasValueForKey:@"res"]) {
        BOOL res = [dic[@"res"] boolValue];
        self.selectedBtn.selected = res;
    }
    
}
@end
