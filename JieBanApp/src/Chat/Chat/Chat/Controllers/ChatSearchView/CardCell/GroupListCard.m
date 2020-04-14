//
//  GroupListCard.m
//  Chat
//
//  Created by lxj on 2018/11/13.
//  Copyright © 2018 ronglian. All rights reserved.
//

#import "GroupListCard.h"
#import "SearchResPersonCell.h"
@implementation GroupListCard

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.lineView.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"#151515"];
    self.nameLabel.textColor = [UIColor colorWithHexString:@"#151515"];
    self.infoLabel.textColor = [UIColor  colorWithHexString:@"#999999"];
    self.timeLabel.textColor = [UIColor lightGrayColor];
    self.placeLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    //默认样式
    self.photoView.hidden = NO;
    self.headView.hidden = YES;
    self.titleLabel.hidden = NO;
    self.nameLabel.hidden = YES;
    self.infoLabel.hidden = YES;
    self.timeLabel.hidden = NO;
     self.placeLabel.hidden = YES;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.font = ThemeFontLarge;
    self.nameLabel.font = ThemeFontLarge;
    self.infoLabel.font = ThemeFontSmall;
    self.timeLabel.font = ThemeFontMiddle;
    self.placeLabel.font = ThemeFontMiddle;
    self.photoView.layer.cornerRadius = 4;//self.photoView.width / 2;
    self.photoView.layer.masksToBounds = YES;
}
///联系人
- (void)setContactDic:(NSDictionary *)contactDic {
    [self clearData];
    self.photoView.hidden = YES;
    self.headView.hidden = YES;
    self.titleLabel.hidden = YES;
    self.nameLabel.hidden = YES;
    self.infoLabel.hidden = YES;
    self.timeLabel.hidden = YES;
    self.placeLabel.hidden = YES;
    _contactDic = contactDic;
    //默认样式
    self.photoView.hidden = NO;
    self.headView.hidden = YES;
    self.titleLabel.hidden = YES;
    self.nameLabel.hidden = NO;
    self.infoLabel.hidden = NO;
    self.timeLabel.hidden = YES;
    self.placeLabel.hidden = YES;
    NSString *titleLabStr = contactDic[Table_User_member_name]?:contactDic[Table_User_mobile];
    self.nameLabel.attributedText = [self changeAttrString:titleLabStr text:self.currentSearchText color:ThemeColor];
//    if ([contactDic[Table_User_position_name] length] >0) {
//        self.placeLabel.text = [NSString stringWithFormat:@" | %@",contactDic[Table_User_position_name]];
//          self.placeLabel.hidden = NO;
//    }

    /// 姓名职位部门
    if (contactDic[Table_User_department_id]) {
        NSString *department_idStr = [[Chat sharedInstance].componentDelegate getDeptNameWithDeptID:contactDic[Table_User_department_id]];
        self.infoLabel.attributedText = [self changeAttrString:department_idStr text:self.currentSearchText color:ThemeColor];
    }

    self.nameLabel.attributedText = [NSAttributedString setAttributedStringWithNameAttributedString:self.nameLabel.attributedText withPlaceString:contactDic[Table_User_position_name] withPlaceColor:[UIColor colorWithHexString:@"#666666"]];
    self.backgroundColor = [UIColor clearColor];
    
    
    NSString *strPP = contactDic[Table_User_avatar];
    NSString *md5 = contactDic[Table_User_urlmd5];
    if (!KCNSSTRING_ISEMPTY(strPP) && !KCNSSTRING_ISEMPTY(md5)) {
#if isHeadRequestUserMd5
        [self.photoView setImageWithURLString:strPP urlmd5:md5 options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(self.photoView.size, contactDic[Table_User_member_name],contactDic[Table_User_account]) withRefreshCached:NO];
#else
        [self.photoView sd_setImageWithURL:[NSURL URLWithString:contactDic[Table_User_avatar]] placeholderImage:ThemeDefaultHead(self.photoView.size, contactDic[Table_User_member_name],contactDic[Table_User_account]) options:SDWebImageRefreshCached|SDWebImageRetryFailed];
#endif
    }else{
        if (!KCNSSTRING_ISEMPTY(strPP)) {
            [self.photoView sd_setImageWithURL:[NSURL URLWithString:contactDic[Table_User_avatar]] placeholderImage:ThemeDefaultHead(self.photoView.size, contactDic[Table_User_member_name],contactDic[Table_User_account]) options:SDWebImageRefreshCached|SDWebImageRetryFailed];
        }else{
            [self.photoView sd_cancelCurrentImageLoad];
            self.photoView.image = ThemeDefaultHead(self.photoView.size, contactDic[Table_User_member_name],contactDic[Table_User_account]);
        }
       
    }
}
///联系人 对象
- (void)setAddress:(KitCompanyAddress *)address{
    [self clearData];
    _address = address;
    //默认样式
    self.photoView.hidden = NO;
    self.headView.hidden = YES;
    self.titleLabel.hidden = YES;
    self.nameLabel.hidden = NO;
    self.infoLabel.hidden = NO;
    self.timeLabel.hidden = YES;
    self.placeLabel.hidden = YES;
    NSString *titleLabStr = address.name?:address.mobilenum;
    self.nameLabel.attributedText = [self changeAttrString:titleLabStr text:self.currentSearchText color:ThemeColor];
    self.nameLabel.attributedText = [NSAttributedString setAttributedStringWithNameAttributedString:self.nameLabel.attributedText withPlaceString:address.place withPlaceColor:[UIColor colorWithHexString:@"#666666"]];
//    self.infoLabel.attributedText = [self changeAttrString:address.mobilenum text:self.currentSearchText color:ThemeColor];
     self.infoLabel.attributedText = [self changeAttrString:address.depart_name text:self.currentSearchText color:ThemeColor];
//    if (ISLEVELMODE && address.level <= [[[Common sharedInstance] getUserLevel] intValue] - 2) {
//        self.infoLabel.text = languageStringWithKey(@"**********");
//    }
    NSString *strPP = address.photourl;
    NSString *md5 = address.urlmd5;
    if (!KCNSSTRING_ISEMPTY(strPP) && !KCNSSTRING_ISEMPTY(md5)) {
#if isHeadRequestUserMd5
        [self.photoView setImageWithURLString:strPP urlmd5:md5 options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(self.photoView.size, contactDic[Table_User_member_name],contactDic[Table_User_account]) withRefreshCached:NO];
#else
        [self.photoView sd_setImageWithURL:[NSURL URLWithString:strPP] placeholderImage:ThemeDefaultHead(self.photoView.size, address.name,address.account) options:SDWebImageRefreshCached |SDWebImageRetryFailed];
#endif
    }else{
        
        if ([address.account isEqualToString:FileTransferAssistant]) {
//              self.nameLabel.text = languageStringWithKey(@"文件传输助手");
              self.photoView.image = ThemeImage(@"icon_filetransferassistant");
        }else {
            if (!KCNSSTRING_ISEMPTY(strPP)) {
                [self.photoView sd_setImageWithURL:[NSURL URLWithString:strPP] placeholderImage:ThemeDefaultHead(self.photoView.size, address.name,address.account) options:SDWebImageRefreshCached |SDWebImageRetryFailed];
            }else{
                [self.photoView sd_cancelCurrentImageLoad];
                self.photoView.image = ThemeDefaultHead(self.photoView.size, address.name,address.account);
            }
        }
    }
}

