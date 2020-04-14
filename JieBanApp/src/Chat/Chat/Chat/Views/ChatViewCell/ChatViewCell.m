
//
//  ChatViewCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/8.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ChatViewCell.h"
#import <objc/runtime.h>

NSString *const KResponderCustomChatViewCellBubbleViewEvent = @"KResponderCustomChatViewCellBubbleViewEvent";
NSString *const KResponderCustomECMessageKey = @"KResponderCustomECMessageKey";
NSString *const KResponderCustomChatViewCellResendEvent = @"KResponderCustomChatViewCellResendEvent";
NSString *const KResponderCustomTableCellKey = @"KResponderCustomTableCellKey";
NSString *const KResponderCustomChatViewCellMessageReadStateEvent = @"KResponderCustomChatViewCellMessageReadStateEvent";
NSString *const KResponderCustomChatViewCellNameTapEvent = @"KResponderCustomChatViewCellNameTapEvent";
const char KTimeIsShowKey;

#define CellMessageUnReadCount @"CellMessageUnReadCount"

#define DefaultFrameY 10.0f

@implementation ChatViewCell

#pragma mark - 创建方法
///创建cell 发送者和接受者的identifier不同
- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.isSender = isSender;
        ///多选按钮
        [self.contentView addSubview:self.moreSelectBtn];
        ///头像
        [self.contentView addSubview:self.portraitImg];
        ///时间label
        [self.contentView addSubview:self.timeLabel];
       
        ///气泡view
        [self.contentView addSubview:self.bubbleView];
        if (self.isSender) {
            [self.contentView addSubview:self.sendStatusView];
            if (isopenReceipte) {//已读未读
                [self.contentView addSubview:self.receipteBtn];
            }
        } else {
            ///特别关注label
            [self.contentView addSubview:self.specialAttLabel];
            ///发送者昵称
            [self.contentView addSubview:self.fromId];
        }
    }
    return self;
}

///创建cell 通知专属 HXChatNotifitionCell
- (instancetype)initWithNotifitionIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.isSender = isSender;
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}
///阅后即焚消息倒计时
- (void)burnTimeLabelChanged:(NSNotification *)not{
    NSArray *dataArr = not.object;
    ECMessage *message = self.displayMessage;
    //谓词搜索
    NSPredicate *predmsgIde = [NSPredicate predicateWithFormat:@"messageId CONTAINS[cd] %@", message.messageId];
    NSArray *searchArray = [dataArr filteredArrayUsingPredicate:predmsgIde];
    if (searchArray == nil || searchArray.count == 0) {
        return;
    }
    if (message.messageBody.messageBodyType == MessageBodyType_Voice) {//语音播放完后倒计时
        NSString *timeStr = [[NSUserDefaults standardUserDefaults] valueForKey:message.messageId];
        if (!timeStr) {
            self.timeLab.text = [NSString stringWithFormat:@"%@",@"30"];
        }else{
            self.timeLab.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:message.messageId]];
        }
    }else{
        self.timeLab.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:message.messageId]];
    }
    if ([self.timeLab.text isEqualToString:@"30"]) {
        self.timeLab.hidden = YES;
        self.burnIcon.hidden = NO;
    }else{
        self.timeLab.hidden = NO;
        self.burnIcon.hidden = YES;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self checkButtonState];
    DDLogInfo(@"eagle.chatviewcell.layoutSubviews --- before");
}

