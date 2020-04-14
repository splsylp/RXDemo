//
//  ChatViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import <Speech/Speech.h>
#pragma mark - zmf 表情云相关 先屏蔽
//#import <BQMM/BQMM.h>//表情云
#import "ChatViewController.h"//各类cell
#import "ChatViewTextCell.h"
#import "ChatViewFileCell.h"
#import "ChatViewVoiceCell.h"
#import "ChatViewImageCell.h"
#import "ChatViewVideoCell.h"
#import "ChatCallNoticeCell.h"
#import "ChatViewCallTextCell.h"
#import "ChatViewCheckCell.h"
#import "ChatViewBigEmojiCell.h"
#import "ChatBurnCoverCell.h"
#import "ChatGroupVotingCell.h"
#import "ChatViewPreviewCell.h"
#import "ChatRecognitionCell.h"
#import "ChatViewLocationCell.h"
#import "ChatRevokeCell.h"
#import "ChatViewCardCell.h"
#import "ChatTextImageCell.h"
#import "ChatWebUrlCell.h"
#import "RXThirdPart.h"
#import "RX_MLSelectPhotoPickerViewController.h"
#import "WebBrowserBaseViewController.h"
//#import "GroupVotingViewController.h"
#import "ReadMessageViewController.h"
#import "Chat.h"
#import "HXMessageMergeManager.h"           //合并转发消息
#import "HXMergeMessageDetailController.h"  //合并消息的详情
#import "ChatViewMergeMessageCell.h"

#pragma mark - 白板相关? zmf
//#import "BoardCoopHelper.h"
#import "ChatToolView.h"           //底部工具栏视图
#import "chatInputTextView.h" //自定义的textView 单例模式
#import "AppModel.h"
//红包cell
#import "ChatViewRedpacketCell.h"
#import "ChatViewRedpacketTakenTipCell.h"
//请加审批 wjy
#import "ChatSPTableViewController.h"
#import "ChatViewCoopCell.h"
#import "HXContinueVoicePlayManager.h"

#import "RXMyFriendList.h"

//#import "RXWorkingWebViewController.h"

#import "HXChatNotifitionCell.h"
#import "RXRevokeMessageBody.h"
#import "RXAlbumManager.h"
#import "RX_MLSelectPhotoBrowserViewController.h"
#import "RX_MLSelectPhotoAssets.h"
#import "GetEndBackTime.h"
#import "RXCollectManager.h"
#import "RXWeakProxy.h"
#import "MSSBrowseActionSheet.h"
#import "RXMenuController.h"
#import "HXGroupInfoViewController.h"
#import "RXPersoninfoControll.h"

#define ToolbarInputViewHeight 50.0f+IphoneXBottom
#define ToolbarMoreViewHeight 90.0f
#define ToolbarMoreViewPartHeight 169.0f
#define Alert_ResendMessage_Tag 1500
#define MessagePageSize 10
#define KNOTIFICATION_ScrollTable       @"KNOTIFICATION_ScrollTable"


const char KMenuViewKey;
const char KAlertResendMessage;

const NSInteger TextMessage_OnlyText = 1000; //纯文本消息
const NSInteger TextMessage_Redpacket = 1003; //红包消息
const NSInteger TextMessage_RedpacketTakenTip = 1004; //抢红包消息
const NSInteger TextMessage_TransformRedPacket = 1007; //转账消息
const NSInteger TextMessage_TransformRedPacketTip = 1009; //收账消息


@interface ChatViewController()<WebBrowserBaseViewControllerDelegate,ChatToolViewDelegate,ChatViewImageCellDelegate, ComponentDelegate, AppModelDelegate, ChatViewRedpacketCellDelegate,ChatViewCellDelegate,ChatMoreActionBarDelegate,UIActionSheetDelegate,
    RXPersoninfoControllDelegate, GroupInfoViewDelegate> {
    //    BOOL isGroup;
    NSIndexPath* _longPressIndexPath;
    RXMenuController *_menuController;
    RXMenuItem *_copyMenuItem;
    RXMenuItem *_deleteMenuItem;
    RXMenuItem *_transitMenuItem;
    RXMenuItem *_collectionMenuItem;//收藏
    RXMenuItem *_shareMenuItem;
    RXMenuItem *_revokeMenuItem;
    RXMenuItem *_moreMenuItem;//更多
    RXMenuItem *_changeToTextItem;//语音转文字
    
    CGFloat viewHeight;
    BOOL isScrollToButtom;
    BOOL ishidden;
    NSString *_filePath ;
    NSURL *_filePathUrl;
    
    BOOL isTimer;
    BOOL isRemove;
    BOOL isAnon_sender;
    BOOL haveLoadMessage;
    //匿名
    BOOL isAnony;
    //红包
    NSArray *_members;
    dispatch_source_t _detectTimer;
    UILabel *memberNum;//群组后显示人数
    UIBarButtonItem *buttonItem;
    
    NSInteger currentUnreadCount;//进入该界面显示未读数量
    
    BOOL refeshAvatar;//刷新头像
    UILabel *_numLabel;
    
    //有的页面跳转回来后不需要刷新滑动到最底部（链接）
    BOOL needGotoBottom;
        
    UIView *_titleview;
}

@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, strong) NSMutableArray * receviceData;
@property (nonatomic, weak) UILabel *stateLabel;
@property (nonatomic, strong) ECGroup *pushGroup;
@property (nonatomic, assign) BOOL isGroupMember;//群组成员

// 阅后即焚
@property (nonatomic, copy) NSString *deleteAtStr;
@property (nonatomic, strong) NSTimer * delMsgTimer;
//  右下脚新消息提示按钮
@property (nonatomic, strong) UIButton *turnToBottomBtn;
@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, assign) float unreadOffSetHeight;
//外界传入搜索到的历史记录消息
@property (nonatomic, strong) ECMessage *recordMessage;

@property (nonatomic ,assign) CGFloat theViewHeight; //通话中下压20

//检测活动
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundIdentifier;

/**
 * 右上角新消息提示按钮
 * 点击滑动到新消息提示最上面
 */
@property (nonatomic,strong) UIButton *turnToTopBtn;

//@property (nonatomic,assign) float newMessageAllHeight;//新消息总共的高度

//录音效果页
@property (nonatomic, strong) UIImageView *amplitudeImageView;
//状态
@property (nonatomic, strong) UILabel *recordInfoLabel;
//取消发送页
@property (nonatomic, strong) UIImageView *cancelImageView;
//取消发送状态
@property (nonatomic, strong) UILabel *cancelLabel;
// hanwei start
@property (nonatomic, strong) NSMutableDictionary *borardDic;
// hanwei end

//新图片提醒发送框
@property (nonatomic, strong) UIView *imgToSendReminderView;
@property (nonatomic, strong) UILabel *reminderLabel;
@property (nonatomic, strong) UIImageView *reminderImageView;
@property (nonatomic, strong) PHAsset *imgPHAsset;
@property (nonatomic, strong) NSTimer * reminderTimer;

//菜单栏视图
@property (nonatomic, strong) ChatToolView *containerView;

///检测在线状态的计时器
@property (nonatomic, strong) NSTimer *onlineTimer;
@property (nonatomic,strong)MSSBrowseActionSheet *browseActionSheet;

/** backImgView */
@property(nonatomic,strong)UIButton *backImgView;
@end

@implementation ChatViewController

- (void)loadView {
    [super loadView];
    needGotoBottom = YES;
}

#pragma mark - 外部调用接口
//外界调用接口
- (instancetype)initWithSessionId:(NSString*)aSessionId {
    if (self = [super init]) {
        self.sessionId = aSessionId;
        isGroup = [aSessionId hasPrefix:@"g"];
    }
    return self;
}
//从搜索历史记录进来的时候
- (instancetype)initWithSessionId:(NSString *)aSessionId andRecodMessage:(ECMessage *)recordMessage{
    if (self = [super init]) {
        self.sessionId = aSessionId;
        isGroup = [aSessionId hasPrefix:@"g"];
        _recordMessage = recordMessage;
    }
    return self;
}
#pragma mark - 控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"eagle.viewDidLoad -before");
    self.view.backgroundColor = [UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f];
    [self setNavigationItem];
    [self setupNavBar];
    
    //注册通知
    [self registerNotification];
    
    //    //初始化默认无多选
    [Common sharedInstance].isIMMsgMoreSelect = NO;
    //  清除被@人数组，设置标志符
    [[ChatMessageManager sharedInstance].AtPersonArray removeAllObjects];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
 
    self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
    //    ///初始化数据
    _longPressIndexPath = nil;
    self.time = @"30";//阅后即焚默认30秒
    self.borardDic = [[NSMutableDictionary alloc] init];
    self.receviceData = [NSMutableArray arrayWithCapacity:0];
    self.messageArray = [NSMutableArray array];
    ssInt = -1;
    self.theViewHeight = kScreenHeight - kTotalBarHeight - kViewDown;
    _deleteAtStr = @" ";
    viewHeight = kScreenHeight - kTotalBarHeight;
    
    DDLogInfo(@"eagle.设置sesionid -before");
    //设置sesionid
    if([self.data isKindOfClass:[NSString class]]){
        self.sessionId = self.data;
    }else if([self.data isKindOfClass:[ECGroup class]]){
        self.pushGroup = self.data;
        self.sessionId = self.pushGroup.groupId;
    }
    ///是否是群组
    isGroup = [self.sessionId hasPrefix:@"g"];
    //记录当前sessionid
    [ChatMessageManager sharedInstance].sessionIdNow = self.sessionId;
    [AppModel sharedInstance].sessionId = self.sessionId;
    
    DDLogInfo(@"eagle.ddSubview:self.tableView -before");
    //创建tableview
    [self.view addSubview:self.tableView];
    
    //水印
    UIView *waterView = [self getWatermarkViewWithFrame:[UIScreen mainScreen].bounds mobile:[[Common sharedInstance] getStaffNo] name:[[Common sharedInstance] getUserName] backColor:[UIColor colorWithHexString:@"EBEBEB"]];
    [self.view addSubview:waterView];
    [self.view sendSubviewToBack:waterView];
    //    创建菜单栏
    DDLogInfo(@"eagle.ddSubview:self.tableView -after");
    [self.view addSubview:self.containerView];
    
    DDLogInfo(@"eagle.ddSubview:self.containerView -after");
    
    if (!isGroup && kPBSSwitch) {//检查当前账号是否被冻结 人员是否离职
        if ( [[Common sharedInstance] checkPointToPiontChatWithAccount:self.sessionId] || ![[Common sharedInstance] checkPointToPiontIsMyFriendWithAccount:self.sessionId needPrompt:YES]) {
            _containerView.userInteractionEnabled = NO;
        }else{
            _containerView.userInteractionEnabled = YES;
        }
    }
    //去掉KitSelectContactsViewController
    if (NSClassFromString(@"KitSelectContactsViewController")) {
        [self removeVcBy:@[NSClassFromString(@"KitSelectContactsViewController")]];
    }
    
    [self setNavData];
}

//view出现时触发
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (needGotoBottom) {
        ///拉取数据
        [self refreshTableView:nil andIsReload:NO];
        ///滚动到底部
        [self scrollViewToBottom:YES];
    }
    
    DDLogInfo(@"eagle.viewWillAppear --- before");
    
    ///初始化数据
    //    _longPressIndexPath = nil;
    //    self.time = @"30";//阅后即焚默认30秒
    //    self.borardDic = [[NSMutableDictionary alloc] init];
    //    self.receviceData = [NSMutableArray arrayWithCapacity:0];
    //    self.messageArray = [NSMutableArray array];
    //    ssInt = -1;
    //    self.theViewHeight = kScreenHeight - kTotalBarHeight - kViewDown;
    //    _deleteAtStr = @" ";
    //    viewHeight = kScreenHeight - kTotalBarHeight;
    
    //设置导航栏
//    [self setupNavBar];
    if (isGroup) {
        [self updateTitleGroupMember];
    }
    
    if ([self.sessionId isEqualToString:IMSystemLoginSessionId]) {
        self.containerView.hidden = YES;
        [self setRightBarItemWithType:0];
    }
    [self setTheViewDown];
    ///_containerView注册键盘通知
    if (_containerView) {
        [_containerView registerKeyboardNotification];
    }
    if (refeshAvatar) {
        refeshAvatar = NO;
        [self.tableView reloadData];
    }
    //    [self refreshUserState];
    if(![Common sharedInstance].isIMMsgMoreSelect){
        [self showNavigationBarBackButtonTitle];
    }
    
    if (_recordMessage) {
        NSArray *beforeArray = [[KitMsgData sharedInstance] getSomeMessagesCount:MessagePageSize OfSession:self.sessionId beforeTime:_recordMessage.timestamp.longLongValue];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:beforeArray.count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    //每次进入的时候 刷新下未读状态
   // [self refreshCellUnreadState];
    DDLogInfo(@"eagle.viewWillAppear --- after");
}
//view出现后触发
- (void)viewDidAppear:(BOOL)animated {
    DDLogInfo(@"eagle.viewDidAppear --- before");
    
    [super viewDidAppear:animated];
    
    [AppModel sharedInstance].sessionId = self.sessionId;
    
    
    //标记消息已读
    //    [[KitMsgData sharedInstance] setUnreadMessageCountZeroWithSessionId:self.sessionId];
    //发送cmd消息 通知多终端已读消息
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"sessionId"] = self.sessionId;
    mDic[@"type"] = @(ChatMessageTypeReadterminal);
    [[ChatMessageManager sharedInstance] sendCmdMessageByDic:mDic];
    //      DDLogInfo(@"eagle.sendCmdMessageByDic --- after");
    if (_containerView) {
        [_containerView chatViewDidAppear];
    }
    //    DDLogInfo(@"eagle._containerView --- after");
    [self createChatToolView];
    [self haveDraftTextUpdateUI];
    [self extracted];
    //    DDLogInfo(@"eagle.extracted --- after");
    [self createUnreadPromptOnBottom];
    if ([self.sessionId isEqualToString:IMSystemLoginSessionId]) {
        self.containerView.hidden = YES;
        [self setRightBarItemWithType:0];
    }
    //    NSLogRect(self.containerView.frame);
    //      DDLogInfo(@"eagle.viewDidAppear --- after");
    
}

//view消失时触发
- (void)viewWillDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
    if (self.voiceMessage) {
        //如果前一个在播放
        objc_setAssociatedObject(self.voiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_VoicePlay object:self.voiceMessage];
    }
    self.voiceMessage = nil;
    [super viewWillDisappear:animated];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];//关闭感应
    //判断是否是多选状态
    if ([Common sharedInstance].isIMMsgMoreSelect) {
        //        [Common sharedInstance].isIMMsgMoreSelect = NO;
        //        [self cancleMoreSelectAction:nil];
    }
    
    if (_containerView) {
        _containerView.resignFirstResponder = YES;
        [_containerView removeKeyboardNotification];
        [_containerView chatVCDisaWillAppear];
        [_containerView setIsBurn];
    }
    //标记消息已读
    [[KitMsgData sharedInstance] setUnreadMessageCountZeroWithSessionId:self.sessionId];
    //发送cmd消息 通知多终端已读消息
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"sessionId"] = self.sessionId;
    mDic[@"type"] = @(ChatMessageTypeReadterminal);
    [[ChatMessageManager sharedInstance] sendCmdMessageByDic:mDic];
    
    //阅后即焚的 放在pop里面 滑动不会触发该方法,所在放在disappear
    if (self.receviceData.count > 0) {
        [ChatMessageManager sharedInstance].sessionIdNow = nil;
        [AppModel sharedInstance].sessionId = nil;
        [[ChatMessageManager sharedInstance] addDelMsgWithDelMsgArr:_receviceData];
    }
}
- (void)layoutControllerSubViews{
    [self setTheViewDown];
    [self notifyStatusBarChange];
}
- (void)willMoveToParentViewController:(nullable UIViewController *)parent;{
    [super willMoveToParentViewController:parent];
    if(parent){
        return;
    }
    //keven 注释：发出通知session列表等等刷新界面
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:nil];
}
- (void)didMoveToParentViewController:(nullable UIViewController *)parent NS_AVAILABLE_IOS(5_0);{
    [super didMoveToParentViewController:parent];
    // DDLogInfo(@"%s,%@",__FUNCTION__,parent);
    if(parent){
        return;
    }
    [AppModel sharedInstance].sessionId = nil;
    [_containerView removeKeyboardNotification];
}

- (void)notifyStatusBarChange{
    [_containerView toolbarDisplayChangedWithStautas:_containerView.toolbarStatus];
}
- (CGFloat)theViewHeight{
    _theViewHeight = kScreenHeight-kTotalBarHeight - kViewDown;
    return _theViewHeight;
}
#pragma mark - 导航栏按钮
//导航栏的右按钮
- (void)navRightBarItemTap:(UIButton *)sender {
    if (isGroup) {
        HXGroupInfoViewController *groupVc = [HXGroupInfoViewController new];
        groupVc.groupInfodelegate = self;
        if (self.data) {
            groupVc.data = self.data;
        } else {
            groupVc.data = self.sessionId;
        }
        [self.navigationController pushViewController:groupVc animated:YES];
    } else {
        [self detailUserinfo:sender];
    }
}
//返回上一层
- (void)popViewController:(id)sender{
    [SVProgressHUD dismiss];
    //判断是否是多选状态
    if ([Common sharedInstance].isIMMsgMoreSelect) {
        [Common sharedInstance].isIMMsgMoreSelect = NO;
        [self cancleMoreSelectAction:nil];
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.view.layer removeAllAnimations];
    [self.tableView.layer removeAllAnimations];
    
    if (_detectTimer) {
        dispatch_source_cancel(_detectTimer);
        _detectTimer = 0;
    }
    
    if ([self.delMsgTimer isValid]){
        [self.delMsgTimer invalidate];
        self.delMsgTimer = nil;
    }
    
    [self popViewController];
    //[self.dataSearchFrom[@"fromePage"] isEqualToString:@"searchDetail"] ||
//    if ([self.dataSearchFrom[@"fromePage"] isEqualToString:@"searchDetail"] || [self.dataSearchFrom[@"fromePage"] isEqualToString:@"groupList"] || [self.dataSearchFrom[@"fromePage"] isEqualToString:@"jsWebview"]) {
//        [self popViewController];
//    }else{
//        [self popRootViewController];
//    }
}


#pragma mark - 更新table
///刷新table
- (void)refreshTableView:(NSNotification *)notification andIsReload:(BOOL)isReload{
    ECMessage *message = (ECMessage *)notification.object;
    if (notification == nil || message == nil) {
        
        [self showNavigationBarBackButtonTitle];
        
        [Chat sharedInstance].isChatViewScroll = YES;
        //整个刷新
        [_messageArray removeAllObjects];
        [self.receviceData removeAllObjects];
        
        NSArray *messageArr = [[KitMsgData sharedInstance] getLatestHundredMessageOfSessionId:self.sessionId andSize:MessagePageSize andASC:YES];
        if (messageArr.count == MessagePageSize) {
            self.tableView.mj_header.hidden = NO;
        } else {
            self.tableView.mj_header.hidden = YES;
        }
        NSUInteger row = 0;
        if (_recordMessage) {
            NSArray *beforeArray = [[KitMsgData sharedInstance] getSomeMessagesCount:MessagePageSize OfSession:self.sessionId beforeTime:_recordMessage.timestamp.longLongValue];
            NSArray *afterArray = [[KitMsgData sharedInstance] getSomeMessagesCount:MessagePageSize OfSession:self.sessionId afterTime:_recordMessage.timestamp.longLongValue];
            
            [self.messageArray addObjectsFromArray:beforeArray];
            [self.messageArray addObject:_recordMessage];
            [self.messageArray addObjectsFromArray:afterArray];
            //第一个和最后一个都是空 用来刷新
            if (messageArr.count == MessagePageSize) {
                self.tableView.mj_header.hidden = NO;
            } else {
                self.tableView.mj_header.hidden = YES;
            }
            if (afterArray.count == MessagePageSize) {
                self.tableView.mj_footer.hidden = NO;
            } else {
                self.tableView.mj_footer.hidden = YES;
            }
            row = beforeArray.count;
        }else {
            [self.messageArray addObjectsFromArray:messageArr];
            [[HXContinueVoicePlayManager shardDefaultManager] setMessageArray:self.messageArray];//连续播放语音设置，记录消息数组地址
        }
        
        if(currentUnreadCount > 0){
            currentUnreadCount = currentUnreadCount-messageArr.count;
        }
        for (ECMessage * msg in messageArr) {
            NSDictionary *im_modeDic = [MessageTypeManager getCusDicWithUserData:msg.userData];
            // 白板隐藏
            NSString *ptpString = [im_modeDic objectForKey:@"com.yuntongxun.rongxin.message_type"];
            if ([ptpString isEqualToString:@"WBSS_HIDE"] || [ptpString isEqualToString:@"WBSS_VOICE"]) {
                [self.messageArray removeObject:msg];
            }
        }
        [Chat sharedInstance].isChatViewScroll = YES;
        
        [self.tableView reloadData];
        if (_recordMessage) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //滚动到正确的位置
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
        }else if (isReload) {
            if (_messageArray.count > 0){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_ScrollTable object:nil];
                });
            }
        }else{
            [self scrollViewToBottom:NO];
        }
        
        //添加阅后即焚倒计时消息
        for (ECMessage * msg in self.messageArray) {
            if (msg.isBurnWithMessage){
                [self addReceviceDataWithBurnMessage:msg];
            }
        }
    } else {
        //添加某条消息
        if (![message.sessionId isEqualToString:self.sessionId]) {
            if(![Common sharedInstance].isIMMsgMoreSelect){
                [self showNavigationBarBackButtonTitle];
            }
            return;
        }
        [Chat sharedInstance].isChatViewScroll = NO;
        NSDictionary *im_modeDic =  [MessageTypeManager getCusDicWithUserData:message.userData];
        NSString *ptpString = [im_modeDic objectForKey:@"com.yuntongxun.rongxin.message_type"];
        if ([ptpString isEqualToString:@"WBSS_HIDE"] || [ptpString isEqualToString:@"WBSS_VOICE"]) {
            return;
        }
        //        if (message.messageState==ECMessageState_Receive && !message.isGroup) {
        //            [_containerView startTimer];
        //        }
        if (notification.userInfo) {
            [self ReceiveMessageRevoke:notification.userInfo];
        } else {
            if ([_messageArray containsObject:message]) {
                return;
            }
            [_messageArray addObject:message];
            
            if (_messageArray.count > 0){
                CGPoint contentOffsetPoint = _tableView.contentOffset;
                CGRect frame = _tableView.frame;
                CGSize tSize = _tableView.contentSize;
                
                if (contentOffsetPoint.y > tSize.height - frame.size.height- frame.size.height || tSize.height < frame.size.height||isShowMessageUnreadCount==0) {
                    //滚动到底部
                    DDLogInfo(@"scroll to the end");
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_ScrollTable object:nil];
                    [self scrollTableView];
                } else {
                    //提示未读数
                    if (_unreadCount == 0) {
                        _unreadOffSetHeight = tSize.height - frame.size.height;
                    }
                    _unreadCount++;
                    NSString *unreadTitle = [NSString stringWithFormat:@"%@(%ld)",languageStringWithKey(@"下面有新消息哦"),(long)_unreadCount];
                    
                    [self.turnToBottomBtn setTitle:unreadTitle forState:UIControlStateNormal];
                    [self.turnToBottomBtn setTitle:unreadTitle forState:UIControlStateHighlighted];
                    [self.turnToBottomBtn setTitle:unreadTitle forState:UIControlStateSelected];
                    if(isShowMessageUnreadCount){
                        self.turnToBottomBtn.hidden = NO;
                    }else{
                        self.turnToBottomBtn.hidden = YES;
                    }
                    CGSize size = [unreadTitle sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontSmall,NSFontAttributeName ,nil]];
                    self.turnToBottomBtn.frame = CGRectMake(kScreenWidth -size.width-20, _tableView.originY + _tableView.height-40, (size.width+20), self.turnToBottomBtn.height);
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }
        if (message.isBurnWithMessage){
            //添加阅后即焚倒计时消息
            [self addReceviceDataWithBurnMessage:message];
        }
    }
}
///table滚动到底部
- (void)scrollViewToBottom:(BOOL)animated {
    if (_recordMessage) {
        return;
    }
    if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:YES];
    }
}
#pragma mark - 更新用户在线状态
- (void)refreshUserState {
    if (![self.sessionId isEqualToString:FileTransferAssistant] && !isGroup) {
        __weak __typeof(self)weakSelf = self;
        [[ECDevice sharedInstance] getUsersState:@[self.sessionId] completion:^(ECError *error, NSArray *usersState) {
            DDLogInfo(@"getUsersState: errorCode=%d,des=%@,usersState=%@",(int)error.errorCode,error.errorDescription,usersState);
            ECUserState *state = [usersState lastObject];
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (error.errorCode == ECErrorType_NoError) {
                if ([strongSelf.sessionId isEqualToString:state.userAcc]) {
                    if (state.isOnline) {
                        strongSelf.stateLabel.text = [NSString stringWithFormat:@"%@-%@", [ChatTools getDeviceWithType:state.deviceType], [ChatTools getNetWorkWithType:state.network]];
                    } else {
                        strongSelf.stateLabel.text = languageStringWithKey(@"对方不在线");
                    }
                }
            }
        }];
    }
}
#pragma mark - 加载历史消息
- (void)loadMoreMessage {
    if (self.messageArray.count == 0) {
        self.tableView.mj_header.hidden = YES;
        return;
    }
    
    ECMessage *message = [self.messageArray objectAtIndex:0];
    NSArray *array = [[KitMsgData sharedInstance] getSomeMessagesCount:MessagePageSize OfSession:self.sessionId beforeTime:message.timestamp.longLongValue];
    CGFloat offsetOfButtom = self.tableView.contentSize.height-self.tableView.contentOffset.y;
    
    NSInteger arraycount = array.count;
    if (array.count == 0) {
        self.tableView.mj_header.hidden = YES;
    } else {
        NSIndexSet *indexset = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, arraycount)];
        [self.messageArray insertObjects:array atIndexes:indexset];
        if (array.count < MessagePageSize) {
            self.tableView.mj_header.hidden = YES;
        }
        currentUnreadCount = currentUnreadCount - array.count;
        
        for (ECMessage * msg in array) {
            NSDictionary *im_modeDic = [MessageTypeManager getCusDicWithUserData:msg.userData];
            // 白板隐藏
            NSString *ptpString = [im_modeDic objectForKey:@"com.yuntongxun.rongxin.message_type"];
            
            if ([ptpString isEqualToString:@"WBSS_HIDE"] || [ptpString isEqualToString:@"WBSS_VOICE"]) {
                [self.messageArray removeObject:msg];
            }
            if (msg.isBurnWithMessage){
                [self addReceviceDataWithBurnMessage:msg];
            }
        }
    }
    [Chat sharedInstance].isChatViewScroll = NO;
    
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointMake(0.0f, self.tableView.contentSize.height-offsetOfButtom);
    [self removeTurnToTopBtn];
}

