//
//  SessionViewCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "SessionViewCell.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSAttributedString+Color.h"

@implementation SessionViewCell

- (void)setSession:(ECSession *)session{
    if (_session != session) {
        _session = session;
    }
    [self setLayoutView];
}

/**
设置设备信息

 @param state 设备信息枚举值
 */
- (void)setStateLabelWithState:(ECUserState *)state{
    NSString *deviceName = languageStringWithKey(@"未知设备");
    NSString *net;
    switch (state.deviceType) {
        case 0:
            deviceName = languageStringWithKey(@"未知设备");
            break;
        case 1:
            deviceName = languageStringWithKey(@"Android");
            break;
        case 2:
            deviceName = languageStringWithKey(@"iPhone");
            break;
        case 10:
            deviceName = @"iPad";
            break;
        case 11:
            deviceName = languageStringWithKey(@"Android PAD");
            break;
        case 20:
            deviceName = @"Windows";
            break;
        case 21:
            deviceName = @"Web";
            break;
        case 22:
            deviceName = @"Mac";
            break;
        default:
            break;
    }
    switch (state.network) {
        case 0:
            net = languageStringWithKey(@"当前无网络");
            break;
        case 1:
            net = @"WiFi";
            break;
        case 2:
            net = @"4G";
            break;
        case 3:
            net = @"3G";
            break;
        case 4:
            net = @"gprs";
            break;
        case 5:
            net = @"Internet";
            break;
        case 6:
            net = languageStringWithKey(@"其他");
            break;
            
        default:
            break;
    }
    NSString *stateStr = [NSString stringWithFormat:@"%@-%@",deviceName,net];
    [[NSUserDefaults standardUserDefaults] setObject:stateStr forKey:[NSString stringWithFormat:@"%@_netState",self.session.sessionId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    self.deptlabel.text = [NSString stringWithFormat:@" [%@]",stateStr];
    self.deptlabel.text = [NSString stringWithFormat:@" %@",languageStringWithKey(@"[在线]")];
}

- (void)initSubView:(CGFloat)scale {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage:) name:@"changeLanguage" object:nil];
    _portraitImg.hidden = NO;
    _groupHeadView.hidden = YES;
    _dateLabel.hidden = NO;
    _contentLabel.hidden = NO;
    _unReadLabel.hidden = YES;
    _deptlabel.hidden = YES;
    _notDisturbView.hidden = YES;
}

- (void)changeLanguage:(NSNotification *)notification{
    [[KitMsgData sharedInstance] updateDraft:nil withSessionID:self.session.sessionId];
}

- (void)setLayoutView {
    //2017yxp
    CGFloat porHeightFloat = self.deviceScale;
    [self initSubView:porHeightFloat];
    _session.text = [_session.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    if (_session.type == 100) {
        self.nameLabel.text = _session.sessionId;
        self.portraitImg.image = ThemeImage(@"logo80x80.png");
    } else if (_session.type == 105){
        [self showPublicMessage];
    } else if (_session.type == HXOAMessageTypePublicNum || [_session.sessionId hasPrefix:KOAMessage_sessionIdentifer]) {
        [self HXOAMessageShow];
         self.deptlabel.hidden = YES;
    } else if ([_session.sessionId isEqualToString:FileTransferAssistant]) {
        self.nameLabel.text = languageStringWithKey(@"文件传输助手");
        self.portraitImg.image = ThemeImage(@"icon_filetransferassistant");
        self.contentLabel.text = _session.text;
        self.deptlabel.hidden = YES;
    } else if ([_session.sessionId isEqualToString:@"rx4"]) {
        [self.portraitImg sd_cancelCurrentImageLoad];
        self.nameLabel.text = AttenceTitle;
        self.portraitImg.image = ThemeImage(@"attenceSession.png");
        self.contentLabel.text =_session.text;
         self.deptlabel.hidden = YES;
    } else if ([_session.sessionId isEqualToString:YHC_CONFMSG]) {
        [self.portraitImg sd_cancelCurrentImageLoad];
        self.nameLabel.text = languageStringWithKey(@"会议助手");
        self.portraitImg.image = ThemeImage(@"addressbook_icon_meeting");
        self.contentLabel.text = _session.text;
        self.deptlabel.hidden = YES;
    } else {
        BOOL isGroup = [_session.sessionId hasPrefix:@"g"]?YES:NO;
        if(isGroup){
            self.deptlabel.hidden = YES;
            [self loadGroupHeadImage:self withGroupId:_session.sessionId];
        } else {
            [self voipRecordsMessageChangeText];
            self.contentLabel.text = _session.text;
            // 请求失败，从缓存读取
            NSString * stateStr = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_netState",self.session.sessionId]];
            if ([stateStr isEqualToString:languageStringWithKey(@"对方不在线")] || (stateStr.length < 1)) {
                self.deptlabel.text = [NSString stringWithFormat:@" %@",languageStringWithKey(@"[离线]")];
                 self.deptlabel.hidden = NO;
            } else {
                self.deptlabel.text = [NSString stringWithFormat:@" %@",languageStringWithKey(@"[在线]")];
                 self.deptlabel.hidden = NO;
            }
            [self checkNet];
            //设置网络状态
            if([Chat sharedInstance].isSessionEdgQueue) {
                __weak typeof(self)weakSelf = self;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:(isGroup?self.session.fromId:self.session.sessionId) withType:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showImAppointMessage:companyInfo];
                    });
                });
            } else {
                NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId: (isGroup?_session.fromId:_session.sessionId) withType:0];
                [self showImAppointMessage:companyInfo];
            }
        }
    }
    if ([_session.sessionId isEqualToString:YHC_CONFMSG]) {
        _dateLabel.text = [ChatTools getSessionDateDisplayString:_session.dateTime];//*1000.0];
    } else {
        _dateLabel.text = [ChatTools getSessionDateDisplayString:_session.dateTime];
    }
}