///检测按钮状态
- (void)checkButtonState{
    if ([Common sharedInstance].isIMMsgMoreSelect) {//多选状态
        if ([self isContainMoreMessage]) {
            self.moreSelectBtn.selected = YES;
        }else {
            self.moreSelectBtn.selected = NO;
        }

        if (self.displayMessage.isGroupNoticeMessage) {//通知类消息
            _moreSelectBtn.hidden = YES;
            return;
        }
        _moreSelectBtn.hidden = NO;
        if (self.isSender) {//发送的无需处理
            return;
        }
        if(self.isIMMsgMoreSelectLoad) {//已经+45像素偏移
            return;
        }
        for (UIView *subView in self.contentView.subviews) {
            if (subView != _moreSelectBtn && subView.superview == self.contentView) {
                subView.originX = subView.originX + 45.0f;
            }
        }
        self.isIMMsgMoreSelectLoad = YES;
    }else{
        _moreSelectBtn.hidden = YES;
        if (!self.isIMMsgMoreSelectLoad) {//没偏移过的无需处理
            return;
        }
        if (self.isSender) {//发送的无需处理
            return;
        }

        for (UIView *subView in self.contentView.subviews) {
            if (subView != _moreSelectBtn && subView.superview == self.contentView) {
                subView.originX = subView.originX - 45.0f;
            }
            if ([self isKindOfClass:NSClassFromString(@"HXChatNotifitionCell")]) {
                subView.centerX = kScreenWidth/2;
            }
        }
        self.isIMMsgMoreSelectLoad = NO;
    }
}
///是否是选中的消息
- (BOOL)isContainMoreMessage{
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[Common sharedInstance].moreSelectMsgData];
    if ([tempArray containsObject:self.displayMessage]) {
        return YES;
    }
    for (ECMessage *message in tempArray) {
        if([message.messageId isEqualToString:self.displayMessage.messageId]){
            return YES;
        }
    }
    return NO;
}
#pragma mark - 赋值方法
- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;

    //是否显示时间
    NSNumber *isShowNumber = objc_getAssociatedObject(self.displayMessage, &KTimeIsShowKey);
    BOOL isShow = isShowNumber.boolValue;
    _timeLabel.hidden = !isShow;

    if (isShow) {
        CGFloat timeWidth = kScreenWidth - 80 * fitScreenWidth;
        if (message.isGroupNoticeMessage) {//群组通知消息
            [self hiddenBubbleViewAndHeadView];
            self.timeLabel.text = [ChatTools getDateDisplayString:self.displayMessage.timestamp.longLongValue];
            CGSize size;
            if (message.getHeight >= 16) {
                size = CGSizeMake(timeWidth,message.getHeight);
            }else{
                size = [[Common sharedInstance] widthForContent:[ChatTools getDateDisplayString:self.displayMessage.timestamp.longLongValue] withSize:CGSizeMake(timeWidth,MAXFLOAT) withLableFont:ThemeFontSmall.pointSize];
            }
            self.timeLabel.frame = CGRectMake((kScreenWidth - size.width - 10)/2, self.timeLabel.originY, floor(size.width + 10), floor(size.height + 9));
            return;
        }
        NSString *getTime = [ChatTools getDateDisplayString:self.displayMessage.timestamp.longLongValue];
        CGSize timeSize = [[Common sharedInstance] widthForContent:getTime withSize:CGSizeMake(timeWidth, MAXFLOAT) withLableFont:ThemeFontSmall.pointSize];
         self.timeLabel.frame = CGRectMake((kScreenWidth - timeSize.width - 10)/2, self.timeLabel.originY, floor(timeSize.width + 10), floor(timeSize.height + 9));
        self.timeLabel.text = getTime;
    }
    self.bubbleView.hidden = NO;
    self.portraitImg.hidden = NO;
    _sendStatusView.hidden = NO;
    self.fromId.hidden = NO;
    ///有时间显示的话 整体下移30像素
    CGFloat imageFrameY = isShow?DefaultFrameY + 30.0f:DefaultFrameY;
    self.moreSelectBtn.originY = imageFrameY;

    CGFloat bubleFrameY = 0.0f;
    if(message.isGroup && !self.isSender && ![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@%@",kGroupInfoGroupNickName,self.displayMessage.sessionId]]){//显示群昵称
        bubleFrameY = 18.0f * FitThemeFont;
        self.fromId.hidden = NO;
    }else{
        self.fromId.hidden = YES;
    }
    
    if([message.from isEqualToString:IMSystemLoginMsgFrom]){
        bubleFrameY = 18.0f * FitThemeFont;
        self.fromId.hidden = NO;
        self.fromId.text = @"个人助手";
    }
    ///根据是否显示时间重置y的起始值
    self.portraitImg.originY = imageFrameY;
    self.fromId.originY = imageFrameY;
    self.bubbleView.originY = imageFrameY + bubleFrameY;

    if (self.isSender) {
        NSString *headURL = [[Chat sharedInstance] getAvatar];
        NSString *md5 = [[Common sharedInstance] getOneUserPhotoMd5];
        NSString *userName = [Chat sharedInstance].getUserName;
        [self loadHeadImage:headURL withMd5:md5 withName:userName withUserStatus:@"1"];
    }else{
        [self checkMemberInfomation];
    }
    if([message.from isEqualToString:IMSystemLoginMsgFrom]){
        bubleFrameY = 18.0f * FitThemeFont;
        self.portraitImg.image =  ThemeImage(@"icon_personalassistant");
    }
    [self setSpecialAtt];

    [self updateMessageSendStatus:self.displayMessage.messageState];

    if (!self.isSender) {//修正倒计时的frame
        self.timeLab.frame = CGRectMake(self.bubbleView.width - 9, -4, 18, 18);
        self.burnIcon.frame = CGRectMake(self.bubbleView.width - 8, -4, 16, 16);
    }
    DDLogInfo(@"eagle.chatviewcell.bubbleViewWithData after");
}
///查询个人信息
- (void)checkMemberInfomation{
    self.portraitImg.image = nil;

    NSDictionary *dict = [[Chat sharedInstance].componentDelegate getDicWithId:self.displayMessage.from withType:0];
    NSString *name = dict[Table_User_member_name];
    NSString *headUrl = dict[Table_User_avatar];
    NSString *md5 = dict[Table_User_urlmd5];
    NSString *userStatus = dict[Table_User_status];
    if(self.displayMessage.isGroup){
        KitGroupMemberInfoData *data = [KitGroupMemberInfoData getGroupMemberInfoWithMemberId:self.displayMessage.from withGroupId:self.displayMessage.sessionId];
        NSString *fromText = !KCNSSTRING_ISEMPTY(name)?name:self.displayMessage.from;
        if ([data.memberName isEqualToString:self.displayMessage.from]) {
            self.fromId.text = fromText;
        }else{
            self.fromId.text = !KCNSSTRING_ISEMPTY(data.memberName)?data.memberName:fromText;
        }
    }
    [self loadHeadImage:headUrl withMd5:md5 withName:name?:self.displayMessage.from withUserStatus:userStatus];
}
///特别关注显示
- (void)setSpecialAtt{
    if([HXSpecialData haveSpecialWithAccount:self.displayMessage.from] && ![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@%@",kGroupInfoGroupNickName,self.displayMessage.sessionId]]){
        if (self.displayMessage.isGroup) {
            self.specialAttLabel.hidden = NO;
            self.specialAttLabel.text = languageStringWithKey(@"特别关注");
            self.specialAttLabel.originY = self.portraitImg.originY;
            self.fromId.originX = self.specialAttLabel.right + 3;
            self.bubbleView.originY = self.portraitImg.originY + 18*FitThemeFont;
        }else{
            self.specialAttLabel.hidden = YES;
            self.specialAttLabel.text = @"";
        }
    }else{
        self.specialAttLabel.hidden = YES;
        self.specialAttLabel.text = @"";
        self.fromId.originX = self.specialAttLabel.left;
    }
}
///头像设置
- (void)loadHeadImage:(NSString *)headUrl withMd5:(NSString *)md5 withName:(NSString *)name withUserStatus:(NSString *)userStatus{
    if ([name isEqualToString:FileTransferAssistant]) {// 文件传输，显示自己名字
        NSString *myName = [[Chat sharedInstance] getUserName];
        name = myName;
    }
    if([userStatus isEqualToString:@"3"]){
        self.portraitImg.image = ThemeDefaultHead(self.portraitImg.size, RXleaveJobImageHeadShowContent,self.displayMessage.from);
        return;
    }
    if(!KCNSSTRING_ISEMPTY(headUrl)){
#if isHeadRequestUserMd5
        [self.portraitImg setImageWithURLString:headUrl urlmd5:md5 options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(self.portraitImg.size, name?name:self.displayMessage.from,self.displayMessage.from) withRefreshCached:NO];
#else
        [self.portraitImg sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:ThemeDefaultHead(self.portraitImg.size,name?name:self.displayMessage.from,self.displayMessage.from) options:SDWebImageRefreshCached|SDWebImageRetryFailed];
#endif
    } else{
        [self.portraitImg sd_cancelCurrentImageLoad];
        self.portraitImg.image = ThemeDefaultHead(self.portraitImg.size, name,self.displayMessage.from);
    }
}
///隐藏气泡和头像昵称
- (void)hiddenBubbleViewAndHeadView{
    self.bubbleView.hidden = YES;
    self.portraitImg.hidden = YES;
    _sendStatusView.hidden = YES;
    self.fromId.hidden = YES;
    self.specialAttLabel.hidden = YES;
    self.specialAttLabel.text = @"";
}
#pragma mark - 点击事件
///单击cell
- (void)bubbleViewTapGesture:(UITapGestureRecognizer *)tap{
    [self dispatchCustomEventWithName:KResponderCustomChatViewCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:tap];
}
///双击cell
- (void)doubleTextTapGesture:(UITapGestureRecognizer *)tap{
    
}

///重发按钮点击
- (void)resendBtnTap:(id)sender{
    [self dispatchCustomEventWithName:KResponderCustomChatViewCellResendEvent userInfo:@{KResponderCustomTableCellKey:self} tapGesture:nil];
}
///已读未读点击
- (void)receiptBtnTap:(id)sender{
    if ([self.displayMessage.sessionId hasPrefix:@"g"]) {
        [self dispatchCustomEventWithName:KResponderCustomChatViewCellMessageReadStateEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:nil];
    }
}
///更多状态下 点击选择按钮
- (void)moreSelectBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(ChatViewCellOfMoreSelectWithMessage:chatCell:isSelect:)]) {
        [self.delegate ChatViewCellOfMoreSelectWithMessage:self.displayMessage chatCell:self isSelect:sender.selected];
    }
}

