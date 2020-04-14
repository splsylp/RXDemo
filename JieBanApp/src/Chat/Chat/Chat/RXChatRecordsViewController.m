//
//  RXChatRecordsViewController.m
//  Chat
//
//  Created by 杨大为 on 2016/12/27.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "RXChatRecordsViewController.h"
#import "ChatViewRedpacketCell.h"
#import "ChatViewRedpacketTakenTipCell.h"
#import "RXMyFriendList.h"
#import "ChatViewMergeMessageCell.h"
#import "ChatTextImageCell.h"
#import "ChatViewController.h"
#import "RXChatCalendarController.h"

#define requestMsgCount 15
#define Alert_ResendMessage_Tag 1500

const NSInteger TextMessage_OnlyTextR = 1000; //纯文本消息
const NSInteger TextMessage_RedpacketR = 1003; //红包消息
const NSInteger TextMessage_RedpacketTakenTipR = 1004; //抢红包消息
const NSInteger TextMessage_TransformRedPacketR = 1007; //转账消息
const NSInteger TextMessage_TransformRedPacketTipR = 1009; //收账消息

const char KResendMessage;

@interface RXChatRecordsViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UISearchControllerDelegate,WebBrowserBaseViewControllerDelegate, ChatViewRedpacketCellDelegate,UIActionSheetDelegate>

@property (assign,nonatomic)BOOL isNoMessage;//当前没有聊天记录
//搜索
@property (strong,nonatomic) UISearchBar *searchBar;
//@property (strong,nonatomic) UISearchDisplayController *searchController;

@property (strong,nonatomic) UISearchController *searchController;

//@property (strong,nonatomic)HXNoDataView *noDataView;
@property (copy,nonatomic)NSString *historyMessageID;//历史消息ID
@property (copy,nonatomic)NSString *requestTime;//请求时间
@property (copy,nonatomic)NSString *startTime;//拉取时间
@property (assign,nonatomic)BOOL isSender;
//默认的背景水印
@property (nonatomic, strong) UIView *waterView;

/** msgIdArray */
@property(nonatomic,strong)NSMutableArray *msgIdArray;
@end

@implementation RXChatRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = languageStringWithKey(@"聊天记录");
    self.view.backgroundColor = [UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f];
    //创建searchVC
    [self createSearchVC];
    //默认设置
    [self defaultSetting];
    //创建tableView
    [self createTableView];
    //刷新
    [self initRefresh];
    
    [self createCalendarBtn];
    
    //下载媒体消息附件完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadMediaAttachFileCompletion:) name:KNOTIFICATION_DownloadMessageCompletion object:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.voiceMessage) {
        //如果前一个在播放
        objc_setAssociatedObject(self.voiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
    }
    self.voiceMessage = nil;
    
}

#pragma mark  - 日历按钮
- (void)createCalendarBtn {
    [self setBarButtonWithNormalImg:ThemeImage(@"btn_calendar_normal") highlightedImg:ThemeImage(@"btn_calendar_pressed") target:self action:@selector(gotoCalendarController) type:NavigationBarItemTypeRight];
}

- (void)gotoCalendarController {
    RXChatCalendarController *vc = [RXChatCalendarController new];
    vc.data = self.sessionId;
    [self pushViewController:vc];
}

#pragma mark 默认设置
- (void)defaultSetting{
    _waterView = [self getWatermarkViewWithFrame:CGRectMake(0, self.searchBar.bottom, kScreenWidth, kScreenHeight - kTotalBarHeight - self.searchBar.bottom) mobile:[Chat sharedInstance].getStaffNo name:[Chat sharedInstance].getUserName backColor:[UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f]];
    [self.view addSubview:_waterView];
    [self.view sendSubviewToBack:_waterView];
    
    self.messageArray = [NSMutableArray array];
    self.searchArray = [NSMutableArray array];
}
#pragma mark createTableView
- (void)createTableView{
    self.recordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchBar.bottom, kScreenWidth, kScreenHeight - kTotalBarHeight - self.searchBar.bottom) style:UITableViewStylePlain];
    self.recordTableView.backgroundColor = [UIColor clearColor];
    self.recordTableView.tag = 1;
    self.recordTableView.delegate = self;
    self.recordTableView.dataSource = self;
    self.recordTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.recordTableView];
    
    if (iOS11) {
        // 这里代码针对ios11之后，tableveiw 刷新时候，闪动，跳动的问题
        self.recordTableView.estimatedRowHeight = 0;
        self.recordTableView.estimatedSectionHeaderHeight = 0;
        self.recordTableView.estimatedSectionFooterHeight = 0;
    }
}
#pragma mark 创建searchVC
- (void)createSearchVC{
    if (self.searchController) {
        self.searchController = nil;
    }
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    self.searchBar.delegate = self;
    [self.searchBar layoutSubviews];
    self.searchBar.placeholder = languageStringWithKey(@"搜索聊天记录");
    
    if ([self.searchBar respondsToSelector:@selector(barTintColor)]) {
        NSArray *searchSubviews = [self.searchBar.subviews[0] subviews];
        for (UIView *subView in searchSubviews) {
            if ([subView isKindOfClass:[UITextField class]]) {
                subView.layer.borderColor = UIColorFromRGB(0xDADBDF).CGColor;
                subView.layer.borderWidth = 0.5;
                subView.layer.cornerRadius = 3.0;
                subView.clipsToBounds = YES;
                break;
            }
        }
    }
    if (iOS7) {
        [self.searchBar setBackgroundImage:[UIColor createImageWithColor:UIColorFromRGB(0xEFEFF4)] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    }else{
        [self.searchBar setBackgroundImage:ThemeImage(@"searchBar_bg")];
    }
    [self.searchBar setImage:ThemeImage(@"searchBar_search_new") forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar sizeToFit];
    //创建搜索控制器
    //搜索显示控制器
//    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
//
//    [self.searchController setDelegate:self];
//    self.searchController.searchResultsDataSource = self;
//    self.searchController.searchResultsDelegate = self;
//    self.searchController.searchResultsTableView.tableFooterView = [[UIView alloc]init];
//    if ([self.searchController.searchResultsTableView respondsToSelector:@selector(setSeparatorInset:)]){
//        [self.searchController.searchResultsTableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
//    }
//    if ([self.searchController.searchResultsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [self.searchController.searchResultsTableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
//    }
//    self.searchController.searchResultsTableView.backgroundColor = [UIColor clearColor];
//    self.searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//
//    [self.searchController setValue:languageStringWithKey(@"点击键盘上的\"搜索\"按钮查询结果") forKey:@"noResultsMessage"];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self];;
    [self.view addSubview:self.searchBar];
}
#pragma mark 刷新
- (void)initRefresh{
    __weak typeof(self) weak_self = self;
    MJRefreshNormalHeader *mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weak_self loadHistoryData];
    }];
    [mj_header.lastUpdatedTimeLabel setHidden:true];
    self.recordTableView.mj_header = mj_header;
    [mj_header setTitle:languageStringWithKey(@"下拉可以刷新") forState:MJRefreshStateIdle];
    [mj_header setTitle:languageStringWithKey(@"松开立即刷新") forState:MJRefreshStatePulling];
    [mj_header setTitle:languageStringWithKey(@"正在刷新数据中...") forState:MJRefreshStateRefreshing];
    [self.recordTableView.mj_header beginRefreshing];
}