//加载新的消息（仅限查看中间消息时会用到）
- (void)loadNewMessages {
    ECMessage *lastMessage = self.messageArray.lastObject;
    NSArray *afterArray = [[KitMsgData sharedInstance] getSomeMessagesCount:MessagePageSize OfSession:self.sessionId afterTime:lastMessage.timestamp.longLongValue];
    if (afterArray.count == MessagePageSize) {
        [self.tableView.mj_footer resetNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
    [self.messageArray addObjectsFromArray:afterArray];
    [self.tableView reloadData];
}

#pragma mark - 通知回调
///被T通知
- (void)notificationDelete:(NSNotification *)notGroupId{
    NSString *groupId = notGroupId.object;
    if(KCNSSTRING_ISEMPTY(groupId) ||
       ![groupId isEqualToString:self.sessionId]){
        return;
    }
    
    RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
    [dialog showTitle:languageStringWithKey(@"提示") subTitle:languageStringWithKey(@"您已被管理员移出该群组") ensureStr:languageStringWithKey(@"知道了") cancalStr:nil selected:^(NSInteger index) {
        [self popViewController];
    }];
}
//消息发送完成回调通知
- (void)sendMessageCompletion:(NSNotification *)notification {
    ECMessage *message = notification.userInfo[KMessageKey];
    if ([Common sharedInstance].isIMMsgMoreSelect) {
        [Common sharedInstance].isIMMsgMoreSelect = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self cancleMoreSelectAction:nil];
        });
    }
    if (![self.sessionId isEqualToString:message.sessionId]) {
        return;
    }
    NSInteger index = -1;
    for (NSInteger i = self.messageArray.count - 1; i >= 0; i--) {
        id content = [self.messageArray objectAtIndex:i];
        if ([content isKindOfClass:[NSNull class]]) {
            continue;
        }
        ECMessage *currMsg = (ECMessage *)content;
        if (![message.messageId isEqualToString:currMsg.messageId]) {
            if (currMsg.messageBody.messageBodyType == MessageBodyType_Video && message.messageBody.messageBodyType == MessageBodyType_Video) {
                ECVideoMessageBody *videoBody = (ECVideoMessageBody *)message.messageBody;
                if (![videoBody.localPath isEqualToString:currMsg.messageId]) {//非视频占位消息
                    continue;
                }
            }else {
                continue;
            }
        }
        currMsg.messageState = message.messageState;
        currMsg.messageBody = message.messageBody;
        
        dispatch_async(dispatch_get_main_queue(), ^{               
            ChatViewCell *cell = (ChatViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.displayMessage = message;
            [cell bubbleViewWithData:message];
            //更新状态
            [cell updateMessageSendStatus:message.messageState];
        });
        index = i;
    }
    if (index>=0) {
        [self.messageArray replaceObjectAtIndex:index withObject:message];
    }
}
//清空聊天记录
- (void)clearMessageArray:(NSNotification *)notification{
    NSString *session = (NSString *)notification.object;
    if (![session isEqualToString:self.sessionId]) {//非本会话的消息不处理
        return;
    }
    [self hideRightItemBar];
    [self performSelectorOnMainThread:@selector(clearTableView) withObject:nil waitUntilDone:[NSThread isMainThread]];
}
///隐藏右上角按钮通知
- (void)hideRightItemBar {
    if (!isGroup) {
        return;
    }

    KitGroupMemberInfoData *data = [KitGroupMemberInfoData getGroupMemberInfoWithMemberId:[Chat sharedInstance].getAccount withGroupId:self.sessionId];
    _isGroupMember = NO;
    if (data) {
        _isGroupMember = YES;
    }
    if (!_isGroupMember) {
        [self updateTitleGroupMember];
        _isGroupMember = YES;
    }else{
        [self setBarButtonWithNormalImg:ThemeImage(@"title_bar_more_normal") highlightedImg:ThemeImage(@"title_bar_more_normal") target:self action:@selector(navRightBarItemTap:) type:NavigationBarItemTypeRight];
    }
}
///清除数据源
- (void)clearTableView {
    [_messageArray removeAllObjects];
    [self.receviceData removeAllObjects];
    [self.tableView reloadData];
}
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
    for (NSInteger i = self.messageArray.count - 1; i >= 0; i--) {
        id content = [self.messageArray objectAtIndex:i];
        if ([content isKindOfClass:[NSNull class]]) {
            continue;
        }
        ECMessage *currMsg = (ECMessage *)content;
        if (![message.messageId isEqualToString:currMsg.messageId]) {
            continue;
        }
        if (message.isBurnWithMessage) {
            NSString *timeStr = [[NSUserDefaults standardUserDefaults] valueForKey:message.messageId];
            if (timeStr &&
                message.messageBody.messageBodyType != MessageBodyType_Voice) {
                [[NSUserDefaults standardUserDefaults] setValue:self.time forKey:message.messageId];
            }
            //添加阅后即焚倒计时消息
            [self addReceviceDataWithBurnMessage:message];
        }
        [self.messageArray replaceObjectAtIndex:i withObject:message];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        });
    }
}
///刷新table通知
- (void)refreshTableView:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshTableView:notification andIsReload:YES];
    });
}
///滚动到底部通知
- (void)scrollTableView {
    if (self && self.tableView && self.messageArray.count > 0) {
        [_menuController setMenuVisible:NO animated:YES];
        [_menuController setMenuItems:nil];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

//音视频呼叫消息记录刷新
- (void)callMessage:(NSNotification *)notification{
    ECMessage *message = (ECMessage *)notification.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        //有新消息入库会走这个方法，所以这里可以判断处理左上角其他人的消息未读数
        if (![message.from isEqualToString:[[Common sharedInstance] getAccount]] && ![message.to isEqualToString:self.sessionId]) {
            [self showNavigationBarBackButtonTitle];
        }
        
        if ([self.sessionId isEqualToString:message.from]) {//来自当前对话对象的消息，不需要刷新未读数，否则需要
            
        }else {
            [self showNavigationBarBackButtonTitle];
        }
        
        if (message == nil || ![message.sessionId isEqualToString:self.sessionId]) {
            return;
        }
        [self refreshTableView:notification];
        [self hideRightItemBar];
    });
}

- (void)refreshTableViewCellByMessageId:(NSNotification *)notification {
    NSString *messageId = (NSString *)notification.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (ChatViewCell *cell in self->_tableView.visibleCells) {
            if ([messageId isEqualToString:cell.displayMessage.messageId]) {
                NSIndexPath *indexPath = [self->_tableView indexPathForCell:cell];
                [self->_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    });
}


///热点变化
- (void)statusBarFrameWillChange:(NSNotification *)notification {
    [_containerView toolbarDisplayChangedWithStautas:_containerView.toolbarStatus];
}
///刷新群组title通知
- (void)reloadGroupTitle:(NSNotification *)titleGroupId{
    NSString *strId = titleGroupId.object;
    if(KCNSSTRING_ISEMPTY(strId) ||
       ![strId isEqualToString:self.sessionId]){
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.titleLabel.text = [[Common sharedInstance] getOtherNameWithPhone:strId];
        
        [self updateTitleGroupMember];
        
        CGSize size = [self.titleLabel.text sizeWithFont:self.titleLabel.font maxWidth:self.titleLabel.frame.size.width lineBreakMode:self.titleLabel.lineBreakMode];
        CGSize size2 = [self->memberNum.text sizeWithFont:self->memberNum.font maxWidth:self->memberNum.width lineBreakMode:self->memberNum.lineBreakMode];
        self.titleLabel.left = -size2.width/2;
        self->memberNum.left = self.titleLabel.left+self.titleLabel.width/2+size.width/2;
    });
}
///更新用户的状态 通知
- (void)notifyUserState:(NSNotification *)notification {
    //    return; // 屏蔽掉
    ECMessage *message = (ECMessage *)notification.object;
    if (![message.sessionId isEqualToString:self.sessionId]) {
        return;
    }
    
    if (_detectTimer) {
        dispatch_source_cancel(_detectTimer);
        _detectTimer = 0;
    }
    
    if (message.messageBody.messageBodyType == MessageBodyType_UserState) {
        ECUserStateMessageBody *body = (ECUserStateMessageBody *)message.messageBody;
        int state = [body.userState intValue];
        if (state == UserState_Write) {
            if (isGroup || [message.sessionId isEqualToString:Common.sharedInstance.getAccount]) {return;}
            _titleLabel.text = languageStringWithKey(@"正在输入");
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _detectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
            dispatch_source_set_timer(_detectTimer,dispatch_time(DISPATCH_TIME_NOW, 12ull*NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
            dispatch_source_set_event_handler(_detectTimer, ^{
                dispatch_source_cancel(self->_detectTimer);
                self->_detectTimer = 0;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->_titleLabel.text = [[Common sharedInstance] getOtherNameWithPhone:self.sessionId];
                });
            });
            dispatch_resume(_detectTimer);
        } else if (state == UserState_Record) {
            
            _titleLabel.text = languageStringWithKey(@"正在录音");
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _detectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
            dispatch_source_set_timer(_detectTimer,dispatch_time(DISPATCH_TIME_NOW, 12ull*NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
            dispatch_source_set_event_handler(_detectTimer, ^{
                dispatch_source_cancel(self->_detectTimer);
                self->_detectTimer = 0;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->_titleLabel.text = [[Common sharedInstance] getOtherNameWithPhone:self.sessionId];
                });
            });
            dispatch_resume(_detectTimer);
            
        } else {
            _titleLabel.text = [[Common sharedInstance] getOtherNameWithPhone:self.sessionId];
        }
    }
}
///刷新消息阅读状态
- (void)refreshMessageReadState:(NSNotification *)noti {
    //消息已读
    NSDictionary *dict = noti.object;
    NSString *messageId = [dict objectForKey:@"messageId"];
    NSString *sessionId = [dict objectForKey:@"sessionid"];
    if (![self.sessionId isEqualToString:sessionId]) {
        return;
    }
    for (NSInteger i = self.messageArray.count - 1; i >= 0; i--) {
        id content = [self.messageArray objectAtIndex:i];
        if ([content isKindOfClass:[NSNull class]]) {
            continue;
        }
        ECMessage *message = (ECMessage *)content;
        if (![messageId isEqualToString:message.messageId]) {
            continue;
        }
        
        NSNumber *isplay = objc_getAssociatedObject(message, &KVoiceIsPlayKey);
        if (isplay.boolValue) {
            objc_setAssociatedObject(self.voiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
            self.voiceMessage = nil;
        }
        message.isRead = YES;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if ([cell isKindOfClass:[ChatViewCell class]]) {
            ChatViewCell *chatCell = (ChatViewCell *)cell;
            [chatCell updateMessageSendStatus:ECMessageState_SendSuccess];
        }
    }
}

- (void)refreshCellUnreadState {
    for (NSInteger i = self.messageArray.count - 1; i >= 0; i--) {
        id content = [self.messageArray objectAtIndex:i];
        if ([content isKindOfClass:[NSNull class]]) {
            continue;
        }
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if ([cell isKindOfClass:[ChatViewCell class]]) {
            ChatViewCell *chatCell = (ChatViewCell *)cell;
            [chatCell updateMessageSendStatus:ECMessageState_SendSuccess];
        }
    }
}

///消息删除
- (void)ReceiveMessageDelete:(NSNotification*)notification {
    NSString *msgId = notification.userInfo[@"msgid"];
    NSString *sessionId = notification.userInfo[@"sessionid"];
    
    if ([self.sessionId isEqualToString:sessionId] && msgId) {
        if (self.messageArray.count>0) {
            // 谓词搜索
            NSPredicate *predmsgIde = [NSPredicate predicateWithFormat:@"messageId CONTAINS[cd] %@", msgId];
            
            NSArray* searchArray = [self.messageArray filteredArrayUsingPredicate:predmsgIde];
            
            for (id searchdata in searchArray) {
                NSInteger index = [self.messageArray indexOfObject:searchdata];
                if (index != NSNotFound) {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:msgId];
                    //                    [self.tableView beginUpdates];
                    if (index == self.messageArray.count -1) {
                        if (index >= 1) {
                            [[KitMsgData sharedInstance] deleteMessage:(ECMessage *)searchdata andPre:[_messageArray objectAtIndex:index-1]];
                        }else{
                            [[KitMsgData sharedInstance] deleteMessage:(ECMessage *)searchdata andPre:nil];
                        }
                    }else{
                        [[KitMsgData sharedInstance] deleteMessage:((ECMessage *)searchdata).messageId andSession:self.sessionId];
                    }
                    [self.messageArray removeObject:searchdata];
                    [self.tableView reloadData];
                    //                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    //                    [self.tableView endUpdates];
                }
            }
        }
    }
}
///阅后即焚相关
- (void)changeIsBurnAfterRead:(NSNotification *)notifi {
    BOOL needBurnAfterRead = [notifi.userInfo[@"isBurnAfterRead"] boolValue];
    if (needBurnAfterRead) {
        _isBurnAfterRead = YES;
    } else {
        _isBurnAfterRead = NO;
    }
    
}
///销毁菜单栏
- (void)menuControllerShouldSetMenuItemsNil {
    [_menuController setMenuItems:nil];
}
///刷新table
- (void)tableViewShouldReloadData:(NSNotification *)notification {
    ECMessage *msg = (ECMessage *)notification.object;
    if (msg == nil || ![msg.sessionId isEqualToString:self.sessionId]) {
        return;
    }
    ECMessage *message = [[KitMsgData sharedInstance] getMessagesWithMessageId:msg.messageId OfSession:self.sessionId];
    NSUInteger index = [self.messageArray indexOfObject:msg];
    if (index != NSNotFound) {
        [self.messageArray replaceObjectAtIndex:index withObject:message];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            
            if (index == self.messageArray.count - 1) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        });
    }
}

- (void)tableViewDeleteCell:(NSNotification *)notification {
    ECMessage *msg = (ECMessage *)notification.object;
    if (msg == nil || ![msg.sessionId isEqualToString:self.sessionId]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageArray removeObject:msg];
        [self.tableView reloadData];
    });
}
///刷新table 语音消息
- (void)tableViewShouldUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.messageArray indexOfObject:self.voiceMessage] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    });
}
///阅后即焚消息通知
- (void)voiceCellAboutBurn:(NSNotification *)notifi {
    ECMessage *message = notifi.userInfo[@"message"];
    if (message.isBurnWithMessage){
        NSString *timeStr = [[NSUserDefaults standardUserDefaults] valueForKey:message.messageId];
        if (!timeStr) {
            [[NSUserDefaults standardUserDefaults] setValue:self.time forKey:message.messageId];
        }
        [self addReceviceDataWithBurnMessage:message];
    }
}
///下载阅后即焚消息
- (void)burnMediaMessageHasDownLoad:(NSNotification *)notifi{
    NSString *messageID = notifi.object;
    NSString *timeStr = [[NSUserDefaults standardUserDefaults] valueForKey:messageID];
    if (!timeStr) {
        [[NSUserDefaults standardUserDefaults] setValue:self.time forKey:messageID];
    }
    ECMessage *message = [[KitMsgData sharedInstance] getMessagesWithMessageId:messageID OfSession:self.sessionId];
    if (message) {
        [self addReceviceDataWithBurnMessage:message];
    }
}

//被移除群
- (void)IGetKickedOutOfGroup:(NSNotification *)notGroupId {
    NSString *groupId =notGroupId.object;
    if(KCNSSTRING_ISEMPTY(groupId) || ![groupId isEqualToString:self.sessionId]){
        return;
    }
    
    RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
    [dialog showTitle:languageStringWithKey(@"提示") subTitle:languageStringWithKey(@"您已被移出群聊") ensureStr:languageStringWithKey(@"知道了") cancalStr:nil selected:^(NSInteger index) {
        [self popViewController];
    }];
}

//群组解散通知
- (void)groupIsDisbanded:(NSNotification *)notGroupId {
    NSString *groupId =notGroupId.object;
    if(KCNSSTRING_ISEMPTY(groupId) || ![groupId isEqualToString:self.sessionId]){
        return;
    }
    
    RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
    [dialog showTitle:languageStringWithKey(@"提示") subTitle:languageStringWithKey(@"群组已解散") ensureStr:languageStringWithKey(@"知道了") cancalStr:nil selected:^(NSInteger index) {
        [self popViewController];
    }];
}
///群设置群昵称开关
- (void)groupMembersNickNameSwitch:(NSNotification *)noti{
    NSString *settingGroupId = noti.object;
    if (![settingGroupId isEqualToString:self.sessionId]) {
        return;
    }
    [Chat sharedInstance].isChatViewScroll = YES;
    [self.tableView reloadData];
}
///群昵称修改通知
- (void)groupNickNameModifyNotice:(NSNotification *)noti {
    ECModifyGroupMemberMsg * memberMsg = (ECModifyGroupMemberMsg *)noti.object;
    if (![memberMsg.groupId isEqualToString:self.sessionId]) {
        return;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@%@",kGroupInfoGroupNickName,self.sessionId]]){
        [Chat sharedInstance].isChatViewScroll = YES;
        
        [self.tableView reloadData];
    }
}
///取消多选状态通知
- (void)cancleMoreSelectAction:(id)sender {
    [[Common sharedInstance].moreSelectMsgData removeAllObjects];
    [Common sharedInstance].isIMMsgMoreSelect = NO;
    self.moreActionBar.disabled = NO;
    //显示返回按钮
    [self showNavigationBarBackButtonTitle];
    
    [Chat sharedInstance].isChatViewScroll = YES;
    [self.tableView reloadData];
    [UIView animateWithDuration:0.5f animations:^{
        self.containerView.hidden = NO;
        self.moreActionBar.hidden = YES;
    }];
}
//停止播放语音
- (void)stopPlayVoice{
    if (self.voiceMessage) {
        //如果前一个在播放
        objc_setAssociatedObject(self.voiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.messageArray indexOfObject:self.voiceMessage] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
    self.voiceMessage = nil;
    
    if (self.presentedViewController && [self.presentedViewController isKindOfClass:[AVPlayerViewController class]]) {
        AVPlayerViewController *av = (AVPlayerViewController *)self.presentedViewController;
        [av.player pause];
    }
    
}
///进入白板通知
- (void)replayEnterBoard:(NSNotification *)noti {
    if ([noti.object isKindOfClass:[NSString class]] && [noti.object isEqualToString:@"nil"]) {
        [_borardDic removeAllObjects];
        return;
    }
    if ([_borardDic objectForKey:ROOMID]) {
        NSString *pwdStr = nil;
        if ([_borardDic hasValueForKey:PASSWORD]) {
            pwdStr = _borardDic[PASSWORD];
        }else{
            pwdStr = @"123456";
        }
        NSDictionary *params = @{USERID:[[Chat sharedInstance] getAccount],
                                 PASSWORD:pwdStr,
                                 ROOMID:[_borardDic objectForKey:ROOMID],
                                 BOARDTYPE:@"1",
                                 SENDIM:@"0",
                                 BOARDURL:[Common sharedInstance].getBoardUrl
                                 };
        [[AppModel sharedInstance] runModuleFunc:@"Board":@"joinRoomWithParams:andPresentVC:":@[params,self]];
    }
}

//人员删除通知
- (void)onBMDeleteAccountsNotification:(NSNotification *)notification {
    id array = notification.object;
    if ([array isKindOfClass:[NSArray class]]) {
        for (NSString *account in array) {
            if ([account isEqualToString:self.sessionId]) {
                [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"当前用户已离职")];
                _containerView.userInteractionEnabled = NO;
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - 群组相关
- (void)queryGroupMembersFromSDK {
    //是否分页下载
    [[ECDevice sharedInstance].messageManager queryGroupMembers:self.sessionId completion:^(ECError *error, NSString *groupId, NSArray *members) {
        if (error.errorCode == ECErrorType_NoError && members.count > 0) {
            [members sortedArrayUsingComparator:
             ^(ECGroupMember *obj1, ECGroupMember *obj2) {
                 if (obj1.role < obj2.role) {
                     return (NSComparisonResult) NSOrderedAscending;
                 } else {
                     return (NSComparisonResult) NSOrderedDescending;
                 }
             }];
            [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
            [KitGroupMemberInfoData insertGroupMemberArray:members withGroupId:groupId];
            [self updateTitleGroupMember];
        }
    }];
}

///更新人数
- (void)updateTitleGroupMember {
    ECGroup *group = [KitGroupInfoData getGroupByGroupId:self.sessionId];
    if (!group) {
        //说明群组不存在或已解散
        isRemove = YES;
        memberNum.text = @"(0)";
        _containerView.isOutGroup = 2;
        [self setRightBarItemWithType:0];
    } else {
        NSArray *groups = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotRealGroups"];
        if (groups && [groups containsObject:self.sessionId]) {
            isRemove = YES;
            memberNum.text = @"(0)";
            _containerView.isOutGroup = 2;
            [self setRightBarItemWithType:0];
        }
        else {
            //如果自己不是群组成员，则群组的人数显示为0
            KitGroupMemberInfoData *data = [KitGroupMemberInfoData getGroupMemberInfoWithMemberId:[Chat sharedInstance].getAccount withGroupId:self.sessionId];
            if (!data) {
                isRemove = YES;
                memberNum.text = @"(0)";
                //按这尿性 看样子是要在_containerView中设置一个属性 然后让按钮点击的时候给提示
                _containerView.isOutGroup = 1;
                [self setRightBarItemWithType:0];
            }
            else {
                _containerView.isOutGroup = 0;
                NSInteger groupMemberCount = [KitGroupMemberInfoData getAllMemberCountGroupId:self.sessionId];
                memberNum.text = [NSString stringWithFormat:@"(%ld)",(long)groupMemberCount];
                [self setRightBarItemWithType:1];
            }
        }
    }
}

#pragma mark - 其他事件
///进入用户详情
- (void)detailUserinfo:(UIButton *)sender {
    [self closeKeyBoard];
    
    RXPersoninfoControll *personal = [RXPersoninfoControll new];
    personal.data = self.sessionId;
    personal.personinfoDelegate = self;
    [self.navigationController pushViewController:personal animated:YES];

}
///收起键盘
- (void)closeKeyBoard{
    /// eagle 当输入状态时候，收起键盘，否则返回的时候，会有键盘丢失的bug
    if (_containerView.toolbarStatus == ToolbarStatus_Input ) {
        _containerView.toolbarStatus = ToolbarStatus_None;
        NSLog(@"eagle.收起键盘");
    }
    [self.view endEditing:YES];
}
///通话
- (void)voipCall:(UIButton *)sender {
    NSNumber *number = [[AppModel sharedInstance] runModuleFunc:@"VidyoHelper" :@"IsVidyoingWhenOtherOperate":nil];
    if(number.integerValue == 1) {
        //视频中不能通话
        return;
    }
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"设备不支持该功能")];
        return;
    }
    [self closeKeyBoard];
    NSDictionary *addbookDic = [[Common sharedInstance].componentDelegate getDicWithId:self.sessionId withType:0];
    NSString *phoneNum = [addbookDic objectForKey:@"mobile"];
    if(addbookDic.count>0 && !KCNSSTRING_ISEMPTY(phoneNum)) {
        if ([AppModel sharedInstance].isInConf) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"当前正在会议中")];
            return ;
        }
        [NSObject callSystenPhoneNumber:[addbookDic objectForKey:@"mobile"] isSaveRecord:YES recordDic:addbookDic];
    } else {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"无效的手机号码")];
    }
}