#pragma mark - 更新发送状态的相关事件
///更新发送状态
- (void)updateMessageSendStatus:(ECMessageState)state {
    if (!self.isSender) {
        return;
    }
    _receipteBtn.hidden = YES;

    [_retryBtn setHidden:YES];
    _sendStatusView.originX = self.bubbleView.originX - 30.0f;
    _sendStatusView.centerY = self.bubbleView.centerY;
    [self.contentView bringSubviewToFront:_sendStatusView];

    ECMessage *message = self.displayMessage;
//    if (state == ECMessageState_Sending) { // 为什么整理不让文件类型的转呢?
    if (state == ECMessageState_Sending && ![message.messageBody isMemberOfClass:[ECFileMessageBody class]]) {
        [_sendStatusView setHidden:NO];
        [_activityView setHidden:NO];
        [_activityView startAnimating];
    } else if (state == ECMessageState_SendFail) {
        [_sendStatusView setHidden:NO];
        [_activityView setHidden:YES];
        [_retryBtn setHidden:NO];
        if (message.messageBody.messageBodyType == MessageBodyType_Voice) {//音频类多一个时间显示
            _sendStatusView.originX = self.bubbleView.originX - 30.0f;//之前是50.0f
        }
    } else if(state == ECMessageState_SendSuccess){
        [_sendStatusView setHidden:YES];
        [_activityView setHidden:YES];
        [_activityView stopAnimating];
        NSDictionary *im_modeDic =  [MessageTypeManager getCusDicWithUserData:message.userData];
        BOOL isBurnMsg = NO;
        if ([[im_modeDic objectForKey:kRonxinBURN_MODE] isEqualToString:kRONGXINBURN_ON] ){
            isBurnMsg = YES;
        }
        if (!message.isVoipRecordsMessage && isopenReceipte && self.isSender && !isBurnMsg) {
            [self checkUnreadCount];
        }
    }
    else {
        [_sendStatusView setHidden:YES];
        [_activityView setHidden:YES];
        [_activityView stopAnimating];
    }
}

