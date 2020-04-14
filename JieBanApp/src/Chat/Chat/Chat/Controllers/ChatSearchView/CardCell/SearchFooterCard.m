//
//  SearchFooterCard.m
//  Chat
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "SearchFooterCard.h"

@implementation SearchFooterCard

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        CGFloat porHeightFloat=[ChatTools isIphone6PlusProPortionHeight];
        
        UIImageView *imageSView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 4, 36*porHeightFloat, 36*porHeightFloat)];
        imageSView.image = ThemeImage(@"searchBar_search_new");
        [self.contentView addSubview:imageSView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageSView.right + 5, 0.0f, 200.0f*porHeightFloat, 44.0f*porHeightFloat)];
        _nameLabel.textColor = [self colorWithHex:0x12a5eaff];
        _nameLabel.font = ThemeFontLarge;
        [self.contentView addSubview:_nameLabel];
        
        // 分割线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(_nameLabel.origin.x, 44*porHeightFloat-1, kScreenWidth-2*_nameLabel.origin.x, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];;
        [self.contentView addSubview:lineView];
        
    }
    return self;
}
- (void)setFooterTitleText:(NSString *)footerTitleText {
    if (_footerTitleText != footerTitleText) {
        _footerTitleText = footerTitleText;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _nameLabel.text = _footerTitleText;
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