#pragma mark - 接收到阅后即焚消息
- (void)addReceviceDataWithBurnMessage:(ECMessage *)message{
    BOOL isSender = message.messageState == ECMessageState_Receive ? NO:YES;
    if ([message.from isEqualToString:FileTransferAssistant]) {
        isSender = YES;
    }
    if (isSender || !message.isRead) {
        return;
    }
    for (ECMessage *data in self.receviceData) {
        if ([data.messageId isEqualToString:message.messageId]) {
            return;
        }
    }
    
    __block  NSString *timeStr = [[NSUserDefaults standardUserDefaults] valueForKey:message.messageId];
    if (message.messageBody.messageBodyType == MessageBodyType_Voice) {//语音播放完后倒计时
        if (timeStr) {
            [self.receviceData addObject:message];
        }
    }else if (message.messageBody.messageBodyType == MessageBodyType_Image){
        if (timeStr) {
            [self.receviceData addObject:message];
        }
        //需求是在点击阅后即焚的时候 对方的文本或图片消息就要消失掉
        [[ECDevice sharedInstance].messageManager deleteMessage:message completion:nil];
    }else{
        if (!timeStr) {
            [[NSUserDefaults standardUserDefaults] setValue:self.time forKey:message.messageId];
        }
        [self.receviceData addObject:message];
        //需求是在点击阅后即焚的时候 对方的文本或图片消息就要消失掉
        [[ECDevice sharedInstance].messageManager deleteMessage:message completion:nil];
    }
    
    //    [GetEndBackTime addObserverUsingBlock:^(NSNotification * _Nonnull note, NSTimeInterval stayBackgroundTime) {
    //
    //        NSInteger time = round(stayBackgroundTime);
    //        NSInteger t = [timeStr integerValue]- time;
    //        timeStr = [NSString stringWithFormat:@"%ld", (long)t];
    //        [[NSUserDefaults standardUserDefaults] setValue:timeStr forKey:message.messageId];
    //
    //    }];
    //起刷新线程
    if (!self.delMsgTimer || ![self.delMsgTimer isValid]){
        self.delMsgTimer = [NSTimer timerWithTimeInterval:1 target:[RXWeakProxy proxyWithTarget:self] selector:@selector(timerDeleteMessge) userInfo:self.sessionId repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.delMsgTimer forMode:NSRunLoopCommonModes];
        [self.delMsgTimer fire];
    }
}