// 快速编译方法，无需调用
- (void)injected{
    NSLog(@"eagle.injected");
    
}

- (void)checkNet{
    
    [[ECDevice sharedInstance] getUsersState:@[self.session.sessionId] completion:^(ECError *error, NSArray *usersState) {
        if ([self.session.sessionId hasPrefix:@"g"]) {
            DDLogInfo(@"群组没有状态");
            self.deptlabel.hidden = YES;
            return ;
        }
        self.deptlabel.text = [NSString stringWithFormat:@" %@",languageStringWithKey(@"[离线]")];//languageStringWithKey(@"对方不在线");
        //解决偶现文件助手出现离线的问题  会议助手的也不要显示
        if (![self.session.sessionId isEqualToString:FileTransferAssistant] && ![self.session.sessionId isEqualToString:YHC_CONFMSG] && self.session.type != 105) {
            self.deptlabel.hidden = NO;
        }
        NSLog(@"eagele.error.code = %ld",(long)error.errorCode);
        if (error.errorCode == ECErrorType_NoError) {
            if (usersState.count != 1) {
                return ;
            }
            ECUserState *state = usersState.firstObject;
            if (state.isOnline) {
                [self setStateLabelWithState:state];

            } else {
                NSString *onLineStr =  languageStringWithKey(@"对方不在线");
                [[NSUserDefaults standardUserDefaults] setObject:onLineStr forKey:[NSString stringWithFormat:@"%@_netState",self.session.sessionId]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } else {
            // 请求失败，从缓存读取
            NSString * stateStr = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_netState",self.session.sessionId]];
            if ([stateStr isEqualToString:languageStringWithKey(@"对方不在线")] || (stateStr.length < 1)) {
                self.deptlabel.text = [NSString stringWithFormat:@" %@",languageStringWithKey(@"[离线]")];
            }else{
               self.deptlabel.text = [NSString stringWithFormat:@" %@",languageStringWithKey(@"[在线]")];
            }
        }
    }];
}

///音视频需要修改_session的text
- (void)voipRecordsMessageChangeText{
    ECMessage *msg = [[AppModel sharedInstance] runModuleFunc:@"KitMsgData" :@"getMessageById:" :@[_session.sessionId]];
    if (msg.isVoipRecordsMessage) {
        NSDictionary *im_modeDic = [MessageTypeManager getCusDicWithUserData:msg.userData];
        if([im_modeDic[@"callType"] intValue] == 1) {//语音
            if ([im_modeDic[@"status"] integerValue] == 103) {
                _session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"已拒绝")];
            }
            else {
                _session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"语音通话")];
            }
        } else if ([im_modeDic[@"callType"] intValue] == 2) {//视频
            if ([im_modeDic[@"status"] integerValue] == 103) {
                _session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"已拒绝")];
            }
            else {
                _session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"视频通话")];
            }
        }
    }
}