#pragma mark - 已读未读功能
- (void)checkUnreadCount {
    if (!self.displayMessage.isGroup) {
        [self updateReadByUnreadCount:0];
        return;
    }
    //Default member counts if group type
    NSArray *members = [[KitMsgData sharedInstance] getGroupInformation:self.displayMessage.sessionId];
    NSInteger count = members.count > 0 ? [members.firstObject[@"memberCount"] integerValue] > 1 ? [members.firstObject[@"memberCount"] integerValue] - 1 : 0 : 0;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *countValue = [userDefaults valueForKey:[NSString stringWithFormat:@"%@_%@",self.displayMessage.messageId,CellMessageUnReadCount]];
    if (!KCNSSTRING_ISEMPTY(countValue)) {
        [self updateReadByUnreadCount:countValue.integerValue];
    }
    else if (count != 0){
        [self updateReadByUnreadCount:count];
    }
    
    [self updateMessageUnreadCountOnRestWithMsgId:self.displayMessage.messageId];
    
}

- (void)updateMessageUnreadCountOnRestWithMsgId:(NSString *)msgId {
    //change by keven .使用rest接口时，多终端登录时 同步的pc消息要用version字段查
    NSString *version = nil;
    NSRegularExpression *numberRegular = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger count = 0;
    if (msgId) {//出现过 self.displayMessage.messageId 为 nil 的情况，先做下保护处理
        count = [numberRegular numberOfMatchesInString:msgId options:NSMatchingReportProgress range:NSMakeRange(0, msgId.length)];
    }
    BOOL isPcMsg = count>0?NO:YES;
    if (isPcMsg) {
        NSArray *array = [msgId componentsSeparatedByString:@"|"];
        if (array.count == 2) {
            version = array.lastObject;
        }
    }
    
    if (!msgId && !version) { //如果msgid 和version 都没值就不继续操作
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[ChatMessageManager sharedInstance] updateUnreadMessageCountFromNetWorkByMessage:self.displayMessage  version:version success:nil];
    });
    [self showUnreadCount];
}