#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!_turnToBottomBtn.hidden) {
        if (scrollView.contentOffset.y >  _unreadOffSetHeight) {
            [self resetTurnToBottomBtn];
            _unreadCount = 0;
            self.turnToBottomBtn.hidden = YES;
        }
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [Chat sharedInstance].isChatViewScroll = NO;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [Chat sharedInstance].isChatViewScroll = NO;
}
- (void)scrollTableViewToTop{
    if (self && self.tableView && self.messageArray.count > 1) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id content = [self.messageArray objectAtIndex:indexPath.row];
    if ([content isKindOfClass:[NSNull class]]) {
        return 44.0f;
    }
    ECMessage *message = (ECMessage*)content;
    BOOL isNoNeedAddHeight = NO;
    //判断Cell是否显示时间
    BOOL isShow = NO;
    if (indexPath.row == 0 ) {
        isShow = YES;
    } else {
        id preMessagecontent = [self.messageArray objectAtIndex:indexPath.row-1];
        if ([preMessagecontent isKindOfClass:[NSNull class]]) {
            isShow = YES;
        } else {
//            NSNumber *isShowNumber = objc_getAssociatedObject(message, &KTimeIsShowKey);
//            if (isShowNumber) {
//                isShow = isShowNumber.boolValue;
//            } else {
//                ECMessage *preMessage = (ECMessage*)preMessagecontent;
//                long long timestamp = message.timestamp.longLongValue;
//                long long pretimestamp = preMessage.timestamp.longLongValue;
//                isShow = ((timestamp-pretimestamp)>180000); //与前一条消息比较大于3分钟显示
//            }
            ECMessage *preMessage = (ECMessage*)preMessagecontent;
            long long timestamp = message.timestamp.longLongValue;
            long long pretimestamp = preMessage.timestamp.longLongValue;
            isShow = ((timestamp-pretimestamp)>180000); //与前一条消息比较大于3分钟显示
        }
    }
    objc_setAssociatedObject(message, &KTimeIsShowKey, @(isShow), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //根据cell内容获取高度
    CGFloat height = 0.0f;
    NSInteger fileType = message.messageBody.messageBodyType;
    if(message.isMergeMessage && message.messageBody.messageBodyType == MessageBodyType_File){
        fileType = MessageBodyType_MessageMerge;
    }
    switch (fileType) {
        case MessageBodyType_None: {
            //撤回
            if ([[message.messageBody class] isSubclassOfClass:[RXRevokeMessageBody class]]) {
                //height = [ChatRevokeCell getHightOfCellViewWith:message.messageBody];
                height = [HXChatNotifitionCell getHightOfCellViewWith:message.messageBody];
                
            }
        }
            break;
        case MessageBodyType_MessageMerge:
            height = [ChatViewMergeMessageCell getHightOfCellViewWithMessage:message];
            break;
        case MessageBodyType_Text:{
            NSDictionary *im_modeDic = [MessageTypeManager getCusDicWithUserData:message.userData];
            ECTextMessageBody *body = (ECTextMessageBody *)message.messageBody;
            //红包
            if ([im_modeDic hasValueForKey:@"ID"] || [im_modeDic hasValueForKey:@"money_is_transfer_message"]) {
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
                    isShow = NO;
                    objc_setAssociatedObject(message, &KTimeIsShowKey, @(isShow), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    height = [ChatViewRedpacketCell getHightOfCellViewWith:message.messageBody];
                }
            }else if ([im_modeDic hasValueForKey:@"SmileyEmoji"]) {
                //大表情
                height = [ChatViewBigEmojiCell getHightOfCellViewWith:message.messageBody];
            }else if ([im_modeDic hasValueForKey:@"GroupVoting_Url"]) {
                //大表情
                height = [ChatGroupVotingCell getHightOfCellViewWith:message.messageBody];
            } else if (message.isCardWithMessage) {
                height = [ChatViewCardCell getHightOfCellViewWith:message.messageBody];
            }else if([[im_modeDic objectForKey:kRonxinMessageType ] isEqualToString:@"GROUP_NOTICE"]){
                height = [HXChatNotifitionCell getHightOfCellViewWith:message.messageBody];
                isNoNeedAddHeight = YES;
                objc_setAssociatedObject(message, @"HXTextAlignment", @"left", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if (message.isAddFriendMessage) {
                isNoNeedAddHeight = YES;
                height = [HXChatNotifitionCell getHightOfCellViewWith:message.messageBody];
            }else if (message.isVoipRecordsMessage) {//voip消息
                height = [ChatCallNoticeCell getHightOfCellViewWith:message.messageBody];
                isNoNeedAddHeight = YES;
            }
            else if ((message.isWebUrlMessage || body.text.isWebUrl) && !message.isAnalysisedMessage && !message.isBurnWithMessage) {
                height = [ChatRecognitionCell getHightOfCellViewWith:message.messageBody];
            }
            else if (message.isWebUrlMessageSendSuccess) {
                height = [ChatWebUrlCell getHightOfCellViewWith:message.messageBody];
            }
            else{
                NSString *imMode = [im_modeDic objectForKey:@"IM_Mode"];
                if (!KCNSSTRING_ISEMPTY(imMode)){
                    //恒丰部分
                    if ([imMode isEqualToString:@"APRV"]) {
                        height = [ChatSPTableViewController getHightOfCellViewWith:message.messageBody];
                    }else {
                        height = [ChatViewCoopCell getHightOfCellViewWith:message.messageBody];
                    }
                }else{
                    if (message.isVoipRecordsMessage) {
                        height = [ChatCallNoticeCell getHightOfCellViewWith:message.messageBody];
                        isNoNeedAddHeight = YES;
                    }else{
                        height = [ChatViewTextCell getHightOfCellViewWith:message.messageBody];
                    }
                }
            }
        }
            break;
        case MessageBodyType_Voice:
        case MessageBodyType_Video:
        case MessageBodyType_Image:
        case MessageBodyType_File: {
            // 根据文件的后缀名来获取多媒体消息的类型 麻烦 缺少displayName
            ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
            //加密新增
            if (KCNSSTRING_ISEMPTY(body.displayName)) {
                if (body.localPath.length > 0) {
                    body.displayName = body.localPath.lastPathComponent;
                } else if (body.remotePath.length>0) {
                    body.displayName = body.remotePath.lastPathComponent;
                } else {
                    body.displayName = languageStringWithKey(@"无名字");
                }
            }
            switch (message.messageBody.messageBodyType) {
                case MessageBodyType_Voice:
                    height = [ChatViewVoiceCell getHightOfCellViewWith:body];
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
                        height += 10;
                    }
                }
                    break;
                case MessageBodyType_Video:
                    height = [ChatViewVideoCell getHightOfCellViewWith:body];
                    break;
                default:
                    height = [ChatViewFileCell getHightOfCellViewWith:body];
                    break;
            }
        }
            break;
        case MessageBodyType_Call:
            //zmf add
            //            height = [ChatViewCallTextCell getHightOfCellViewWith:message.messageBody];
            height = [ChatCallNoticeCell getHightOfCellViewWith:message.messageBody];
            //zmf end
            break;
        case MessageBodyType_Location:
            height = [ChatViewLocationCell getHightOfCellViewWith:message.messageBody];
            break;
        case MessageBodyType_Preview:{
            ECPreviewMessageBody *body = (ECPreviewMessageBody *)message.messageBody;
            if (body.thumbnailLocalPath.length > 0) {
                body.thumbnailLocalPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:body.thumbnailLocalPath.lastPathComponent];
            }
            if (body.localPath.length > 0) {
                body.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:body.localPath.lastPathComponent];
            }
            height = [ChatViewPreviewCell getHightOfCellViewWith:message.messageBody];
        }
            break;
        case MessageBodyType_Command:{
            BOOL isRedTip = [[Chat sharedInstance].componentDelegate isRedpacketOpenMessageWithData:message.userData];
            if (isRedTip) {
                height = [ChatViewRedpacketTakenTipCell getHightOfCellViewWith:message.messageBody];
            }
        }
            break;
        default: {
            ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
            body.displayName = body.remotePath.lastPathComponent;
            height = [ChatViewFileCell getHightOfCellViewWith:body];
            break;
        }
    }
    
    CGFloat addHeight = 0.0f;
    BOOL isSender = (message.messageState == ECMessageState_Receive?NO:YES);
    if ([message.from isEqualToString:FileTransferAssistant]) {
        isSender = YES;
    }
    
    if (!isSender && message.isGroup) {
        if ((![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@%@",kGroupInfoGroupNickName, self.sessionId]] || [HXSpecialData haveSpecialWithAccount:message.from]) && !isNoNeedAddHeight){
            addHeight = 15.0f*FitThemeFont;
        } else {
            addHeight = 0.0f;
        }
    }
    // 韩微
    if (message.isBurnWithMessage &&
        (!isSender) && !message.isRead && message.messageBody.messageBodyType != MessageBodyType_Image) {
        height = [ChatBurnCoverCell getHightOfCellViewWith:message.messageBody];
    }
    // 显示的时间高度为30.0f
    return height + (isShow ?30.0f:0.0f) + addHeight;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    DDLogInfo(@"eagle.chatvc.msg.count = %lu",(unsigned long)self.messageArray.count);
    return self.messageArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = [self.messageArray objectAtIndex:indexPath.row];
    if ([cellContent isKindOfClass:[NSNull class]]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellrefresscellid"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellrefresscellid"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityView.tag = 100;
            [cell.contentView addSubview:activityView];
        }
        UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[cell.contentView viewWithTag:100];
        activityView.center = CGPointMake(kScreenWidth/2, cell.contentView.center.y);
        [activityView startAnimating];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ///加载更多消息
            [self loadMoreMessage];
        });
        return cell;
    }
    ECMessage *message = (ECMessage *)cellContent;
    BOOL isSender = (message.messageState == ECMessageState_Receive ? NO:YES);
    if ([message.from isEqualToString:FileTransferAssistant]) {
        isSender = YES;
    }
    if ([message.from isEqualToString:IMSystemLoginMsgFrom]) {
        isSender = NO;
    }
    NSInteger fileType = message.messageBody.messageBodyType;
    
    NSString *cellidentifier = nil;
    NSDictionary *im_modeDic = [MessageTypeManager getCusDicWithUserData:message.userData];
    if (message.isBurnWithMessage &&
        (!isSender) &&
        !message.isRead &&
        message.messageBody.messageBodyType == MessageBodyType_Text) {
        cellidentifier = @"isreceiver_MessageBodyType_Burn_";
    }else if (message.isVoipRecordsMessage) {//音视频通话
        cellidentifier = [NSString stringWithFormat:@"%@_%@_%@", isSender?@"issender":@"isreceiver",NSStringFromClass([message.messageBody class]),message.userData];
    }else if(message.isMergeMessage && message.messageBody.messageBodyType == MessageBodyType_File){
        fileType = MessageBodyType_MessageMerge;
    }else{
        NSString *messageBodyTypeStr;
        if ([im_modeDic hasValueForKey:@"SmileyEmoji"]) {
            messageBodyTypeStr = @"MessageBodyType_BigEmoji";
        }else if ([im_modeDic hasValueForKey:@"GroupVoting_Url"]) {
            messageBodyTypeStr = @"MessageBodyType_GroupVoting";
        }else{
            messageBodyTypeStr = NSStringFromClass([message.messageBody class]);
        }
        if ([im_modeDic hasValueForKey:@"isRead"]) {
            cellidentifier = [NSString stringWithFormat:@"%@_%@_%d%@", isSender?@"issender":@"isreceiver",messageBodyTypeStr,(int)fileType,[im_modeDic objectForKey:@"isRead"]];
        }else if([im_modeDic hasValueForKey:@"IM_Mode"]){
            cellidentifier = [NSString stringWithFormat:@"%@_%@_%d%@", isSender?@"issender":@"isreceiver",messageBodyTypeStr,(int)fileType,[im_modeDic objectForKey:@"IM_Mode"]];
            
        }else if ([[im_modeDic objectForKey:kRonxinMessageType] isEqualToString:@"GROUP_NOTICE"]){
            cellidentifier = [NSString stringWithFormat:@"%@_%@_%d%@", isSender?@"issender":@"isreceiver",messageBodyTypeStr,(int)fileType,@"GROUP_NOTICE"];
        }else if (message.isRichTextMessage) {
            cellidentifier = [NSString stringWithFormat:@"%@_%@_%d%@", isSender?@"issender":@"isreceiver",messageBodyTypeStr,(int)fileType,@"Rich_text"];
        }else{
            cellidentifier = [NSString stringWithFormat:@"%@_%@_%d", isSender?@"issender":@"isreceiver",messageBodyTypeStr,(int)fileType];
        }
        //红包
        BOOL isRedpacket = [[Chat sharedInstance].componentDelegate isRedpacketWithData:message.userData];
        BOOL isTranser = [[Chat sharedInstance].componentDelegate isTransferWithData:message.userData];
        BOOL isRedTip = [[Chat sharedInstance].componentDelegate isRedpacketOpenMessageWithData:message.userData];
        if (isRedpacket == YES) {
            if (isRedTip == YES) {
                cellidentifier = [NSString stringWithFormat:@"%@_%ld_s",cellidentifier,(long)isRedTip];
            } else {
                cellidentifier = [NSString stringWithFormat:@"%@_%ld_n",cellidentifier,(long)isRedTip];
            }
        }
        if (isTranser == YES) {
            cellidentifier = [NSString stringWithFormat:@"%@_%ld_t",cellidentifier,(long)isTranser];
        }
        if (message.isCardWithMessage) {//名片
            NSDictionary *dict = [im_modeDic hasValueForKey:SMSGTYPE] ? im_modeDic:im_modeDic[ShareCardMode];
            cellidentifier = [NSString stringWithFormat:@"%@_%@",cellidentifier,dict];
        }
        if (fileType == 1) {
            ECTextMessageBody *body = (ECTextMessageBody *)message.messageBody;
            if ((body.text.isWebUrl || message.isWebUrlMessage) && !message.isAnalysisedMessage && !message.isBurnWithMessage) {
                cellidentifier = @"webUrlMessageIdentifiler";
            }
            else if (message.isWebUrlMessageSendSuccess) {
                cellidentifier = @"webUrlMessageSendSuccessIdentifiler";
            }
        }
        
        //好友关系
        if (message.isAddFriendMessage) {
            cellidentifier = [NSString stringWithFormat:@"%@_%@_%@",cellidentifier, [im_modeDic objectForKey:receiverFriendInvite], receiverFriendInvite];
        }else if([message.userData containsString:kMergeMessage_CustomType]){
            //合并消息转发的标识
            cellidentifier = [NSString stringWithFormat:@"%@_%@_%d_%@", isSender?@"issender":@"isreceiver",NSStringFromClass([message.messageBody class]),(int)fileType,kMergeMessage_CustomType];
        }
        
    }
    
    ChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    if (cell == nil) {
        if ([cellidentifier isEqualToString: @"isreceiver_MessageBodyType_Burn_"]) {
            //阅后即焚未读
            cell = [[ChatBurnCoverCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BurnCoverCellBubbleViewPress:)];
            cell.bubbleView.userInteractionEnabled = YES;
            [cell.bubbleView addGestureRecognizer:tap];
        }else{
            switch (fileType) {
                case MessageBodyType_None:{
                    if ([[message.messageBody class] isSubclassOfClass:[RXRevokeMessageBody class]]) {
                        cell = [[HXChatNotifitionCell alloc] initWithNotifitionIsSender:isSender reuseIdentifier:cellidentifier];
                    }else{
                        cell = nil;
                    }
                }
                    break;
                case MessageBodyType_Text:{
                    NSDictionary *im_modeDic =  [MessageTypeManager getCusDicWithUserData:message.userData];
                    ECTextMessageBody *body = (ECTextMessageBody *)message.messageBody;
                    if ([im_modeDic hasValueForKey:@"SmileyEmoji"]) {//大表情
                        cell = [[ChatViewBigEmojiCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    }else if ([im_modeDic hasValueForKey:@"GroupVoting_Url"]) {//群投票
                        cell = [[ChatGroupVotingCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    } else if (message.isCardWithMessage) {
                        cell = [[ChatViewCardCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    }else if (message.isAddFriendMessage){
                        cell = [[HXChatNotifitionCell alloc] initWithNotifitionIsSender:isSender reuseIdentifier:cellidentifier];
                    }else if ([[im_modeDic objectForKey:kRonxinMessageType ] isEqualToString:@"GROUP_NOTICE"]){
                        cell = [[HXChatNotifitionCell alloc] initWithNotifitionIsSender:isSender reuseIdentifier:cellidentifier];
                    }
                    else if ((message.isWebUrlMessage || body.text.isWebUrl) && !message.isAnalysisedMessage && !message.isBurnWithMessage) {
                        cell = [[ChatRecognitionCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    }
                    else if (message.isWebUrlMessageSendSuccess) {
                        cell = [[ChatWebUrlCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    }
                    else{
                        BOOL isRedpacket = [[Chat sharedInstance].componentDelegate isRedpacketWithData:message.userData];
                        BOOL isTranser = [[Chat sharedInstance].componentDelegate isTransferWithData:message.userData];
                        BOOL isRedTip = [[Chat sharedInstance].componentDelegate isRedpacketOpenMessageWithData:message.userData];
                        if (message.isVoipRecordsMessage) {
                            cell = [[ChatCallNoticeCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                        }
                        else if([im_modeDic  hasValueForKey:@"IM_Mode"])
                        {
                            if ([[im_modeDic objectForKey:@"IM_Mode"] isEqualToString:@"APRV"]) {
                                cell = [[ChatSPTableViewController alloc] initWithIsSender:NO reuseIdentifier:cellidentifier];
                            }else {
                                cell = [[ChatViewCoopCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                            }
                        }
                        else {
                            cell = [[ChatViewTextCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                        }
                        if (isRedpacket == YES) {
                            if (isRedTip == YES) {
                                cell = [[ChatViewRedpacketTakenTipCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                            } else {
                                cell = [[ChatViewRedpacketCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                                [(ChatViewRedpacketCell*)cell setDelegate:self];
                            }
                        }
                        if (isTranser == YES) {
                            cell = [[ChatViewRedpacketCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                            [(ChatViewRedpacketCell*)cell setDelegate:self];
                        }
                    }
                }
                    break;
                case MessageBodyType_Voice:
                    cell = [[ChatViewVoiceCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    break;
                case MessageBodyType_Video:
                    cell = [[ChatViewVideoCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    break;
                case MessageBodyType_Image:{
                    if (message.isRichTextMessage) {
                        cell = [[ChatTextImageCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    } else {
                        cell = [[ChatViewImageCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                        ChatViewImageCell *imageCell = (ChatViewImageCell *)cell;
                        imageCell.delegate = self;
                    }
                }
                    break;
                case MessageBodyType_Call:
                    //zmf add
                    //                    cell = [[ChatViewCallTextCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    cell = [[ChatCallNoticeCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    //zmf end
                    break;
                case MessageBodyType_Location:
                    cell = [[ChatViewLocationCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    break;
                case MessageBodyType_Preview: {
                    cell = [[ChatViewPreviewCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    cell.displayMessage = message;
                }   break;
                case MessageBodyType_MessageMerge:
                    cell = [[ChatViewMergeMessageCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    break;
                case MessageBodyType_Command:{
                    BOOL isRedTip = [[Chat sharedInstance].componentDelegate isRedpacketOpenMessageWithData:message.userData];
                    if (isRedTip) {
                        cell = [[ChatViewRedpacketTakenTipCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    }
                }
                    break;
                default:
                    cell = [[ChatViewFileCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    break;
            }
        }
        if (cell) {
            //            NSDictionary *im_modeDic = [MessageTypeManager getCusDicWithUserData:message.userData];
            if (![[message.messageBody class] isSubclassOfClass:[RXRevokeMessageBody class]] || !message.isAddFriendMessage) {
                NSDictionary *im_modeDic =  [MessageTypeManager getCusDicWithUserData:message.userData];
                if (im_modeDic.count) {
                    //进白板
                    if (message.isBoardMessage) {
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(celljoinBoardPress:)];
                        [cell.bubbleView addGestureRecognizer:tap];
                    }
                }
                
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellHandleLongPress:)];
                [cell.bubbleView addGestureRecognizer:longPress];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellportraitImgPress:)];
                cell.portraitImg.userInteractionEnabled = YES;
                [cell.portraitImg addGestureRecognizer:tap];
                
                UILongPressGestureRecognizer *headLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellheadLongPress:)];
                [cell.portraitImg addGestureRecognizer:headLongPress];
            }
        }
    }
    cell.delegate = self;
    if (cell) {
        cell.burnIcon.hidden = YES;
        cell.timeLab.hidden = YES;
        //阅后即焚倒计时
        if (message.isBurnWithMessage) {
            if (isSender) {
                cell.bubleimg.image = [ThemeImage(@"burn_chating_right_02") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
            }else if ([cell isKindOfClass:[ChatBurnCoverCell class]]) {
                cell.burnIcon.hidden = NO;
            }else{
                NSString * timeStr = [[NSUserDefaults standardUserDefaults] valueForKey:message.messageId];
                if (!timeStr) {
                    cell.timeLab.text = [NSString stringWithFormat:@"%@",self.time];
                }else{
                    cell.timeLab.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:message.messageId]];
                }
                if ([cell.timeLab.text isEqualToString:[NSString stringWithFormat:@"%@",self.time]]) {
                    cell.timeLab.hidden = YES;
                    cell.burnIcon.hidden = NO;
                }else{
                    cell.timeLab.hidden = NO;
                    cell.burnIcon.hidden = YES;
                }
            }
        }
        [cell bubbleViewWithData:[self.messageArray objectAtIndex:indexPath.row]];
        return cell;
    }else{
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Null"];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = [self.messageArray objectAtIndex:indexPath.row];
    if ([cellContent isKindOfClass:[ECMessage class]]) {
        ECMessage *message = (ECMessage *)cellContent;
        if (message.isBurnWithMessage || message.isMergeMessage) {
            return;
        }
        if (!message.isRead && message.messageState == ECMessageState_Receive) {
            if (message.messageBody.messageBodyType == MessageBodyType_Voice ||
                message.messageBody.messageBodyType == MessageBodyType_Video) {
                return;
            }
            //回执发送已读
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                DDLogInfo(@"已阅了消息%@---%d",message.messageId,message.isRead);
                [[AppModel sharedInstance] readedMessage:message completion:^(ECError *error, ECMessage *amessage) {
                    if (error.errorCode == ECErrorType_NoError) {
                        [[KitMsgData sharedInstance] updateMessageReadStateByMessageId:amessage.messageId isRead:amessage.isRead];
                    }
                }];
            });
        }
    }
}

#pragma mark - GestureRecognizer
//长按头像
- (void)cellheadLongPress:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan && isGroup){
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return;
        
        ECMessage * message = [self.messageArray objectAtIndex:indexPath.row];
        //企业通讯录
        NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:message.from withType:0];
        
        if ([message.from isEqualToString:[[Chat sharedInstance] getAccount]]) {
            return;
        }
        //离职人员无法@ add yuxp
        if([companyInfo[Table_User_status ]isEqualToString:@"3"]) {
            return;
        }
        //如果不是群组成员@则无效
        KitGroupMemberInfoData *info = [KitGroupMemberInfoData getGroupMemberInfoWithMemberId:message.from withGroupId:self.sessionId];
        if (!info) {
            return;
        }
        NSMutableString *string = [NSMutableString stringWithFormat:@"@%@%@",companyInfo[Table_User_member_name],_deleteAtStr];
        
        //做@某人用的
        if ([_containerView getTextViewText] && [[_containerView getTextViewText] isEqualToString:@""]) {
            [_containerView setCurInputTextView:string];
            
        }else{
            [string insertString:[_containerView getTextViewText] atIndex:0];
            [_containerView setCurInputTextView:string];
        }
        [_containerView textViewBecomeFirstResponder];
        [_containerView toolbarDisplayChangedWithStautas:ToolbarStatus_Input];
        NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:message.from,@"memberId",message.senderName,@"memberName" ,nil];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"GroupMemberNickNameList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSMutableArray *personArr = [[ChatMessageManager sharedInstance].AtPersonArray mutableCopy];
        [personArr addObject:dict];
        
        NSSet *personSet = [NSSet setWithArray:personArr];
        
        [ChatMessageManager sharedInstance].AtPersonArray = [personSet.allObjects mutableCopy];
        
    }
}
//单击头像
- (void)cellportraitImgPress:(UITapGestureRecognizer *)tap{
    
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [tap locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return;
        refeshAvatar = YES;
        ECMessage * message = [self.messageArray objectAtIndex:indexPath.row];
        
        UIViewController *contactorInfosVC;
        if ([message.from isEqualToString:FileTransferAssistant]) {
            // 白板协同的PC 发来的消息
            contactorInfosVC = [[Chat sharedInstance].componentDelegate getContactorInfosVCWithData:message.to];
        }else{
            contactorInfosVC = [[Chat sharedInstance].componentDelegate getContactorInfosVCWithData:message.from];
        }
        
        //恒信
        //        UIViewController *contactorInfosVC = [[Chat sharedInstance].componentDelegate getContactorInfosVCWithData:message.from];
        [self pushViewController:contactorInfosVC];
    }
}
//阅后即焚未读点击
- (void)BurnCoverCellBubbleViewPress:(UITapGestureRecognizer *)tap{
    if (tap.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint point = [tap locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if(indexPath == nil) return;
    ECMessage *message = [self.messageArray objectAtIndex:indexPath.row];
    ///消息已读
    [[AppModel sharedInstance] readedMessage:message completion:nil];
    message.isRead = YES;
    [[KitMsgData sharedInstance] updateMessageReadStateByMessageId:message.messageId isRead:message.isRead];
    ///阅后即焚倒计时
    [self addReceviceDataWithBurnMessage:message];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell && [cell isKindOfClass:[ChatBurnCoverCell class]]) {
        ChatBurnCoverCell *newCell = (ChatBurnCoverCell *)cell;
        newCell.hidden = YES;
    }
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)cellHandleLongPress:(UILongPressGestureRecognizer *)longPress{
    
    if ([Common sharedInstance].isIMMsgMoreSelect) {
        return;
    }
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return;
        id tableviewcell = [self.tableView cellForRowAtIndexPath:indexPath];
        ChatViewCell *cell = (ChatViewCell *)tableviewcell;
        if (_containerView.textViewIsFirstResponder) {
            [cell resignFirstResponder];

        }else{
            [cell becomeFirstResponder];
        }
        _longPressIndexPath = indexPath;
        [self showMenuViewController:cell.bubbleView messageType:cell.displayMessage.messageBody.messageBodyType message:cell.displayMessage];
        
    }
}

//阅后即焚刷新倒计时
- (void)timerDeleteMessge{
    
    BOOL haveChaged = NO;
    for (int i = 0; i < self.receviceData.count;) {
        ECMessage *message = [self.receviceData objectAtIndex:i];
        
        NSString *timeStr = [[NSUserDefaults standardUserDefaults] valueForKey:message.messageId];
        if (KCNSSTRING_ISEMPTY(timeStr)) {
            [self.receviceData removeObject:message];
        }else{
            int times = [timeStr intValue];
            times = times - 1;
            if (times < 1) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:message.messageId];
                [self.receviceData removeObject:message];
                isTimer = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"burnModeDeleteMsg" object:message];
                NSInteger index = _messageArray.count - 1;
                for (NSInteger i = 0; i < _messageArray.count; i++) {
                    ECMessage *msg = _messageArray[i];
                    if ([msg.messageId isEqualToString:message.messageId]) {
                        index = i;
                        break;
                    }
                }
                
                [[KitMsgData sharedInstance] deleteMessage:message.messageId andSession:message.sessionId];
                
                if (_messageArray.count > 0) {
                    if ([[(ECMessage *)_messageArray.lastObject messageId]isEqualToString:message.messageId]){
                        haveChaged = YES;
                    }
                }
                if (_messageArray.count > index &&
                    index > -1) {
                    [self.tableView beginUpdates];
                    [self.messageArray removeObjectAtIndex:index];
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                }
            }else{
                NSString *timeStr = [NSString stringWithFormat:@"%d",times];
                [[NSUserDefaults standardUserDefaults] setValue:timeStr forKey:message.messageId];
                i ++;
            }
        }
    }
    if (haveChaged) {
        NSArray *messageArr = [[KitMsgData sharedInstance] getLatestHundredMessageOfSessionId:self.sessionId andSize:1 andASC:YES];
        if (messageArr.count > 0) {
            ECMessage *premessage = messageArr.lastObject;
            long long int newtime = [premessage.timestamp longLongValue];
            ECSession *session = [ECSession messageConvertToSession:premessage useNewTime:NO];
            session.dateTime = newtime;
            [[KitMsgData sharedInstance] updateSession:session];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BurnTimeLabelChanged" object:self.receviceData];
    if (self.receviceData.count == 0) {
        if ([self.delMsgTimer isValid]){
            [self.delMsgTimer invalidate];
            self.delMsgTimer = nil;
        }
    }
}

//进入白板
- (void)celljoinBoardPress:(UITapGestureRecognizer *)tap{
//    NSNumber *number = [[AppModel sharedInstance] runModuleFunc:@"VidyoHelper" :@"IsVidyoingWhenOtherOperate" :nil];
//    if (number.integerValue == 1) {
//        return;
//    }
    
    [SVProgressHUD showWithStatus:languageStringWithKey(@"正在加入白板协同")];
    CGPoint point = [tap locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    ECMessage *tempMsg = _messageArray[indexPath.row];
    if ([[Common sharedInstance] checkPointToPiontChatWithAccount:tempMsg.from] || [[Common sharedInstance] checkPointToPiontChatWithAccount:tempMsg.to]) {
        [SVProgressHUD dismiss];
        return;
    }
    
    NSDictionary *im_modeDic = [MessageTypeManager getCusDicWithUserData:tempMsg.userData];
    _borardDic = [[NSMutableDictionary alloc] init];
    _borardDic = [NSMutableDictionary dictionaryWithDictionary:im_modeDic];
    BOOL isNewJsonType = [im_modeDic hasValueForKey:SMSGTYPE];
    NSString *roomId = isNewJsonType ? im_modeDic[@"roomId"]:im_modeDic[ROOMID];
    NSString *pwd = isNewJsonType ? im_modeDic[@"pwd"]:im_modeDic[PASSWORD];
    NSDictionary *params = @{USERID:[[Chat sharedInstance] getAccount],PASSWORD:pwd,ROOMID:roomId,BOARDTYPE:@"1",SENDIM:@"0",BOARDURL:[Common sharedInstance].getBoardUrl};
    [[AppModel sharedInstance] runModuleFunc:@"Board":@"joinRoomWithParams:andPresentVC:":@[params,self] hasReturn:YES];
    
    [_containerView chatVCEndKeyBoard];
}

#pragma mark - 长按菜单
- (void)showMenuViewController:(UIView *)showInView messageType:(MessageBodyType)messageType message:(ECMessage *)msg{
    if (_menuController == nil) {
        _menuController = [RXMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[RXMenuItem alloc] initWithTitle:languageStringWithKey(@"复制") target:self action:@selector(copyMenuAction:)];
    }
    
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[RXMenuItem alloc] initWithTitle:languageStringWithKey(@"删除") target:self action:@selector(deleteMenuAction:)];
    }
    if (_transitMenuItem == nil) {
        _transitMenuItem = [[RXMenuItem alloc] initWithTitle:languageStringWithKey(@"转发") target:self action:@selector(transmitMenuAction:)];
    }
    if (_collectionMenuItem == nil && [[AppModel sharedInstance].appModelDelegate respondsToSelector:@selector(getCollectionViewControllerWithData:)]) {
        _collectionMenuItem = [[RXMenuItem alloc] initWithTitle:languageStringWithKey(@"收藏") target:self action:@selector(collectionMenuAction:)];
    }
    //    if (_shareMenuItem == nil) {
    //        _shareMenuItem = [[UIMenuItem alloc]initWithTitle:@"分享" action:@selector(shareMenuAction:)];
    //    }
    if (_revokeMenuItem == nil && ![self.sessionId isEqualToString:FileTransferAssistant]) {
        _revokeMenuItem = [[RXMenuItem alloc] initWithTitle:languageStringWithKey(@"撤回") target:self action:@selector(revokeMessage:)];
    }
    
    if (_moreMenuItem == nil && [[AppModel sharedInstance].appModelDelegate respondsToSelector:@selector(getCollectionViewControllerWithData:)]) {
        _moreMenuItem = [[RXMenuItem alloc] initWithTitle:languageStringWithKey(@"更多…") target:self action:@selector(moreMenuAction:)];
    }
    if (isHaveChangeVoiceToText) {
        if (_changeToTextItem == nil ) {
            _changeToTextItem = [[RXMenuItem alloc] initWithTitle:languageStringWithKey(@"转文字") target:self action:@selector(changeVoiceToText:)];
        }
    }
    
   // objc_setAssociatedObject(_menuController, &KMenuViewKey, msg, OBJC_ASSOCIATION_RETAIN);
    
    id tableviewcell = [self.tableView cellForRowAtIndexPath:_longPressIndexPath];
    
    NSDictionary *im_modeDic = [MessageTypeManager getCusDicWithUserData:msg.userData];
    BOOL isRedPacketMessage =[im_modeDic hasValueForKey:@"is_money_msg"];
    BOOL isTransFormerMessage = [im_modeDic hasValueForKey:@"money_is_transfer_message"];
    BOOL isOnlyDelete = NO;
    
    if (msg.isBurnWithMessage ||[self isGroupVotingWith:msg] || msg.isVoipRecordsMessage) {
        
        isOnlyDelete =YES;
        [_menuController setMenuItems:@[ _deleteMenuItem]];
    }else{
        BOOL isCallRecode = NO;//是否是音视频通话记录
        BOOL isWhiteBoard = NO;//白板
        if (messageType == MessageBodyType_Text &&
            ![tableviewcell isKindOfClass:[ChatViewBigEmojiCell class]]) {
            NSDictionary *cardData = [im_modeDic hasValueForKey:SMSGTYPE] ? im_modeDic:im_modeDic[ShareCardMode];
            NSInteger type = [[cardData objectForKey:@"type"] integerValue];//名片类型
            if (type == 1 || type == 2) { //个人名片、公众号名片
                [_menuController setMenuItems:@[_transitMenuItem,_deleteMenuItem]];
            }else if([msg.userData containsString:@"WBSS_SHOWMSG"]){ //白板协同邀请消息
                isWhiteBoard = YES;
                [_menuController setMenuItems:@[_deleteMenuItem]];
            }else if ([msg.userData containsString:@"IM_Mode"]) { //请假审批消息
                [_menuController setMenuItems:@[_revokeMenuItem,_deleteMenuItem]];
            }else{
                if(isRedPacketMessage || isTransFormerMessage){
                    [_menuController setMenuItems:@[_deleteMenuItem]];
                }else{
                    [_menuController setMenuItems:_collectionMenuItem ?@[_copyMenuItem,_collectionMenuItem,_transitMenuItem,_deleteMenuItem] :@[_copyMenuItem,_transitMenuItem,_deleteMenuItem]];
                }
            }
        }else if (messageType == MessageBodyType_Voice) {
            if (isHaveChangeVoiceToText) {
                [_menuController setMenuItems:_collectionMenuItem ?@[_collectionMenuItem,_deleteMenuItem,_changeToTextItem] :@[_deleteMenuItem]];
            }else{
                [_menuController setMenuItems:_collectionMenuItem ?@[_collectionMenuItem,_deleteMenuItem] :@[_deleteMenuItem]];
            }
        }else if (messageType == MessageBodyType_Image) {
            if (!IsHengFengTarget &&
                msg.isRichTextMessage) {//容信图文消息支持收藏功能
                [_menuController setMenuItems:_collectionMenuItem ?@[_transitMenuItem, _collectionMenuItem,_deleteMenuItem] :@[_transitMenuItem,_deleteMenuItem]];
            } else {
                [_menuController setMenuItems:_collectionMenuItem ?@[_transitMenuItem, _collectionMenuItem,_deleteMenuItem] :@[_transitMenuItem,_deleteMenuItem]];
            }
        }else if (messageType == MessageBodyType_Preview) {
            if(!KCNSSTRING_ISEMPTY(msg.userData) && [msg.userData rangeOfString:fromWorkFileShare].location != NSNotFound){
                [_menuController setMenuItems:@[ _transitMenuItem,_deleteMenuItem/*,_shareMenuItem*/]];
                isOnlyDelete = YES;
            }else{
                if(!KCNSSTRING_ISEMPTY(msg.userData) && [msg.userData rangeOfString:kFileTransferMsgNotice_CustomType].location!= NSNotFound){
                    NSString * keyStr = [NSString stringWithFormat:@"%@,",kFileTransferMsgNotice_CustomType];
                    NSString * userDataCove = [[msg.userData substringFromIndex:keyStr.length] base64DecodingString];
                    if([userDataCove rangeOfString:fromWorkFileShare].location != NSNotFound){
                        [_menuController setMenuItems:@[ _transitMenuItem,_deleteMenuItem/*,_shareMenuItem*/]];
                        isOnlyDelete = YES;
                    }else{
                        [_menuController setMenuItems:_collectionMenuItem ?@[ _transitMenuItem, _collectionMenuItem,_deleteMenuItem/*,_shareMenuItem*/] :@[ _transitMenuItem,_deleteMenuItem/*,_shareMenuItem*/]];
                    }
                }else{
                    [_menuController setMenuItems:_collectionMenuItem ?@[ _transitMenuItem, _collectionMenuItem,_deleteMenuItem/*,_shareMenuItem*/] :@[ _transitMenuItem,_deleteMenuItem/*,_shareMenuItem*/]];
                }
            }
        }else if (messageType == MessageBodyType_Video) {
            ECVideoMessageBody *body = (ECVideoMessageBody *)msg.messageBody;
//            if (![body.remotePath hasPrefix:@"http"]) {
//                [_menuController setMenuItems:@[_transitMenuItem,_deleteMenuItem]];
//            }else {
//            }
            [_menuController setMenuItems:_collectionMenuItem ?@[ _transitMenuItem, _collectionMenuItem,_deleteMenuItem] :@[ _transitMenuItem,_deleteMenuItem]];
        }else {
            if (messageType == MessageBodyType_Location) {
                [_menuController setMenuItems:_collectionMenuItem ? @[_transitMenuItem,_collectionMenuItem,_deleteMenuItem] : @[_transitMenuItem, _deleteMenuItem]];
            } else {
                if (messageType == MessageBodyType_File && msg.isMergeMessage) {//合并消息（聊天记录）
                    [_menuController setMenuItems:@[_transitMenuItem, _collectionMenuItem,_deleteMenuItem]];
                }else{
                    [_menuController setMenuItems:_collectionMenuItem ?@[ _transitMenuItem, _collectionMenuItem,_deleteMenuItem] :@[ _transitMenuItem,_deleteMenuItem]];
                }
            }
        }
        NSTimeInterval tmp = [[NSDate date] timeIntervalSince1970]*1000;
        NSInteger count = tmp - msg.timestamp.longLongValue;
        if (msg.messageState == ECMessageState_SendSuccess && count <= 120000 && ![msg.from isEqualToString:msg.to] && !isCallRecode) {
            NSMutableArray *arr = [_menuController.menuItems mutableCopy];
            if(isRedPacketMessage||isTransFormerMessage||isWhiteBoard){//红包或者转账消息不能撤回
                //不加入撤销
            }else{
                if (_revokeMenuItem != nil) {
                    [arr addObject:_revokeMenuItem];
                }
            }
            _menuController.menuItems = arr;
        }
    }
    
    //添加更多
    if(K_MergeMessageForward && !isOnlyDelete && [[AppModel sharedInstance].appModelDelegate respondsToSelector:@selector(getCollectionViewControllerWithData:)]){
        NSMutableArray * moreArr = [_menuController.menuItems mutableCopy];
        [moreArr addObject:_moreMenuItem];
//        if (messageType == MessageBodyType_Video) {
//            ECVideoMessageBody *body = (ECVideoMessageBody *)msg.messageBody;
//            if (![body.remotePath hasPrefix:@"http"]) {//没有远程路径
//                [moreArr removeObject:_moreMenuItem];
//            }
//        }
        _menuController.menuItems = moreArr;
    }
    
    
    //插件部分只支持 复制、撤回、删除
    NSArray *getMenuItems = [[Chat sharedInstance].componentDelegate getMenuItems];
    if (getMenuItems.count>0) {
        NSMutableArray *items = _menuController.menuItems.mutableCopy;
        for (UIMenuItem *item in _menuController.menuItems) {
            if (![[getMenuItems componentsJoinedByString:@","] containsString:item.title]) {
                [items removeObject:item];
            }
        }
        _menuController.menuItems = items;
    }
    
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}
/**
 语音转文字
 */
-(void)changeVoiceToText:(RXMenuController *)menu{
    [self hideMenuController];
    NSLog(@"%s",__func__);
    ECMessage *message = [self.messageArray objectAtIndex:_longPressIndexPath.row];
    if ([message.messageBody isKindOfClass:[ECVoiceMessageBody class]]) {
        ECVoiceMessageBody *newVoiceMsgBody = (ECVoiceMessageBody *)message.messageBody;
        NSURL *url = [NSURL URLWithString:newVoiceMsgBody.localPath];
        BOOL awV = [[PFAudio shareInstance] amr2Wav:url.absoluteString isDeleteSourchFile:NO];
        
        NSURL *url2 = [NSURL URLWithString:[NSString stringWithFormat:@"%@.wav",[[NSURL URLWithString:newVoiceMsgBody.localPath] URLByDeletingPathExtension].absoluteString]];
        if (awV) {
            NSLog(@"语音文件转换成功 url1=  %@-----> url2 = %@",newVoiceMsgBody.localPath,url2.absoluteString);
            if ( [[NSFileManager defaultManager] fileExistsAtPath:url2.absoluteString]) {
                NSLog(@"语音文件存在 %@",url2.absoluteString);
                NSURL *playerURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", url2.absoluteString]];
                [self changeToTextWithUrl:playerURL];
            }else{
                NSLog(@"语音文件不存在 %@",url2.absoluteString);
            }
        }else{
            NSLog(@"语音文件转换失败");
            NSURL *url22 = [[NSBundle mainBundle] URLForResource:@"tmp20190226151453001.wav" withExtension:nil];
            [self changeToTextWithUrl:url22];
        }
    }
}
-(void)changeToTextWithUrl:(NSURL *)localPathNSURL{
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        NSLog(@"status %@", status == SFSpeechRecognizerAuthorizationStatusAuthorized ? @"授权成功" : @"授权失败");
    }];
    SFSpeechRecognizer *recognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    SFSpeechURLRecognitionRequest *request = [[SFSpeechURLRecognitionRequest alloc] initWithURL:localPathNSURL];
    request.shouldReportPartialResults = YES;
    [recognizer recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (result.isFinal) {
            NSLog(@" %s--识别结果1：%@ ",__func__,[NSString stringWithFormat:@"%@", result.bestTranscription.formattedString]);
        }
        NSLog(@" %s--识别结果2：%@ ",__func__,[NSString stringWithFormat:@"%@", result.bestTranscription.formattedString]);
    }];
}

//让cell变背景色
- (void)setupCellBackgroundColor {
    //        if ([tableviewcell isKindOfClass:[ChatViewCell class]]) {
    //            ChatViewCell *cell = (ChatViewCell *)tableviewcell;
    //            if(message.isMergeMessage || message.isWebUrlMessageSendFail || message.isWebUrlMessageSendSuccess){
    //                //合并消息 不变色
    //            }else {
    //                if([cell isKindOfClass:[ChatViewCardCell class]]){
    //                    if(cell.isSender){
    //                        cell.bubleimg.image = [ThemeImage(@"chat_sender_preView") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    //                    }else {
    //                        cell.bubleimg.image  = [ThemeImage(@"chating_left_01_on") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    //                    }
    //                }else if (!message.isBurnWithMessage && ![cell isKindOfClass:[ChatViewBigEmojiCell class]]) {
    //
    //                    //                    NSDictionary *im_modeDic =  [MessageTypeManager getCusDicWithUserData:message.userData];
    //
    //                    if(cell.isSender){
    //                        if ([cell isKindOfClass:[ChatViewPreviewCell class]]) {
    //                            cell.bubleimg.image = [ThemeImage(@"chat_sender_preView") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    //                        }else if ([cell isKindOfClass:[ChatViewFileCell class]])
    //                        {
    //                            cell.bubleimg.image = [ThemeImage(@"chating_File_right_02_on") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    //
    //                        }else{
    //                            if (message.isRichTextMessage) {
    //                                cell.bubleimg.image = [ThemeImage(@"chating_richText_right") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    //                            }else if ([cell isKindOfClass:[ChatViewLocationCell class]])
    //                            {
    //                                cell.bubleimg.image = [ThemeImage(@"chatLocationTop_right") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    //
    //                            }else{
    //                                cell.bubleimg.image = [ThemeImage(@"chating_right_02") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    //                            }
    //                        }
    //                    }else{
    //                        if (message.isRichTextMessage) {
    //                            cell.bubleimg.image  = [ThemeImage(@"chating_left_01") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    //                        }else{
    //                            cell.bubleimg.image  = [ThemeImage(@"chating_left_01_on") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    //                        }
    //                    }
    //                }
    //            }
    //            if (_containerView.textViewIsFirstResponder) {
    //                [cell resignFirstResponder];
    //
    //            }else{
    //                [cell becomeFirstResponder];
    //            }
    //            //和恒丰保持一致
    //            _containerView.toolbarStatus = ToolbarStatus_None;
    //            //[cell becomeFirstResponder];
    //            //初始化-1  目的cell有第0个的indexPath.row 取消原先的选中状态
    //            int _longpressIndexCount =-1;
    //            _longpressIndexCount =(int)_longPressIndexPath.row;
    //
    //            if(_longPressIndexPath && _longpressIndexCount>-1) {
    //
    //                id tableviewOldcell = [self.tableView cellForRowAtIndexPath:_longPressIndexPath];
    //                if ([tableviewOldcell isKindOfClass:[ChatViewCell class]]) {
    //                    ChatViewCell *oldCell = (ChatViewCell *)tableviewOldcell;
    //                    if(message.isMergeMessage){
    //                        //合并消息 不变色
    //                    }else {
    //                        if (![oldCell isKindOfClass:[ChatViewBigEmojiCell class]]) {
    //                            if(oldCell.isSender)
    //                            {
    //                                //oldCell.bubleimg.image = [ThemeImage(@"chating_right_02") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    //                            }else
    //                            {
    //                                oldCell.bubleimg.image  = [ThemeImage(@"chating_left_01") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //            _longPressIndexPath = indexPath;
    //
    //        }
}

//让cell还原背景色
- (void)resumeCellBackgroundColor {
    id tableviewcell = [self.tableView cellForRowAtIndexPath:_longPressIndexPath];
    ECMessage *message = [self.messageArray objectAtIndex:_longPressIndexPath.row];
    
//    if ([tableviewcell isKindOfClass:[ChatViewCell class]]){
//        ChatViewCell *cell = (ChatViewCell *)tableviewcell;
//        if(message.isMergeMessage || message.isWebUrlMessageSendFail || message.isWebUrlMessageSendSuccess){
//            //合并消息不变色
//        }else if([cell isKindOfClass:[ChatViewCardCell class]]){
//            if (cell.isSender) {
//                cell.bubleimg.image = [ThemeImage(@"chat_sender_preView") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
//            } else {
//                cell.bubleimg.image = [ThemeImage(@"chating_left_01") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
//            }
//        }else if (!message.isBurnWithMessage && ![cell isKindOfClass:[ChatViewBigEmojiCell class]]) {
//            //长按背景恢复
//            if(cell.isSender){
//                if ([cell isKindOfClass:[ChatViewPreviewCell class]]) {
//                    cell.bubleimg.image = [ThemeImage(@"chat_sender_preView") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
//                }else if ([cell isKindOfClass:[ChatViewFileCell class]]){
//                    cell.bubleimg.image = [ThemeImage(@"chating_File_right_02") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
//                }else if ([cell isKindOfClass:[ChatTextImageCell class]]) {
//                    cell.bubleimg.image = [ThemeImage(@"chating_richText_right") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
//                }else if ([cell isKindOfClass:[ChatViewLocationCell class]])
//                {
//                    cell.bubleimg.image = [ThemeImage(@"chatLocationTop_right") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
//
//                }else{
//                    cell.bubleimg.image = [ThemeImage(@"chating_right_02") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
//                }
//            }else{
//                cell.bubleimg.image = [ThemeImage(@"chating_left_01") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
//            }
//        }
//    }
    _longPressIndexPath = nil;
}

- (void)moreMenuAction:(RXMenuController *)menu{
    [self hideMenuController];
    
    [self resumeCellBackgroundColor];
    
    [_containerView textViewResignFirstResponder];
    [Common sharedInstance].moreSelectMsgData = [NSMutableArray arrayWithCapacity:0];
    [Common sharedInstance].isIMMsgMoreSelect = YES;
    
    [Chat sharedInstance].isChatViewScroll = YES;
    
    [self.tableView reloadData];
    
    [UIView animateWithDuration:0.5f animations:^{
        self->_containerView.hidden = YES;
        self.moreActionBar.hidden = NO;
        // hanwei
        //        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        //        [tapGR setNumberOfTouchesRequired:1];
        //        [self.moreActionBar addGestureRecognizer:tapGR];
    }];
}
- (void)tapAction:(UITapGestureRecognizer *)sender{
    //    [self ChatMoreActionBarClickWithType:ChatMoreActionBarType_forword_Multiple_Merge];
}
- (void)copyMenuAction:(id)sender {
    //复制
    [self hideMenuController];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_longPressIndexPath.row < self.messageArray.count) {
        ECMessage *message = [self.messageArray objectAtIndex:_longPressIndexPath.row];
        ECTextMessageBody *body = (ECTextMessageBody*)message.messageBody;
        
        if (![body isKindOfClass:[ECTextMessageBody class]]) {
            DDLogInfo(@"这里没有内容复制");
            return;
        }
        pasteboard.string = body.text;
    }
    _longPressIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender {
    [self hideMenuController];
    
    __weak typeof(self) weakSelf = self;
    RXCommonDialog * dialog = nil;
    if ([_containerView textViewIsFirstResponder]) {
        dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosTOPk withTapAtBackground:YES];
    }
    else {
        dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
    }
    [dialog showTitle:languageStringWithKey(@"确定删除") subTitle:nil ensureStr:languageStringWithKey(@"确定") cancalStr:languageStringWithKey(@"取消") selected:^(NSInteger index) {
        if (index == 1) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //删除
            if (strongSelf->_longPressIndexPath && strongSelf->_longPressIndexPath.row >= 0) {
                ECMessage *message = [strongSelf->_messageArray objectAtIndex:strongSelf->_longPressIndexPath.row];
                NSNumber* isplay = objc_getAssociatedObject(message, &KVoiceIsPlayKey);
                if (isplay.boolValue) {
                    objc_setAssociatedObject(strongSelf.voiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
                    strongSelf.voiceMessage = nil;
                }
                
                if (message == strongSelf.messageArray.lastObject) {
                    //删除最后消息才需要刷新session
                    if (message == strongSelf.messageArray.firstObject) { //如果删除的也是唯一一个消息，删除session
                        [[KitMsgData sharedInstance] deleteMessage:message andPre:nil];
                    } else { //使用前一个消息刷新session
                        [[KitMsgData sharedInstance] deleteMessage:message andPre:[strongSelf->_messageArray objectAtIndex:strongSelf->_longPressIndexPath.row-1]];
                    }
                } else {
                    [[KitMsgData sharedInstance] deleteMessage:message.messageId andSession:strongSelf.sessionId];
                }
                if (message.messageId.length > 0) {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:message.messageId];
                }
                [strongSelf.messageArray removeObject:message];
                [strongSelf.tableView reloadData];
            }
            strongSelf->_longPressIndexPath = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteMessage object:nil];
        }
    }];
}

- (void)hideMenuController {
    [[RXMenuController sharedMenuController] setMenuVisible:NO];
}

- (void)transmitMenuAction:(RXMenuController *)menu {
    //转发
    [self hideMenuController];
    ECMessage *message = [self.messageArray objectAtIndex:_longPressIndexPath.row];
    if (message.messageBody.messageBodyType == MessageBodyType_Video) {
        ECVideoMessageBody *videoBody = (ECVideoMessageBody *)message.messageBody;
        if (![NSFileManager.defaultManager fileExistsAtPath:videoBody.localPath]) {
            [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"小视频还未缓存，请观看后再转发")];
            return;
        }
    }
    
    
    //未查看的合并转发消息暂时不能转发
    if (message.isMergeMessage) {
        ECFileMessageBody *fileBody = (ECFileMessageBody *)message.messageBody;
        NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:fileBody.remotePath];
        if (!fileBody.localPath) {
            NSString *filePaht = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
            fileBody.localPath = filePaht;
        }
        if (fileBody.localPath.length ==0 || ![[NSFileManager defaultManager]fileExistsAtPath:fileBody.localPath isDirectory:nil] ||fileDic.count == 0) {
            [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"未查看的聊天记录不能转发")];
            return;
        }
    }
    
    NSDictionary *exceptData = @{@"msg":message};
    UIViewController *groupVC = [[Chat sharedInstance].componentDelegate getChooseMembersVCWithExceptData:exceptData WithType:SelectObjectType_TransmitSelectMember];
    [self pushViewController:groupVC];
    _longPressIndexPath = nil;
}

- (void)collectionMenuAction:(id)sender{
    [self hideMenuController];
    if (_longPressIndexPath && _longPressIndexPath.row >= 0) {
        ECMessage *message = [self.messageArray objectAtIndex:_longPressIndexPath.row];
        if ([message.messageBody isKindOfClass:[ECFileMessageBody class]]) {
            ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
            if (![body.remotePath hasPrefix:@"http"]) {
                _longPressIndexPath = nil;
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"收藏失败")];
                return;
            }
        }
        NSArray<RXCollectData *> *collects = [RXCollectManager getCollectionsWithMessageData:@[message]];
        [self addCollectionRequestWithCollections:collects];
    }
}
//收藏单条消息
- (void)addCollectionRequestWithCollections:(NSArray *)collections {
    
    [SVProgressHUD showWithStatus:languageStringWithKey(@"正在收藏")];
    
    [RestApi addMultiCollectDataWithAccount:[[Common sharedInstance] getAccount] sessionId:self.sessionId collectContents:collections didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        NSDictionary *headDic = [dict objectForKey:@"head"];
        NSInteger statusCode = [[headDic objectForKey:@"statusCode"] integerValue];
        if (statusCode == 000000) {
            [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"收藏成功")];
            NSDictionary *bodyDic = [dict objectForKey:@"body"];
            for (NSInteger i = 0; i < collections.count; i ++) {
                RXCollectData * data = collections[i];
                data.collectId = bodyDic[@"collectId"];
                if ([[bodyDic objectForKey:@"collectIds"] count] > 0) {
                    data.collectId = [[bodyDic objectForKey:@"collectIds"] firstObject];
                }
                data.time = [bodyDic objectForKey:@"createTime"];
                [RXCollectData insertCollectionInfoData:data];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:statusCode == 901551 ? languageStringWithKey(@"请不要重复收藏"): languageStringWithKey(@"收藏失败")];
        }
    } didFailLoaded:^(NSError *error, NSString *path) {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"收藏失败")];
    }];
    
    //    NSString *userAccount = [[Common sharedInstance] getAccount];
    //    NSString *teContent = nil;
    //    NSString *daType = nil;
    //    NSString *fromStr = nil;
    //    for (RXCollectData * data in collections) {
    //        if (data.type) {
    //            daType = data.type;
    //        }
    //        if (data.txtContent) {
    //            if ([data.type isEqualToString:@"6"]) {
    //                NSMutableDictionary *dict = [MessageTypeManager getCusDicWithUserData:data.txtContent];
    //                dict[@"content"] = [dict[@"content"] base64DecodingString];
    //                teContent = dict.jsonEncodedKeyValueString;
    //            }else{
    //                teContent = data.txtContent;
    //            }
    //        }
    //        if (data.sessionId) {
    //            fromStr = data.sessionId;
    //            //场景 多终端同时登陆, pc发文件, ios收藏
    //            if ([fromStr isEqualToString:FileTransferAssistant]) {
    //                fromStr = [Common sharedInstance].getOneAccount;
    //            }
    //        }
    //    }
    
    //    [RestApi addCollectDataWithAccount:userAccount fromAccount:fromStr TxtContent:teContent Url:nil DataType:daType didFinishLoaded:^(NSDictionary *dict, NSString *path) {
    //        NSDictionary *headDic = [dict objectForKey:@"head"];
    //        NSInteger statusCode = [[headDic objectForKey:@"statusCode"] integerValue];
    //        if (statusCode == 000000) {
    //            [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"收藏成功")];
    //            NSDictionary *bodyDic = [dict objectForKey:@"body"];
    //            for (NSInteger i = 0; i < collections.count; i ++) {
    //                RXCollectData * data = collections[i];
    //                data.collectId = bodyDic[@"collectId"];
    //                data.time = [bodyDic objectForKey:@"createTime"];
    //                [RXCollectData insertCollectionInfoData:data];
    //            }
    //        } else {
    //            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"收藏失败")];
    //        }
    //    } didFailLoaded:^(NSError *error, NSString *path) {
    //        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"收藏失败")];
    //    }];
}

- (void)shareMenuAction:(RXMenuController *)menu{
    [self hideMenuController];
    //分享到微信
    ECMessage *message = (ECMessage*)objc_getAssociatedObject(menu, &KMenuViewKey);
    
    id tableviewcell = [self.tableView cellForRowAtIndexPath:_longPressIndexPath];
    
    if (message.messageBody.messageBodyType == MessageBodyType_Image) {
        if ([tableviewcell isKindOfClass:[ChatViewImageCell class]]) {
            ChatViewImageCell *cell = (ChatViewImageCell *)tableviewcell;
            
            if ([Chat sharedInstance].componentDelegate && [[Chat sharedInstance].componentDelegate respondsToSelector:@selector(shareDataWithTarget:Text:Image:Url:)]) {
                [[Chat sharedInstance].componentDelegate shareDataWithTarget:self Text:nil Image:cell.displayImage.image Url:nil];
            }
            
        }
    }else if (message.messageBody.messageBodyType == MessageBodyType_Preview) {
        if ([tableviewcell isKindOfClass:[ChatViewPreviewCell class]]) {
            ECPreviewMessageBody *body = (ECPreviewMessageBody *)message.messageBody;
            ChatViewPreviewCell *cell = (ChatViewPreviewCell *)tableviewcell;
            
            UIImage *img = cell.imgView.image ? cell.imgView.image :ThemeImage(@"ios_rx_logo");
            if ([Chat sharedInstance].componentDelegate && [[Chat sharedInstance].componentDelegate respondsToSelector:@selector(shareDataWithTarget:Text:Image:Url:)]) {
                [[Chat sharedInstance].componentDelegate shareDataWithTarget:self Text:body.title Image:img Url:body.url];
            }
            
        }
    }
    _longPressIndexPath = nil;
}

- (void)revokeMessage:(RXMenuController*)menu {
    
    [self hideMenuController];
    //撤回
    [_menuController setMenuItems:nil];
    if (_longPressIndexPath && _longPressIndexPath.row >= 0) {
        ECMessage *message = [self.messageArray objectAtIndex:_longPressIndexPath.row];
        
        NSNumber* isplay = objc_getAssociatedObject(message, &KVoiceIsPlayKey);
        if (isplay.boolValue) {
            objc_setAssociatedObject(self.voiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
            self.voiceMessage = nil;
        }
        
        NSInteger row = _longPressIndexPath.row;
        __weak typeof(self)weakSelf = self;
        [[ECDevice sharedInstance].messageManager revokeMessage:message completion:^(ECError *error, ECMessage *message) {
            /**新增错误码
             580030	//消息msgId,version都为空
             580031	//消息不存在
             580032	//消息回执错误，回执数据不存在
             580033	//消息撤回错误，消息发送者信息不存在
             580034	//消息回执错误，未读用户不存在
             580035	//消息撤回错误，当前应用没有开放此功能
             580036	//消息回执错误，当前应用没有开放此功能
             */
            __strong typeof(weakSelf)strongSelf = weakSelf;
            DDLogInfo(@"撤回消息 error=%d", (int)error.errorCode);
            if (error.errorCode == ECErrorType_NoError) {
                RXRevokeMessageBody *revokeBody = [[RXRevokeMessageBody alloc] initWithText:languageStringWithKey(@"你撤回了一条消息")];
                ECMessage *amessage = [[ECMessage alloc] initWithReceiver:message.sessionId body:revokeBody];
                NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
                NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
                amessage.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
                amessage.isRead = YES;
                amessage.isGroup = message.isGroup;
                amessage.messageState = ECMessageState_SendSuccess;
                amessage.userData = nil;
                
                ECMessage *message1 = (self->_messageArray.count>row)?[self.messageArray objectAtIndex:row]:nil;
                if (message1 && [message.messageId isEqualToString:message1.messageId]) {
                    [strongSelf.tableView beginUpdates];
                    [strongSelf.messageArray replaceObjectAtIndex:row withObject:amessage];
                    [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    [strongSelf.tableView endUpdates];
                    [strongSelf scrollTableView];
                }else{
                    NSInteger newRow = -1;
                    for (NSInteger i=strongSelf.messageArray.count-1; i>=0; i--) {
                        id content = [strongSelf.messageArray objectAtIndex:i];
                        if ([content isKindOfClass:[NSNull class]]) {
                            continue;
                        }
                        ECMessage *message3 = (ECMessage *)content;
                        if ([message.messageId isEqualToString:message3.messageId]) {
                            newRow = i;
                            break;
                        }
                    }
                    if (newRow != -1) {
                        [strongSelf.tableView beginUpdates];
                        [strongSelf.messageArray replaceObjectAtIndex:newRow withObject:amessage];
                        [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                        [strongSelf.tableView endUpdates];
                        [strongSelf scrollTableView];
                    }
                }
                [[KitMsgData sharedInstance] updateSrcMessage:message.sessionId msgid:message.messageId withDstMessage:amessage];
            }
        }];
    }
    _longPressIndexPath = nil;
}

#pragma mark - ChatMoreActionBarDelegate 更多的一系列操作

/**
 ChatMoreActionBarDelegate的代理，包含逐条转发 和 合并转发 收藏

 @param type ChatMoreActionBarType_forword 逐条转发   ChatMoreActionBarType_forword_Multiple_Merge 合并转发  ChatMoreActionBarType_collection 收藏
 */
- (void)ChatMoreActionBarClickWithType:(ChatMoreActionBarType)type {
    // 转发
    if (type == ChatMoreActionBarType_forword || type == ChatMoreActionBarType_forword_Multiple_Merge) {
        [self forword];
    }else{
        [self ChatMoreActionBarClickWithType2:type];
    }
}

/**
 转发弹窗，包含逐条转发 和 合并转发
 */
-(void)forword{
    
    NSMutableArray *clickArray = [NSMutableArray new];
    [clickArray addObject:languageStringWithKey(@"逐条转发")];
    [clickArray addObject:languageStringWithKey(@"合并转发")];
    WS(weakSelf);
    _browseActionSheet = [[MSSBrowseActionSheet alloc]initWithTitleArray:clickArray cancelButtonTitle:languageStringWithKey(@"取消") didSelectedBlock:^(NSInteger index) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf browseActionSheetDidSelectedAtIndex:index];
    }];
    [_browseActionSheet showInView:self.view];
}

#pragma mark MSSActionSheetClick
- (void)browseActionSheetDidSelectedAtIndex:(NSInteger)index{
    
    if (index == MSSBrowseTypeEachForword) {//逐条转发
        [self ChatMoreActionBarClickWithType2:ChatMoreActionBarType_forword];
    }else if (index == MSSBrowseTypeMergeForword){//合并转发
        [self ChatMoreActionBarClickWithType2:ChatMoreActionBarType_forword_Multiple_Merge];
    }else if (index == ChatMoreActionBarType_collection){
        [self ChatMoreActionBarClickWithType2:ChatMoreActionBarType_forword_Multiple_Merge];
    }else if (index == MSSBrowseTypeMergeDelete){
        [self ChatMoreActionBarClickWithType2:ChatMoreActionBarType_delete];
    }
    
}

#pragma UIActionSheetDelegate 更多的几个按钮事件
- (void)ChatMoreActionBarClickWithType2:(ChatMoreActionBarType)type {
    __weak ChatViewController *blockSelf = self;
    
    switch (type) {
            
        case ChatMoreActionBarType_forword:
        {
            if ([Common sharedInstance].moreSelectMsgData.count > 9) {
                [self showCustomToast:languageStringWithKey(@"最多转发9条聊天消息")];
                return;
            }
            NSInteger indexType = [RXCollectManager checkMessageMoreActionBarClickWithType:type messageArr:[Common sharedInstance].moreSelectMsgData];
            if (indexType == ChatMoreActionFuncType_None) {
                [[HXMessageMergeManager sharedInstance] eachForwardChatMessage:[Common sharedInstance].moreSelectMsgData withVC:self];
            }else if (indexType == ChatMoreActionFuncType_NotSupport) {
                [UIAlertView showAlertView:languageStringWithKey(@"选择的消息中，阅后即焚/语音/通话记录/白板/红包类消息不能转发") message:nil click:^{
                    //                    [[HXMessageMergeManager sharedInstance]eachForwardChatMessage:[Common sharedInstance].moreSelectMsgData withVC:blockSelf];
                } cancelText:languageStringWithKey(@"取消") okText:languageStringWithKey(@"确定")];
            }else if (indexType == ChatMoreActionFuncType_NotDownload) {
                [UIAlertView showAlertView:languageStringWithKey(@"选择的消息中，未下载的视频/文件不能转发") message:nil click:^{
                    //                    [[HXMessageMergeManager sharedInstance]eachForwardChatMessage:[Common sharedInstance].moreSelectMsgData withVC:blockSelf];
                } cancelText:languageStringWithKey(@"取消") okText:languageStringWithKey(@"确定")];
            }
        }
            break;
            //多条合并
        case ChatMoreActionBarType_forword_Multiple_Merge:
        {
            if ([Common sharedInstance].moreSelectMsgData.count > MAX_Message_Count) {
                [self showCustomToast:languageStringWithKey(@"最多转发30条聊天消息")];
                return;
            }
            NSInteger indexType = [RXCollectManager checkMessageMoreActionBarClickWithType:type messageArr:[Common sharedInstance].moreSelectMsgData];
            if (indexType == ChatMoreActionFuncType_None) {
                [[HXMessageMergeManager sharedInstance] setMergeMessageTitleWithSessonId:self.sessionId];//提取合并转发的标题
                [[HXMessageMergeManager sharedInstance] forwardChatMultipleMessageMerge:[Common sharedInstance].moreSelectMsgData withVC:blockSelf];
            }else if (indexType == ChatMoreActionFuncType_NotSupport) {
                [UIAlertView showAlertView:languageStringWithKey(@"文本、图片、小视频、链接、文件、服务号、可以支持合并转发；其他消息内容均不允许转发") message:nil click:^{
                } cancelText:languageStringWithKey(@"取消") okText:languageStringWithKey(@"确定")];
            }else if (indexType == ChatMoreActionFuncType_NotDownload) {
                [UIAlertView showAlertView:languageStringWithKey(@"选择的消息中，未下载的视频/文件不能转发") message:nil click:^{
                } cancelText:languageStringWithKey(@"取消") okText:languageStringWithKey(@"确定")];
            }
        }
            break;
        case ChatMoreActionBarType_collection:
        {
            // fixbug by liyijun 2017/08/08
            // 1.if ([Common sharedInstance].moreSelectMsgData.count > 9) 判断添加return 语句
            // 2.添加定位收藏判断
            if ([Common sharedInstance].moreSelectMsgData.count > 9) {
                [self showCustomToast:languageStringWithKey(@"最多收藏9条聊天消息")];
                return;
            }
            //            NSArray<RXCollectData *> *collects = [RXCollectManager getCollectionsWithMessageData:[Common sharedInstance].moreSelectMsgData];
            
            if ([RXCollectManager checkMessageMoreActionBarClickWithType:type messageArr:[Common sharedInstance].moreSelectMsgData] == ChatMoreActionFuncType_None) {
                //                [RXCollectManager collectionRequestWithCollections:collects sessionId:self.sessionId];
                
                if ([Common sharedInstance].moreSelectMsgData.count==1) {//普通单条收藏
                    NSArray<RXCollectData *> *collects = [RXCollectManager getCollectionsWithMessageData:@[[Common sharedInstance].moreSelectMsgData.firstObject]];
                    [self addCollectionRequestWithCollections:collects];
                }else {//合并收藏
                    [[HXMessageMergeManager sharedInstance] setMergeMessageTitleWithSessonId:self.sessionId];//提取合并转发的标题
                    [[HXMessageMergeManager sharedInstance] forwardChatMultipleMessageMerge:[Common sharedInstance].moreSelectMsgData withVC:nil];
                    [HXMessageMergeManager.sharedInstance gy_sendMergeMessageAndSelectResultArray:self.sessionId andCompletion:^(ECMessage *message) {
                        if (message) {
                            NSArray<RXCollectData *> *collects = [RXCollectManager getCollectionsWithMessageData:@[message]];
                            [self addCollectionRequestWithCollections:collects];
                        }else {
                            [SVProgressHUD showWithStatus:languageStringWithKey(@"收藏失败")];
                        }
                    }];
                }
                [self cancleMoreSelectAction:nil];
            }else {
                // fixbug by liyijun 2017/08/08
                // 收藏提示语信息修改：添加合并、审批、位置
                NSString *alertString = languageStringWithKey(@"选择的消息中，阅后即焚/名片/通话记录/白板/红包类不能收藏");
                if (!IsHengFengTarget) { // 恒丰没有图文、位置、消息合并
                    alertString = languageStringWithKey(@"选择的消息中，语音/阅后即焚/合并/名片/位置/通话记录/白板/审批/红包类不能收藏");
                }
                [UIAlertView showAlertView:alertString message:nil click:^{
                } cancelText:languageStringWithKey(@"取消") okText:languageStringWithKey(@"确定")];
            }
        }
            break;
        case ChatMoreActionBarType_delete:
        {
            NSString * prompt = nil;
            if ([RXCollectManager checkMessageMoreActionBarClickWithType:type messageArr:[Common sharedInstance].moreSelectMsgData] == ChatMoreActionFuncType_None) {
                prompt = languageStringWithKey(@"删除选中的消息");
            }else {
                prompt = languageStringWithKey(@"选择的消息中，未查看的阅后即焚消息不能删除");
            }
            [UIAlertView showAlertView:prompt message:nil click:^{
                for (NSInteger i = 0; i < [Common sharedInstance].moreSelectMsgData.count; i ++) {
                    ECMessage * message = [Common sharedInstance].moreSelectMsgData[i];
                    if ([RXCollectManager checkMessageMoreActionBarClickWithType:type messageArr:@[message]] != ChatMoreActionFuncType_None) {
                        continue;
                    }
                    NSInteger index = [self.messageArray indexOfObject:message];
                    if (index != NSNotFound) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                        [self deleteChatMessageWithIndexPath:indexPath Message:message];
                    }
                }
                [self cancleMoreSelectAction:nil];
                
            } cancelText:languageStringWithKey(@"取消") okText:languageStringWithKey(@"确定")];
        }
            break;
        default:
            break;
    }
}

- (void)deleteChatMessageWithIndexPath:(NSIndexPath *)indexPath Message:(ECMessage *)message{
    
    NSNumber* isplay = objc_getAssociatedObject(message, &KVoiceIsPlayKey);
    if (isplay.boolValue) {
        objc_setAssociatedObject(self.voiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
        self.voiceMessage = nil;
    }
    if (message==self.messageArray.lastObject) {
        //删除最后消息才需要刷新session
        if (message==self.messageArray.firstObject) {
            //如果删除的也是唯一一个消息，删除session
            [[KitMsgData sharedInstance] deleteMessage:message.messageId andSession:message.sessionId];
        } else {
            //使用前一个消息刷新session
            [[KitMsgData sharedInstance] deleteMessage:message andPre:[_messageArray objectAtIndex:indexPath.row-1]];
        }
    } else {
        [[KitMsgData sharedInstance] deleteMessage:message.messageId andSession:self.sessionId];
    }
    [self.messageArray removeObject:message];
    
    
    //可放后台操作
    
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        
        //是否是文件
        if([message.messageBody isKindOfClass:[ECFileMessageBody class]]){
            NSDictionary *fileCacheDic = [[SendFileData sharedInstance]getCacheFileData:((ECFileMessageBody *)message.messageBody).remotePath];
            
            if(fileCacheDic.count>0){
                //标识有缓存 清空
                
                if([[fileCacheDic objectForKey:cacheimSissionId] isEqualToString:self.sessionId])
                {
                    //修改路径
                    [[SendFileData sharedInstance]deleteAllFileUrl:((ECFileMessageBody *)message.messageBody).remotePath];
                    
                    [HXFileCacheManager deleteAppointFileInSession:[fileCacheDic objectForKey:cacheimSissionId] identifer:[fileCacheDic objectForKey:cachefileIdentifer] withCacheDirectory:[fileCacheDic objectForKey:cachefileDirectory]];
                }
            }
        }
        
        self.backgroundIdentifier=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void){
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundIdentifier];
            self.backgroundIdentifier = UIBackgroundTaskInvalid;
        }];
    }
}

#pragma mark - ChatViewCellDelegate 更多选择
- (void)ChatViewCellOfMoreSelectWithMessage:(ECMessage *)msg chatCell:(ChatViewCell *)cell isSelect:(BOOL)isSelect {
    
    if (isSelect) {
        [[Common sharedInstance].moreSelectMsgData addObject:msg];
    }else {
        [[Common sharedInstance].moreSelectMsgData removeObject:msg];
    }
    
    if ([Common sharedInstance].moreSelectMsgData.count > 0) {
        self.moreActionBar.disabled = YES;
    }else {
        self.moreActionBar.disabled = NO;
    }
}

#pragma mark - UIResponder custom  点击cell的时候调用
- (void)dispatchCustomEventWithName:(NSString *)name userInfo:(NSDictionary *)userInfo tapGesture:(UITapGestureRecognizer *)tap{
    if (_menuController) {
        [_menuController setMenuVisible:NO animated:YES];
        [_menuController setMenuItems:nil];
        [tap cancelsTouchesInView];
    }
    needGotoBottom = YES;
    ECMessage *message = [userInfo objectForKey:KResponderCustomECMessageKey];
    
    CGPoint point = [tap locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if ([Common sharedInstance].isIMMsgMoreSelect) {//“更多”模式
        ChatViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.moreSelectBtn.selected = !cell.moreSelectBtn.selected;
        [self ChatViewCellOfMoreSelectWithMessage:message chatCell:cell isSelect:cell.moreSelectBtn.selected];
        return;
    }
    
    if ([name isEqualToString:KResponderCustomChatViewMergeMessageCellBubbleViewEvent]) {
        //点击合并消息的时候才标记该消息为已读
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            DDLogInfo(@"已阅了消息%@---%d",message.messageId,message.isRead);
            [[AppModel sharedInstance] readedMessage:message completion:^(ECError *error, ECMessage *amessage) {
                if (error.errorCode == ECErrorType_NoError) {
                    [[KitMsgData sharedInstance] updateMessageReadStateByMessageId:amessage.messageId isRead:amessage.isRead];
                }
            }];
        });
        needGotoBottom = NO;
        [self pushViewController:@"HXMergeMessageDetailController" withData:@{@"message":message} withNav:YES];
    }else if ([name isEqualToString:KResponderCustomChatViewCellResendEvent]) {
        ChatViewCell *resendCell = [userInfo objectForKey:KResponderCustomTableCellKey];
        ECMessage *message = resendCell.displayMessage;
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:languageStringWithKey(@"重发该消息") delegate:self cancelButtonTitle:languageStringWithKey(@"取消") otherButtonTitles:languageStringWithKey(@"重发"),nil];
        objc_setAssociatedObject(alertView, &KAlertResendMessage, message, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        alertView.tag = Alert_ResendMessage_Tag;
        [alertView show];
    } else if ([name isEqualToString:KResponderCustomChatViewTextLnkCellBubbleViewEvent]) {
        needGotoBottom = NO;
        //gy add
        if ([[Chat sharedInstance].componentDelegate respondsToSelector:@selector(getWebViewControllerWithDic:)] && [[Chat sharedInstance].componentDelegate getWebViewControllerWithDic:userInfo]) {//插件用的
            UIViewController *vc = [[Chat sharedInstance].componentDelegate getWebViewControllerWithDic:userInfo];
            if (vc) {
                [self pushViewController:vc];
            }
        }else{
            id vc = [[NSClassFromString(@"WebViewController") alloc] init];
            if (vc) {
                [self pushViewController:@"WebViewController" withData:@{@"URL":[userInfo objectForKey:@"url"],@"sender":self.sessionId} withNav:YES];
            }else{
                NSString *url = [userInfo objectForKey:@"url"]?[userInfo objectForKey:@"url"]:nil;
                WebBrowserBaseViewController *webBrowserVC = [[WebBrowserBaseViewController alloc] init];
                webBrowserVC.urlStr = url;
                webBrowserVC.delegate = self;
                [self pushViewController:webBrowserVC];
            }
        }
        //gy end
        // WebViewController在 PublicService里面，既然用了这个那下面的WebBrowserBaseViewController又是干嘛的？
        //        NSString *url = [userInfo objectForKey:@"url"]?[userInfo objectForKey:@"url"]:nil;
        //        [self pushViewController:@"WebViewController" withData:@{@"URL":[userInfo objectForKey:@"url"],@"sender":self.sessionId} withNav:YES];
        //
        //        WebBrowserBaseViewController *webBrowserVC = [[WebBrowserBaseViewController alloc] init];
        //        webBrowserVC.urlStr = url;
        //        webBrowserVC.delegate = self;
        
    } else if ([name isEqualToString:KResponderCustomChatViewTextMobileCellBubbleViewEvent]){
        
        NSString *mobile = [userInfo objectForKey:@"url"] ? [userInfo objectForKey:@"url"] : nil;
        NSString *tip = [NSString stringWithFormat:languageStringWithKey(@"%@\n可能是个电话号码,你可以"),mobile];
        [self showSheetWithTip:tip items:@[languageStringWithKey(@"拨打")] inView:self.view selectedIndex:^(NSInteger index) {
            if (index == 1) {
                if(mobile){
                    //拨打电话
                    NSString *num = [[NSString alloc]initWithFormat:@"tel://%@",mobile];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]]; //拨号
                }
            }
        }];
        
        
//        UIActionSheet *sheetView = [[UIActionSheet alloc]initWithTitle:[NSString stringWithFormat:languageStringWithKey(@"%@\n可能是个电话号码,你可以"),mobile] delegate:self cancelButtonTitle:languageStringWithKey(@"取消") destructiveButtonTitle:nil otherButtonTitles:languageStringWithKey(@"拨打"), nil];
//        [sheetView showInView:self.view];
    } else if ([name isEqualToString:@"KResponderCustomChatViewWebCellBubbleViewEvent"]) {
        needGotoBottom = NO;
        ECTextMessageBody *body = (ECTextMessageBody *)message.messageBody;
        if ([body.text isWebUrl]) {
            NSDictionary *dic = @{@"URL":body.text};
            if ([[Chat sharedInstance].componentDelegate respondsToSelector:@selector(getWebViewControllerWithDic:)]) {
                UIViewController *webViewVC = [[Chat sharedInstance].componentDelegate getWebViewControllerWithDic:dic];
                [self.navigationController pushViewController:webViewVC animated:YES];
            }
        }
    }
    else if ([name isEqualToString:KResponderCustomChatViewPreviewCellBubbleViewEvent]) {
        ECPreviewMessageBody *body = (ECPreviewMessageBody *)message.messageBody;
        if (body.url && message.from) {
            //转发应用文件处理
            if(!KCNSSTRING_ISEMPTY(message.userData) &&
               [message.userData rangeOfString:fromWorkFileShare].location != NSNotFound){
                UIViewController *onlineView = [[AppModel sharedInstance]runModuleFunc:@"AppStore" :@"getOnlineShowFileViewController:" :@[@{@"fileUrl":KSCNSTRING_ISNIL(body.url),@"fileName":KSCNSTRING_ISNIL(body.title)}]];
                RXBaseNavgationController * nav = [[RXBaseNavgationController alloc] initWithRootViewController:onlineView];
                [self presentViewController:nav animated:YES completion:nil];
            }else{
                if(!KCNSSTRING_ISEMPTY(message.userData) && [message.userData rangeOfString:kFileTransferMsgNotice_CustomType].location!= NSNotFound){
                    NSString * keyStr = [NSString stringWithFormat:@"%@,",kFileTransferMsgNotice_CustomType];
                    NSString * userDataCove = [[message.userData substringFromIndex:keyStr.length] base64DecodingString];
                    if([userDataCove rangeOfString:fromWorkFileShare].location != NSNotFound){
                        UIViewController *onlineView = [[AppModel sharedInstance] runModuleFunc:@"AppStore" :@"getOnlineShowFileViewController:" :@[@{@"fileUrl":KSCNSTRING_ISNIL(body.url),@"fileName":KSCNSTRING_ISNIL(body.title)}]];
                        RXBaseNavgationController *nav = [[RXBaseNavgationController alloc] initWithRootViewController:onlineView];
                        [self presentViewController:nav animated:YES completion:nil];
                        return;
                    }
                }
                NSDictionary *dic = @{@"URL":body.url,@"sender":message.from};
                if ([[Chat sharedInstance].componentDelegate respondsToSelector:@selector(getWebViewControllerWithDic:)]) {
                    UIViewController *webViewVC = [[Chat sharedInstance].componentDelegate getWebViewControllerWithDic:dic];
                    [self.navigationController pushViewController:webViewVC animated:YES];
                }
            }
        }
    } else if([name isEqualToString:KResponderCustomChatViewCellMessageReadStateEvent]){
        [self pushViewController:@"ReadMessageViewController" withData:message withNav:YES];
    }else if ([name isEqualToString:KResponderCustomChatGroupVotingCellBubbleViewEvent]){
        NSDictionary* userData =[MessageTypeManager getCusDicWithUserData:message.userData];
        if ([userData hasValueForKey:@"GroupVoting_Url"]) { //群投票
            NSString *votingUrl = [userData valueForKey:@"GroupVoting_Url"];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.sessionId,@"groupId",[[Chat sharedInstance] getAccount],@"account",votingUrl,@"votingUrl",nil];
            [self pushViewController:@"GroupVotingViewController" withData:dic withNav:YES];
        }
    } else if ([name isEqualToString:@"KResponderCustomChatViewCardCellBubbleViewEvent"]) {
        CGPoint point = [tap locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return;
        ECMessage *message = [self.messageArray objectAtIndex:indexPath.row];
        NSDictionary *shareCardDic = [MessageTypeManager getCusDicWithUserData:message.userData];
        BOOL isNewJson = [shareCardDic hasValueForKey:SMSGTYPE] ? YES:NO;
        NSString *type = isNewJson?shareCardDic[@"type"]:[[shareCardDic objectForKey:@"ShareCard"] objectForKey:@"type"];
        NSString *account = isNewJson?shareCardDic[@"account"]:[[shareCardDic objectForKey:@"ShareCard"] objectForKey:@"account"];
        NSString *pn_id = isNewJson?shareCardDic[@"pn_id"]:[[shareCardDic objectForKey:@"ShareCard"] objectForKey:@"pn_id"];
        if ([type isEqualToString:@"1"]) {
            UIViewController *contactorInfosVC = [[Chat sharedInstance].componentDelegate getContactorInfosVCWithData:account];
            [self pushViewController:contactorInfosVC];
        } else if ([type isEqualToString:@"2"]) {
            UIViewController *contactorInfosVC = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"getHXPublicDetailViewControllerWithID:" :@[pn_id?:@""]];
            if (contactorInfosVC) {
                [self pushViewController:contactorInfosVC];
            }
        }
    }else if ([name isEqualToString:KResponderCustomChatViewTextCheckCellBubbleViewEvent]) {
        [self textCellBubbleViewChechWebView:message];
    }else if ([name isEqualToString:KResponderCustomChatViewFileCellBubbleViewEvent]) {
        [self fileCellBubbleViewTap:message];
    }else if ([name isEqualToString:KResponderCustomChatViewCallTextCellBubbleViewEvent] || [name isEqualToString:KResponderCustomChatViewCellBubbleViewEvent]){//点击语音、视频通话时长拨打
        //add yuxp 账号冻结,或者离职
        if ([[Common sharedInstance]checkPointToPiontChatWithAccount:message.from]) {
            return;
        }
        NSNumber *number = [[AppModel sharedInstance] runModuleFunc:@"VidyoHelper" :@"IsVidyoingWhenOtherOperate" :nil];
        if(number.integerValue == 1){
            return;
        }
        NSString *calltype = [[NSString alloc] init];
        //zmf add
        if (message.messageBody.messageBodyType == MessageBodyType_Call){
            ECCallMessageBody *body = (ECCallMessageBody *)message.messageBody;
            if (body.calltype == VOICE) {
                calltype = @"voice";
            } else if (body.calltype == VIDEO) {
                calltype = @"video";
            }
        }
        NSDictionary *im_modeDic = [MessageTypeManager getCusDicWithUserData:message.userData];
        if (message.isVoipRecordsMessage && [im_modeDic[@"callType"] intValue] == 1) {
            if ([[Common sharedInstance]checkPointToPiontChatWithAccount:message.from] || [[Common sharedInstance]checkPointToPiontChatWithAccount:message.to]) {
                return;
            }
            [_containerView callBtnTap:nil];//拨打语音
        }else if (message.isVoipRecordsMessage && [im_modeDic[@"callType"] intValue] == 2) {
            if ([[Common sharedInstance]checkPointToPiontChatWithAccount:message.from] || [[Common sharedInstance]checkPointToPiontChatWithAccount:message.to]) {
                return;
            }
            [_containerView videoBtnTap:nil];//拨打视频
        }
    }else if ([name isEqualToString:KResponderCustomChatViewCellNameTapEvent]){//点击群通知的名字
        NSString *account = userInfo[@"account"];
        [self pushViewController:@"RXContactorInfosViewController" withData:account withNav:YES];//跳转至联系人详情页面
    }
    else if ([name isEqualToString:KResponderCustomChatViewVideoCellBubbleViewEvent]) {
        needGotoBottom = NO;
    }
    //zmf end
}

//审批模式
- (void)textCellBubbleViewChechWebView:(ECMessage *)message{
    NSDictionary *im_mode = [MessageTypeManager getCusDicWithUserData:message.userData];
    NSInteger arrvType = [[im_mode objectForKey:@"APRV_Type"] integerValue];
    switch (arrvType) {
        case 1:
        {
            //请假
//            RXWorkingWebViewController *vc = [[RXWorkingWebViewController alloc]init];
//            vc.data = message;
//            vc.isPop = YES;
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            NSString *meetUrl =[im_mode objectForKey:@"APRV_Url"];
            if(meetUrl) {
                //会议通知
                UIViewController *attWebview = [[AppModel sharedInstance] runModuleFunc:@"AppStore"
                                                                                       :@"getRLWebViewController:":@[@{@"url":meetUrl,@"appId":@"没有AppId",@"isNaviBar":@(1)}]];
                attWebview.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:attWebview animated:YES];
            }
        }
            break;
        case 3:
        {
            //日志通知
        }
            break;
            
        default:
        {
//            RXWorkingWebViewController *vc = [[RXWorkingWebViewController alloc]init];
//            vc.data = message;
//            vc.isPop = YES;
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
    }
    DDLogInfo(@"点击跳转了webView");
    
}

#pragma mark - UIAlertViewDelegate
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == Alert_ResendMessage_Tag) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            ECMessage *message = objc_getAssociatedObject(alertView, &KAlertResendMessage);
            if ([self.messageArray containsObject:message]) {
                [self.messageArray removeObject:message];
            } else {
                NSArray *msgarr = self.messageArray.copy;
                for (ECMessage *msg in msgarr) {
                    if ([msg.messageId isEqualToString:message.messageId]) {
                        [self.messageArray removeObject:msg];
                    }
                }
            }
            [[ChatMessageManager sharedInstance] resendMessage:message];
            [self.messageArray addObject:message];
            [Chat sharedInstance].isChatViewScroll = YES;
            [self.tableView reloadData];
        }
    }
}