#pragma mark - 单聊
//点对点消息
- (void)showImAppointMessage:(NSDictionary *)companyInfo{
    self.nameLabel.text = _session.sessionId;
    if(companyInfo.count > 0) {
        NSString *nameString = companyInfo[Table_User_member_name]?:companyInfo[Table_User_mobile];
        ///名称
        self.nameLabel.text = nameString;

        NSString *departmentName = nil;
        if ([companyInfo[Table_User_Level] integerValue] > 2) {
            departmentName = [[Chat sharedInstance].componentDelegate getDeptNameWithDeptID:companyInfo[Table_User_department_id]];
        }
        //部门
        if(departmentName && ![departmentName isEqualToString:@""]){
//            _deptlabel.hidden = NO;
//            _deptlabel.text = [NSString stringWithFormat:@" | %@",departmentName];
        }
        NSString *headImageUrl = companyInfo[Table_User_avatar];
        NSString *md5 = companyInfo[Table_User_urlmd5];
        [self.portraitImg sd_cancelCurrentImageLoad];
        
        NSString *userStatus = companyInfo[Table_User_status];
        if([userStatus isEqualToString:@"3"]){
            self.portraitImg.image = ThemeDefaultHead(self.portraitImg.size, RXleaveJobImageHeadShowContent,companyInfo[Table_User_account]);
        } else {
            if(!(KCNSSTRING_ISEMPTY(headImageUrl))){
                [self.portraitImg setImageWithURLString:headImageUrl urlmd5:md5 options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(self.portraitImg.size, companyInfo[Table_User_member_name],companyInfo[Table_User_account]) withRefreshCached:NO];
            }else{
                self.portraitImg.image = ThemeDefaultHead(self.portraitImg.size, companyInfo[Table_User_member_name],companyInfo[Table_User_account]);
            }
        }
        //改变坐标
        if (_nameLabel.text) {
            CGFloat porHeightFloat = self.deviceScale*FitThemeFont;
            CGSize size = [_nameLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontLarge,NSFontAttributeName, nil]];
            CGSize onlineSize = [_deptlabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontMiddle,NSFontAttributeName, nil]];

            CGFloat maxWidth = kScreenWidth - self.portraitImg.right - 30 - self.dateLabel.width;
            if (_deptlabel.hidden == NO) {
                maxWidth -= onlineSize.width;
            }
            CGFloat width = size.width < maxWidth ? size.width: maxWidth;
            _nameLabel.frame = CGRectMake(_portraitImg.right + 15, 13 * porHeightFloat, width, 20 *porHeightFloat);
            _deptlabel.frame = CGRectMake(_nameLabel.right, 13 * self.deviceScale*FitThemeFont, onlineSize.width + 2 ,20 *porHeightFloat);
        }
        return;
    }
    
    if (isOpenPhoneContact) {/// eagle  这里也可能是手机通讯录
        id addBook = [[AppModel sharedInstance] runModuleFunc:@"KitAddressBookManager" :@"checkAddressBook:" :@[_session.sessionId] hasReturn:YES];
        NSDictionary *dic = [addBook yy_modelToJSONObject];
        if ([dic hasValueForKey:@"name"]) {
            self.nameLabel.text = [dic valueForKey:@"name"];
            [self.portraitImg sd_cancelCurrentImageLoad];
            self.portraitImg.image = ThemeDefaultHead(self.portraitImg.size, [dic valueForKey:@"name"],nil);
            return;
        }
    }
    
    [self.portraitImg sd_cancelCurrentImageLoad];
    self.portraitImg.image = ThemeDefaultHead(self.portraitImg.size, _session.sessionId,_session.sessionId);
    if ([self.session.sessionId isEqualToString:IMSystemLoginSessionId]) {
        self.portraitImg.image = ThemeImage(@"icon_personalassistant");
        self.nameLabel.text = @"个人助手";
        self.contentLabel.text = @"IM系统已登录";
    }
}

#pragma mark - 群聊
//群组消息 现在加载群组头像规则改成 先去数据库查找count,而不是找成员信息 如果大于1的话 判断是否是滑动查看(isSessionEdgQueue为YES)  是的话 就是异步加载 去查询数据库  查数据库如果通讯录没有下载  没有下载直接查群组成员表,下载了的话直接查询通讯录表  如果不是异步加载的话 就主线程走一次
- (void)loadQueueGroupHeadImage:(SessionViewCell *)cell withGroupId:(NSString *)groupId{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loadGroupName:cell withGroupId:groupId];
        [self loadGroupImage:cell withGroupId:groupId];
    });
}

- (void)loadGroupHeadImage:(SessionViewCell *)cell withGroupId:(NSString *)groupId{
    [self loadGroupName:cell withGroupId:groupId];
    [self loadGroupImage:cell withGroupId:groupId];
}