///聊天记录
- (void)setRecordDic:(NSDictionary *)recordDic{
    [self clearData];
    _recordDic = recordDic;
    //默认样式
    self.photoView.hidden = NO;
    self.headView.hidden = YES;
    self.titleLabel.hidden = YES;
    self.nameLabel.hidden = NO;
    self.infoLabel.hidden = NO;
    self.timeLabel.hidden = NO;
 self.placeLabel.hidden = YES;
    NSArray *searchMessageArr = _recordDic[@"searchMessageArr"];
    ECSession *session = _recordDic[@"searchSession"];

    //系统通知type=100
    if (session.type == 100) {
        self.nameLabel.text = session.sessionId;
        self.photoView.image = ThemeImage(@"logo80x80.png");
    }else{//群组消息
        if([session.sessionId hasPrefix:@"g"]){
            self.nameLabel.text = [[Common sharedInstance] getOtherNameWithPhone:session.sessionId];
            [self reloadImage];
        }else{//个人聊天
            NSString *sessionStr = session.sessionId;
            self.infoLabel.text = session.text;
            //cell复用时取消当前异步下载线程，解决头像错乱问题
            [self.photoView sd_cancelCurrentImageLoad];

            NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:sessionStr withType:0];
            NSString *sex = @"";
            if(companyInfo){
                self.nameLabel.text = companyInfo[Table_User_member_name]?:companyInfo[Table_User_mobile];
                sex = companyInfo[Table_User_sex];
                NSString *headImageUrl = companyInfo[Table_User_avatar];
                NSString *md5 = companyInfo [Table_User_urlmd5];
                if([headImageUrl hasPrefix:@"http"] && !KCNSSTRING_ISEMPTY(md5)){
#if isHeadRequestUserMd5
                    [self.photoView setImageWithURLString:headImageUrl urlmd5:md5 options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(self.photoView.size, companyInfo[Table_User_member_name],sessionStr) withRefreshCached:NO];
#else
                    [self.photoView sd_setImageWithURL:[NSURL URLWithString:headImageUrl] placeholderImage:ThemeDefaultHead(self.photoView.size, companyInfo[Table_User_member_name],sessionStr) options:SDWebImageRefreshCached|SDWebImageRetryFailed];
#endif
                }else{
                    self.photoView.image = ThemeDefaultHead(self.photoView.size, companyInfo[Table_User_member_name],sessionStr);
                }
            }else{
                if ([sessionStr isEqualToString:FileTransferAssistant]) {
                   self.nameLabel.text = languageStringWithKey(@"文件传输助手");
                   self.photoView.image = ThemeImage(@"icon_filetransferassistant");
                }else {
                    self.nameLabel.text = session.sessionId;
                    self.photoView.image = ThemeDefaultHead(self.photoView.size, session.sessionId,sessionStr);
                }
            }
            
        }
    }
    //判断是不是搜索 头像两个tableView都可以使用
    if (searchMessageArr.count == 1) {
        ECMessage *message = searchMessageArr[0];
        ECTextMessageBody *body = (ECTextMessageBody *)message.messageBody;
        self.infoLabel.attributedText = [self changeAttrString:body.text text:self.currentSearchText color:ThemeColor];
        self.timeLabel.text = [ChatTools getDateDisplayStringWithSession:message.timestamp.longLongValue];
    } else if (searchMessageArr.count > 1){
        NSString *tepStr = languageStringWithKey(@"条相关聊天记录");
        self.infoLabel.text = [NSString stringWithFormat:@"%zd%@",(unsigned long)searchMessageArr.count,tepStr];
        ECMessage *message = searchMessageArr[0];
        self.timeLabel.text = [ChatTools getDateDisplayStringWithSession:message.timestamp.longLongValue];
    } else {
        NSString *notice_key = [NSString stringWithFormat:@"%@_%@_notice",[[Common sharedInstance] getAccount], session.sessionId];
        NSString *resultStr = [[NSUserDefaults standardUserDefaults] objectForKey:notice_key];
        //时间，内容和未读显示
        NSArray *message = [[KitMsgData sharedInstance] getLatestHundredMessageOfSessionId:session.sessionId andSize:15 andASC:YES];
        if(message.count < 1 && session.type!=100){
            self.infoLabel.text = @"";
            self.timeLabel.text = @"";
        }else{
            //如果用户设置了不通知 而且未读消息数大于1 显示有几条数据
            if (session.unreadCount > 0 && [resultStr isEqualToString:@"1"]) {
                NSString *tepS = languageStringWithKey(@"条");
                NSString *str = [NSString stringWithFormat:@"[%@%ld]%@",tepS,(long)session.unreadCount,session.text];
                self.infoLabel.text = str;
            } else {
                self.infoLabel.text = session.text;
            }
            self.timeLabel.text = [ChatTools getDateDisplayStringWithSession:session.dateTime];
        }
    }
}
///群组
- (void)setGroup:(ECGroup *)group{
    [self clearData];
    _group = group;
    //默认样式
    self.photoView.hidden = NO;
    self.headView.hidden = YES;
    self.titleLabel.hidden = NO;
    self.nameLabel.hidden = YES;
    self.infoLabel.hidden = YES;
    self.timeLabel.hidden = NO;
    self.placeLabel.hidden = YES;
    [self reloadImage];
    if (group.remark && ![group.remark isEqualToString:@""]) {
        self.nameLabel.text = group.name;
        self.infoLabel.attributedText = [self changeAttrString:[NSString stringWithFormat:@"包含:%@",group.remark] text:self.currentSearchText color:ThemeColor];
        self.titleLabel.hidden = YES;
        self.nameLabel.hidden = NO;
        self.infoLabel.hidden = NO;
    }else{
        self.titleLabel.attributedText = [self changeAttrString:group.name text:self.currentSearchText color:ThemeColor];
        self.titleLabel.hidden = NO;
        self.nameLabel.hidden = YES;
        self.infoLabel.hidden = YES;
    }

    NSInteger memberCount = [KitGroupMemberInfoData getAllMemberCountGroupId:group.groupId];
    self.timeLabel.text = [NSString stringWithFormat:@"(%d)",(int)memberCount];
}
///一个session有多条消息的 显示
- (void)setMessage:(ECMessage *)message{
    [self clearData];
    _message = message;
    //默认样式
    self.photoView.hidden = NO;
    self.headView.hidden = YES;
    self.titleLabel.hidden = YES;
    self.nameLabel.hidden = NO;
    self.infoLabel.hidden = NO;
    self.timeLabel.hidden = NO;
 self.placeLabel.hidden = YES;
    if([self.session.sessionId hasPrefix:@"g"]){//群组消息
        self.nameLabel.text = [[Common sharedInstance] getOtherNameWithPhone:self.session.sessionId];
        [self reloadImage];
    }else{//个人聊天
        //cell复用时取消当前异步下载线程，解决头像错乱问题
        [self.photoView sd_cancelCurrentImageLoad];

        NSString *sessionStr = self.session.sessionId;
        NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:sessionStr withType:0];
        if(companyInfo){
            self.nameLabel.text = companyInfo[Table_User_member_name]?companyInfo[Table_User_member_name]:companyInfo[Table_User_mobile];
            NSString *headImageUrl = companyInfo[Table_User_avatar];

            if([companyInfo[Table_User_status] isEqualToString:@"3"]){//离职
                self.photoView.image = ThemeDefaultHead(self.photoView.size, RXleaveJobImageHeadShowContent,sessionStr);
            }else{
                [self.photoView setImageWithURLString:headImageUrl urlmd5:companyInfo[Table_User_urlmd5] options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(self.photoView.size, self.nameLabel.text,sessionStr) withRefreshCached:NO];
            }
        }else{
            self.nameLabel.text = self.session.sessionId;
            self.photoView.image = ThemeDefaultHead(self.photoView.size, sessionStr,sessionStr);
        }
    }
    ECTextMessageBody *body = (ECTextMessageBody *)self.message.messageBody;
    self.infoLabel.attributedText = [self changeAttrString:body.text text:self.currentSearchText color:ThemeColor];
    self.timeLabel.text = [ChatTools getDateDisplayStringWithSession:message.timestamp.longLongValue];
}