#pragma mark scroll
- (void)scrollTableView{
    if (self && self.recordTableView && self.messageArray.count>0) {
        [self.recordTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [Chat sharedInstance].isChatViewScroll = YES;
}
#pragma mark 滑动到底部
- (void)scrollToBottom:(BOOL)animated{
    if (self.recordTableView.contentSize.height > self.recordTableView.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.recordTableView.contentSize.height - self.recordTableView.frame.size.height);
        [self.recordTableView setContentOffset:offset animated:animated];
    }
}
#pragma mark 加载历史消息
- (void)loadHistoryData{
    if(self.isNoMessage){
        [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"没有更多的聊天记录了")];
        [self.recordTableView.mj_header endRefreshing];
        return;
    }
    if(0){//群聊记录
        NSString *messtime = nil;
        __weak typeof(self)weak_self = self;
        if(self.messageArray.count > 0 && _startTime){
            NSTimeInterval tempMilli = [_startTime longLongValue];
            NSTimeInterval seconds = tempMilli/1000.0;
            NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
            messtime = [NSDate getStringFromDate:myDate dateFormatter:@"yyyy-MM-dd HH:mm:ss"];
        }else{
            NSDate *date = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            messtime = [dateFormatter stringFromDate:date];
        }
        _requestTime =_startTime;
        [RestApi getHistoryGroupListMessageGroupId:self.sessionId startTime:nil endTime:messtime pageNo:nil pageSize:[NSString stringWithFormat:@"%d",requestMsgCount] msgDecompression:@"1" didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            [Common sharedInstance].historyMessageUrl = nil;
            NSString *stateCode = [dict objectForKey:@"statusCode"];
            if ([stateCode isEqualToString:@"000000"]) {
                NSArray *dataArray = [dict objectForKey:@"result"];
                if (dataArray.count > 0) {
                    CGFloat offsetOfButtom = self.recordTableView.contentSize.height - self.recordTableView.contentOffset.y;
                    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        @autoreleasepool {
                            [weak_self getMessageData:(NSDictionary *)obj];
                        }
                    }];
                    if (dataArray.count < requestMsgCount) {
                        weak_self.isNoMessage = YES;
                    }
                    
                    [Chat sharedInstance].isChatViewScroll = NO;

                    [weak_self.recordTableView reloadData];
                    if (weak_self.messageArray.count > requestMsgCount) {
                        weak_self.recordTableView.contentOffset = CGPointMake(0.0, weak_self.recordTableView.contentSize.height - offsetOfButtom);
                    }else{
                        if (weak_self.messageArray.count > 0) {
                            weak_self.recordTableView.contentOffset = CGPointMake(0.0, weak_self.recordTableView.contentSize.height - offsetOfButtom);
                            //[weak_self scrollToBottom:YES];
                        }else{
                            [weak_self scrollToBottom:NO];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300*NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                                [weak_self scrollTableView];
                            });
                        }
                    }
                }
            }else if ([stateCode isEqualToString:@"560105"]){
                [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"没有更多的聊天记录了")];
                weak_self.isNoMessage = YES;
            }else if([stateCode isEqualToString:@"112144"]){
                [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"当前没有聊天记录")];
            }else if([stateCode isEqualToString:@"112076"]){
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"没有更多的聊天记录了")];
            }
            [self.recordTableView.mj_header endRefreshing];

        } didFailLoaded:^(NSError *error, NSString *path) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"拉取消息失败")];
            [self.recordTableView.mj_header endRefreshing];
        }];
        return;
    }else{//点对点单聊
        __weak typeof(self)weak_self = self;
        [RestApi getHistoryMyChatMessageWithAccount:[[Chat sharedInstance]getAccount] withAppid:[[Chat sharedInstance]getAppid] version:0 time:self.startTime pageSize:requestMsgCount talker:self.sessionId order:2 didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            [Common sharedInstance].historyMessageUrl = nil;
            NSString *stateCode = [dict objectForKey:@"statusCode"];
            if ([stateCode isEqualToString:@"000000"]) {
                NSArray *dataArray = [dict objectForKey:@"result"];
                if (dataArray.count > 0) {
                    CGFloat offsetOfBottom = self.recordTableView.contentSize.height - self.recordTableView.contentOffset.y;
                    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        @autoreleasepool {
                            [weak_self getMessageData:(NSDictionary *)obj];
                        }
                    }];
                    if (dataArray.count < requestMsgCount) {// 为什么要这么写，服务端只反了一条数据，就没办法加载更多了。先注释
//                        weak_self.isNoMessage = YES;
                    }
                    [weak_self.recordTableView reloadData];
                    if (weak_self.messageArray.count > requestMsgCount) {
                        self.recordTableView.contentOffset = CGPointMake(0.0, weak_self.recordTableView.contentSize.height - offsetOfBottom);
                    }else{
                        if (weak_self.messageArray.count > 0) {
                            self.recordTableView.contentOffset = CGPointMake(0.0f, weak_self.recordTableView.contentSize.height - offsetOfBottom);
                            [weak_self scrollToBottom:YES];
                        }else{
                            [weak_self scrollToBottom:NO];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [weak_self scrollTableView];
                            });
                        }
                    }
                }
            }else if ([stateCode isEqualToString:@"560105"]){
                [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"没有更多的聊天记录了")];
            }else if([stateCode isEqualToString:@"112144"]){
                [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"当前没有聊天记录")];
            }else if([stateCode isEqualToString:@"112076"]){
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"没有更多的聊天记录了")];
            }
            [self.recordTableView.mj_header endRefreshing];
        } didFailLoaded:^(NSError *error, NSString *path) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"拉取消息失败")];
            [self.recordTableView.mj_header endRefreshing];
            [Common sharedInstance].historyMessageUrl = nil;
        }];
    }
}
#pragma mark 分组
- (void)getMessageData:(NSDictionary *)dic {
    if ([[dic objectForKey:@"msgDateCreated"] isEqualToString:self.requestTime] &&
        [self.historyMessageID isEqualToString:[dic objectForKey:@"msgId"]]) {
        //去掉拉取的重复消息
        return;
    }
    if ([self.msgIdArray containsObject:[dic objectForKey:@"msgId"]]) {//去掉拉取的重复消息
        return;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeString = dic[@"msgDateCreated"];
    if (KCNSSTRING_ISEMPTY(timeString)) {//防止timeString 为空 下面代码截取的时候崩溃
        return;
    }
    NSDate *someDayDate = [dateFormatter dateFromString:[timeString substringToIndex:timeString.length - 4]];
    NSTimeInterval times = [someDayDate timeIntervalSince1970];
    NSString *firstStamp = [NSString stringWithFormat:@"%ld",(long)times * 1000];
    
    //设置消息
    ECMessage *message = [[ECMessage alloc] init];
    message.sessionId = self.sessionId;
    message.messageId = dic[@"msgId"];
    [message setVersion:[dic[@"version"] integerValue]];
    message.from = dic[@"msgSender"];
    message.to = dic[@"msgReceiver"];
    message.timestamp = firstStamp;
    NSString *domain = dic[@"msgDomain"];
//    NSData *domainData = [[NSData alloc] initWithBase64EncodedString:domain?domain:@"" options:0];
//    NSString *domainBase64 = [[NSString alloc] initWithData:domainData encoding:NSUTF8StringEncoding];
    NSString *domainBase64 = [domain?domain:@"" base64DecodingString];
    message.userData = domainBase64;
    
    //wwl 新增字段，用于图片视频宽高，链接消息相关信息等
    NSString *extOpts = dic[@"extOpts"];
    NSData *extOptsData = [[NSData alloc] initWithBase64EncodedString:extOpts?extOpts:@"" options:0];
    self.historyMessageID = dic[@"msgId"];
    self.startTime = dic[@"msgDateCreated"];
    
    NSDictionary *imDict = [MessageTypeManager getCusDicWithUserData:message.userData];
    NSString *groupType = nil;
    if ([imDict hasValueForKey:kRonxinMessageType]) {
        groupType = imDict[kRonxinMessageType];
    }
    if ([message.userData isEqualToString:@"voice"]||
        [message.userData isEqualToString:@"video"]||
        [imDict hasValueForKey:@"IM_Mode"] ||
        (groupType && [groupType isEqualToString:@"GROUP_NOTICE"]) ||
        [imDict hasValueForKey:@"is_open_money_msg"] ||
        [imDict.allValues containsObject:@"WBSS_SHOWMSG"] ||
        message.messageBody.messageBodyType == MessageBodyType_Call
        ){
        return;
    }
    message.isRead = YES;
    if ([[[Chat sharedInstance] getAccount] isEqualToString:message.from]) {
        message.messageState = ECMessageState_SendSuccess;//发送成功
    }else{
        message.messageState = ECMessageState_Receive;
    }
    
    MessageBodyType msgType = [dic intValueForKey:@"msgType"];
    if (msgType == 7) {//压缩的文件
        msgType = MessageBodyType_File;
    }
    
    //下载路径
    NSString *lvsStr = @"";
    if ([[Chat sharedInstance] getLvsArray].count > 0) {
        lvsStr = [@"http://" stringByAppendingString:[[Chat sharedInstance] getLvsArray][0]];
    }
    if (msgType == 9) { //屏蔽群消息通知类型
        return;
    }
    if (msgType == 10) {
        msgType = MessageBodyType_Call;
    }
    switch (msgType) {
        case MessageBodyType_Text:

        case MessageBodyType_At:{
            if (message.isForwardMessage) {//文件转发消息
                BOOL isNewJson = [imDict hasValueForKey:SMSGTYPE];
                NSString *fileUrl = [imDict objectForKey:@"fileUrl"];
                NSString *fileLength = [imDict objectForKey:@"length"];
                NSString *originFileLength = isNewJson ? imDict[@"originLen"]:imDict[@"originFileLen"];
                NSString *fileName = [imDict objectForKey:@"fileName"];

                ECFileMessageBody *fileMessageBody = [[ECFileMessageBody alloc] init];
                fileMessageBody.displayName = fileName;
                fileMessageBody.remotePath = fileUrl;
                fileMessageBody.fileLength = [fileLength longLongValue];
                fileMessageBody.originFileLength = [originFileLength longLongValue];
                fileMessageBody.mediaDownloadStatus = ECMediaUnDownload;
                message.messageBody = fileMessageBody;
            } else {
                NSString *content = dic[@"msgContent"];
                NSData *contentData = [[NSData alloc] initWithBase64EncodedString:content options:0];
                NSString *contentBase64 = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
                
                ECTextMessageBody *msgBody = [[ECTextMessageBody alloc] initWithText:contentBase64];
                msgBody.serverTime = firstStamp;
                message.messageBody = msgBody;
                msgBody.text =  [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:msgBody.text];
                if ([msgBody.text isEqualToString:@"\a"]) {
                    return;
                }
            }
        }
            break;
        case MessageBodyType_File:{
            NSString *fileName = [self base64String:dic[@"msgFileName"]];
            ECFileMessageBody *fileMsgBody = [[ECFileMessageBody alloc] initWithFile:[lvsStr stringByAppendingString:[dic objectForKey:@"msgFileUrl"]] displayName:fileName];
            fileMsgBody.remotePath = [lvsStr stringByAppendingString:dic[@"msgFileUrl"]];
            fileMsgBody.serverTime = firstStamp;
            fileMsgBody.fileLength = [dic[@"msgFileSize"]longLongValue];
            fileMsgBody.displayName = fileName;
            message.messageBody = fileMsgBody;
        }
            break;
        case MessageBodyType_Image:{
            NSString *fileUrl = @"";
            if (dic[@"msgFileUrl"] && [dic[@"msgFileUrl"] hasSuffix:@"_thum"]) {
                fileUrl = [dic[@"msgFileUrl"] stringByReplacingOccurrencesOfString:@"_thum" withString:@""];
            }else{
                fileUrl = dic[@"msgFileUrl"];
            }
            NSString *fileName = [self base64String:[dic objectForKey:@"msgFileName"]];
            NSString *pathName = fileName;
            if (![[fileUrl pathExtension]isEqualToString:fileName]) {
                if (![message.from isEqualToString:[[Chat sharedInstance]getAccount]]) {
                    pathName = [fileUrl lastPathComponent];
                }
            }
            ECImageMessageBody *imageMsgBody = [[ECImageMessageBody alloc] initWithFile:[lvsStr stringByAppendingString:fileUrl] displayName:fileName];
            imageMsgBody.remotePath = [lvsStr stringByAppendingString:fileUrl];
            imageMsgBody.serverTime = firstStamp;
            imageMsgBody.displayName = fileName;

            imageMsgBody.thumbnailRemotePath = [lvsStr stringByAppendingString:[fileUrl stringByReplacingOccurrencesOfString:[fileUrl pathExtension] withString:@"_thum"]];
            message.messageBody = imageMsgBody;
            NSString *localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:pathName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                imageMsgBody.localPath = localPath;
                imageMsgBody.mediaDownloadStatus = ECMediaDownloadSuccessed;
            }
        }
            break;
        case MessageBodyType_Video:{
            NSString *fileName  = [self base64String:dic[@"msgFileName"]];
            NSString *fileUrl = dic[@"msgFileUrl"];
            ECVideoMessageBody *videoMsgBody = [[ECVideoMessageBody alloc] initWithFile:[lvsStr stringByAppendingString:fileUrl] displayName:fileName];
            videoMsgBody.remotePath = [lvsStr stringByAppendingString:fileUrl];
            videoMsgBody.serverTime = firstStamp;
            videoMsgBody.displayName = fileName;
            videoMsgBody.fileLength = [dic[@"msgFileSize"] longLongValue];
            videoMsgBody.thumbnailRemotePath = [videoMsgBody.remotePath stringByAppendingString:@"_thum"];
            NSString *pathName = fileName;
            
            if(KCNSSTRING_ISEMPTY(fileName)){
                pathName = [fileUrl lastPathComponent];
                videoMsgBody.displayName = [fileUrl lastPathComponent];
            }
            NSString *localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:pathName];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:localPath]){
                videoMsgBody.localPath = localPath;
                videoMsgBody.mediaDownloadStatus = ECMediaDownloadSuccessed;
            }
            message.messageBody = videoMsgBody;
        }
            break;
        case MessageBodyType_Voice:{
            NSString *fileName = dic[@"msgFileName"];
            NSString *localName = fileName;
            NSString *voiceUrl = [dic objectForKey:@"msgFileUrl"];
            if(![message.from isEqualToString:[[Chat sharedInstance] getAccount]]){
                localName = [voiceUrl lastPathComponent];
            }
            ECVoiceMessageBody *messageBody = [[ECVoiceMessageBody alloc] initWithFile:[lvsStr stringByAppendingString:voiceUrl] displayName:fileName];
            messageBody.remotePath = [lvsStr stringByAppendingString:[dic objectForKey:@"msgFileUrl"]];
            messageBody.serverTime = firstStamp;
            NSString *localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:localName];
            if([[NSFileManager defaultManager] fileExistsAtPath:localPath]){
                messageBody.localPath = localPath;
                messageBody.mediaDownloadStatus = ECMediaDownloadSuccessed;
            }
            message.messageBody = messageBody;
        }
            break;
        case MessageBodyType_Call:{
            ECCallMessageBody *callMsgBody = [[ECCallMessageBody alloc] initWithCallText:languageStringWithKey(@"未接听的语音呼叫")];
            callMsgBody.calltype = VOICE;
            message.messageBody = callMsgBody;
        }
            break;
        case MessageBodyType_Preview:{
            ECPreviewMessageBody *previewMsgBody = [[ECPreviewMessageBody alloc] init];
            previewMsgBody.remotePath = [lvsStr stringByAppendingString:dic[@"msgFileUrl"]];
            previewMsgBody.serverTime = firstStamp;
            
            NSError *error;
            // hanwei start
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:extOptsData options:NSJSONReadingMutableLeaves error:&error];
           // hanwei end
            if (!jsonObject) {
                message.messageBody = previewMsgBody;
            }
            previewMsgBody.title = [jsonObject objectForKey:@"title"];
            previewMsgBody.desc = [jsonObject objectForKey:@"desc"];
            previewMsgBody.url = [jsonObject objectForKey:@"url"];
            previewMsgBody.thumbnailLocalPath = [jsonObject objectForKey:@"imgPath"];
            previewMsgBody.thumbnailRemotePath = [jsonObject objectForKey:@"imgPath"];
            message.messageBody = previewMsgBody;
        }
            break;
        case MessageBodyType_Location:{
            NSString *content = dic[@"msgContent"];
            NSData *contentData = [[NSData alloc] initWithBase64EncodedString:content options:0];
            NSString *contentBase64 = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
            NSDictionary *locationDict = [contentBase64 coverToDictionary];
            double latitude = [[locationDict objectForKey:locationLat] doubleValue];
            double longitude = [[locationDict objectForKey:locationLon] doubleValue];
            NSString *title = [locationDict objectForKey:locationTitle];
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = latitude;
            coordinate.longitude = longitude;
            ECLocationMessageBody *messageBody = [[ECLocationMessageBody alloc] init];
            messageBody.coordinate = coordinate;
            messageBody.title = title;
            message.messageBody = messageBody;
        }
            break;
        default:
            break;
    }
    if (message.isBurnWithMessage) {
        return;
    }
    [self.messageArray insertObject:message atIndex:0];
    [self.msgIdArray addObject:message.messageId];
}