/// 展示消息未读数（本地）
- (void)showUnreadCount {
    if ([self.displayMessage.sessionId hasPrefix:@"g"]) {return;}
    NSInteger unReadCount = [self.displayMessage getUnreadCount];
    [self updateReadByUnreadCount:unReadCount];
}

///根据数量设置已读未读显示
- (void)updateReadByUnreadCount:(NSInteger)unreadCount{
    if (!self.receipteBtn) {
        return;
    }
    NSString *str = (self.displayMessage.isRead && unreadCount == 0)?languageStringWithKey(@"已读"):languageStringWithKey(@"未读");
    NSString *unreadStr = (unreadCount == 0 ? str:[NSString stringWithFormat:@"%ld%@",(long)unreadCount,str]);

    UIColor *color = (self.displayMessage.isRead && unreadCount == 0)?[UIColor colorWithHexString:@"1FAB89"]:[UIColor colorWithHexString:@"1FAB89"];
    [self.receipteBtn setTitle:unreadStr forState:UIControlStateNormal];
    [self.receipteBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:self.receipteBtn.currentTitle attributes:@{NSFontAttributeName:ThemeFontSmall,NSForegroundColorAttributeName:color}] forState:UIControlStateNormal];
    CGFloat width = self.receipteBtn.currentAttributedTitle.size.width + 10;
    CGFloat _receipbtnW;
    if (self.displayMessage.messageBody.messageBodyType == MessageBodyType_Voice) {
        _receipbtnW = self.bubbleView.originX - width;
    } else {
        _receipbtnW = self.bubbleView.originX - width;
    }
    ///不能超出屏幕
    if (_receipbtnW < 0) {
        width += _receipbtnW - 5;
        _receipbtnW = 5;
    }
    self.receipteBtn.frame = CGRectMake(_receipbtnW, self.bubbleView.originY, width - 10, self.bubbleView.height);

    if (self.displayMessage.messageState != ECMessageState_SendFail &&
        ![self.displayMessage.sessionId isEqualToString:[Chat sharedInstance].getAccount] &&
        ![self.displayMessage.sessionId isEqualToString:FileTransferAssistant] && !self.displayMessage.isBurnWithMessage) {
        self.receipteBtn.hidden = NO;
    }
}
#pragma mark - 子类实现的高度回调

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)messageBody{
    NSAssert(NO, @"ChatViewCell: 不能调用基类的方法，无实现");
    return 0;
}

+ (CGFloat)getHightOfCellViewWithMessage:(ECMessage *)message{
    NSAssert(NO, @"ChatViewCell: 不能调用基类的方法，无实现");
    return 0;
}

#pragma mark - get

