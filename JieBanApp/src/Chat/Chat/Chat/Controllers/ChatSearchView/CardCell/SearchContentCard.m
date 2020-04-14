//
//  SearchContentCard.m
//  Chat
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "SearchContentCard.h"

@implementation SearchContentCard

-(void)setSession:(ECSession *)session
{
    if(_session!=session)
    {
        _session=session;
    }
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        CGFloat porHeightFloat = [ChatTools isIphone6PlusProPortionHeight];
        
        _portraitImg = [[UIImageView alloc] initWithFrame:CGRectMake(15.0f, (60.0f*porHeightFloat-45*porHeightFloat)/2, 45.0f*porHeightFloat, 45.0f*porHeightFloat)];
        
        _portraitImg.layer.cornerRadius=_portraitImg.frame.size.width/2;
        _portraitImg.layer.masksToBounds=YES;
        
        _portraitImg.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_portraitImg];
        
        self.groupHeadView = [[RXGroupHeadImageView alloc] initWithFrame:CGRectMake(15.0f, (60.0f*porHeightFloat-45*porHeightFloat)/2, 45.0f*porHeightFloat, 45.0f*porHeightFloat)];
        self.groupHeadView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.groupHeadView];
        
        _dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 75*porHeightFloat, 9*porHeightFloat, 65*porHeightFloat, 20.0f*porHeightFloat)];
        _dateLabel.textColor = [UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.00f];
        _dateLabel.backgroundColor=[UIColor clearColor];
        _dateLabel.font =ThemeFontSmall;
        _dateLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_dateLabel];
        

        _atLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_portraitImg.frame) + 15 * porHeightFloat, 35.0f * porHeightFloat, 40.0f * porHeightFloat, 15.0f * porHeightFloat)];
        _atLabel.textColor = [UIColor redColor];
        _atLabel.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"有人@我")];
        _atLabel.backgroundColor = [UIColor clearColor];
        _atLabel.font = ThemeFontMiddle;
        _atLabel.textAlignment = NSTextAlignmentCenter;
        [_atLabel sizeToFit];
        _atLabel.hidden = YES;
        [self.contentView addSubview:_atLabel];
        
        
        _unReadLabel = [[UILabel alloc] initWithFrame:CGRectMake(_portraitImg.right-10, 1.5, 20.0f*porHeightFloat, 20.0f*porHeightFloat)];