- (void)ReceiveMessageRevoke:(NSDictionary*)dict {
    //消息撤回
    NSString *msgId =dict[@"msgid"];
    NSString *sessionId = dict[@"sessionid"];
    ECMessage *insertMessage = dict[@"message"];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:msgId];
    
    __weak  __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if ([strongSelf.sessionId isEqualToString:sessionId]) {
            for (NSInteger i=strongSelf.messageArray.count-1; i>=0; i--) {
                id content = [strongSelf.messageArray objectAtIndex:i];
                if ([content isKindOfClass:[NSNull class]]) {
                    continue;
                }
                ECMessage *message = (ECMessage *)content;
                if ([msgId isEqualToString:message.messageId]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSNumber* isplay = objc_getAssociatedObject(message, &KVoiceIsPlayKey);
                        if (isplay.boolValue) {
                            objc_setAssociatedObject(self.voiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                            [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
                            self.voiceMessage = nil;
                        }
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:message.messageId];
                        [strongSelf.tableView beginUpdates];
                        [weakSelf.messageArray replaceObjectAtIndex:i withObject:insertMessage];
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
                        [strongSelf.tableView endUpdates];
                        
                    });
                    break;
                }
            }
        }
    });
}

#pragma mark - WebBrowserBaseViewControllerDelegate
- (void)onSendPreviewMsgWithUrl:(NSString *)url title:(NSString *)title imgRemotePath:(NSString *)imgRemotePath imgLocalPath:(NSString *)imgLocalPath imgThumbPath:(NSString *)imgThumbPath description:(NSString *)description {
    
    ECMessage *message = [[ECMessage alloc] init];
    ECPreviewMessageBody *msgBody = [[ECPreviewMessageBody alloc] initWithFile:imgLocalPath displayName:[imgLocalPath lastPathComponent]];
    msgBody.url = url;
    msgBody.title = title;
    msgBody.remotePath = imgRemotePath;
    msgBody.desc = description;
    msgBody.thumbnailLocalPath = imgThumbPath;
    BOOL isTransmit = YES;
    NSNumber *isTransmitNum = [NSNumber numberWithBool:isTransmit];
    BOOL isShared = YES;
    NSNumber *isSharedNum = [NSNumber numberWithBool:isShared];
    message.messageBody = msgBody;
    //web端要从userdata里取值
    NSMutableDictionary *userData = [NSMutableDictionary dictionary];
    userData[@"title"] = msgBody.title.length >0 ?msgBody.title :@"";
    userData[@"desc"] = msgBody.desc.length >0 ?msgBody.desc :@"";
    userData[@"url"] = msgBody.url.length >0 ?msgBody.url :@"";
    message.userData = [userData convertToString];
    
    NSDictionary *exceptData = @{@"msg":message,@"isTransmitNum":isTransmitNum,@"isSharedNum":isSharedNum, @"ShareWeb":@"ShareWeb"};
    UIViewController *groupVC = [[Chat sharedInstance].componentDelegate getChooseMembersVCWithExceptData:exceptData WithType:SelectObjectType_TransmitSelectMember];
    [self pushViewController:groupVC];
}