- (NSString *)base64String:(NSString *)string{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string?string:@"" options:0];
    return  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark UISearchDisplayControllerDelegate


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [_searchArray removeAllObjects];
    WS(weakSelf)
    if(searchBar.text.length > 0){
         [self searchLoactionDataWithsearchString:searchBar.text completion:^(id response, NSError *error) {
             weakSelf.searchArray = response;
//             [weakSelf.searchController setValue:languageStringWithKey(@"没有找到相关结果") forKey:@"noResultsMessage"];
//             [weakSelf.searchController.searchResultsTableView reloadData];
             [weakSelf.recordTableView reloadData];
        }];
    }
    [searchBar resignFirstResponder];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [_searchArray removeAllObjects];
    WS(weakSelf)
    if(searchText.length > 0){
        [self searchLoactionDataWithsearchString:searchBar.text completion:^(id response, NSError *error) {
            weakSelf.searchArray = response;
//            [weakSelf.searchController setValue:languageStringWithKey(@"没有找到相关结果") forKey:@"noResultsMessage"];
//            [weakSelf.searchController.searchResultsTableView reloadData];
            [weakSelf.recordTableView reloadData];
        }];
    }
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    //找到取消按钮
    UIButton *cancleBtn = [searchBar valueForKey:@"cancelButton"];
    //修改颜色
    [cancleBtn setTitleColor:ThemeColor forState:UIControlStateNormal];
    self.searchController.searchBar.tintColor = [UIColor blackColor];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.recordTableView reloadData];
}