- (UILabel *)timeLabel{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 100) / 2, 5,100 * FitThemeFont, 20.0f)];
        _timeLabel.layer.cornerRadius = 4;
        _timeLabel.layer.masksToBounds = YES;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = ThemeFontSmall;
        _timeLabel.backgroundColor = [UIColor colorWithRed:0.81f green:0.81f blue:0.81f alpha:1.00f];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.numberOfLines = 0;
        _timeLabel.highlightedTextColor = [UIColor whiteColor];
        _timeLabel.hidden = YES;
    }
    return _timeLabel;
}

- (UIButton *)moreSelectBtn{
    if (_moreSelectBtn == nil) {
        _moreSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreSelectBtn.frame = CGRectMake(0, DefaultFrameY, 50, 50);
        
        UIImage *image = ThemeImage(@"choose_icon");
        UIImage *imageon = ThemeImage(@"choose_icon_on");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_moreSelectBtn setImage:image forState:UIControlStateNormal];
            [self->_moreSelectBtn setImage:imageon forState:UIControlStateHighlighted];
            [self->_moreSelectBtn setImage:imageon forState:UIControlStateSelected];
        });
        
        [_moreSelectBtn addTarget:self action:@selector(moreSelectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _moreSelectBtn.hidden = YES;
    }
    return _moreSelectBtn;
}

- (UIImageView *)portraitImg{
    if (_portraitImg == nil) {
        _portraitImg = [[UIImageView alloc] init];
        _portraitImg.frame = CGRectMake(0, DefaultFrameY, 40.0f, 40.0f);
        self.portraitImg.backgroundColor = [UIColor clearColor];
        self.portraitImg.contentMode = UIViewContentModeScaleAspectFill;
        self.portraitImg.layer.cornerRadius = 4;
        self.portraitImg.layer.masksToBounds = YES;
        if (self.isSender) {
            _portraitImg.originX = kScreenWidth - DefaultFrameY - _portraitImg.width;
        }else{
            _portraitImg.originX = DefaultFrameY;
        }
    }
    return _portraitImg;
}
- (UIView *)bubbleView{
    if (_bubbleView == nil) {
        _bubbleView = [[UIView alloc] init];
        _bubbleView.frame = CGRectMake(0, self.portraitImg.originY, 40.0f, self.portraitImg.height);
        if (self.isSender) {
            _bubbleView.originX = kScreenWidth - self.portraitImg.originX - _bubbleView.width - 5.0f;
        } else {
            _bubbleView.originX = self.portraitImg.right + 5.0f;
        }
        ///气泡背景图
        [self.bubbleView addSubview:self.bubleimg];
        ///bubbleView添加点击事件
        [self addTapEvent];

        if (!self.isSender) {
            ///阅后即焚图标
            [self.bubbleView addSubview:self.burnIcon];
            ///阅后即焚倒计时
            [self.bubbleView addSubview:self.timeLab];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(burnTimeLabelChanged:) name:@"BurnTimeLabelChanged" object:nil];
        }
    }
    return _bubbleView;
}

- (UIImageView *)bubleimg{
    if (_bubleimg == nil) {
        _bubleimg = [[UIImageView alloc] initWithFrame:self.bubbleView.bounds];
        
        _bubleimg.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        if (self.isSender) {
            _bubleimg.image = [ThemeImage(@"chating_right_02") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
        } else {
            _bubleimg.image = [ThemeImage(@"chating_left_01") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
            _bubleimg.highlightedImage = [ThemeImage(@"chating_left_01_on") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
        }
        _bubleimg.tag = 1000;
    }
    return _bubleimg;
}

- (UIImageView *)burnIcon{
    if (_burnIcon == nil) {
        _burnIcon = [[UIImageView alloc] initWithFrame:CGRectMake(-4, -4, 16, 16)];
        _burnIcon.layer.cornerRadius = 8;
        UIImage *image = ThemeImage(@"burn_lock_icon");
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_burnIcon.image =image;
        });
        _burnIcon.hidden = YES;
    }
    return _burnIcon;
}

- (UILabel *)timeLab{
    if (_timeLab == nil) {
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.bubbleView.width + 5 , -4, 16, 16)];
        _timeLab.font = ThemeFontSmall;
        _timeLab.backgroundColor = [UIColor colorWithHexString:@"f3780b"];
        _timeLab.layer.cornerRadius = 9;
        _timeLab.clipsToBounds = YES;
        _timeLab.textColor = [UIColor whiteColor];
        _timeLab.textAlignment = NSTextAlignmentCenter;
        _timeLab.hidden = YES;
    }
    return _timeLab;
}