///群组刷新头像
- (void)reloadImage{
    self.photoView.hidden = YES;
    self.headView.hidden = NO;

    //群组id
    NSString *groupId = _group.groupId ?:[(ECSession *)_recordDic[@"searchSession"] sessionId]?:self.session.sessionId;
    NSInteger memberCount = [KitGroupMemberInfoData getAllMemberCountGroupId:groupId];
    self.photoView.hidden = NO;
    self.headView.hidden = YES;
    self.photoView.image = ThemeImage(@"icon_groupdefaultavatar");
    if (memberCount == 1) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<KitGroupMemberInfoData *> *members = [KitGroupMemberInfoData getSequenceMembersforGroupId:groupId memberCount:9];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(members.count == 1){
                KitGroupMemberInfoData *info = members.firstObject;
                if([info.role isEqualToString:@"1"] ||
                   [info.role isEqualToString:@"2"]){
                    return;
                }
            }
            if(members.count > 1){//直接加载头像 先查看本地 后加载网络
                self.photoView.hidden = YES;
                self.headView.hidden = NO;
                [self.headView createHeaderViewH:self.headView.width withImageWH:self.headView.width groupId:groupId withMemberArray:members];
                return;
            }
            if ([[Common sharedInstance].cacheGroupMemberRequestArray containsObject:groupId]) {
                return;
            }
            [[Common sharedInstance].cacheGroupMemberRequestArray addObject:groupId];
            [[ECDevice sharedInstance].messageManager queryGroupMembers:groupId completion:^(ECError *error, NSString *groupId, NSArray *members) {
                [[Common sharedInstance].cacheGroupMemberRequestArray removeObject:groupId];
                if (error.errorCode == ECErrorType_NoError && members.count > 0) {
                    [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
                    [KitGroupMemberInfoData insertGroupMemberArray:members withGroupId:groupId];
                    //wwl 群组头像刷新改为通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_ReloadSessionGroup object:groupId];
                }
            }];
        });
    });
}
///清除数据 以免复用
- (void)clearData{
    _contactDic = nil;
    _recordDic = nil;
    _group = nil;
    _message = nil;
}

@end