#pragma mark searchLoactionData  void(^SearchCompletionBlock)(id response, NSError *error)
- (void)searchLoactionDataWithsearchString:(NSString *)searchString completion:(void (^)(id response, NSError *error))completion{
    
//    __block NSMutableArray *addressSearchData = [[NSMutableArray alloc] init];
    [[Common sharedInstance] searchWithType:RXSearchTypeLocalSearch keyword:searchString otherData:@{@"sessionId":self.sessionId} completed:^(id response, NSError *error) {
        !completion?:completion(response,error);
    }];
    
/*
 for(ECMessage *message in self.messageArray){
 if(message.messageBody.messageBodyType == MessageBodyType_Text){
 ECTextMessageBody *textBody = (ECTextMessageBody *)message.messageBody;
 NSRange nameResult = [textBody.text rangeOfString:searchString options:NSCaseInsensitiveSearch];
 if(nameResult.length > 0){
 [addressSearchData addObject:message];
 }
 }else if (message.messageBody.messageBodyType == MessageBodyType_File){
 ECFileMessageBody *fileBody = (ECFileMessageBody *)message.messageBody;
 NSRange fileNameResult = [fileBody.displayName rangeOfString:searchString options:NSCaseInsensitiveSearch];
 if(fileNameResult.length > 0){
 [addressSearchData addObject:message];
 }
 }
 }
 */
    
}

#pragma mark tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECMessage *message = nil;
    if (self.searchBar.text.length <= 0) {
        message = [self.messageArray objectAtIndex:indexPath.row];
    }else{
        message = self.searchArray[indexPath.row];
    }
    //判断Cell是否显示时间
    BOOL isShowTime = NO;
    if (indexPath.row == 0) {
        isShowTime = YES;
    }
    //else if ([self isGroupNoticeMessage:message]){//群组通知
    //isShowTime = YES;