- (UIView *)sendStatusView{
    if (_sendStatusView == nil) {
        _sendStatusView = [[UIView alloc] initWithFrame:CGRectMake(self.bubbleView.originX - 30.0f, DefaultFrameY, 30.0f, 28.0f)];
        _sendStatusView.backgroundColor = self.backgroundColor;
        ///菊花view
        [_sendStatusView addSubview:self.activityView];
        ///重发按钮
        [_sendStatusView addSubview:self.retryBtn];
    }
    return _sendStatusView;
}

- (UIActivityIndicatorView *)activityView{
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.backgroundColor = [UIColor clearColor];
    }
    return _activityView;
}

- (UIButton *)retryBtn{
    if (_retryBtn == nil) {
        _retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([self isKindOfClass:[ChatViewVoiceCell class]]) {
            _retryBtn.frame = CGRectMake(2, 2, 26, 26);
        } else {
            _retryBtn.frame = CGRectMake(2, 2, 26, 26);
        }
        UIImage *image = ThemeImage(@"messageSendFailed");
        dispatch_async(dispatch_get_main_queue(), ^{
             [self->_retryBtn setImage:image forState:UIControlStateNormal];
        });
        _retryBtn.hidden = YES;
        [_retryBtn addTarget:self action:@selector(resendBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryBtn;
}

- (UIButton *)receipteBtn{
    if (_receipteBtn == nil) {
        _receipteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _receipteBtn.frame = CGRectMake(0,0, 60, 28);
        _receipteBtn.titleLabel.numberOfLines = 2;
        _receipteBtn.backgroundColor = [UIColor clearColor];
        _receipteBtn.hidden = YES;
        [_receipteBtn addTarget:self action:@selector(receiptBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _receipteBtn;
}

- (UILabel *)specialAttLabel{
    if (_specialAttLabel == nil) {
        _specialAttLabel = [[UILabel alloc] init];
        _specialAttLabel.frame = CGRectIntegral(CGRectMake(self.portraitImg.right + 10.0f, 10.0f, 60.0f * FitThemeFont, 15.0f * FitThemeFont));
        _specialAttLabel.backgroundColor = [UIColor colorWithRed:0.81f green:0.81f blue:0.81f alpha:1.00f];
        _specialAttLabel.textColor = [UIColor whiteColor];
        _specialAttLabel.font = ThemeFontSmall;
        _specialAttLabel.textAlignment = NSTextAlignmentCenter;
        _specialAttLabel.layer.cornerRadius = 3;
        _specialAttLabel.layer.masksToBounds = YES;
        _specialAttLabel.hidden = YES;
    }
    return _specialAttLabel;
}

- (UILabel *)fromId{
    if (_fromId == nil) {
        _fromId = [[UILabel alloc] initWithFrame:CGRectMake(self.portraitImg.right + 10.0f, self.portraitImg.originY, 220.0f * FitThemeFont, 15.0f * FitThemeFont)];
        _fromId.font = ThemeFontSmall;
        _fromId.textColor = [UIColor grayColor];
        _fromId.backgroundColor = self.backgroundColor;
    }
    return _fromId;
}
#pragma mark - 添加点击事件
- (void)addTapEvent{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewTapGesture:)];
    [tap setNumberOfTapsRequired:1];
    [self.bubbleView addGestureRecognizer:tap];

    if (isHaveIMBigText == 1) {
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTextTapGesture:)];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [self.bubbleView addGestureRecognizer:doubleTapGestureRecognizer];
        [tap requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    }
//    if (isHaveChangeVoiceToText == 1) {
//        // 长按
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//
//
//        [self.bubbleView addGestureRecognizer:longPress];
//        [tap requireGestureRecognizerToFail:longPress];
//    }
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
///长按事件 需要这个
- (BOOL)canBecomeFirstResponder {
    return YES;
}
@end
