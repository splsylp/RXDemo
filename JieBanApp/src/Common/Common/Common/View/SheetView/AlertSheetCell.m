//
//  AlertSheetCell.m
//  Common
//
//  Created by 韩微 on 2017/8/15.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "AlertSheetCell.h"

@implementation AlertSheetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)getTextWith:(NSString *)text withWidth:(CGFloat)width{
    CGSize bubbleSize = [[Common sharedInstance] widthForContent:text withSize:CGSizeMake(width - 12, MAXFLOAT) withLableFont:ThemeFontMiddle.pointSize];
    if (!_textlabel) {
        _textlabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0, width-12, bubbleSize.height)];
        _textlabel.text = text;
        _textlabel.font = ThemeFontMiddle;
        _textlabel.textColor = [self colorWithHex:0x333333ff];
        [self.contentView addSubview:_textlabel];
        _textlabel.numberOfLines = 0;
        _textlabel.lineBreakMode = NSLineBreakByCharWrapping;
        _textlabel.backgroundColor = [UIColor clearColor];
        [self changeLineSpaceForLabel:_textlabel WithSpace:5.0f];
    }
   
}

+ (CGFloat)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width{
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 5;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f
                          };
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.height;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

#pragma private method -
-(void)changeLineSpaceForLabel:(UILabel *)label WithSpace:(float)space {
    
    NSString *labelText = label.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:space];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    label.attributedText = attributedString;
    [label sizeToFit];
    
}

- (UIColor *)colorWithHex:(int)color {
    
    float red = (color & 0xff000000) >> 24;
    float green = (color & 0x00ff0000) >> 16;
    float blue = (color & 0x0000ff00) >> 8;
    float alpha = (color & 0x000000ff);
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}
@end