//}
    else{
        id previousMessageCount;
        if (self.searchBar.text.length <= 0) {
            previousMessageCount = [self.messageArray objectAtIndex:indexPath.row - 1];
        }else{
            previousMessageCount = [self.searchArray objectAtIndex:indexPath.row - 1];
        }
        if ([previousMessageCount isKindOfClass:[NSNull class]]) {
            isShowTime = YES;
        }else{
            NSNumber *isShowNumber = objc_getAssociatedObject(message, &KTimeIsShowKey);
            if (isShowNumber) {
                isShowTime = isShowNumber.boolValue;
            }else{
                ECMessage *previousMessage = (ECMessage *)previousMessageCount;
                long long timeStamp = message.timestamp.longLongValue;
                long long previousTimeStamp = previousMessage.timestamp.longLongValue;
                isShowTime = (timeStamp - previousTimeStamp)>180000;
                
            }
        }
    }
    objc_setAssociatedObject(message, &KTimeIsShowKey, @(isShowTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self isGroupNoticeMessage:message]) {//群通知
        ECTextMessageBody *messageBody = (ECTextMessageBody *)message.messageBody;
        CGSize size = [messageBody.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontMiddle,NSFontAttributeName, nil]];
        int ADHeight = 0;
        if (size.width > 200) {
            int width = (int)size.width;
            int a = width / 200;
            int b = width %200?1:0;
            ADHeight = 30*(a+b)-10;
            return ADHeight;
        }
        return 30;
    }
    //根据Cell内容获取高度
    NSInteger fileType = message.messageBody.messageBodyType;
    if([message.userData containsString:kMergeMessage_CustomType]&&message.messageBody.messageBodyType == MessageBodyType_File ){
        fileType = MessageBodyType_MessageMerge;
    }
    
    CGFloat height = 0;
    switch (fileType) {
        case MessageBodyType_MessageMerge:
            height = [ChatViewMergeMessageCell getHightOfCellViewWithMessage:message];
        break;
        case MessageBodyType_Text:
        {
            if ([message.from isEqualToString:[[Chat sharedInstance]getAccount]]) {
                self.isSender = YES;
            }else{
                self.isSender = NO;
            }
            NSDictionary *im_modeDic =  [MessageTypeManager getCusDicWithUserData:message.userData];

            //红包
            if ([im_modeDic hasValueForKey:@"ID"]) {
                BOOL isRedpacket = [[Chat sharedInstance].componentDelegate isRedpacketWithData:message.userData];
                BOOL isRedTip = [[Chat sharedInstance].componentDelegate isRedpacketOpenMessageWithData:message.userData];
                BOOL isTranser = [[Chat sharedInstance].componentDelegate isTransferWithData:message.userData];
                if (isRedpacket == YES) {
                    if (isRedTip == YES) {
                        height = [ChatViewRedpacketTakenTipCell getHightOfCellViewWith:message.messageBody];
                    } else {
                        height = [ChatViewRedpacketCell getHightOfCellViewWith:message.messageBody];
                    }
                }
                if (isTranser == YES) {
                    isShowTime = NO;
                    objc_setAssociatedObject(message, &KTimeIsShowKey, @(isShowTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    height = [ChatViewRedpacketCell getHightOfCellViewWith:message.messageBody];
                }
            }else if (message.isCardWithMessage) {
                height = [ChatViewCardCell getHightOfCellViewWith:message.messageBody];
            }else if ([message.userData isEqualToString:@"voice"] || [message.userData isEqualToString:@"video"] || [message.userData isEqualToString:@"video_single"]) {
                height =[ChatCallNoticeCell getHightOfCellViewWith:message.messageBody];
            }else{
                height = [ChatViewTextCell getHightOfCellViewWith:message.messageBody];
            }
        }
            break;
        case MessageBodyType_Voice:
        case MessageBodyType_Video:
        case MessageBodyType_Image:
        case MessageBodyType_File:
        {
            ECFileMessageBody *body =(ECFileMessageBody *)message.messageBody;
            if (body.localPath.length > 0) {
                body.localPath =  [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:body.localPath.lastPathComponent];
                if (KCNSSTRING_ISEMPTY(body.displayName)) {
                    body.displayName = body.localPath.lastPathComponent;
                }
            }else if (body.remotePath.length > 0){
                if (KCNSSTRING_ISEMPTY(body.displayName)) {
                    body.displayName = body.remotePath.lastPathComponent;
                }
            }else{
                if (KCNSSTRING_ISEMPTY(body.displayName)) {
                    body.displayName = languageStringWithKey(@"无名字");
                }
            }
            //发送的文件类型
            switch (message.messageBody.messageBodyType) {
                case MessageBodyType_Voice:
                {
                    height = [ChatViewVoiceCell getHightOfCellViewWith:body];
                }
                    break;
                case MessageBodyType_Image:{
                    NSDictionary *userData = [MessageTypeManager getCusDicWithUserData:message.userData];
                    height = [ChatViewImageCell getHightOfCellViewWithMessage:message];
                    if (message.isRichTextMessage) {
                        height = [ChatTextImageCell getHightOfCellViewWith:body];
                        NSString *text = [userData hasValueForKey:@"content"] ? userData[@"content"]:userData[@"Rich_text"];
                        NSString *textStr = text.base64DecodingString;
                        CGSize titleSize = [[Common sharedInstance] widthForContent:textStr withSize:CGSizeMake(180, MAXFLOAT) withLableFont:ThemeFontLarge.pointSize];
                        height += titleSize.height;
                    }
                }
                    break;
                case MessageBodyType_Video:{
                    height = [ChatViewVideoCell getHightOfCellViewWith:body];
                }
                    break;
                default:
                {
                    if (message.isMergeMessage) {
                        height = [ChatViewMergeMessageCell getHightOfCellViewWithMessage:message];
                    }else {
                        height = [ChatViewFileCell getHightOfCellViewWith:body];
                    }
                }
                    
                    break;
            }
        }
            break;
        case MessageBodyType_Call:
            height = [ChatViewCallTextCell getHightOfCellViewWith:message.messageBody];
            break;
        case MessageBodyType_Location:
            height = [ChatViewLocationCell getHightOfCellViewWith:message.messageBody];
            break;
        case MessageBodyType_Preview:{
            ECPreviewMessageBody *messageBody = (ECPreviewMessageBody *)message.messageBody;
            if (messageBody.thumbnailLocalPath.length > 0) {
                messageBody.thumbnailLocalPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:messageBody.thumbnailLocalPath.lastPathComponent];
            }
            if (messageBody.localPath.length > 0) {
                messageBody.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:messageBody.localPath.lastPathComponent];
            }
            height = [ChatViewPreviewCell getHightOfCellViewWith:message.messageBody];
        }
            break;
        default:
        {
            ECFileMessageBody *messageBody = (ECFileMessageBody *)message.messageBody;
            if (KCNSSTRING_ISEMPTY(messageBody.displayName)) {
                messageBody.displayName = messageBody.remotePath.lastPathComponent;
            }
            height = [ChatViewFileCell getHightOfCellViewWith:messageBody];
        }
            break;
    }