// MARK: - personinfocell delegate
- (void)personinfoControll:(UIViewController *)RXPersoninfoControll didSelectedIndexPath:(NSIndexPath *)indexpath {
    if (indexpath.section == 2 && indexpath.row == 0) {
        _recordMessage = nil;
    }
}

// MARK: - groupinfodelegate
- (void)groupInfoView:(UIViewController *)groupInfoView didSelectedIndexPath:(NSIndexPath *)indexpath {
    if (indexpath.section == 4 && indexpath.row == 2) { //清空聊天记录
        _recordMessage = nil;
    }
}


#pragma mark - ChatToolViewDelegate
//改变tableView的frame
- (void)changeTableViewFrameWithFrame:(CGRect)frame andDuration:(NSTimeInterval)duration {
    __weak __typeof(self)weakSelf = self;
    needGotoBottom = NO;
    if (self.containerView.toolbarStatus == ToolbarStatus_Input && [self.dataSearchFrom[@"fromePage"] isEqualToString:@"searchDetail"]) {
        self.recordMessage = nil;
        [self refreshTableView:nil andIsReload:YES];
        [self.tableView.mj_footer setHidden:YES];
    }
    
    
    CGRect frame1 = self.tableView.frame;
    frame1.size.height = frame.origin.y-self.tableView.frame.origin.y;//-kViewDown;
    
    [UIView animateWithDuration:duration delay:0.0f options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.tableView.frame = frame1;
        }
        if (self->isScrollToButtom) {
            if (strongSelf.tableView.contentSize.height > frame1.size.height) {
                CGPoint offset = CGPointMake(0, strongSelf.tableView.contentSize.height - frame1.size.height);
                [strongSelf.tableView setContentOffset:offset animated:NO];
                //                 [self hiddenReminderView];
            }
        } else {
            self->isScrollToButtom = YES;
        }
        self->_imgToSendReminderView.bottom = frame.origin.y;
        // hanwe
        if (frame.origin.y > 450) {
            [self hiddenReminderView];
        }
        
    } completion:nil];
}