//        _unReadLabel.backgroundColor = [UIColor redColor];
        _unReadLabel.textColor = [UIColor whiteColor];
        _unReadLabel.font =ThemeFontSmall;
        _unReadLabel.layer.cornerRadius = 10;
        _unReadLabel.layer.masksToBounds = YES;
        _unReadLabel.textAlignment = NSTextAlignmentCenter;
        _unReadLabel.layer.backgroundColor = [UIColor colorWithRed:1.00f green:0.29f blue:0.25f alpha:1.00].CGColor;

        [self.contentView addSubview:_unReadLabel];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30+45.0f*porHeightFloat, 9*porHeightFloat,kScreenWidth-30-120*porHeightFloat, 19.0f*porHeightFloat)];
        // _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _nameLabel.font = ThemeFontLarge;
        [self.contentView addSubview:_nameLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(30+45.0f*porHeightFloat, _nameLabel.frame.origin.y+_nameLabel.frame.size.height+7*porHeightFloat, kScreenWidth-30-120*porHeightFloat, 15.0f*porHeightFloat)];
        _contentLabel.font = ThemeFontMiddle;
        //_contentLabel.numberOfLines=0;
        //_contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _contentLabel.textColor = [UIColor colorWithRed:0.68f green:0.68f blue:0.68f alpha:1.00f];
        [self.contentView addSubview:_contentLabel];
        
        // 分割线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(_portraitImg.right, 60*porHeightFloat-1, kScreenWidth-_portraitImg.right, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];;
        [self.contentView addSubview:lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSArray* messageArr = [[KitMsgData sharedInstance] getLatestHundredMessageOfSessionId:self.session.sessionId andSize:1 andASC:YES];
    ECMessage *msg = [messageArr firstObject];
    BOOL isSpecial = [HXSpecialData haveSpecialWithAccount:msg.from];
    if (isSpecial) {
        
        _atLabel.hidden = NO;
        _atLabel.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"特别关注")];
        [_atLabel sizeToFit];
        
        CGRect frame = _contentLabel.frame;
        frame.origin.x = CGRectGetMaxX(_atLabel.frame);
        frame.size.width = self.frame.size.width-140-_atLabel.frame.size.width;
        _contentLabel.frame = frame;
        
    }
    else if (self.session.isAt) {
        _atLabel.hidden = NO;
        _atLabel.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"有人@我")];
        [_atLabel sizeToFit];
        
        CGRect frame = _contentLabel.frame;
        frame.origin.x = CGRectGetMaxX(_atLabel.frame);
        frame.size.width = self.frame.size.width-140-_atLabel.frame.size.width;
        _contentLabel.frame = frame;
    } else if(!KCNSSTRING_ISEMPTY(self.session.draft)){
        _atLabel.hidden = NO;
        _atLabel.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"草稿")];
        [_atLabel sizeToFit];
        _contentLabel.text = self.session.draft;
        
        CGRect frame = _contentLabel.frame;
        frame.origin.x = CGRectGetMaxX(_atLabel.frame);
        frame.size.width = self.frame.size.width-140-_atLabel.frame.size.width;
        _contentLabel.frame = frame;
    }else{
        [_atLabel setHidden:YES];
        CGRect frame = _contentLabel.frame;
        frame.origin.x = CGRectGetMinX(_nameLabel.frame);
        frame.size.width = self.frame.size.width-140;
        _contentLabel.frame = frame;
    }
    if (_session.type ==105){
        [self showPublicMessage];
    }
    if ([_session.sessionId isEqualToString:FileTransferAssistant]) {
        [self fileTransfer];
    }
}
//公众号
-(void)showPublicMessage
{
    //订阅号
    //cell.portraitImg.image=ThemeImage(@"ReadVerified_icon.png");
    NSString *tepStr = languageStringWithKey(@"服务号");
    _nameLabel.text = [NSString stringWithFormat:@"%@",tepStr];
    //cell.contentLabel.text=session.text;
    _dateLabel.text =_session.dateTime?[ChatTools getDateDisplayStringWithSession:_session.dateTime]:nil;
    
    _portraitImg.image=ThemeImage(@"app_official_account_icon");
    _contentLabel.text =[NSString stringWithFormat:@"%@",_session.text?_session.text:@""];
    
    //    HXPNMessageNumber *num = [HXPNMessageNumber getPublicNumInfoWithPnId:_session.fromId withFmdb:nil];
    //    if(num &&!KCNSSTRING_ISEMPTY(num.pnName))
    //    {
    //        _contentLabel.text =[NSString stringWithFormat:@"%@: %@",num.pnName,_session.text?_session.text:@""];
    //    }else
    //    {
    //        //cell.portraitImg.image=ThemeImage(@"ReadVerified_icon.png");
    //        if(!KCNSSTRING_ISEMPTY(_session.fromId))
    //        {
    //            _contentLabel.text =[NSString stringWithFormat:@"%@: %@",_session.fromId,_session.text?_session.text:@""];
    //
    //            __weak typeof(self)weak_self=self;
    //
    //            [HYTApiClient getPublicInfoDataSig:[[DeviceDelegateHelper sharedInstance]md5:HXClientAccount withStr2:[RXUser sharedInstance].clientpwd] account:HXClientAccount publicId:_session.fromId utime:nil didFinishLoaded:^(KXJson *json, NSString *path) {
    //
    //                DDLogInfo(@"..json...");
    //
    //                // KXJson* head = [json getJsonForKey:@"head"];
    //                NSString *statuscode = [json getStringForKey:@"statusCode"];
    //                if([statuscode isEqualToString:@"000000"])
    //                {
    //                    KXJson *dataJson =[json getJsonForKey:@"data"];
    //                    weak_self.contentLabel.text =[NSString stringWithFormat:@"%@: %@",[dataJson getStringForKey:@"pn_name"],weak_self.session.text];
    //
    //                    [HXAttPublicNum insertOneDataToSqlite:dataJson];
    //                    [[PublicDBHelper sharedInstance]updatePublicDic:weak_self.session.fromId];
    //                }
    //                NSInteger status =[json getIntForKey:@"status"];
    //
    //                if(status==publicNotExistErrorCode || status==publicDataNotExistErrorCode)
    //
    //                {
    //
    //                    //公众号不存在
    //                    [[PublicDBHelper sharedInstance]deleteAllAppointPublicMessage:weak_self.session.fromId];
    //
    //                    [weak_self updateAllData];
    //                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_update_session_im_message_num object:nil];
    //                }
    //
    //            } didFailLoaded:^(NSError *error, NSString *path) {
    //
    //            }];
    //        }else
    //        {
    //            _contentLabel.text =_session.text;
    //        }
    //
    //    }
}

#pragma mark - 文件传输助手
- (void)fileTransfer {
    _nameLabel.text =languageStringWithKey(@"文件传输助手");
    _dateLabel.text =_session.dateTime?[ChatTools getDateDisplayStringWithSession:_session.dateTime]:nil;
    _portraitImg.image=ThemeImage(@"icon_filetransferassistant");
    _contentLabel.text =[NSString stringWithFormat:@"%@",_session.text?_session.text:@""];
}

@end