///名称副标题相关
- (void)loadGroupName:(SessionViewCell *)cell withGroupId:(NSString *)groupId{
    NSString *fromName = nil;
    if(![_session.fromId isEqualToString:[Common sharedInstance].getAccount] &&
       !KCNSSTRING_ISEMPTY(_session.fromId) &&
       ![_session.fromId isEqualToString:languageStringWithKey(@"群组退出通知")] &&
       ![_session.fromId isEqualToString:@"10089"]){
        NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId: ([_session.sessionId hasPrefix:@"g"]?_session.fromId:_session.sessionId) withType:0];
        if(companyInfo.count > 0){
            fromName = [NSString stringWithFormat:@"%@: ",companyInfo[Table_User_member_name]?:companyInfo[Table_User_mobile]];
        }else{
            fromName = [NSString stringWithFormat:@"%@: ",_session.fromId];
        }
        KitGroupMemberInfoData *data = [KitGroupMemberInfoData getGroupMemberInfoWithMemberId:_session.fromId withGroupId:_session.sessionId];
        if (data.memberName) { // 有昵称就显示昵称
            fromName = [NSString stringWithFormat:@"%@: ",data.memberName];
        }
    }
    NSString *groupName = [[Common sharedInstance] getOtherNameWithPhone:self.session.sessionId];
    self.nameLabel.text = groupName;
    if(!KCNSSTRING_ISEMPTY(self.session.draft)){
        self.contentLabel.text = self.session.draft;
    } else {
        if (self.session.type == 0 || self.session.isNotice) {
            self.contentLabel.text = [NSString stringWithFormat:@"%@",self.session.text];
        } else {
            self.contentLabel.text = [NSString stringWithFormat:@"%@%@",(fromName?:@""),self.session.text];
        }
    }
}
///头像相关
- (void)loadGroupImage:(SessionViewCell *)cell withGroupId:(NSString *)groupId{
    NSInteger memberCount = [KitGroupMemberInfoData getAllMemberCountGroupId:self.session.sessionId];
    if(memberCount == 0){
        cell.portraitImg.hidden = NO;
        cell.groupHeadView.hidden = YES;
        cell.portraitImg.image = ThemeImage(@"icon_groupdefaultavatar");
        if ([[Common sharedInstance].cacheGroupMemberRequestArray containsObject:groupId]) {
            return;
        } else {
            [[Common sharedInstance].cacheGroupMemberRequestArray addObject:groupId];
            [[ECDevice sharedInstance].messageManager queryGroupMembers:groupId completion:^(ECError *error, NSString* groupId, NSArray *members) {
                [[Common sharedInstance].cacheGroupMemberRequestArray removeObject:groupId];
                if (error.errorCode == ECErrorType_NoError && members.count > 0) {
                    [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
                    [KitGroupMemberInfoData insertGroupMemberArray:members withGroupId:groupId];
                    //wwl 群头像刷新改为通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_ReloadSessionGroup object:groupId];
                }
            }];
        }
    } else {//直接加载头像 先查看本地 后加载网络
        if (isLargeAddressBookModel) {
            [self loadGroupImageWhenBigAddress:cell withGroupId:groupId];
        } else {
            NSArray *members = [KitGroupMemberInfoData getSequenceMembersforGroupId:groupId memberCount:9];                cell.portraitImg.hidden = YES;
            cell.groupHeadView.hidden = NO;
            [self groupHeadMembers:members withGroupId:groupId];
        }
    }
}
#pragma mark - 大通讯录 群组头像需调接口查询
- (void)loadGroupImageWhenBigAddress:(SessionViewCell *)cell withGroupId:(NSString *)groupId{
    NSArray *members = [KitGroupMemberInfoData getMemberInfoWithGroupId:groupId withCount:9];
    ///连表查询结果
    NSArray *oldMembers = [KitGroupMemberInfoData getSequenceMembersforGroupId:groupId memberCount:9];
    cell.portraitImg.hidden = YES;
    cell.groupHeadView.hidden = NO;
    if (members.count == oldMembers.count) {
        [self groupHeadMembers:oldMembers withGroupId:groupId];
        return ;
    }

    NSMutableArray *accoutList = [[NSMutableArray alloc] init];
    for (KitGroupMemberInfoData *memberInfo in members) {
        [accoutList addObject:[NSString stringWithFormat:@"%@",memberInfo.memberId]];
    }
    [[RestApi sharedInstance] getUserAvatarListByUseraccList:accoutList type:@"2" didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        NSArray *dataArr = dict[@"body"][@"voipinfo"];
        NSArray<KitCompanyAddress *> *array = [NSArray yy_modelArrayWithClass:KitCompanyAddress.class json:dataArr.yy_modelToJSONString];
        for (int i = 0; i < array.count; i++) {
            KitGroupMemberInfoData *memberInfo = members[i];
            KitCompanyAddress *addressInfo = array[i];
            memberInfo.headUrl =  addressInfo.photourl;
            memberInfo.headMd5 = addressInfo.urlmd5;
            memberInfo.userName = addressInfo.name;
        }
        [KitCompanyAddress insertCompanyAddressInfo:dataArr];

        cell.portraitImg.hidden = YES;
        cell.groupHeadView.hidden = NO;
        [self groupHeadMembers:members withGroupId:groupId];
    } didFailLoaded:^(NSError *error, NSString *path) {
        cell.portraitImg.hidden = NO;
        cell.groupHeadView.hidden = YES;
        cell.portraitImg.image = ThemeImage(@"icon_groupdefaultavatar");
    }];
}

