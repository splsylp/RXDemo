//
//  RXGrouchatQRcodeView.m
//  Chat
//
//  Created by keven on 2019/1/3.
//  Copyright © 2019年 ronglian. All rights reserved.
//

#import "RXGrouchatQRcodeView.h"

@interface RXGrouchatQRcodeView ()

@property(nonatomic,strong) UILabel * codeTitleLabel;
@property(nonatomic,strong) UILabel * groupTitleLabel;
@property(nonatomic,strong) UILabel * groupSubTitleLabel;
@property(nonatomic,strong) UIView * seperteLine;
@property(nonatomic,strong) UIImageView * qrCodeImageView;
@property(nonatomic,strong) RXGroupHeadImageView * groupImageView;

@end

@implementation RXGrouchatQRcodeView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
    }
    return self;
}

#pragma mark -

- (void)setupSubviews{
    [self addSubview:self.codeTitleLabel];
    [self addSubview:self.groupSubTitleLabel];
    [self addSubview:self.groupTitleLabel];
    [self addSubview:self.qrCodeImageView];
    [self addSubview:self.groupImageView];
    [self addSubview:self.seperteLine];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.codeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).mas_offset(12);
        make.trailing.equalTo(self).mas_offset(-12);
        make.top.equalTo(self).mas_offset(30*iPhone6FitScreenHeight);
    }];
    WS(weakself);
    [self.qrCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).mas_offset(60*iPhone6FitScreenWidth);
        make.trailing.equalTo(self).mas_offset(-60*iPhone6FitScreenWidth);
        make.top.equalTo(self.codeTitleLabel.mas_bottom).mas_offset(30*iPhone6FitScreenHeight);
        make.height.equalTo(weakself.qrCodeImageView.mas_width);
    }];
    [self.seperteLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self.groupImageView.mas_top).mas_offset(-20*iPhone6FitScreenHeight);
        make.height.mas_equalTo(1);
    }];
    [self.groupImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).mas_offset(30*iPhone6FitScreenWidth);
        make.bottom.equalTo(self.mas_bottom).mas_offset(-20*iPhone6FitScreenHeight);
        make.size.mas_equalTo(CGSizeMake(iPhone6FitScreenWidth*50, iPhone6FitScreenWidth*50));
    }];
    [self.groupTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupImageView.mas_top);
        make.leading.equalTo(self.groupImageView.mas_trailing).mas_offset(12);
        make.trailing.equalTo(self).mas_offset(-12);
    }];
    [self.groupSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.groupImageView.mas_trailing).mas_offset(12);
        make.trailing.equalTo(self).mas_offset(-12);
        make.bottom.equalTo(self.groupImageView.mas_bottom);
    }];
}

#pragma mark -  setter
- (void)setGroupModel:(ECGroup *)groupModel{
    _groupModel = groupModel;
    
    //群名
    self.groupTitleLabel.text = groupModel.name;
    //二维码
    NSDictionary * groupParam = @{
                                   @"groupid":KSCNSTRING_ISNIL(groupModel.groupId),
                                   @"owner":KSCNSTRING_ISNIL(groupModel.owner),
                                   @"time":KSCNSTRING_ISNIL(groupModel.createdTime),
                                   @"count":[NSString stringWithFormat:@"%ld",(long)groupModel.memberCount],
                                   @"name":KSCNSTRING_ISNIL(groupModel.name)
                                   };
    NSDictionary * dataParas = @{
                                   @"url":@"joinGroup",
                                   @"data":[groupParam convertToString].base64EncodingString
                                };
    NSString * dataStr = [dataParas convertToString];
    self.qrCodeImageView.image = [SGQRCodeObtain generateQRCodeWithData:dataStr size:500 * iPhone6FitScreenWidth];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *members =[KitGroupMemberInfoData getSequenceMembersforGroupId:groupModel.groupId memberCount:9];
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.groupImageView createHeaderViewH:iPhone6FitScreenWidth*50 withImageWH:iPhone6FitScreenWidth*50 groupId:groupModel.groupId withMemberArray:members];
            self.qrCodeImageView.image = [SGQRCodeObtain generateQRCodeWithData:dataStr size:500 * iPhone6FitScreenWidth logoImage:self.groupImageView.imgView.image ratio:4];
        });
    });
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
#pragma mark -  lazy

- (UILabel*)codeTitleLabel{
    if (!_codeTitleLabel) {
        _codeTitleLabel = [[UILabel alloc]init];
        _codeTitleLabel.text = languageStringWithKey(@"扫描下面二维码加入群组");
        _codeTitleLabel.textAlignment = NSTextAlignmentCenter;
        _codeTitleLabel.font = [UIFont boldSystemFontOfSize:16];
        _codeTitleLabel.textColor = [UIColor colorWithHexString:@"333333"];
    }
    return _codeTitleLabel;
}
- (UILabel*)groupTitleLabel{
    if (!_groupTitleLabel) {
        _groupTitleLabel = [[UILabel alloc]init];
        _groupTitleLabel.textAlignment = NSTextAlignmentLeft;
        _groupTitleLabel.font = [UIFont systemFontOfSize:16];
        _groupTitleLabel.text = @"群名";
        _groupTitleLabel.numberOfLines = 1;
        _groupTitleLabel.textColor = [UIColor colorWithHexString:@"333333"];
    }
    return _groupTitleLabel;
}
- (UILabel*)groupSubTitleLabel{
    if (!_groupSubTitleLabel) {
        _groupSubTitleLabel = [[UILabel alloc]init];
        _groupSubTitleLabel.textAlignment = NSTextAlignmentLeft;
        _groupSubTitleLabel.font = [UIFont systemFontOfSize:14];
        _groupSubTitleLabel.numberOfLines = 1;
        _groupSubTitleLabel.textColor = [UIColor lightGrayColor];
        _groupSubTitleLabel.text = @"欢迎加入群聊";
    }
    return _groupSubTitleLabel;
}
- (UIImageView*)qrCodeImageView{
    if (!_qrCodeImageView) {
        _qrCodeImageView = [[UIImageView alloc]init];
        _qrCodeImageView.backgroundColor = [UIColor whiteColor];
    }
    return _qrCodeImageView;
}
- (RXGroupHeadImageView *)groupImageView{
    if (!_groupImageView) {
        _groupImageView = [[RXGroupHeadImageView alloc]init];
//        _groupImageView.image = ThemeImage(@"icon_groupdefaultavatar");
        
    }
    return _groupImageView;
}
- (UIView*)seperteLine{
    if (!_seperteLine) {
        _seperteLine = [[UIView alloc]init];
        _seperteLine.backgroundColor = MainTheme_ViewBackgroundColor;
    }
    return _seperteLine;
}
@end
