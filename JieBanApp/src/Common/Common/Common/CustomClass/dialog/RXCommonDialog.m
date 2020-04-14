//
//  HYTCommonDialog.m
//  HIYUNTON
//
//  Created by yuxuanpeng on 14-10-22.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import "RXCommonDialog.h"
#import "UIView+Ext.h"
#import "UIButton+Ext.h"

@interface RXCommonDialog ()

@property (copy, nonatomic) SelectedBlock block;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subTitleBottomHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeight;

@end

@implementation RXCommonDialog

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = ColorEFEFEF;
    self.textLabel.font = ThemeFontLarge;
    self.leftButton.titleLabel.font = ThemeFontMiddle;
    self.rightButton.titleLabel.font = ThemeFontMiddle;
    
    [self.leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:ThemeColor forState:UIControlStateNormal];
    
    self.textLabel.text = languageStringWithKey(@"将清空所有个人和群的聊天记录");
    [self.leftButton setTitle:languageStringWithKey(@"取消") forState:UIControlStateNormal];
    [self.rightButton setTitle:languageStringWithKey(@"确定") forState:UIControlStateNormal];
}

- (IBAction)actionHandle:(id)sender {
    UIButton* btn = (UIButton*)sender;
    if (self.selectButtonAtIndex) {
        self.selectButtonAtIndex(btn.tag);
    }
    if (self.block) {
        self.block(btn.tag);
    }
    [self dismissModalDialogWithAnimation:YES];
}

- (void)showTitle:(NSString *)title subTitle:(NSString *)subTitle ensureStr:(NSString *)ensureStr cancalStr:(NSString *)cancleStr selected:(SelectedBlock)selected {
    //根据字数算高度
    CGFloat titleHeight = 40;
    CGFloat subTitleHeight = [self getStringHeight:subTitle font:self.subTitle.font] + 1;
    self.titleHeight.constant = titleHeight;
    if (subTitleHeight == 0 || subTitle.length == 0 || !subTitle) {
        subTitleHeight = 0;
        self.subTitleBottomHeight.constant = 0;
    }
    else {
        self.subTitleBottomHeight.constant = 15;
    }
    CGRect frm = self.frame;
    self.frame = CGRectMake(frm.origin.x, frm.origin.y, frm.size.width, titleHeight + subTitleHeight + 75 + self.subTitleBottomHeight.constant);
    
    self.block = selected;
    if (!cancleStr) {
        self.rightWidth.constant = self.bounds.size.width;
    }
    self.textLabel.text = title;
    self.subTitle.text = subTitle;
    [self.leftButton setTitle:cancleStr forState:UIControlStateNormal];
    [self.rightButton setTitle:ensureStr forState:UIControlStateNormal];
}

- (CGFloat)getStringHeight:(NSString *)str font:(UIFont *)font {
    if (KCNSSTRING_ISEMPTY(str)) {
        return 0;
    }
    if (!font) {
        font = [UIFont systemFontOfSize:14];
    }
    CGRect bounds = [str boundingRectWithSize:CGSizeMake(210, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return bounds.size.height;
}

@end