#pragma mark - groupLoadHeadImage
///生成头像
- (void)groupHeadMembers:(NSArray *)members withGroupId:(NSString *)groupId{
    if(members.count == 0){
        self.portraitImg.hidden = NO;
        self.groupHeadView.hidden = YES;
        self.portraitImg.image = ThemeImage(@"icon_groupdefaultavatar");
    }
    [self.groupHeadView createHeaderViewH:50.0f *self.deviceScale*FitThemeFont withImageWH:50.0f *self.deviceScale*FitThemeFont groupId:groupId withMemberArray:members];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDeviceScale:(CGFloat)deviceScale {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.deviceScale = deviceScale;
        CGFloat porHeightFloat = deviceScale*FitThemeFont;
        
        _portraitImg = [[UIImageView alloc] initWithFrame:CGRectMake(15.0f, (72.0f * porHeightFloat - 50 * porHeightFloat)/2, 50.0f * porHeightFloat, 50.0f * porHeightFloat)];
        _portraitImg.layer.cornerRadius = 4;
        _portraitImg.layer.masksToBounds = YES;
        _portraitImg.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_portraitImg];
        
        self.groupHeadView = [[RXGroupHeadImageView alloc] initWithFrame:CGRectMake(15.0f, (72.0f * porHeightFloat - 50 * porHeightFloat)*FitThemeFont/2, 50.0f * porHeightFloat, 50.0f * porHeightFloat)];
        self.groupHeadView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.groupHeadView];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 75*porHeightFloat, 13*porHeightFloat, 65*porHeightFloat, 20.0f*porHeightFloat)];
        _dateLabel.textColor = [UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.00f];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.font = ThemeFontSmall;
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

        _unReadLabel = [[UILabel alloc]initWithFrame:CGRectMake(_portraitImg.right-9*porHeightFloat, 2*porHeightFloat, 18.0f*porHeightFloat, 18.0f*porHeightFloat)];
        _unReadLabel.layer.backgroundColor = [UIColor colorWithRed:1.00f green:0.29f blue:0.25f alpha:1.00f].CGColor;
        _unReadLabel.textColor = [UIColor whiteColor];
        _unReadLabel.font =ThemeFontSmall;
        _unReadLabel.layer.cornerRadius = 10*porHeightFloat;
        _unReadLabel.layer.masksToBounds = YES;
        _unReadLabel.textAlignment = NSTextAlignmentCenter;
        _unReadLabel.layer.backgroundColor = [UIColor colorWithRed:1.00f green:0.29f blue:0.25f alpha:1.00].CGColor;
        [self.contentView addSubview:_unReadLabel];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_portraitImg.right + 15, 13 * porHeightFloat,kScreenWidth - 30 - self.portraitImg.right - self.dateLabel.width - 70, 20.0f * porHeightFloat)];
        _nameLabel.font = ThemeFontLarge;
        [self.contentView addSubview:_nameLabel];
        
        _deptlabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.right, 13 * porHeightFloat, 70 * porHeightFloat, 20.0f * porHeightFloat)];
        _deptlabel.font = ThemeFontMiddle;
        _deptlabel.textColor = [UIColor colorWithHexString:@"#999999"];
        [self.contentView addSubview:_deptlabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0f * porHeightFloat, _nameLabel.frame.origin.y+ _nameLabel.frame.size.height+7*porHeightFloat, kScreenWidth-30-120*porHeightFloat, 15.0f*porHeightFloat)];
        _contentLabel.font = ThemeFontMiddle;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor colorWithRed:0.68f green:0.68f blue:0.68f alpha:1.00f];
        [self.contentView addSubview:_contentLabel];
        
        //消息免打扰提示
        _notDisturbView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-16*fitScreenWidth*FitThemeFont-15*fitScreenWidth*FitThemeFont, _contentLabel.originY, 16*fitScreenWidth*FitThemeFont, 16*fitScreenWidth*FitThemeFont)];
        _notDisturbView.image = ThemeImage(@"message_icon_mute");
        _notDisturbView.hidden = YES;
        [self.contentView addSubview:_notDisturbView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat porHeightFloat = self.deviceScale*FitThemeFont;
    _portraitImg.frame = CGRectMake(15.0f, (72.0f * porHeightFloat - 50 * porHeightFloat)/2, 50.0f * porHeightFloat, 50.0f * porHeightFloat);
    _unReadLabel.frame = CGRectMake(_portraitImg.right - 12* porHeightFloat, self.portraitImg.originY - 4 * porHeightFloat, 18.0f * porHeightFloat, 18.0f * porHeightFloat);
    
    if (_dateLabel.text) {
        CGSize size = [_dateLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontSmall,NSFontAttributeName, nil]];
        _dateLabel.frame = CGRectMake(kScreenWidth - size.width - 15.f, 13*porHeightFloat, size.width + 5, 20.0f*porHeightFloat);
    }
    
    if (_nameLabel.text) {
        CGSize size = [_nameLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontLarge,NSFontAttributeName, nil]];
        CGSize onlineSize = [_deptlabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontMiddle,NSFontAttributeName, nil]];

        CGFloat maxWidth = kScreenWidth - self.portraitImg.right - 30 - self.dateLabel.width;
        if (_deptlabel.hidden == NO) {
            maxWidth -= onlineSize.width;
        }
        CGFloat width = size.width < maxWidth ? size.width: maxWidth;
        _nameLabel.frame = CGRectMake(_portraitImg.right + 15, 13 * porHeightFloat, width, 20 *porHeightFloat);
        _deptlabel.frame = CGRectMake(_nameLabel.right, 13 * self.deviceScale*FitThemeFont, onlineSize.width + 2 ,20 *porHeightFloat);
    }
  
    _contentLabel.frame = CGRectMake(30 + 45.0f*porHeightFloat, _nameLabel.frame.origin.y + _nameLabel.frame.size.height + 7 * porHeightFloat, kScreenWidth - 30 - 120*porHeightFloat, 15.0f*porHeightFloat);
    
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
            subView.backgroundColor = [UIColor clearColor];
        }
    }
    
    BOOL isSpecial = [HXSpecialData haveSpecialWithAccount:_session.fromId];
    _atLabel.text = nil;
    
    if (self.session.isAt) {
        _atLabel.hidden = NO;
        _atLabel.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"有人@我")];
        [_atLabel sizeToFit];
        
        CGRect frame = _contentLabel.frame;
        frame.origin.x = CGRectGetMaxX(_atLabel.frame);
        frame.size.width = self.frame.size.width - 120 * porHeightFloat - 20 - _atLabel.frame.size.width;
        _contentLabel.frame = frame;
        _atLabel.centerY = _contentLabel.centerY;
    } else if (isSpecial && _session.unreadCount > 0) {
        _atLabel.hidden = NO;
        _atLabel.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"特别关注")];
        [_atLabel sizeToFit];
        
        CGRect frame = _contentLabel.frame;
        frame.origin.x = CGRectGetMaxX(_atLabel.frame);
        frame.size.width = self.frame.size.width - 120 * porHeightFloat - 20 - _atLabel.frame.size.width;
        _contentLabel.frame = frame;
        _atLabel.centerY = _contentLabel.centerY;
    } else if(!KCNSSTRING_ISEMPTY(self.session.draft)){
        _atLabel.hidden = NO;
        _atLabel.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"草稿")];
        [_atLabel sizeToFit];
        _contentLabel.text = self.session.draft;
        
        CGRect frame = _contentLabel.frame;
        frame.origin.x = CGRectGetMaxX(_atLabel.frame);
        frame.size.width = self.frame.size.width-120*porHeightFloat-20-_atLabel.frame.size.width;
        _contentLabel.frame = frame;
        _atLabel.centerY = _contentLabel.centerY;
    } else {
        [_atLabel setHidden:YES];
        CGRect frame = _contentLabel.frame;
        frame.origin.x = _nameLabel.left;
        frame.size.width = self.frame.size.width - _nameLabel.left - 16*fitScreenWidth*FitThemeFont - 15;
        _contentLabel.frame = frame;
    }
    NSString *groupNotice = [NSString stringWithFormat:@"%@_%@_notice",[[Chat sharedInstance] getAccount],_session.sessionId];
    NSString *isNotice = [[NSUserDefaults standardUserDefaults] objectForKey:groupNotice];
    
    // fix bug liyijun 2017/08/10
    // #67013 消息免打扰，最新一条消息前添加条数提醒
    if (!IsHengFengTarget && [isNotice isEqualToString:@"1"]) {
        if (_session.unreadCount > 0) {
            NSString *tepS = [NSString stringWithFormat:@"%@", languageStringWithKey(@"条")];
            NSString *contentString = [NSString stringWithFormat:@"[%ld%@]%@: %@", (long)_session.unreadCount,tepS,[_session.sessionId hasPrefix:@"g"]?[[Common sharedInstance] getOtherNameWithPhone:_session.fromId]:@"",_session.text];
            _contentLabel.text = contentString;
        }
    }
    
    if (_session.unreadCount == 0) {
        _unReadLabel.hidden = YES;
        if([isNotice isEqualToString:@"1"]){
            _notDisturbView.hidden = NO;
        }
    }else{
        self.unReadLabel.frame = CGRectMake(self.portraitImg.right - 12* self.deviceScale*FitThemeFont, self.portraitImg.originY - 4 * self.deviceScale*FitThemeFont, 18.0f* self.deviceScale*FitThemeFont, 18.0f* self.deviceScale*FitThemeFont);
        self.unReadLabel.layer.cornerRadius = 9 * self.deviceScale*FitThemeFont;
        if([isNotice isEqualToString:@"1"]){
            //不通知消息提示音
            self.unReadLabel.text = @"";
            self.unReadLabel.frame = CGRectMake(self.portraitImg.right-4*FitThemeFont, (self.portraitImg.originY - 2)*FitThemeFont, 8.0f*FitThemeFont, 8.0f*FitThemeFont);
            self.unReadLabel.layer.cornerRadius = 4*FitThemeFont;
            _notDisturbView.hidden = NO;
        }else if ((int)_session.unreadCount > 99) {
            self.unReadLabel.text = @"...";
        }else{
            self.unReadLabel.text = [NSString stringWithFormat:@"%d",(int)_session.unreadCount];
        }
        self.unReadLabel.hidden =NO;
    }
    //置顶颜色
    NSString *strTop = [NSString stringWithFormat:@"%@_cur_top",_session.sessionId];
    NSString *topStr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,_session.sessionId]];
    if([topStr isEqualToString:strTop]){
        self.backgroundColor = [self colorWithHexString:@"#F2F2F2"];
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
}

