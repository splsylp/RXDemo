//
//  HXMergeMessageFatherCell.m
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/3/31.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXMergeMessageFatherCell.h"
#import "HXMergerMessageBubbleFatherView.h"
#import "HXMessageMergeManager.h"
#import "HXMergeMessageModel.h"
#import "HXMergerMessageTextBubbleView.h"   //文字
#import "HXMergerImageBubbleView.h"         //图片
#import "HXMergerVideoBubbleView.h"         //视频
#import "HXMergerLinkBubbleView.h"          //链接
#import "HXMergeNameCardBubbleView.h"       //名片
#import "HXMergerFileBubbleView.h"          //文件
#import "HXMergerVoiceBubbleView.h"         //语音
#import "HXMergeLoactionBubbleView.h"        //位置

@interface HXMergeMessageFatherCell ()

@property (nonatomic,strong) UIView      *mBackView;

@property (nonatomic,strong) HXMergeMessageModel *mModel;

@end

@implementation HXMergeMessageFatherCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (UIView *)mBackView{
    if(!_mBackView){
        _mBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 90)];
        _mBackView.backgroundColor = [UIColor clearColor];
    }
    return _mBackView;
}

- (UIImageView *)mHeaderImageView{
    if(!_mHeaderImageView){
        _mHeaderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(EDGE_Distance_LEFT, EDGE_Distance_TOP,MERGE_HEAD_WITH ,MERGE_HEAD_HEIGHT)];
        _mHeaderImageView.layer.cornerRadius = 4;
        _mHeaderImageView.clipsToBounds      = YES;
    }
    return _mHeaderImageView;
}

- (UILabel *)mNameLabel{
    if(!_mNameLabel){
        _mNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mHeaderImageView.right + 10 ,EDGE_Distance_TOP, 100, 15 * FitThemeFont)];
        _mNameLabel.textColor = [UIColor grayColor];
        _mNameLabel.textAlignment = NSTextAlignmentLeft;
        _mNameLabel.font = ThemeFontSmall;
    }
    return _mNameLabel;
}

- (UILabel *)mTimeLabel{
    if(!_mTimeLabel){
        _mTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mHeaderImageView.right + 120 -EDGE_Distance_BUTTOM, EDGE_Distance_TOP, kScreenWidth - self.mHeaderImageView.right - 120, 15 * FitThemeFont)];

        _mTimeLabel.textColor = [UIColor grayColor];
        _mTimeLabel.textAlignment = NSTextAlignmentRight;
        _mTimeLabel.font = ThemeFontSmall;
    }
    return _mTimeLabel;
}


