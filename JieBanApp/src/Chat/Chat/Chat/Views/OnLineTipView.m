//
//  OnLineTipView.m
//  Chat
//
//  Created by 李晓杰 on 2019/9/21.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "OnLineTipView.h"

@interface OnLineTipView()

@end

@implementation OnLineTipView

+ (OnLineTipView *)showInView:(UIView *)view frame:(CGRect)frame name:(NSString *)name isOnline:(BOOL)isOnline duration:(NSInteger)duration completion:(void(^)(void))completion{
    OnLineTipView *tipView = [[self alloc] init];
    tipView.frame = frame;
    tipView.nameLabel.text = name;
    tipView.tipLabel.text = isOnline?@"已上线":@"已下线";
    [view addSubview:tipView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tipView removeFromSuperview];
        if (completion) {
            completion();
        }
    });
    return tipView;
}

- (instancetype)init{
    if (self = [super init]) {
        [self addSubview:self.backImageView];
        [self addSubview:self.photoImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.tipLabel];
        
        [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.mas_equalTo(self);
        }];
        [_photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).with.offset(18);
            make.top.mas_equalTo(self.mas_top).with.offset(8);
            make.bottom.mas_equalTo(self.mas_bottom).with.offset(-8);
            make.width.mas_equalTo(20);
        }];
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.mas_right).with.offset(-8);
            make.top.bottom.mas_equalTo(self);
            make.width.mas_equalTo(45);
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self);
            make.left.mas_equalTo(self.photoImageView.mas_right).with.offset(8);
            make.right.mas_equalTo(self.tipLabel.mas_left).with.offset(-4);
        }];
    }
    return self;
}

#pragma mark - get
- (UIImageView *)backImageView{
    if (_backImageView == nil) {
        _backImageView = [[UIImageView alloc] init];
        UIImage *image = ThemeImage(@"bg_online");
        image = [image stretchableImageWithLeftCapWidth:18 topCapHeight:36];
        _backImageView.image = image;
    }
    return _backImageView;
}

- (UIImageView *)photoImageView{
    if (_photoImageView == nil) {
        _photoImageView = [[UIImageView alloc] init];
        UIImage *image = ThemeImage(@"icon_attention_friend");
        _photoImageView.image = image;
    }
    return _photoImageView;
}

- (UILabel *)nameLabel{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = [UIColor colorWithHexString:@"333333"];
    }
    return _nameLabel;
}

- (UILabel *)tipLabel{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = [UIColor colorWithHexString:@"333333"];
    }
    return _tipLabel;
}

@end