//公众号
- (void)showPublicMessage {
    [self.portraitImg sd_cancelCurrentImageLoad];
    //订阅号
    //cell.portraitImg.image=[UIImage imageNamed:@"ReadVerified_icon.png"];
    NSString *tepS = languageStringWithKey(@"服务号");
    _nameLabel.text = [NSString stringWithFormat:@"%@",tepS];
    //cell.contentLabel.text=session.text;
    _dateLabel.text =_session.dateTime?[ChatTools getSessionDateDisplayString:_session.dateTime]:nil;
    
    _portraitImg.image = ThemeImage(@"app_official_account_icon");
    if(!_session.fromId){
        _contentLabel.text = [NSString stringWithFormat:@"%@",_session.text?_session.text:@""];
        return;
    }
    NSDictionary *publicDic = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"getPublicInforMessageId:":@[_session.fromId]];
    if(publicDic.count > 0){
        _contentLabel.text = [NSString stringWithFormat:@"%@: %@",[publicDic objectForKey:@"pn_name"],_session.text?_session.text:@""];
    }else{
        //cell.portraitImg.image=[UIImage imageNamed:@"ReadVerified_icon.png"];
        if(!KCNSSTRING_ISEMPTY(_session.fromId)){
            _contentLabel.text = [NSString stringWithFormat:@"%@: %@",_session.fromId,_session.text?_session.text:@""];
            __weak typeof(self)weak_self = self;
            [HYTApiClient getPublicInfoDataSig:[self md5:[Common sharedInstance].getAccount withStr2:[Common sharedInstance].getAppClientpwd] account:[Common sharedInstance].getAccount publicId:_session.fromId utime:nil didFinishLoadedMK:^(NSDictionary *json, NSString *path) {
                NSString *statuscode = [json objectForKey:@"statusCode"];
                if([statuscode isEqualToString:@"000000"]){
                    NSDictionary *dataJson = [json objectForKey:@"data"];
                    if ([weak_self.session.sessionId isEqualToString:KPublicMessList_publicId]) {
                        weak_self.contentLabel.text =[NSString stringWithFormat:@"%@: %@",[dataJson getStringForKey:@"pn_name"],weak_self.session.text];
                    }
                    /// eagle 更新服务号IM 消息数据库表的名字
                    
                    if ([dataJson hasValueForKey:@"id"]) {
                        [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"updatePublic_numberlistpnId:withDic:":@[dataJson[@"id"],dataJson]];
                    }
                    //更新服务号信息
                    [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"updatePublicMessageDic:":@[dataJson]];
                }
                NSInteger status = [[json objectForKey:@"status"] integerValue];
                
                if(status == publicNotExistErrorCode ||
                   status == publicDataNotExistErrorCode){
                    //公众号不存在
                    [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"removePublicMessage:":@[self->_session.fromId]];
                    [weak_self updateAllData];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_update_session_im_message_num object:nil];
                }
            } didFailLoadedMK:^(NSError *error, NSString *path) {
                DDLogInfo(@".........我的天..");
            }];
        } else {
            _contentLabel.text =_session.text;
        }
    }
}