//    CGFloat addHeight = 0;
//    if (!self.isSender && message.isGroup) {
//        addHeight = 15;
//    }
    
    CGFloat addHeight = 0.0f;
    BOOL isSender = (message.messageState==ECMessageState_Receive?NO:YES);
    if (!isSender && message.isGroup) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@%@",kGroupInfoGroupNickName, self.sessionId]]){
            addHeight = 15.0f;
        } else {
            addHeight = 0.0f;
        }
    }
    //显示的时间高度为30
    return height + (isShowTime? 30:0)+addHeight;
}
- (NSDictionary *)getShareCard:(NSString *)message{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 1) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return dict;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchBar.text.length <= 0) {
        return self.messageArray.count;
    }
    return self.searchArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECMessage *message = nil;
    if (self.searchBar.text.length <= 0) {
        message = [self.messageArray objectAtIndex:indexPath.row];
    }else{
        message = self.searchArray[indexPath.row];
    }
    //有时候，这条消息明明是自己发的，但是这个消息的状态还是ECMessageState_Receive 因此，增加一个message.from来进行再次判断
    self.isSender = ((message.messageState == ECMessageState_Receive && ![message.from isEqualToString:[Common sharedInstance].getAccount]) ? NO:YES);
    NSInteger messageType = message.messageBody.messageBodyType;
    
    if(message.isMergeMessage && message.messageBody.messageBodyType == MessageBodyType_File){
        messageType = MessageBodyType_MessageMerge;
    }
    NSString *cellID;
    if ([message.userData isEqualToString:@"voice"] || [message.userData isEqualToString:@"video"] || [message.userData isEqualToString:@"video_single"]) {
        cellID = [NSString stringWithFormat:@"%@_%@_%@",(self.isSender?@"isSender":@"isReceiver"),NSStringFromClass([message.messageBody class]),message.userData];
    }else{
        //红包
//        if (message.messageBody.messageBodyType==MessageBodyType_Text) {
//            cellID = [NSString stringWithFormat:@"%@_%ld",cellID,(long)[self ExtendTypeOfTextMessage:message]];
//        }
        cellID = [NSString stringWithFormat:@"%@_%@_%ld",(self.isSender?@"isSender":@"isReceiver"),NSStringFromClass([message.messageBody class]),(long)messageType];
//        NSDictionary *imCard_jsonDic = [NSJSONSerialization JSONObjectWithData:[message.userData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        //红包
        BOOL isRedpacket = [[Chat sharedInstance].componentDelegate isRedpacketWithData:message.userData];
        BOOL isTranser = [[Chat sharedInstance].componentDelegate isTransferWithData:message.userData];
        BOOL isRedTip = [[Chat sharedInstance].componentDelegate isRedpacketOpenMessageWithData:message.userData];
        if (isRedpacket == YES) {
            if (isRedTip == YES) {
                cellID = [NSString stringWithFormat:@"isre_%ld_s", (long)isRedTip];
            } else {
                cellID = [NSString stringWithFormat:@"isRR_%ld_n", (long)isRedTip];
            }
        }
        if (isTranser == YES) {
            cellID = [NSString stringWithFormat:@"istrans_%ld_t", (long)isTranser];
        }
        NSDictionary *im_modeDic =  [MessageTypeManager getCusDicWithUserData:message.userData];
        if (message.isCardWithMessage) {
            NSDictionary *dict = [im_modeDic hasValueForKey:SMSGTYPE] ? im_modeDic:im_modeDic[ShareCardMode];
            cellID = [NSString stringWithFormat:@"%@_%@",cellID,dict];
        }else if (message.isRichTextMessage) {
            cellID = [NSString stringWithFormat:@"%@_%@_%d%@", self.isSender?@"issender":@"isreceiver",NSStringFromClass([message.messageBody class]),(int)message.messageBody.messageBodyType,@"Rich_text"];
        }
    }
    ChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        switch (messageType) {
            case MessageBodyType_Text:
            {
//                if ([message.from isEqualToString:[[Chat sharedInstance]getAccount]]) {
//                    self.isSender = YES;
//                }else{
//                    self.isSender = NO;
//                }
                NSDictionary *im_modeDic =  [MessageTypeManager getCusDicWithUserData:message.userData];
                
                //红包
                if ([im_modeDic hasValueForKey:@"ID"]) {
                    BOOL isRedpacket = [[Chat sharedInstance].componentDelegate isRedpacketWithData:message.userData];
                    BOOL isRedTip = [[Chat sharedInstance].componentDelegate isRedpacketOpenMessageWithData:message.userData];
                    BOOL isTranser = [[Chat sharedInstance].componentDelegate isTransferWithData:message.userData];
                    if (isRedpacket == YES) {
                        if (isRedTip == YES) {
                            cell = [[ChatViewRedpacketTakenTipCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                        } else {
                            cell = [[ChatViewRedpacketCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                        }
                    }
                    if (isTranser == YES) {
                        cell = [[ChatViewRedpacketCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                    }
                }else if (message.isCardWithMessage) {
                    cell = [[ChatViewCardCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                }else if ([message.userData isEqualToString:@"voice"] || [message.userData isEqualToString:@"video"] || [message.userData isEqualToString:@"video_single"]) {
                    cell = [[ChatCallNoticeCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                }else{
                    cell = [[ChatViewTextCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                }
                [cell.receipteBtn removeFromSuperview];
            }
                break;
            case MessageBodyType_Voice:
            {
                cell = [[ChatViewVoiceCell alloc]initWithIsSender:self.isSender reuseIdentifier:cellID];
                [cell.receipteBtn removeFromSuperview];
                cell.isHistoryMessage = YES;
            }
                break;
            case MessageBodyType_MessageMerge:
                cell = [[ChatViewMergeMessageCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                [cell.receipteBtn removeFromSuperview];
                cell.isHistoryMessage = YES;
                break;
            case MessageBodyType_Video:{
                cell = [[ChatViewVideoCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                [cell.receipteBtn removeFromSuperview];
                cell.isHistoryMessage = YES;
            }
            break;
            case MessageBodyType_Image:{
                if (message.isRichTextMessage) {
                    cell = [[ChatTextImageCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                } else {
                    cell = [[ChatViewImageCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                }
                [cell.receipteBtn removeFromSuperview];
                cell.isHistoryMessage = YES;
            }
                break;
            case MessageBodyType_Location:{
                cell = [[ChatViewLocationCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                [cell.receipteBtn removeFromSuperview];
                cell.isHistoryMessage = YES;
            }
                break;
            case MessageBodyType_Call:{
                cell = [[ChatViewCallTextCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                [cell.receipteBtn removeFromSuperview];
            }
                break;
            case MessageBodyType_Preview:{
                cell = [[ChatViewPreviewCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                cell.displayMessage = message;
                [cell.receipteBtn removeFromSuperview];
            }
                break;
            default:{
                cell = [[ChatViewFileCell alloc] initWithIsSender:self.isSender reuseIdentifier:cellID];
                [cell.receipteBtn removeFromSuperview];
            }
                break;
        }
        if (message.isRichTextMessage) {
            cell.bubleimg.alpha = 1;
            if (_isSender) {
                cell.bubleimg.image = [ThemeImage(@"chating_richText_right") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
            }else{
                cell.bubleimg.image = [ThemeImage(@"chating_left_01") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
            }
        }
        UITapGestureRecognizer *portraitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellportraitImgPress:)];
        cell.portraitImg.userInteractionEnabled = YES;
        [cell.portraitImg addGestureRecognizer:portraitTap];
    }
    cell.portraitImg.tag = indexPath.row;
    [cell bubbleViewWithData:message];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchBar.text.length > 0) {
        ECMessage *message = self.searchArray[indexPath.row];
        //聊天界面入口
        ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:message.sessionId andRecodMessage:message];
        chatVC.dataSearchFrom = @{@"fromePage":@"searchDetail"};
        [self pushViewController:chatVC];
    }
}


//单击头像
- (void)cellportraitImgPress:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        NSInteger row = tap.view.tag;
        ECMessage *message = nil;
        if(self.searchBar.text.length > 0){
            if (row >= self.searchArray.count) {
                return;
            }
            message = [self.searchArray objectAtIndex:row];
        } else {
            if (row >= self.messageArray.count) {
                return;
            }
            else {
                message = [self.messageArray objectAtIndex:row];
            }
        }
        
        BOOL isSender = (message.messageState == ECMessageState_Receive?NO:YES);
        BOOL isFriend = [RXMyFriendList isMyFriend:message.from];
        if (![[AppModel sharedInstance] runModuleFunc:@"Common" :@"isHighLevelOfTwoWithAccount:" :@[message.from] hasReturn:YES]  || isFriend || isSender) {
            UIViewController *contactorInfosVC = [[Chat sharedInstance].componentDelegate getContactorInfosVCWithData:message.from];
            [self pushViewController:contactorInfosVC];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark other
- (BOOL)isGroupNoticeMessage:(ECMessage *)message{
    NSString *type;
    NSDictionary *dict = [MessageTypeManager getCusDicWithUserData:message.userData];
    if ([dict hasValueForKey:kRonxinMessageType]) {
        type = dict[kRonxinMessageType];
    }
    if ([type isEqualToString:@"GROUP_NOTICE"]) {
        return YES;
    }
    return NO;
}
#pragma mark - UIResponder custom  点击cell的时候调用
- (void)dispatchCustomEventWithName:(NSString *)name userInfo:(NSDictionary *)userInfo tapGesture:(UITapGestureRecognizer *)tap{
    ECMessage * message = [userInfo objectForKey:KResponderCustomECMessageKey];
    if ([name isEqualToString:KResponderCustomChatViewMergeMessageCellBubbleViewEvent]) {
        [self pushViewController:@"HXMergeMessageDetailController" withData:@{@"message":message} withNav:YES];
    }else if ([name isEqualToString:KResponderCustomChatViewFileCellBubbleViewEvent]){
        [self fileCellBubbleViewTap:message];
    }else if ([name isEqualToString:KResponderCustomChatViewCellResendEvent]) {
        ChatViewCell *resendCell = [userInfo objectForKey:KResponderCustomTableCellKey];
        ECMessage *message = resendCell.displayMessage;
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:languageStringWithKey(@"重发该消息") delegate:self cancelButtonTitle:languageStringWithKey(@"取消") otherButtonTitles:languageStringWithKey(@"重发"),nil];
        
        objc_setAssociatedObject(alertView, &KResendMessage, message, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        alertView.tag = Alert_ResendMessage_Tag;
        [alertView show];
    } else if ([name isEqualToString:KResponderCustomChatViewTextLnkCellBubbleViewEvent]) {
        //gy add
        if ([[Chat sharedInstance].componentDelegate respondsToSelector:@selector(getWebViewControllerWithDic:)] && [[Chat sharedInstance].componentDelegate getWebViewControllerWithDic:userInfo]) {//插件用的
            UIViewController *vc = [[Chat sharedInstance].componentDelegate getWebViewControllerWithDic:userInfo];
            if (vc) {
                [self pushViewController:vc];
            }
        }else {
            id vc = [[NSClassFromString(@"WebViewController") alloc]init];
            if (vc) {
                 [self pushViewController:@"WebViewController" withData:@{@"URL":[userInfo objectForKey:@"url"],@"sender":self.sessionId} withNav:YES];
            }else {
                NSString *url = [userInfo objectForKey:@"url"]?[userInfo objectForKey:@"url"]:nil;
                WebBrowserBaseViewController *webBrowserVC = [[WebBrowserBaseViewController alloc] init];
                webBrowserVC.urlStr = url;
                webBrowserVC.delegate = self;
                [self pushViewController:webBrowserVC];
            }
        }
    }else if ([name isEqualToString:KResponderCustomChatViewTextMobileCellBubbleViewEvent]){
        //add yxp
        NSString *mobile = [userInfo objectForKey:@"url"]?[userInfo objectForKey:@"url"]:nil;
        NSString *tepStr = languageStringWithKey(@"可能是个电话号码,你可以");
        NSString *cancelStr =languageStringWithKey(@"取消");
        NSString *dialStr = languageStringWithKey(@"拨打");
        UIActionSheet *sheetView = [[UIActionSheet alloc]initWithTitle:[NSString stringWithFormat:@"%@\n%@",mobile,tepStr] delegate:self cancelButtonTitle:cancelStr destructiveButtonTitle:nil otherButtonTitles:dialStr, nil];
        [sheetView showInView:self.view];
    } else if ([name isEqualToString:KResponderCustomChatViewPreviewCellBubbleViewEvent]) {
        
//        ECPreviewMessageBody *body = (ECPreviewMessageBody*)message.messageBody;
//        WebBrowserBaseViewController *webBrowserVC = [[WebBrowserBaseViewController alloc] initWithBody:body andDelegate:self];
//        RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:webBrowserVC];
//        [self presentViewController:nav animated:YES completion:^{
//            
//        }];
        ECPreviewMessageBody *body = (ECPreviewMessageBody*)message.messageBody;
        if (body.url && message.from) {
            
            NSDictionary *dic = @{@"URL":body.url,@"sender":message.from};
            if ([[Chat sharedInstance].componentDelegate respondsToSelector:@selector(getWebViewControllerWithDic:)]) {
                UIViewController *webViewVC = [[Chat sharedInstance].componentDelegate getWebViewControllerWithDic:dic];
                [self.navigationController pushViewController:webViewVC animated:YES];
            }
        }
    } else if([name isEqualToString:KResponderCustomChatViewCellMessageReadStateEvent]){
        [self pushViewController:@"ReadMessageViewController" withData:message withNav:YES];
    }else if ([name isEqualToString:@"KResponderCustomChatViewCardCellBubbleViewEvent"]) {
        CGPoint point = [tap locationInView:self.recordTableView];
        NSIndexPath * indexPath = [self.recordTableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return;
        ECMessage * message = [self.messageArray objectAtIndex:indexPath.row];
//        NSDictionary *imCard_jsonDic = [NSJSONSerialization JSONObjectWithData:[message.userData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        //        NSDictionary * userDataDic = @{@"ShareCard":@{@"pn_id":publicData.pnId,@"pn_name":publicData.pnName,@"pn_photourl":publicData.headPicUrl,@"type":@"2"}};
        NSDictionary *shareCardDic = [MessageTypeManager getCusDicWithUserData:message.userData];
        
        if (shareCardDic.count > 0) {
            shareCardDic = [shareCardDic objectForKey:@"ShareCard"];
        }
        
        if ([shareCardDic[@"type"] isEqualToString:@"1"]) {
            NSString *str = [shareCardDic objectForKey:@"account"];
            
            UIViewController *contactorInfosVC = [[Chat sharedInstance].componentDelegate getContactorInfosVCWithData:str];
            [self pushViewController:contactorInfosVC];
        } else if ([shareCardDic[@"type"] isEqualToString:@"2"]) {
            UIViewController *contactorInfosVC = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"getHXPublicDetailViewControllerWithID:" :@[shareCardDic[@"pn_id"]?:@""]];
            if (contactorInfosVC) {
                [self pushViewController:contactorInfosVC];
            }
        }
    }
    else{//点击语音、视频通话时长拨打
        if ([message.userData isEqualToString:@"voice"]) {
            [self callBtnTap:nil];//拨打语音
        }else if ([message.userData isEqualToString:@"video"]) {
            [self videoBtnTap:nil];//拨打视频
        }
    }
}
- (void)callBtnTap:(id)sender{
    NSString *callerNickname = [[Common sharedInstance] getOtherNameWithPhone:self.sessionId];
    NSString *callerNumber = self.sessionId;
    
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"callType",callerNumber,@"caller",callerNickname,@"nickname",[NSNumber numberWithInt:EOutgoing],@"callDirect",nil];
    
    [[AppModel sharedInstance] runModuleFunc:@"Dialing" :@"startCallViewWithDict:" :@[dict]];
}
- (void)videoBtnTap:(id)sender{
    //点击tableview，结束输入操作
    NSString *callerNickname = [[Common sharedInstance] getOtherNameWithPhone:self.sessionId];
    NSString *callerNumber = self.sessionId;
    
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"callType",callerNumber,@"caller",callerNickname,@"nickname",[NSNumber numberWithInt:EOutgoing],@"callDirect",nil];
    
    [[AppModel sharedInstance] runModuleFunc:@"Dialing" :@"startCallViewWithDict:" :@[dict]];
}
- (void)redpacketCell:(ChatViewRedpacketCell *)cell didTap:(ECMessage *)message {
//    if(RedpacketMessageTypeRedpacket == message.rpModel.messageType) {
        NSString *phone = message.from;
//        message.rpModel.redpacketSender.userNickname = [[Common sharedInstance] getOtherNameWithPhone:phone];//根据需求显示，拆红包界面的发送者用户名
//        message.rpModel.redpacketSender.userAvatar  = [[Common sharedInstance] getIMageUrlWithPhone:phone];          //根据需求显示，拆红包界面的发送整的用户头像
//        message.rpModel.redpacketSender.userId = phone;
//        message.from = phone;
//        
//        if ([[[message redPacketDic] valueForKey:RedpacketKeyRedapcketToAnyone] isEqualToString:@"member"]) {
//            [[ECDevice sharedInstance] getOtherPersonInfoWith:message.rpModel.toRedpacketReceiver.userId completion:^(ECError *error, ECPersonInfo *person) {
//                
//                message.rpModel.toRedpacketReceiver.userNickname = person.nickName; //根据需求显示，拆红包界面的定向接收者用户名
//                message.rpModel.toRedpacketReceiver.userAvatar  = nil;              //根据需求显示，拆红包界面的定向接收者用户头像
//                
//                //     [self.redpacketViewControl redpacketCellTouchedWithMessageModel:message.rpModel];
//                
//                if ([AppModel sharedInstance].appModelDelegate && [[AppModel sharedInstance].appModelDelegate respondsToSelector:@selector(reloadRedpacketCellWithData:withVC:withSessionId:)]) {
//                    [[AppModel sharedInstance].appModelDelegate reloadRedpacketCellWithData:message.rpModel withVC:self withSessionId:self.sessionId];
//                }
//            }];
//        } else {
    //用字典代替  用户名 用户头像 账号
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:[[Common sharedInstance] getOtherNameWithPhone:phone] forKey:@"userNickname"];
    NSString *userAvatar = [[AppModel sharedInstance] runModuleFunc:@"Common" :@"getIMageUrlWithPhone:" :@[phone] hasReturn:YES];
    [data setObject:userAvatar forKey:@"userAvatar"];
    [data setObject:phone forKey:@"phone"];

            if ([AppModel sharedInstance].appModelDelegate && [[AppModel sharedInstance].appModelDelegate respondsToSelector:@selector(reloadRedpacketCellWithData:withVC:withSessionId:)]) {
                [[AppModel sharedInstance].appModelDelegate reloadRedpacketCellWithData:[data copy] withVC:self withSessionId:self.sessionId];
            }
//        }
//    }
}
- (NSInteger)ExtendTypeOfTextMessage:(ECMessage*)message {
    if (message.userData) {
        //        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[message.userData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//        NSData *data = [message.userData dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

//        if ([message isRedpacket]) {
//            if (![message isRedpacketOpenMessage]) {
//                return TextMessage_RedpacketR;
//            } else {
//                return TextMessage_RedpacketTakenTipR;
//            }
//        }
    }
    return TextMessage_OnlyTextR;
}
-(void)fileCellBubbleViewTap:(ECMessage*)message {
    ECFileMessageBody *fileBody =(ECFileMessageBody *)message.messageBody;
    //先判断是否下载成功 或者本地有缓存
    if(fileBody.mediaDownloadStatus!=ECMediaDownloadSuccessed)
    {
        if(KCNSSTRING_ISEMPTY(fileBody.remotePath))
        {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件不存在")];
            return;
        }
    }
    [self pushViewController:@"HXShowFileViewController" withData:message withNav:YES];
}

#pragma mark - 通知方法
///下载媒体消息附件完成，状态更新
- (void)downloadMediaAttachFileCompletion:(NSNotification *)notification{
    ECError *error = notification.userInfo[KErrorKey];
    if (error.errorCode != ECErrorType_NoError) {
        return;
    }
    ECMessage *message = notification.userInfo[KMessageKey];
    if (![self.sessionId isEqualToString:message.sessionId]) {
        return;
    }
    
    NSMutableArray *msg = self.searchArray;
    if (self.searchBar.text.length <= 0) {
        msg = self.messageArray;
    }

    for (NSInteger i = msg.count - 1; i >= 0; i--) {
        id content = [msg objectAtIndex:i];
        if ([content isKindOfClass:[NSNull class]]) {
            continue;
        }
        ECMessage *currMsg = (ECMessage *)content;
        if (![message.messageId isEqualToString:currMsg.messageId]) {
            continue;
        }
        [msg replaceObjectAtIndex:i withObject:message];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.recordTableView beginUpdates];
            [self.recordTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.recordTableView endUpdates];
        });
    }
}

#pragma mark 新增yuxp sheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        NSArray *mobileArray = [actionSheet.title componentsSeparatedByString:@"\n"];
        if(mobileArray.count > 0){
            //拨打电话
            NSString *num = [[NSString alloc]initWithFormat:@"tel://%@",mobileArray[0]];
            //2017yxp修改 10月16
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];//拨号
        }
    }
}

- (NSMutableArray *)msgIdArray {
    if (!_msgIdArray) {
        _msgIdArray = [NSMutableArray array];
    }
    return _msgIdArray;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