#pragma mark - 发送红包
//判断红包类型
- (NSInteger)ExtendTypeOfTextMessage:(ECMessage*)message {
    if (message.userData) {
        
        NSData *data = [message.userData dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictt = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([dictt hasValueForKey:@"1"]) {//红包消息
            return TextMessage_Redpacket;
        } else if ([dictt hasValueForKey:@"2"]) {//红包被抢消息
            return TextMessage_RedpacketTakenTip;
        }
        else if ([dictt hasValueForKey:@"3"]) {//转账消息
            return TextMessage_TransformRedPacket;
        } else if ([dictt hasValueForKey:@"4"]) {//收账消息
            return TextMessage_TransformRedPacketTip;
        }
        
    }
    return TextMessage_OnlyText;
}
//红包点击事件
- (void)redpacketCell:(ChatViewRedpacketCell *)cell didTap:(ECMessage *)message {
    
    
    if ([Common sharedInstance].isIMMsgMoreSelect) {
        cell.moreSelectBtn.selected = !cell.moreSelectBtn.selected;
        if (cell.moreSelectBtn.selected) {
            [[Common sharedInstance].moreSelectMsgData addObject:message];
        }else {
            [[Common sharedInstance].moreSelectMsgData removeObject:message];
        }
        
        if ([Common sharedInstance].moreSelectMsgData.count > 0) {
            self.moreActionBar.disabled = YES;
        }else {
            self.moreActionBar.disabled = NO;
        }
        return;
    }
    
    
    NSString *phone = message.from;
    
    // 用字典代替  用户名 用户头像 账号
    NSDictionary *curUserDic = [[Common sharedInstance].componentDelegate getDicWithId:phone withType:0];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSString *userName = phone;
    //2017yxp7月26
    if(curUserDic)
    {
        NSString *headUrl = curUserDic[Table_User_avatar];
        userName = curUserDic [Table_User_member_name];
        if(headUrl)
        {
            [userInfo setObject:headUrl forKey:@"userAvatar"];
        }
    }
    
    [userInfo setObject:userName forKey:@"userNickname"];
    [userInfo setObject:phone forKey:@"userId"];
    
    NSData *data = [message.userData dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 1) {
        return ;
    }
    [userInfo setObject:message.userData forKey:@"userData"];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    
    if ([[dict valueForKey:@"money_type_special"] isEqualToString:@"member"]) {
        [userInfo setObject:[[Common sharedInstance] getOtherNameWithPhone:[dict objectForKey:@"money_receiver_id"]] forKey:@"userNickname"];
        
        if ([AppModel sharedInstance].appModelDelegate && [[AppModel sharedInstance].appModelDelegate respondsToSelector:@selector(reloadRedpacketCellWithData:withVC:withSessionId:)]) {
            [[AppModel sharedInstance].appModelDelegate reloadRedpacketCellWithData:[userInfo copy] withVC:self withSessionId:self.sessionId];
        }
    } else {
        if ([AppModel sharedInstance].appModelDelegate && [[AppModel sharedInstance].appModelDelegate respondsToSelector:@selector(reloadRedpacketCellWithData:withVC:withSessionId:)]) {
            [[AppModel sharedInstance].appModelDelegate reloadRedpacketCellWithData:[userInfo copy] withVC:self withSessionId:self.sessionId];
        }
    }
}

#pragma mark ----关于返回按钮的变化---------
///设置返回按钮
- (void)showNavigationBarBackButtonTitle {
    NSInteger num = [[KitMsgData sharedInstance] getUnreadMessageCountFromSession];
    //zmf add 左上角显示未读消息不对
    ECSession *currentSession = [[KitMsgData sharedInstance] loadSessionWithID:self.sessionId];
    num -= currentSession.unreadCount;
    //zmf end
    
    NSString *backButtonTitle = nil;
    if (num > 100) {
        return;
    }else if(num > 99){
        backButtonTitle = [NSString stringWithFormat:@"(99+)"];
    }else if(num > 0){
        backButtonTitle = [NSString stringWithFormat:@"(%ld)",(long)num];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeleftNavigationItemTitle:backButtonTitle];
    });
    //    [self setBackButtonItemWithNormalImg:ThemeImage(@"title_bar_back") highlightedImg:ThemeImage(@"title_bar_back") titleText:backButtonTitle titleColor:APPMainUIColorHexString target:self action:@selector(popViewController:) type:NavigationBarItemTypeLeft];
}

- (void)changeleftNavigationItemTitle:(NSString *)backButtonTitle {
    CGFloat font = SystemFontLarge.pointSize;   //文字字体
    CGFloat height = 40;   //背景高度
    CGFloat offsetx = -10; //文字和返回按钮的距离
    //返回按钮的图片
    CGRect btnFrame = CGRectMake(0, 0, height, height);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) {
        btnFrame = CGRectMake(0, 0, height, height);
    }
    
    UIButton *imageView = self.backImgView;// [self.navigationItem.leftBarButtonItem.customView viewWithTag:1001];
    CGSize size = [backButtonTitle sizeWithFont:[UIFont systemFontOfSize:font] maxSize:CGSizeMake(300, font) lineBreakMode:NSLineBreakByWordWrapping];
    _numLabel.frame = CGRectMake(imageView.frame.origin.x+imageView.frame.size.width+offsetx, (height - font)/2, size.width, font);
    _numLabel.text = backButtonTitle;
    self.navigationItem.leftBarButtonItem.customView.frame = CGRectMake(0, 0,btnFrame.size.width+size.width+offsetx, height);
}

- (void)setNavigationItem {
    
    CGFloat font = SystemFontLarge.pointSize;   //文字字体
    CGFloat height = 40;   //背景高度
    CGFloat offsetx = -10; //文字和返回按钮的距离
    //背景button
    UIButton * frameViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,0,height)];
    //    frameViewButton.backgroundColor = [UIColor redColor];
    [frameViewButton addTarget:self action:@selector(popViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //返回按钮的图片
    CGRect btnFrame = CGRectMake(0, 0, height, height);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) {
        btnFrame = CGRectMake(0, 0, height, height);
    }
    
    UIButton *imageView = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageView setFrame:btnFrame];
    imageView.tag = 1001;
    self.backImgView = imageView;
    [imageView setUserInteractionEnabled:NO];
    dispatch_queue_t addNewMsgQueue = dispatch_queue_create("ChatViewController", NULL);
    dispatch_async(addNewMsgQueue, ^{
        UIImage *image =ThemeColorImage(ThemeImage(@"title_bar_back"), [UIColor blackColor]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageView setImage:image forState:UIControlStateNormal];
        });
    });
    //    [imageView setImage:ThemeImage(@"title_bar_back") forState:UIControlStateNormal];
    //    [imageView setImage:ThemeImage(@"title_bar_back") forState:UIControlStateHighlighted];
    [imageView.titleLabel setFont:[UIFont systemFontOfSize:font]];
    [imageView setTitleColor:[UIColor colorWithHexString:APPMainUIColorHexString] forState:UIControlStateNormal];
    [imageView setTitleColor:[UIColor colorWithHexString:APPMainUIColorHexString] forState:UIControlStateHighlighted];
    [imageView.imageView setContentMode:UIViewContentModeCenter];
    frameViewButton.frame = CGRectMake(0, 0,btnFrame.size.width, height);
    [frameViewButton addSubview:imageView];
    
    NSString *backButtonTitle = @"";
    //返回按钮的文字
    CGSize size = [backButtonTitle sizeWithFont:[UIFont systemFontOfSize:font] maxSize:CGSizeMake(300, font) lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x+imageView.frame.size.width+offsetx, (height - font)/2, size.width, font)];
    [titleLabel setTextColor:[UIColor colorWithHexString:APPMainUIColorHexString]];
    titleLabel.text = backButtonTitle;
    titleLabel.font = SystemFontMiddle;
    frameViewButton.frame = CGRectMake(0, 0,btnFrame.size.width+size.width+offsetx, height);
    [frameViewButton addSubview:titleLabel];
    _numLabel = titleLabel;
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:frameViewButton];
    self.navigationItem.leftBarButtonItem = buttonItem;
    
    
    NSInteger num = [[KitMsgData sharedInstance] getUnreadMessageCountFromSession];
    //zmf add 左上角显示未读消息不对
    ECSession *currentSession = [[KitMsgData sharedInstance] loadSessionWithID:self.sessionId];
    num -= currentSession.unreadCount;
    if(num > 99){
        backButtonTitle = [NSString stringWithFormat:@"(99+)"];
    }else {
        backButtonTitle = [NSString stringWithFormat:@"(%ld)",(long)num];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeleftNavigationItemTitle:backButtonTitle];
    });
}

#pragma 恒丰新增wjy
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
    
    if (fileBody.fileLength<=0.f && fileBody.localPath.length<10) {//判断空文件不让点 2018.5.16 by gy
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件不存在")];
        return;
    }
    
    [self pushViewController:@"HXShowFileViewController" withData:message withNav:YES];
}


#pragma mark 新增yuxp sheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0)
    {
        NSArray *mobileArray  =[actionSheet.title componentsSeparatedByString:@"\n"];
        if(mobileArray.count>0)
        {
            //拨打电话
            NSString *num = [[NSString alloc]initWithFormat:@"tel://%@",mobileArray[0]];
            //2017yxp修改 10月16
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]]; //拨号
        }
        
    }
}
#pragma mark - 清空栈内控制器
- (void)removeVcBy:(NSArray<Class> *)classArr{
    //清空栈内控制器
    NSMutableArray *tempMarr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController *temp in self.navigationController.viewControllers) {
        for (Class class in classArr) {
            if ([temp isMemberOfClass:class]) {
                [tempMarr removeObject:temp];
            }
        }
    }
    [self.navigationController setViewControllers:tempMarr animated:YES];
}
#pragma mark - get
//tableview
- (UITableView *)tableView{
    if (_tableView == nil) {
        if (isIPhoneX) {
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kScreenWidth,kScreenHeight-ToolbarInputViewHeight-kTotalBarHeight) style:UITableViewStylePlain];
        } else {
            if ([UIApplication sharedApplication].statusBarFrame.size.height == 40) {
                self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, -21, kScreenWidth,kScreenHeight-ToolbarInputViewHeight-65.0f) style:UITableViewStylePlain];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                    self.tableView.frame = CGRectMake(0.0f, 0, kScreenWidth,kScreenHeight-ToolbarInputViewHeight-65.0f);
                } else {
                    self.tableView.frame = CGRectMake(0.0f, 00, kScreenWidth,kScreenHeight-ToolbarInputViewHeight-45.0f);
                }
            }else{
                self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, kScreenWidth,kScreenHeight-ToolbarInputViewHeight-65.0f) style:UITableViewStylePlain];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                    self.tableView.frame = CGRectMake(0.0f, 0.0f, kScreenWidth,kScreenHeight-ToolbarInputViewHeight-65.0f);
                } else {
                    self.tableView.frame = CGRectMake(0.0f, 0.0f, kScreenWidth,kScreenHeight-ToolbarInputViewHeight-45.0f);
                }
            }
        }
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.scrollsToTop = YES;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.tableFooterView = [[UIView alloc] init];
        
        isScrollToButtom = YES;
        if (iOS11) {
            // 这里代码针对ios11之后，tableveiw 刷新时候，闪动，跳动的问题
            self.tableView.estimatedRowHeight = 0;
            self.tableView.estimatedSectionHeaderHeight = 0;
            self.tableView.estimatedSectionFooterHeight = 0;
        }
        
        __weak typeof(self) weak_self = self;
        MJRefreshNormalHeader *mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weak_self loadMoreMessage];
            [weak_self.tableView.mj_header endRefreshing];
        }];
        [mj_header.lastUpdatedTimeLabel setHidden:true];
        [mj_header setTitle:languageStringWithKey(@"下拉可以刷新") forState:MJRefreshStateIdle];
        [mj_header setTitle:languageStringWithKey(@"松开立即刷新") forState:MJRefreshStatePulling];
        [mj_header setTitle:languageStringWithKey(@"正在刷新数据中...") forState:MJRefreshStateRefreshing];
        self.tableView.mj_header = mj_header;
        
        if ([self.dataSearchFrom[@"fromePage"] isEqualToString:@"searchDetail"]) {
            MJRefreshBackNormalFooter *footerRefresh = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                [weak_self loadNewMessages];
            }];
            self.tableView.mj_footer = footerRefresh;
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewWillBeginDragging:)];
        [self.tableView addGestureRecognizer:tap];
        
    }
    return _tableView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_menuController setMenuVisible:NO animated:YES];
    [_menuController setMenuItems:nil];
    
    [_containerView textViewResignFirstResponder];
    isScrollToButtom = NO;
    [_containerView toolbarDisplayChangedWithStautas:ToolbarStatus_None];
    
    ECMessage *message = nil;
    if (_longPressIndexPath) {
        if (self.messageArray.count <= _longPressIndexPath.row) {
            return;
        }
        message = [self.messageArray objectAtIndex:_longPressIndexPath.row];
    }

    [Chat sharedInstance].isChatViewScroll = YES;
}
//生成工具栏
- (ChatToolView *)containerView{
    if (_containerView == nil) {
        if (isIPhoneX) {
            _containerView = [[ChatToolView alloc] initWithframe:CGRectMake(0, kScreenHeight-ToolbarInputViewHeight-kTotalBarHeight, kScreenWidth,ToolbarInputViewHeight+216.0f * fitScreenWidth) andSessionId:_sessionId andIsGroup:isGroup];
        }else{
            if ([UIApplication sharedApplication].statusBarFrame.size.height == 40) {
                _containerView = [[ChatToolView alloc] initWithframe:CGRectMake(0, kScreenHeight-ToolbarInputViewHeight-64-20, kScreenWidth,ToolbarInputViewHeight+216.0f * fitScreenWidth) andSessionId:_sessionId andIsGroup:isGroup];
            }else{
                _containerView = [[ChatToolView alloc] initWithframe:CGRectMake(0, kScreenHeight-ToolbarInputViewHeight-64, kScreenWidth,ToolbarInputViewHeight+216.0f * fitScreenWidth) andSessionId:_sessionId andIsGroup:isGroup];
            }
        }
        _containerView.delegate = self;
        _containerView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
        if (!isGroup) {
            [_containerView startTimer];
        }
    }
    return _containerView;
}
#pragma mark - 通知相关
//注册通知
- (void)registerNotification {
    ///被T通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationDelete:) name:KNOTIFICATION_onReceivedGroupNoticeDeleteMine object:nil];
    //消息发送完成回调通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessageCompletion:) name:KNOTIFICATION_SendMessageCompletion object:nil];
    //清空聊天记录通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMessageArray:) name:KNotification_DeleteLocalSessionMessage object:nil];
    ///隐藏右上角按钮通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideRightItemBar) name:KNotification_HiddenChatVCRightButtonSessionMessage object:nil];
    //下载媒体消息附件完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadMediaAttachFileCompletion:) name:KNOTIFICATION_DownloadMessageCompletion object:nil];
    ///消息撤回通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:) name:@"notificationrevokeMessage" object:nil];
    ///收到群组消息
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTableView:) name:KNOTIFICATION_onReceivedGroupNotice object:nil];
    ///滚动到底部通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollTableView) name:KNOTIFICATION_ScrollTable object:nil];
    ///消息记录刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callMessage:) name:@"callMessageClick" object:nil];
    ///刷新群组title通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadGroupTitle:) name:KNotice_reloadSessionGroupName object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadGroupTitle:) name:KNotice_InsertGroupMemberArray object:nil];
    ///更新用户的状态 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyUserState:) name:@"KNOTIFICATION_onUserState" object:nil];
    
    ///刷新消息阅读状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessageReadState:) name:@"KNOTIFICATION_IsReadMessage" object:nil];
    ///消息删除
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReceiveMessageDelete:) name:KNOTIFICATION_ReceiveMessageDelete object:nil];
    ///阅后即焚相关
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIsBurnAfterRead:) name:@"changeIsBurnAfterRead" object:nil];
    ///菜单栏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerShouldSetMenuItemsNil) name:@"menuControllerShouldSetMenuItemsNil" object:nil];
    ///刷新table通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewShouldReloadData:) name:@"tableViewShouldReloadData" object:nil];
    ///刷新table通知 语音消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewShouldUpdate) name:@"tableViewShouldUpdate" object:nil];
    ///阅后即焚消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceCellAboutBurn:)  name:@"voiceCellAboutBurn" object:nil];
    ///下载阅后即焚消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(burnMediaMessageHasDownLoad:) name:@"burnMediaMessageHasDownLoad" object:nil];
    //群组解散通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupIsDisbanded:) name:@"groupIsDisbanded" object:nil];
    //自己被移除群通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(IGetKickedOutOfGroup:) name:@"IGetKickedOutOfGroup" object:nil];
    //群组中个人昵称
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupMembersNickNameSwitch:) name:kGroupInfoGroupMembersNickNameSwitch object:nil];
    ///群昵称修改通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupNickNameModifyNotice:) name:KNOTIFICATION_onReceivedGroupNickNameModifyNotice object:nil];
    ///热点变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameWillChange:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    ///取消多选状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancleMoreSelectAction:) name:@"cancleMoreSelectActionInfo" object:nil];
    //终止语音播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopPlayVoice) name:kNotification_Video_Voice_Call_StopVoiceMessagePlay object:nil];
    //群组增加或者删除成员通知
    if(isGroup){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitleGroupMember) name:kNotification_memberChange_Group object:nil];
    }
    ///进入白板通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replayEnterBoard:) name:@"replayEnterBoard" object:nil];
    ///多终端已读通知 刷新返回数量
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNavigationBarBackButtonTitle) name:KNotice_Multi_TerminalRead object:nil];
    
    
    // 在init的时候监听状态栏改变的通知 UIApplicationDidChangeStatusBarFrameNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (layoutControllerSubViews) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    // 接收离线消息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveOfflineStates:) name:@"kitOnReceiveOfflineCompletion" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewDeleteCell:) name:@"tableViewDeleteCell" object:nil];
    
    //后台删除人员的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBMDeleteAccountsNotification:) name:@"BM_DeleteAccount_Notification" object:nil];
    
    //消息未读数的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableViewCellByMessageId:) name:@"MessageUnreadCount_Notification" object:nil];
    
    //移除对键盘监测的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputViewResignFirstResponder) name:@"NOTIFICATION_REGISTERFIRSETRESPONDER" object:nil];
    
    //在线离线  订阅
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsPublishPresence:) name:@"KNOTIFICATION_onReceiveFriendsPublishPresence" object:nil];
}

//kitOnReceiveOfflineCompletion
-(void)onReceiveOfflineStates:(NSNotification*)offlineStates
{
    NSNumber *numOffReciver =(NSNumber *)offlineStates.object;
    NSInteger statues =[numOffReciver integerValue];
    if(statues==0)
    {
        
    }else if(statues==1)
    {
        
        [self performSelector:@selector(refreshTableView:) withObject:nil afterDelay:0.15];
        
    }else if(statues==2)
    {
        [self performSelector:@selector(refreshTableView:) withObject:nil afterDelay:0.15];
    }
}

-(void)berefreshTableView{
    
    
}

- (void)inputViewResignFirstResponder {
    _containerView.resignFirstResponder = YES;
}


#pragma mark - 设置UI
//设置导航栏
- (void)setupNavBar {
    if ([self.sessionId isEqualToString:FileTransferAssistant]) {//文件传输助手
        UIView *titleview = [[UIView alloc] initWithFrame:CGRectMake(100, 0.0f, kScreenWidth - 180, 44.0f)];
        _titleview = titleview;
        titleview.backgroundColor = [UIColor clearColor];
        self.navigationItem.titleView = titleview;
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.0f, titleview.width, 44.0f)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        [titleview addSubview:titleLabel];
        titleLabel.text = languageStringWithKey(@"文件传输助手");
    } else {
        if (![Common sharedInstance].isIMMsgMoreSelect) {
            [self showNavigationBarBackButtonTitle];
        }
        UIView *titleview = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0f, kScreenWidth-180, 44.0f)];
        _titleview = titleview;
        titleview.backgroundColor = [UIColor clearColor];
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2.0f, titleview.width, 44.0f)];// 有在线状态高度为30，没有时候为44
        _titleLabel = titleLabel;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [titleview addSubview:_titleLabel];
        
        if (!isGroup && ![self.sessionId isEqualToString:IMSystemLoginSessionId]) {
            _titleLabel.height = 28;
            UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 28.0f, titleview.width, 12.0f)];
            _stateLabel = stateLabel;
            _stateLabel.font = [UIFont systemFontOfSize:11.0f];
            _stateLabel.textAlignment = NSTextAlignmentCenter;
            _stateLabel.textColor = APPMainUIColor;
            _stateLabel.backgroundColor = [UIColor clearColor];
            _stateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            //在线状态
            [titleview addSubview:_stateLabel];
        }
        titleview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _stateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        self.navigationItem.titleView = titleview;
        
        memberNum = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.right, 0, 100, 44)];
        memberNum.textAlignment = NSTextAlignmentLeft;
        memberNum.backgroundColor = [UIColor clearColor];
        memberNum.textColor = [UIColor blackColor];
        //加粗
        memberNum.font = [UIFont boldSystemFontOfSize:17];
        [titleview addSubview:memberNum];
        memberNum.hidden = YES;
    }
}
    