- (void)HXOAMessageShow{
    [self.portraitImg sd_cancelCurrentImageLoad];
    if(_session.type==HXOAMessageTypePublicNum) {
        _nameLabel.text = OATitle;
        _portraitImg.image = ThemeImage(@"monitor_session.png");
        _contentLabel.text =_session.text;
    } else {
        _contentLabel.text =_session.text;
        
        NSRange range = [self.session.sessionId rangeOfString:KOAMessage_sessionIdentifer];
        NSString *logoUrl =nil;
        NSString *oaName = _session.sessionId;
        if(range.location !=NSNotFound) {
            NSString *oaAppId = [self.session.sessionId substringFromIndex:range.location+range.length];
            NSDictionary *oneDic =  [[AppModel sharedInstance] runModuleFunc:@"AppStore" :@"getAppStoreParamsWithAppId: appType:" :@[oaAppId, @(1)]];
            if(oneDic.count > 0){
                logoUrl = oneDic[@"appLogo"];
                oaName = oneDic [@"appName"];
            }else{
                //getLoadMyAppStoreState
                NSNumber *num = [[AppModel sharedInstance] runModuleFunc:@"AppStore" :@"getLoadMyAppStoreState" :nil];
                if(![num boolValue]){
                    [[AppModel sharedInstance] runModuleFunc:@"AppStore" :@"getMyAppsFromNet" :nil];
                }
            }
        }
        _nameLabel.text = oaName;
        if(!KCNSSTRING_ISEMPTY(logoUrl)){
            [_portraitImg sd_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:ThemeDefaultHead(_portraitImg.size, _nameLabel.text, _session.sessionId)];
        }else{
            _portraitImg.image = ThemeDefaultHead(_portraitImg.size, _nameLabel.text, _session.sessionId);
        }
    }
    //不需要显示时间
//    _dateLabel.hidden=YES;
}
- (void)updateAllData{
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateListAllData)]){
        [self.delegate updateListAllData];
    }
}
//md5加密
- (NSString *)md5:(NSString *)str1 withStr2:(NSString *)str2{
    if(KCNSSTRING_ISEMPTY(str1) || KCNSSTRING_ISEMPTY(str2)){
        return nil;
    }
    const char *cStr = [[NSString stringWithFormat:@"%@%@",str1,str2] UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSString* MD5 =  [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
    
    return MD5;
}
#pragma mark - 文件传输助手
- (void)fileTransfer{
     [self.portraitImg sd_cancelCurrentImageLoad];
    _nameLabel.text = languageStringWithKey(@"文件传输助手");
    _dateLabel.text = _session.dateTime?[ChatTools getSessionDateDisplayString:_session.dateTime]:nil;
    _portraitImg.image = ThemeImage(@"icon_filetransferassistant");
    _contentLabel.text = [NSString stringWithFormat:@"%@",_session.text?_session.text:@""];
}
#pragma mark - 颜色相关
//置顶颜色
- (UIColor *)colorWithHex:(int)color {
    float red = (color & 0xff000000) >> 24;
    float green = (color & 0x00ff0000) >> 16;
    float blue = (color & 0x0000ff00) >> 8;
    float alpha = (color & 0x000000ff);

    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}
- (UIColor *)colorWithHexString:(NSString *)color{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;

    //r
    NSString *rString = [cString substringWithRange:range];

    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];

}
@end
