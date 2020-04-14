//
//  ChatSearchHeaderCard.m
//  Chat
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ChatSearchHeaderCard.h"

@implementation ChatSearchHeaderCard

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CGFloat porHeightFloat = [ChatTools isIphone6PlusProPortionHeight];

        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0.0f, 200.0f * porHeightFloat, 44.0f * porHeightFloat)];
        _nameLabel.textColor = [self colorWithHex:0x999999ff];
        _nameLabel.font = ThemeFontLarge;
        [self.contentView addSubview:_nameLabel];
        // 分割线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(_nameLabel.origin.x, 44 * porHeightFloat - 1, kScreenWidth - 2 * _nameLabel.origin.x, 0)];
        lineView.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];;
        [self.contentView addSubview:lineView];
    }
    return self;
}
- (void)setHeaderTitleText:(NSString *)headerTitleText {
    if (_headerTitleText != headerTitleText) {
        _headerTitleText = headerTitleText;
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    _nameLabel.text = _headerTitleText;
}
- (UIColor *)colorWithHex:(int)color {
    
    float red = (color & 0xff000000) >> 24;
    float green = (color & 0x00ff0000) >> 16;
    float blue = (color & 0x0000ff00) >> 8;
    float alpha = (color & 0x000000ff);
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