- (void)setNavData {
    if (isGroup) {
        ECGroup *group = [KitGroupInfoData getGroupByGroupId:self.sessionId];
        if (!group) {
            //如果没有本地数据 就插入一条数据
            __weak typeof(self)weak_self = self;
            [[ECDevice sharedInstance].messageManager getGroupDetail:self.sessionId completion:^(ECError *error, ECGroup *group) {
                if (error.errorCode == ECErrorType_NoError && group.name.length > 0) {
                    KitGroupInfoData *groupData = [[KitGroupInfoData alloc] init];
                    groupData.groupName = group.name;
                    groupData.groupId = group.groupId;
                    groupData.declared = group.declared;
                    groupData.owner = group.owner;
                    groupData.createTime = group.createdTime;
                    groupData.type = group.type;
                    groupData.memberCount = group.memberCount;
                    groupData.isDiscuss = group.isDiscuss;
                    groupData.scope = group.scope;
                    [KitGroupInfoData insertGroupInfoData:groupData];
                    
                    [weak_self setTitleFrame];
                    weak_self.titleLabel.text = group.name;
                    [self queryGroupMembersFromSDK];
                    
                } else if (error.errorCode == 590010) {//群组不存在
                    DDLogInfo(@"群主不存在");
                }
            }];
        }
        else {
            _titleLabel.text = group.name;
            [self setTitleFrame];
            [self queryGroupMembersFromSDK];
        }
        _stateLabel.hidden = YES;
        memberNum.hidden = NO;
        
    } else {
        if ([self.sessionId isEqualToString:IMSystemLoginSessionId]) {
            self.titleLabel.text = @"个人助手";
        } else {
            self.titleLabel.text= self.sessionId;
            __weak typeof(self)weak_self = self;
            [[Common sharedInstance] getUserInfoByAccount:self.sessionId completion:^(NSDictionary *userInfo, NSString *userName) {
                weak_self.titleLabel.text = userName;
            }];
        }
        if (!isGroup) {
            [self checkNet];
        }
        if ([self.sessionId isEqualToString:Common.sharedInstance.getAccount]){
            //给自己发消息
            return;
        }
        if (![[Common sharedInstance] isIMMsgMoreSelect]) {
            BOOL isShowCallBtn = YES;
            NSDictionary *dic = [[Common sharedInstance].componentDelegate getDicWithId:self.sessionId withType:0];
            if ([dic[@"level"] integerValue] == 1 || [dic[@"level"] integerValue] == 2) {
                if (!isHCQ) {
                    isShowCallBtn = YES;
                }else{
                    isShowCallBtn = NO;
                }
            } else {
                isShowCallBtn = NO;
            }
            if ([[Common sharedInstance] checkUserAuth:VOIPAuth]) {
                if (!isHCQ) {
                    isShowCallBtn = YES;
                }else{
                    isShowCallBtn = NO;
                }
            }
            
            NSDictionary* dict = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getCompanyAddressWithId:withType:" :[NSArray arrayWithObjects:self.sessionId,[NSNumber numberWithInt:0], nil]];
            NSString *personLevel = dict[@"personLevel"];
            
            if([[Common sharedInstance] checkPointToPiontChatWithAccount:self.sessionId] || ![[Common sharedInstance] checkPointToPiontIsMyFriendWithAccount:self.sessionId needPrompt:NO] || ![Common.sharedInstance canLookContacts:personLevel account:self.sessionId]){
                isShowCallBtn = NO;
            }
            if (isShowCallBtn) {
                [self setRightBarItemWithType:2];
            } else {
                [self setRightBarItemWithType:1];
            }
        }
    }
}

- (void)setTitleFrame {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.titleLabel.frame = self->_titleview.bounds;
        CGSize size = [self.titleLabel.text sizeWithFont:self.titleLabel.font maxWidth:self.titleLabel.frame.size.width lineBreakMode:self.titleLabel.lineBreakMode];
        CGSize size2 = [self->memberNum.text sizeWithFont:self->memberNum.font maxWidth:self->memberNum.width lineBreakMode:self->memberNum.lineBreakMode];
        self.titleLabel.left = -size2.width/2;
        self->memberNum.left = self.titleLabel.left + self.titleLabel.width/2 + size.width/2;
    });
}

- (void)setRightBarItemWithType:(NSInteger)type {
    if (type == 0) {
        UIView *view = [[UIView alloc] init];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    }
    else if (type == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setBarButtonWithNormalImg:ThemeImage(@"title_bar_more_normal") highlightedImg:ThemeImage(@"title_bar_more_normal") target:self action:@selector(navRightBarItemTap:) type:NavigationBarItemTypeRight];
        });
    }
    else if (type == 2) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addRightTwoBarButtonsWithFirstImage:ThemeImage(@"title_bar_more_normal") highlightedImg:ThemeImage(@"title_bar_more_normal") target:self firstAction:@selector(navRightBarItemTap:) secondImage:ThemeImage(@"bohao_") highlightedImg:ThemeImage(@"bohao_") secondAction:@selector(voipCall:)];
        });
    }
}

- (void)setTheViewDown{
    if (isIPhoneX) {
        return;
    }
    [AppModel sharedInstance].theViewDown = [UIScreen mainScreen].bounds.size.height - self.view.frame.size.height - 64;
    if ([AppModel sharedInstance].theViewDown != 20) {
        [AppModel sharedInstance].theViewDown = 0;
    }
}
///创建聊天tool
- (void)createChatToolView {
    if (self.moreActionBar != nil) {
        return;
    }
    CGFloat moreActionBarY = kScreenHeight - ToolbarInputViewHeight;
    if (isIPhoneX) {
        self.moreActionBar = [[ChatMoreActionBar alloc] initWithFrame:CGRectMake(0, moreActionBarY-kTotalBarHeight-([[UIApplication sharedApplication] statusBarFrame].size.height==40?20:0)-IphoneXBottom, kScreenWidth, ToolbarInputViewHeight)];
    } else {
        self.moreActionBar = [[ChatMoreActionBar alloc] initWithFrame:CGRectMake(0, moreActionBarY-kTotalBarHeight-([[UIApplication sharedApplication] statusBarFrame].size.height==40?20:0), kScreenWidth, ToolbarInputViewHeight)];
    }
    self.moreActionBar.hidden = YES;
    self.moreActionBar.disabled = NO;
    self.moreActionBar.delegate = self;
    [self.view addSubview:self.moreActionBar];
    
    self.amplitudeImageView = [[UIImageView alloc] initWithImage:ThemeImage(@"press_speak_icon_01")];
    _amplitudeImageView.center = CGPointMake(kScreenWidth/2, kScreenHeight/2.5);
    self.recordInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, _amplitudeImageView.frame.size.height-40.0f, _amplitudeImageView.frame.size.width, 30.0f)];
    _recordInfoLabel.backgroundColor = [UIColor clearColor];
    _recordInfoLabel.textAlignment = NSTextAlignmentCenter;
    _recordInfoLabel.textColor = [UIColor whiteColor];
    _recordInfoLabel.font = ThemeFontMiddle;
    self.amplitudeImageView.animationImages = @[ThemeImage(@"press_speak_icon_01"), ThemeImage(@"press_speak_icon_02"), ThemeImage(@"press_speak_icon_03"), ThemeImage(@"press_speak_icon_04"), ThemeImage(@"press_speak_icon_05"), ThemeImage(@"press_speak_icon_06"), ThemeImage(@"press_speak_icon_07")];
    self.amplitudeImageView.animationDuration = 1.0;
    [_amplitudeImageView addSubview:_recordInfoLabel];
    [self.view addSubview:_amplitudeImageView];
    _amplitudeImageView.hidden = YES;
    
    self.cancelImageView = [[UIImageView alloc] initWithImage:ThemeImage(@"cancel_send_voice")];
    self.cancelImageView.center = CGPointMake(kScreenWidth/2, kScreenHeight/2.5);
    self.cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, _amplitudeImageView.frame.size.height-40.0f, _amplitudeImageView.frame.size.width, 30.0f)];
    self.cancelLabel.backgroundColor = [UIColor colorWithHexString:@"#AC1111"];
    self.cancelLabel.textAlignment = NSTextAlignmentCenter;
    self.cancelLabel.textColor = [UIColor whiteColor];
    self.cancelLabel.font = ThemeFontMiddle;
    self.cancelLabel.text = @"松开手指,取消发送";
    CGSize size = [self.cancelLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontMiddle,NSFontAttributeName, nil]];
    self.cancelLabel.frame = CGRectMake((_amplitudeImageView.frame.size.width - size.width)*0.5-3,  _amplitudeImageView.frame.size.height-40.0f, size.width+6, 30.0f);
    [self.cancelImageView addSubview:self.cancelLabel];
    [self.view addSubview:self.cancelImageView];
    self.cancelImageView.hidden = YES;
}
//有草稿刷新界面 以及未读消息个数
- (void)haveDraftTextUpdateUI {
    //草稿
    ECSession *session = [[KitMsgData sharedInstance] loadSessionWithID:_sessionId];
    if (session && session.draft &&
        ![session.draft isEqualToString:@""]) {
        //        [_containerView setCurInputTextView:session.draft];
        if(!_recordMessage){
            [_containerView textViewBecomeFirstResponder];
        }
        //清空草稿
        [[KitMsgData sharedInstance] updateDraft:@"" withSessionID:_sessionId];
    }
    //判断是否有未读消息 数量是否大于一页的数量 10条
    if(session.unreadCount > MessagePageSize) {//
        currentUnreadCount = session.unreadCount;
        [self isHaveNewMessagePrompt:currentUnreadCount];
    }
}
// 快速编译方法，无需调用
- (void)injected{
    NSLog(@"eagle.injected");
}
- (void)isHaveNewMessagePrompt:(NSInteger)newCount{
    self.turnToTopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.turnToTopBtn.layer.cornerRadius = 15;
    self.turnToTopBtn.layer.borderWidth = 0.5;
    self.turnToTopBtn.layer.borderColor = [UIColor colorWithRed:0.87f green:0.87f blue:0.87f alpha:1.00f].CGColor;
    self.turnToTopBtn.layer.masksToBounds = YES;
    
    self.turnToTopBtn.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 8, 16, 16)];
    imgView.backgroundColor = [UIColor clearColor];
    imgView.image= ThemeImage(@"icon_upward");
    [self.turnToTopBtn addSubview:imgView];
    
    
    NSString *showUnreadStr = [NSString stringWithFormat:@"%ld%@",(long)newCount,languageStringWithKey(@"条未读消息")];
    CGSize showSize = [[Common sharedInstance] widthForContent:showUnreadStr withSize:CGSizeMake(100, CGFLOAT_MAX) withLableFont:14];
    
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right+2, 1, showSize.width, 30)];
    promptLabel.font = ThemeFontMiddle;
    promptLabel.textColor = [UIColor colorWithRed:0.24f green:0.70f blue:0.40f alpha:1.00f];
    promptLabel.text = showUnreadStr;
    promptLabel.backgroundColor = [UIColor clearColor];
    [self.turnToTopBtn addSubview:promptLabel];
    [self.turnToTopBtn addTarget:self action:@selector(turnToTopBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.turnToTopBtn];
    //动画之前的时间
    self.turnToTopBtn.frame =CGRectMake(kScreenWidth, 40, 0, 32);
    //_newMessageAllHeight = self.tableView.contentOffset.y;
    [UIView animateWithDuration:.5 animations:^{
        self.turnToTopBtn.frame =CGRectMake(kScreenWidth-imgView.width-promptLabel.width-15, 40, imgView.width+promptLabel.width+10+25, 32);
    }];
}
- (void)removeTurnToTopBtn{
    //这里为什么判断小于1的原因是什么? 导致电机未读消息 无法消失的问题
    // if(currentUnreadCount < 1){
    [UIView animateWithDuration:.3 animations:^{
        self.turnToTopBtn.frame = CGRectMake(kScreenWidth, 40, 0, 32);
    } completion:^(BOOL finished) {
        [self.turnToTopBtn removeFromSuperview];
    }];
    // }
}

- (void)turnToTopBtnAction:(UIButton *)btn{
    [self loadMoreUnreadMessage];
    [self removeTurnToTopBtn];
}

- (void)loadMoreUnreadMessage{
    ECMessage *message = [self.messageArray objectAtIndex:0];
    NSArray * array = [[KitMsgData sharedInstance] getSomeMessagesCount:currentUnreadCount OfSession:self.sessionId beforeTime:message.timestamp.longLongValue];
    if (array.count == 0) {
        self.tableView.mj_header.hidden = YES;
    } else {
        NSIndexSet *indexset = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)];
        [self.messageArray insertObjects:array atIndexes:indexset];
        if (array.count < currentUnreadCount) {
            self.tableView.mj_header.hidden = YES;
        }
        currentUnreadCount =currentUnreadCount-array.count;
        
    }
    [Chat sharedInstance].isChatViewScroll = YES;
    
    [self.tableView reloadData];
    [self scrollTableViewToTop];
}

///底部新消息提醒
- (void)createUnreadPromptOnBottom {
    if (self.turnToBottomBtn) {
        return;
    }
    //  右下角新消息提示按钮
    self.turnToBottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.turnToBottomBtn.frame = CGRectMake(kScreenWidth - 110 * fitScreenWidth, 3, 120 * fitScreenWidth , 30);
    self.turnToBottomBtn.backgroundColor = ThemeColor;
    self.turnToBottomBtn.layer.cornerRadius = self.turnToBottomBtn.frame.size.height/2;
    self.turnToBottomBtn.layer.masksToBounds = YES;
    self.turnToBottomBtn.titleLabel.font =ThemeFontSmall;
    self.turnToBottomBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
    [self.turnToBottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    ///重置
    [self resetTurnToBottomBtn];
    
    _unreadCount = 0;
    _unreadOffSetHeight = 0;
    [self.turnToBottomBtn addTarget:self action:@selector(turnToBottomBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //一开始隐藏
    [self.view addSubview:self.turnToBottomBtn];
    self.turnToBottomBtn.hidden = YES;
}
///点击bottomBtn按钮
- (void)turnToBottomBtnAction:(UIButton *)btn{
    [self resetTurnToBottomBtn];
    _unreadCount = 0;
    self.turnToBottomBtn.hidden = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self scrollTableView];
    });
}

- (void)resetTurnToBottomBtn{
    [self.turnToBottomBtn setTitle:@"0" forState:UIControlStateNormal];
    [self.turnToBottomBtn setTitle:@"0" forState:UIControlStateHighlighted];
    [self.turnToBottomBtn setTitle:@"0" forState:UIControlStateSelected];
}

#pragma mark - 语音代理 -voiceViewShouldGoWithString
- (void)voiceViewShouldGoWithString:(NSString *)placeString andRecordInfoLabelText:(NSString *)infoText {
    if (infoText.length > 0) {
        _recordInfoLabel.text = infoText;
    }
    _cancelImageView.hidden = YES;
    self.view.userInteractionEnabled = NO;
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    
    if ([placeString isEqualToString:@"back"]) {
        _amplitudeImageView.hidden = YES;
        [_amplitudeImageView stopAnimating];
        self.view.userInteractionEnabled = YES;
        self.navigationController.navigationBar.userInteractionEnabled = YES;
        
    } else if ([placeString isEqualToString:@"front"]) {
        _amplitudeImageView.hidden = NO;
        [_amplitudeImageView startAnimating];
    } else if ([placeString isEqualToString:@"cancel"]) {
        self.cancelLabel.backgroundColor = [UIColor colorWithHexString:@"#AC1111"];
        self.cancelLabel.text = languageStringWithKey(@"松开手指,取消发送");
        _cancelImageView.image = ThemeImage(@"cancel_send_voice");
        _amplitudeImageView.hidden = YES;
        [_amplitudeImageView stopAnimating];
        _cancelImageView.hidden = NO;
    } else {
        _cancelImageView.image = ThemeImage(placeString);
        self.cancelLabel.backgroundColor = [UIColor clearColor];
        self.cancelLabel.text = infoText;
        _amplitudeImageView.hidden = YES;
        [_amplitudeImageView stopAnimating];
        _cancelImageView.hidden = NO;
    }
    
}
#pragma mark - 最新图片预览发送相关
- (void)extracted {
    [self createReminderView];
}
- (void)createReminderView{
    //新图片提示发送
    self.imgToSendReminderView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth-80.0f, kScreenHeight, 80, 120)];
    self.imgToSendReminderView.hidden = YES;
    self.imgToSendReminderView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_imgToSendReminderView];
    self.reminderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 70, 40)];
    self.reminderLabel.text = languageStringWithKey(@"你可能要发送的图片:");
    self.reminderLabel.numberOfLines = 0;
    self.reminderLabel.font = ThemeFontSmall;
    [_imgToSendReminderView addSubview:_reminderLabel];
    self.reminderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 40, 70, 70)];
    self.reminderImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.reminderImageView.clipsToBounds = YES;
    [_imgToSendReminderView addSubview:_reminderImageView];
    _reminderImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reminderViewTapHandle)];
    tap.numberOfTapsRequired = 1;
    [self.reminderImageView addGestureRecognizer:tap];
    //    self.imgToSendReminderView.layer.masksToBounds = NO;
    self.imgToSendReminderView.backgroundColor = [UIColor whiteColor];
    self.imgToSendReminderView.layer.borderColor = [UIColor grayColor].CGColor;
    self.imgToSendReminderView.layer.cornerRadius = 3;
    self.imgToSendReminderView.layer.borderWidth = 1.0f;
    //    self.reminderImageView.layer.masksToBounds = NO;
    self.reminderImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.reminderImageView.layer.cornerRadius = 3;
    self.reminderImageView.layer.borderWidth = 1.0f;
}

- (void)showReminderView{
    [self hiddenReminderView];
    PHAsset *asset = [[[RXAlbumManager shared] dataSource] lastObject];
    if (asset) {
        NSTimeInterval timeInterval = [asset.creationDate timeIntervalSinceNow];
        timeInterval = -timeInterval;
        if (timeInterval < 30) {
            self.imgToSendReminderView.hidden = NO;
            self.imgPHAsset = asset;
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            //            options.deliveryMode=PHImageRequestOptionsDeliveryModeHighQualityFormat;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                self.reminderImageView.image = [UIImage imageWithData:imageData];
                self.reminderTimer =[NSTimer scheduledTimerWithTimeInterval:10 target:[RXWeakProxy proxyWithTarget:self] selector:@selector(hiddenReminderView) userInfo:nil repeats:NO];
            }];
        }
        [[[RXAlbumManager shared] dataSource] removeAllObjects];
    }
}

- (void)hiddenReminderView {
    if (_reminderTimer && [_reminderTimer isValid]) {
        [_reminderTimer invalidate];
        _reminderTimer = nil;
    }
    self.imgPHAsset = nil;
    self.reminderImageView.image = nil;
    self.imgToSendReminderView.hidden = YES;
}

- (void)reminderViewTapHandle{
    if (self.imgPHAsset) {
        [_containerView textViewResignFirstResponder];
        RX_MLSelectPhotoBrowserViewController *browserVc = [[RX_MLSelectPhotoBrowserViewController alloc] init];
        [browserVc setValue:@(YES) forKeyPath:@"isEditing"];
        RX_MLSelectPhotoAssets *photo = [[RX_MLSelectPhotoAssets alloc] init];
        photo.phAsset = self.imgPHAsset;
        browserVc.photos = @[photo];
        browserVc.callBack = ^(NSArray *selectArr) {
            [self dismissViewControllerAnimated:YES completion:nil];
            for (RX_MLSelectPhotoAssets *asset in selectArr) {
                PHAsset *photo = asset.phAsset;
                [self sendImageWithPHAsset:photo];
                
            }
        };
        RXBaseNavgationController *nav = [[RXBaseNavgationController alloc] initWithRootViewController:browserVc];
        
        [self presentViewController:nav animated:YES completion:^{
            // hanwei
            [self->_containerView chatVCEndKeyBoard];
            [self hiddenReminderView];
        }];
    }
}
//发送图片
- (void)sendImageWithPHAsset:(PHAsset *)asset {
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    //    options.synchronous = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
    [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        //gif 图片
        if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && imageData) {
                NSDateFormatter *formater = [[NSDateFormatter alloc] init];
                [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
                NSString *fileName = [NSString stringWithFormat:@"%@.gif", [formater stringFromDate:[NSDate date]]];
                NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
                [imageData writeToFile:filePath atomically:YES];
                ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:filePath displayName:filePath.lastPathComponent];
                //发送媒体类型消息
                [self.containerView sendMediaMessage:mediaBody];
            }
        }else {
            //其他格式的图片，直接请求压缩后的图片
            NSString *imagePath = [self->_containerView saveToDocument:[UIImage imageWithData:imageData]];
            ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
            //发送媒体类型消息
            [self.containerView sendMediaMessage:mediaBody];
        }
    }];
}
- (BOOL)isGroupVotingWith:(ECMessage *)message{
    if (![message isKindOfClass:[NSNull class]]) {
        NSDictionary *userData = [MessageTypeManager getCusDicWithUserData:message.userData];
        if ([userData hasValueForKey:@"GroupVoting_Url"]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 销毁
- (void)dealloc{
    NSLog(@"%s",__func__);
    //    _inputTextView.delegate = nil;
    //    [_inputTextView removeFromSuperview];
    if(_containerView){
        [_containerView updateDraftData];
    }
    if (_detectTimer) {
        dispatch_source_cancel(_detectTimer);
        _detectTimer = 0;
    }
    if ([self.delMsgTimer isValid]){
        [self.delMsgTimer invalidate];
        self.delMsgTimer = nil;
    }
    
    [_tableView.layer removeAllAnimations];
    _tableView = nil;

    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];//关闭感应
    
    [self.onlineTimer invalidate];
    [self.onlineTimer invalidate];
    [self.delMsgTimer invalidate];
    
    self.reminderTimer = nil;
    self.onlineTimer = nil;
    self.delMsgTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)setStateLabelWithState:(ECUserState *)state{
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
            net = @"GPRS";
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
    [[NSUserDefaults standardUserDefaults] setObject:stateStr forKey:[NSString stringWithFormat:@"%@_netState",self.sessionId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.stateLabel.text = stateStr;
}

- (void)checkNet {
    
    [self getNetWorkFromCache];
    
    [[ECDevice sharedInstance] getUsersState:@[self.sessionId] completion:^(ECError *error, NSArray *usersState) {
        
        self.stateLabel.hidden = NO;
        DDLogInfo(@"获取用户状态eagele.error.code = %ld",(long)error.errorCode);
        if (error.errorCode == ECErrorType_NoError) {
            if (usersState.count<=0) {
                self.stateLabel.text = languageStringWithKey(@"对方不在线");
                return ;
            }
            if (usersState.count != 1) {
                return ;
            }
            ECUserState *state = usersState.firstObject;
            if (state.isOnline) {
                [self setStateLabelWithState:state];
            }else{
                NSString *stateStr = languageStringWithKey(@"对方不在线");
                [[NSUserDefaults standardUserDefaults] setObject:stateStr forKey:[NSString stringWithFormat:@"%@_netState",self.sessionId]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        DDLogInfo(@"获取用户状态eagele.error.code checkNet over");
    }];
}

- (void)getNetWorkFromCache {
    NSString * stateStr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_netState",self.sessionId]];
    if (stateStr.length>0) {
        self.stateLabel.text = stateStr;
    }else{
        self.stateLabel.text = languageStringWithKey(@"对方不在线");
    }
}

//订阅相关 可以预知对方在线 离线
- (void)friendsPublishPresence:(NSNotification *)not {
    NSArray<ECUserState *> *friends = not.object;
    for (ECUserState *state in friends) {
        //state.isOnline 里面有是否在线 这里只需要刷新cell 也可以完成该功能
        NSString *account = [state.userAcc componentsSeparatedByString:@"#"].lastObject;
        if ([account isEqualToString:self.sessionId]) {
            if (state.isOnline) {
                [self checkNet];
            } else {
                NSString *stateStr = languageStringWithKey(@"对方不在线");
                self.stateLabel.text = stateStr;
                [[NSUserDefaults standardUserDefaults] setObject:stateStr forKey:[NSString stringWithFormat:@"%@_netState",self.sessionId]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
}


@end
