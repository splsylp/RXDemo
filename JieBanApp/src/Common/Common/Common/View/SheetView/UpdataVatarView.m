//
//  UpdataVatarView.m
//  Common
//
//  Created by 韩微 on 2017/8/18.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "UpdataVatarView.h"

@interface UpdataVatarView ()

@property (nonatomic, strong) UIImageView *avatarImageView;


@end

@implementation UpdataVatarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self internalInit];
        
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self internalInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self internalInit];
    }
    
    return self;
}

- (void)internalInit {
    
    self.backgroundColor = [UIColor whiteColor];
    
    _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-20*fitScreenWidth, 30*fitScreenHeight, 45, 45)];
    [self addSubview:_avatarImageView];
    _avatarImageView.layer.masksToBounds = YES;
    CGFloat shorterSide = MIN(_avatarImageView.bounds.size.width, _avatarImageView.bounds.size.height);
    _avatarImageView.layer.cornerRadius = shorterSide / 2.0f;
    
    UIImage *phImage = ThemeDefaultHead(self.avatarImageView.size, [Common sharedInstance].getUserName,[Common sharedInstance].getAccount);
    _avatarImageView.image = phImage;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, _avatarImageView.origin.y+_avatarImageView.frame.size.width+10*fitScreenWidth, self.frame.size.width, 18)];
    label.text = languageStringWithKey(@"是否恢复以上默认头像");
    label.textColor = [self colorWithHex:0x444444ff];
    label.font = ThemeFontLarge;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-50, self.frame.size.width, 0.5)];
    [self addSubview:view1];
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, self.frame.size.height-50, 0.5, 50)];
    [self addSubview:view2];
    view1.backgroundColor = [self colorWithHex:0x999999ff];
    view2.backgroundColor = [self colorWithHex:0x999999ff];
    
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, self.frame.size.height-50, self.frame.size.width/2-7, 50)];
    [self addSubview:cancelBtn];
    [cancelBtn setTitle:languageStringWithKey(@"取消") forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = ThemeFontLarge;
    cancelBtn.backgroundColor = [UIColor clearColor];
    [cancelBtn setTitleColor:[self colorWithHex:0x12a5eaff] forState:UIControlStateNormal];
    
    UIButton *confimBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2+3, self.frame.size.height-50, self.frame.size.width/2-8, 50)];
    [self addSubview:confimBtn];
    confimBtn.titleLabel.font = ThemeFontLarge;
    [confimBtn setTitle:languageStringWithKey(@"确认") forState:UIControlStateNormal];
    confimBtn.backgroundColor = [UIColor clearColor];
    [confimBtn setTitleColor:[self colorWithHex:0x12a5eaff] forState:UIControlStateNormal];
    
    [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [confimBtn addTarget:self action:@selector(confimAction:) forControlEvents:UIControlEventTouchUpInside];

    
}

- (void)cancelAction:(UIButton *)btn {
    
    if (self.alertViewAvatarDelegate && [self.alertViewAvatarDelegate respondsToSelector:@selector(removeAvatarView)]) {
        [self.alertViewAvatarDelegate removeAvatarView];
    }
}

- (void)confimAction:(UIButton *)btn {
    if (self.alertViewAvatarDelegate && [self.alertViewAvatarDelegate respondsToSelector:@selector(confimAlertView)]) {
        [self.alertViewAvatarDelegate confimAlertView];
    }
}


#pragma privite methods -
- (UIColor *)colorWithHex:(int)color {
    
    float red = (color & 0xff000000) >> 24;
    float green = (color & 0x00ff0000) >> 16;
    float blue = (color & 0x0000ff00) >> 8;
    float alpha = (color & 0x000000ff);
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}


@end
