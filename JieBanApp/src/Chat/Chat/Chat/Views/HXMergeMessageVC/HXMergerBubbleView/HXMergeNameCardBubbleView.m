//
//  HXMergeNameCardBubbleView.m
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/4/5.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXMergeNameCardBubbleView.h"



@interface HXMergeNameCardBubbleView()

/**
 @brief 头像
 @discussion
 */
@property (nonatomic,strong) UIImageView *mImageView;


/**
 @brief 名字
 @discussion
 */
@property (nonatomic,strong) UILabel      *mNameLabel;


/**
 @brief 电话号码
 @discussion
 */
@property (nonatomic,strong) UILabel      *mPhoneLabel;

/**
 @brief 细线
 @discussion
 */
@property (nonatomic,strong) UIView       *mLineView;

/**
 @brief 个人名片
 @discussion
 */
@property (nonatomic,strong) UILabel       *mDesLabel;

//公众号名字
@property (nonatomic,strong) UILabel       *mPublicNameLabel;

@end


@implementation HXMergeNameCardBubbleView


-(UILabel *)mPublicNameLabel
{
    if(!_mPublicNameLabel){
        _mPublicNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mImageView.right+5, 0, self.width-(self.mImageView.right+5), 20)];
        _mPublicNameLabel.font = ThemeFontLarge;
        _mPublicNameLabel.textColor = [UIColor blackColor];
        _mPublicNameLabel.center = CGPointMake(_mPublicNameLabel.center.x, self.mImageView.center.y);
    }
    return _mPublicNameLabel;
}


- (UILabel *)mDesLabel{
    if(!_mDesLabel){
        _mDesLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.mLineView.top ,self.width, HX_NameCardLineHeight)];
        _mDesLabel.font = ThemeFontMiddle;
        _mDesLabel.textColor = [UIColor lightGrayColor];
        _mDesLabel.text = languageStringWithKey(@"个人名片");
    }
    return _mDesLabel;
}

- (UIView *)mLineView{
    if(!_mLineView){
        _mLineView = [[UIView alloc] initWithFrame:CGRectMake(0,HX_NameCardHeight - HX_NameCardLineHeight, self.width, 0.5)];
        _mLineView.backgroundColor = [UIColor lightGrayColor];
    }
    return _mLineView;
}


-(UILabel *)mPhoneLabel
{
    if(!_mPhoneLabel){
        _mPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mImageView.right+5, self.mImageView.bottom - 14 * FitThemeFont, self.width-self.mImageView.width-5, 14 * FitThemeFont)];
        _mPhoneLabel.font = ThemeFontMiddle;
        _mPhoneLabel.textAlignment = NSTextAlignmentLeft;
        _mPhoneLabel.textColor = [UIColor lightGrayColor];
    }
    return _mPhoneLabel;
}

-(UIImageView *)mImageView
{
    if(!_mImageView){
        _mImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
    }
    return _mImageView;
}
-(UILabel *)mNameLabel
{
    if(!_mNameLabel){
        _mNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mImageView.right+5, 10, self.width-self.mImageView.right-5, 16)];
        _mNameLabel.font = ThemeFontLarge;
        _mNameLabel.textAlignment = NSTextAlignmentLeft;
        _mNameLabel.textColor = [UIColor blackColor];
    }
    return _mNameLabel;
}


- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10, BUBLEVIEW_TITLE_Disatance+EDGE_Distance_TOP + 15 * FitThemeFont,BubbleViewWidth, HX_NameCardHeight)];
    if (self) {
        
        [self addSubview:self.mImageView];
        [self addSubview:self.mNameLabel];
        [self addSubview:self.mPhoneLabel];
        [self addSubview:self.mLineView];
        [self addSubview:self.mDesLabel];
        [self addSubview:self.mPublicNameLabel];
        self.backgroundColor = [UIColor colorWithHexString:@"F3F3F5"];
    }
    return self;
}


- (void)setModel:(HXMergeMessageModel *)model{
    _model = model;
    NSDictionary *useDataDic = nil;
    if([model.merge_userData isKindOfClass:[NSDictionary class]]){
        useDataDic = (NSDictionary *)model.merge_userData;
    }else{
        useDataDic =  [MessageTypeManager getCusDicWithUserData:_model.merge_userData];
    }
    NSDictionary *cardData = [useDataDic hasValueForKey:SMSGTYPE] ? useDataDic:useDataDic[ShareCardMode];
    NSInteger type = [[cardData objectForKey:@"type"] integerValue];
    if (type == 1) {
        self.mDesLabel.text = languageStringWithKey(@"个人名片");
        NSDictionary *book = [[Common sharedInstance].componentDelegate getDicWithId:[cardData objectForKey:@"account"] withType:0];
        
        NSString *userStatus = book[Table_User_status];
        if([userStatus isEqualToString:@"3"]){
            self.mImageView.image = ThemeDefaultHead(self.mImageView.size, RXleaveJobImageHeadShowContent,book[Table_User_account]);
        }else{
            [self.mImageView setImageWithURLString:book[Table_User_avatar] urlmd5:book[Table_User_urlmd5] options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(self.mImageView.size, book[Table_User_member_name],book[Table_User_account]) withRefreshCached:NO];
        }
        self.mPhoneLabel.hidden = NO;
        self.mPhoneLabel.hidden = NO;
        self.mPublicNameLabel.hidden = YES;
        // self.phoneLab.text = !KCNSSTRING_ISEMPTY(book.phoneNum)?book.phoneNum:@"";
        NSInteger userLevel = [book[Table_User_Level] integerValue];
        NSString * phone = book[Table_User_mobile];

        self.mPhoneLabel.text = clientShowInfomation?(HXLevelisFristAndSecond(userLevel,book[Table_User_account]))?hiddenMobileAndShowDefault:!KCNSSTRING_ISEMPTY(phone)?phone:@"":!KCNSSTRING_ISEMPTY(phone)?book[Table_User_mobile]:@"";
        if (ISLEVELMODE && userLevel <= [[[Common sharedInstance] getUserLevel] intValue] - 2) {
            self.mPhoneLabel.text = languageStringWithKey(@"**********");
        }

        self.mNameLabel.text = book[Table_User_member_name]?book[Table_User_member_name]:[cardData objectForKey:@"account"];
    }else if(type == 2){
        self.mDesLabel.text = languageStringWithKey(@"服务号名片");
        [self.mImageView sd_setImageWithURL:[cardData objectForKey:@"pn_photourl"] placeholderImage:ThemeImage(@"ios_rx_logo") options:0];
        
        self.mPublicNameLabel.text = [cardData objectForKey:@"pn_name"];
        self.mPhoneLabel.hidden = YES;
        self.mNameLabel.hidden = YES;
        self.mPublicNameLabel.hidden = NO;
    }

    
}


+ (CGFloat)heightForBubbleWithObject:(HXMergeMessageModel *)model
{
    return HX_NameCardHeight;
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(self.bubbleViewClickBlock){
        self.bubbleViewClickBlock(self.model,XSMergeMessageBublleEvent_NameCard);
    }
}

@end