- (instancetype)initWithEachMergeMessageModel:(HXMergeMessageModel *)model reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.mHeaderImageView];
        [self.contentView addSubview:self.mNameLabel];
        [self.contentView addSubview:self.mTimeLabel];
        _mBubbleView = [self bubbleViewForMessageModel:model];
        if(_mBubbleView){
            [self.contentView addSubview:_mBubbleView];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

+ (NSString *)cellIdentifierForMessageModel:(HXMergeMessageModel *)model{
    NSDictionary *im_jsonDic = [HXMessageMergeManager jsonDicWithNOBase64UserData:model.merge_userData];
    if(model.merge_type.integerValue == MessageBodyType_Text){
        if(im_jsonDic[ShareCardMode] ||
           [im_jsonDic[SMSGTYPE] isEqualToString:TYPE_CARD]){
            return @"Merge_Chard"; //名片
        }else{
            return @"Merge_Text";//文字
        }
    }else if(model.merge_type.integerValue ==   MessageBodyType_Image){
        return @"Merge_Image";
    }else if(model.merge_type.integerValue ==   MessageBodyType_Video){
        return @"Merge_Vidoe";
    }else if(model.merge_type.integerValue ==   MessageBodyType_Preview){//服务号和链接
        return @"Merge_Preview";
    }else if(model.merge_type.integerValue ==    MessageBodyType_File){
        return @"Merge_File";
    }else if(model.merge_type.integerValue ==    MessageBodyType_Voice){
        return @"Merge_Voice";
    }else if(model.merge_type.integerValue ==    MessageBodyType_Location){
        return @"Merge_Location";
    }else{
        return nil;
    }
    return @"heeh";
}

- (HXMergerMessageBubbleFatherView *)bubbleViewForMessageModel:(HXMergeMessageModel *)model{
    NSDictionary *im_jsonDic = [HXMessageMergeManager jsonDicWithNOBase64UserData:model.merge_userData];
    if(model.merge_type.integerValue == MessageBodyType_Text){
        if(im_jsonDic[ShareCardMode] ||
           [im_jsonDic[SMSGTYPE] isEqualToString:TYPE_CARD]){
            return [[HXMergeNameCardBubbleView alloc] init]; //名片
        }else{
            return [[HXMergerMessageTextBubbleView alloc] init];//文字
        }
    }else if(model.merge_type.integerValue ==   MessageBodyType_Image){
        return   [[HXMergerImageBubbleView alloc] init];          //图片
    }else if(model.merge_type.integerValue ==   MessageBodyType_Video){
        return     [[HXMergerVideoBubbleView alloc] init];       //视频
    }else if(model.merge_type.integerValue ==   MessageBodyType_Preview){//服务号和链接
        return [[HXMergerLinkBubbleView alloc] init];            //链接
    }else if(model.merge_type.integerValue ==    MessageBodyType_File){
        return [[HXMergerFileBubbleView alloc] init];
    }else if(model.merge_type.integerValue ==    MessageBodyType_Voice){
        return [[HXMergerVoiceBubbleView alloc] init];
    }else if(model.merge_type.integerValue ==    MessageBodyType_Location){
        return [[HXMergeLoactionBubbleView alloc] init];
    }else{
        return nil;
    }
}
+ (CGFloat)returnHeightWithModel:(HXMergeMessageModel *)model{
    NSDictionary *im_jsonDic = [HXMessageMergeManager jsonDicWithNOBase64UserData:model.merge_userData];
    CGFloat height1 = EDGE_Distance_TOP + 15 * FitThemeFont + BUBLEVIEW_TITLE_Disatance;
    CGFloat height2 = 0;
    if(model.merge_type.integerValue == MessageBodyType_Text){
        if(im_jsonDic[ShareCardMode] ||
           [im_jsonDic[SMSGTYPE] isEqualToString:TYPE_CARD]){
            height2 = [HXMergeNameCardBubbleView heightForBubbleWithObject:model];
        }else{
            height2= [HXMergerMessageTextBubbleView heightForBubbleWithObject:model];
        }
    }else if(model.merge_type.integerValue == MessageBodyType_Image){
        height2 = [HXMergerImageBubbleView  heightForBubbleWithObject:model];          //图片
    }else if(model.merge_type.integerValue ==   MessageBodyType_Video){
        height2 = [HXMergerVideoBubbleView heightForBubbleWithObject:model];               //视频
    }else if(model.merge_type.integerValue ==   MessageBodyType_Preview){
        height2 = [HXMergerLinkBubbleView heightForBubbleWithObject:model];                //服务号和链接
    }else if(model.merge_type.integerValue ==    MessageBodyType_File){
        height2 = [HXMergerFileBubbleView heightForBubbleWithObject:model];
    }else if(model.merge_type.integerValue ==    MessageBodyType_Voice){
        height2 = [HXMergerVoiceBubbleView heightForBubbleWithObject:model];
    }else if(model.merge_type.integerValue ==    MessageBodyType_Location){
        height2 = [HXMergeLoactionBubbleView heightForBubbleWithObject:model];
    }else{
        height2 = 0;
    }
    if(height1 + height2 < MERGE_HEAD_HEIGHT + EDGE_Distance_TOP){
        return MERGE_HEAD_HEIGHT+EDGE_Distance_TOP;
    }else{
        return height2 + height1;
    }
}

- (void)setModel:(HXMergeMessageModel *)model{
    _model = model;
    _mBubbleView.bubbleViewClickBlock = self.bubbleViewClickBlock;

    NSDictionary *wbBook = [[Common sharedInstance].componentDelegate getDicWithId:_model.merge_account withType:0];
    if(wbBook){
        NSString *header = wbBook[Table_User_avatar] ? :@"";
        NSMutableString *heaaderString = [[NSMutableString alloc] initWithString:header];
        NSRange range = [heaaderString rangeOfString:@"_thum"];
        if(range.location != NSNotFound){
            [heaaderString deleteCharactersInRange:range];
        }
       
        // hanwei start
        self.mHeaderImageView.layer.cornerRadius = 4.f;//self.mHeaderImageView.frame.size.width / 2;
        self.mHeaderImageView.layer.masksToBounds = YES;
        // hanwei end
        
        NSString *userStatus = wbBook[Table_User_status];
        if([userStatus isEqualToString:@"3"]){
            self.mHeaderImageView.image = ThemeDefaultHead(self.mHeaderImageView.size, RXleaveJobImageHeadShowContent,wbBook[Table_User_account]);
        }else{
            [self.mHeaderImageView setImageWithURLString:heaaderString urlmd5:wbBook[Table_User_urlmd5] options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(self.mHeaderImageView.size, wbBook[Table_User_member_name],wbBook[Table_User_account]) withRefreshCached:NO];
        }
        self.mNameLabel.text = wbBook[Table_User_member_name];
        self.mTimeLabel.text = [HXMessageMergeManager timeWithTimeIntervalString:_model.merge_time];
    }else{
        if (isLargeAddressBookModel) {//请求个人信息
            [[RestApi sharedInstance] getVOIPUserInfoWithMobile:_model.merge_account type:@"2" didFinishLoaded:^(NSDictionary *json, NSString *path) {
                NSInteger statuscode = [[[json objectForKey:@"head"] objectForKey:@"statusCode"] integerValue];
                NSArray *voipinfos = [[json objectForKey:@"body"] objectForKey:@"voipinfo"];
                if (statuscode != 0) {
                    return ;
                }
                NSDictionary *voipinfo = @{};
                for (NSDictionary *dic in voipinfos) {//一个账号多个企业会返回多个个人信息
                    if ([Common.sharedInstance.getAccount isEqualToString:dic[@"account"]]) {
                        voipinfo = dic;
                    }
                }
                //入库
                [KitCompanyAddress insertCompanyAddressDic:voipinfo];
                //显示
                KitCompanyAddress *address = [KitCompanyAddress yy_modelWithDictionary:voipinfo];

                [self.mHeaderImageView setImageWithURLString:address.photourl urlmd5:address.urlmd5 options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(self.mHeaderImageView.size,address.name,address.account) withRefreshCached:NO];
                self.mNameLabel.text = address.name;
            } didFailLoaded:nil];
        }
    }
    [_mBubbleView setModel:_model];
}

+ (UIView *)returnSecontionFooterView{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth , FooterHeight)];
    footerView.backgroundColor = [UIColor whiteColor];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10, FooterHeight-0.5, kScreenWidth-(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10), 0.5)];
    lineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [footerView addSubview:lineView];
    return footerView;
}


@end
