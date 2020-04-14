//
//  SessionViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "SessionViewController.h"
#import "SessionViewCell.h"
#import "ECSession.h"
#import "RXGroupHeadImageView.h"
#import "RXNaviMenuView.h"
#import "ChatViewController.h"
//#import "RecordsTableViewController.h"//聊天记录相关
//#import "NSAttributedString+Color.h"
#import "SearchAllChatView.h"
#import "YxpidVerificationAlert.h"
//ydw add
#import "DeviceStateViewController.h"
#import "RXThirdPart.h"
#import "OnLineManager.h"
#import "UISearchBar+RXAdd.h"

extern CGFloat NavAndBarHeight;
extern bool globalisVoipView;

@interface SessionViewController()<UISearchBarDelegate, DidSelectSearchDelegate,SessionViewCellDelegate,UIActionSheetDelegate,YxpidVerificationAlertDelegate>

@property (nonatomic, strong) NSMutableArray *sessionArray;
@property (nonatomic, strong) ECGroupNoticeMessage *message;
@property (nonatomic, strong) UIView * linkview;
@property (nonatomic, strong) UIView *PCloginView;//PC登陆
@property (nonatomic, strong) UIView *menuView;//背景view
@property (nonatomic, strong) NSMutableArray * companyData;
@property (nonatomic, strong) NSMutableArray *searchArray;

@property (nonatomic, strong) UIButton *unreadCountBtn;//未读消息条数
@property (nonatomic, strong) UIImageView * noMsgImageView;//暂无沟通记录


//搜索
@property (nonatomic, retain) UISearchBar *searchbar;
//@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) SearchAllChatView* searchAllChatView;
@property (nonatomic, strong) UIView *searchLinkView;
@property (nonatomic, assign) BOOL isNavigationTransform;
@property (nonatomic, assign) CGFloat scaleDevice;//当前比例 由于当前view不需要横屏 所以比例最好直接获取存起来
@property (nonatomic, strong) ECSession *selectSession;//当前选中的cell数据

@property (assign,nonatomic)BOOL isDisconnect;
@property (strong,nonatomic)UIView *deviceView;
@property (assign,nonatomic)BOOL isMultiDevice;
@property (strong,nonatomic)UIView *headerView;
@property (nonatomic, strong) DeviceStateViewController *deviceVC;
@property (nonatomic ,assign) BOOL downLoadAddress; //是否下载通讯录
@property (nonatomic ,assign) BOOL hasDownLoadAddress; //是否已经下载量。防止无线下载
///0未登录 1pc 2mac
@property(nonatomic ,assign) NSInteger loginState;

@end

@implementation SessionViewController{
    UITableViewCell * _memoryCell;
    LinkJudge linkjudge;
    UIView *titleview;
    UILabel* titleLabel;
    UIActivityIndicatorView *activityView;
}


//单例模式创建
+ (SessionViewController *)sharedInstance {
    static dispatch_once_t sessionViewControllerOnce;
    static SessionViewController *sessionViewController;
    dispatch_once(&sessionViewControllerOnce, ^{
        sessionViewController = [[SessionViewController alloc] init];
    });
    return sessionViewController;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    _companyData=nil;
}

-(void)viewDidLoad{
    [super viewDidLoad];
   
    if (iOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
    
    self.scaleDevice = [ChatTools isIphone6PlusProPortionHeight];
    _isNavigationTransform = 0;
    
    [self setTitleWithString:languageStringWithKey(@"消息") withAnimated:NO];
    
    [self createNavItems];

    [self createTableView];
    
    [self.view addSubview:self.watermarkView];
    [self.view sendSubviewToBack:self.watermarkView];
 
    self.sessionArray = [NSMutableArray arrayWithCapacity:0];
    
    //改变字体大小的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:THEMEFONTCHANGENOTIFICATION object:nil];
    
    //后台删除人员的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"BM_DeleteAccount_Notification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"ECGroupMessageChangeMemberRoleNotif" object:nil];
    
    //keven Add注释：收到-(void)onReceiveMessage:(ECMessage*)message里的通知，
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:KNOTIFICATION_onMesssageChanged object:nil];//msgchanged
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplayOfSessionId:) name:KNOTIFICATION_onMesssageChangedTheSessionId object:nil];//msgchanged
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:KNOTIFICATION_onReceivedGroupNotice object:nil];//群组通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReloadSessionGroup:) name:
     KNotice_ReloadSessionGroup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:kDeleteMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linkSuccess:) name:KNOTIFICATION_onConnected object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateNetWord:) name:KNOTIFICATION_onNetworkChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePCLoginViewWith:) name:KNOTIFICATION_PCLogin object:nil];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(prepareDisplay) name:@"setSessionForPublic" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:KNotification_UpdatecompanOtherSuccess object:nil];//群组通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:@"refreshMyAppsupdateSessionNotification" object:nil];//应用商店通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkPCloginIn) name:@"checkPCloginIn" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateCompanyData) name:@"SessionVCupdateCompanyData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:@"SessionRefreshDraft" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToChatVc:) name:@"sendToChatVc" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsPublishPresence:) name:@"KNOTIFICATION_onReceiveFriendsPublishPresence" object:nil];
    if(KitOnReceiveOfflineMessage) {
        //2017yxp8.15 新增收取中
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveOfflineStates:) name:@"kitOnReceiveOfflineCompletion" object:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getGroupListCount];
    });
    [self prepareDisplay];
    
    [self setupSearchBar];
    [self setupPopView];
    if (isIPhoneX) {
        
    }else{
        AppModel.sharedInstance.theViewDown = kScreenHeight - self.view.frame.size.height - 64;
    }
    
    //获取当前网络情况
    [self changeNetStateViewWith:[self getNetState]];
    
    //测试
    // 设置允许摇一摇功能
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    // 并让自己成为第一响应者
    [self becomeFirstResponder];
    //测试
}

- (UIView *)watermarkView {
    UIView *waterView = [self getWatermarkViewWithFrame:self.tableView.frame mobile:[[Common sharedInstance] getStaffNo] name:[[Common sharedInstance] getUserName] backColor:[UIColor whiteColor]];
    return waterView;
}

-(void)pushToChatVc:(NSNotification *)not{
    NSString *str =not.object;
    ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:str];
    [self pushViewController:chatVC];
}
- (void)friendsPublishPresence:(NSNotification *)not{
    NSArray<ECUserState *> *friends = not.object;
    for (ECUserState *state in friends) {
        //state.isOnline 里面有是否在线 这里只需要刷新cell 也可以完成该功能
        NSString *account = [state.userAcc componentsSeparatedByString:@"#"].lastObject;
        for (int i = 0; i < self.sessionArray.count; i ++) {
            ECSession *session = self.sessionArray[i];
            if ([session.sessionId isEqualToString:account]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                SessionViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
                cell.deptlabel.text = state.isOnline ? languageStringWithKey(@"[在线]") : languageStringWithKey(@"[离线]");
//                [self.tableView beginUpdates];
//                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                [self.tableView endUpdates];
            }
        }
        //下面是弹窗提示上线/下线的 暂时用不到 屏蔽了
        //[mgr showTipInView:self.tableView name:address.name ? : account isOnline:state.isOnline duration:2.0];
    }
}

#pragma mark  - 摇一摇测试
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
#if DEBUG
    [self showProgressWithMsg:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{    
        [SVProgressHUD dismiss];
    });
   
    return;
    // 调用JS {
    NSString *url = @"http://192.168.8.21:8080/tianrun/qxb.html";
    UIViewController *attWebview = [[AppModel sharedInstance] runModuleFunc:@"AppStore"
                                                                           :@"getRLWebViewController:":@[@{@"url":url,@"appCode":@"",@"isNaviBar":@(1)}]];
    attWebview.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:attWebview animated:YES];
//}

#endif
}

- (void)reloadTable{
    if (self.tabBarController) {
        self.tableView.frame = CGRectMake(0.0f, iOS11 ? 54 :44, kScreenWidth, kScreenHeight - kTotalBarHeight - TAB_BAR_HEIGHT - (iOS11 ? 54 :44));
    } else {
        self.tableView.frame = CGRectMake(0.0f, iOS11 ? 54 :44, kScreenWidth, kScreenHeight - (iOS11 ? 54 :44));
    }
    [self.tableView reloadData];
    
    if (_searchbar.text.length > 0) {
        self.searchAllChatView.hidden = NO;
        self.searchAllChatView.frame = CGRectMake(0, _searchLinkView.height, kScreenWidth, kScreenHeight-kTotalBarHeight-TAB_BAR_HEIGHT-_searchLinkView.height);
        [self.searchAllChatView reloadSearchText:_searchbar.text withSessions:_sessionArray withVC:self withSearchB:_searchbar];
    } else {
        self.searchAllChatView.hidden = YES;
        self.searchAllChatView.frame = CGRectMake(0, kScreenHeight-kTotalBarHeight, kScreenWidth, kScreenHeight-kTotalBarHeight-TAB_BAR_HEIGHT);
    }
}
- (void)onClickDeviceView:(UIGestureRecognizer *)recognizer{
    DeviceStateViewController *deviceVC = [[DeviceStateViewController alloc]init];
    deviceVC.deviceType = self.loginState;
    self.deviceVC = deviceVC;
    [self presentViewController:deviceVC animated:YES completion:nil];
}
- (void)setTitleWithString:(NSString *)string withAnimated:(BOOL)animated{
    if (!titleview) {
        titleview = [[UIView alloc] initWithFrame:CGRectMake(100, 0.0f, kScreenWidth-180, 44.0f)];
        titleview.backgroundColor = [UIColor clearColor];
        self.navigationItem.titleView = titleview;
    }
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.0f, titleview.width, 44.0f)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.backgroundColor = [UIColor clearColor];
        [titleview addSubview:titleLabel];
    }
    if (!activityView) {
        activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake(0, 12, 20, 20);
        activityView.hidden = YES;
        [titleview addSubview:activityView];
    }
    titleLabel.text = string;
    CGSize size = [string?:@"" sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:titleLabel.font,NSFontAttributeName, nil]];
    activityView.left = (titleview.width-size.width)/2-activityView.width-3;
    if (animated) {
        activityView.hidden = NO;
        [activityView startAnimating];
    }else{
        activityView.hidden = YES;
        [activityView stopAnimating];
    }
    self.navigationItem.titleView = nil;
    self.navigationItem.titleView = titleview;
}

//- (void)senVideo:(NSNotification *)noti {
//    [[ChatMessageManager sharedInstance] sendMessage:noti.object type:0];
////     [[KitMsgData sharedInstance] addNewMessage:noti.object andSessionId:self.callerAccount];
//}
- (void)checkPCloginIn{
    if (!self.deviceVC.isExitPC) {
        [[ECDevice sharedInstance] getMineOnlineMultiDevice:^(ECError *error, NSArray *multiDevices) {
            if (multiDevices.count > 0) {
                for (ECMultiDeviceState *deviceState in multiDevices) {
                    if (deviceState.deviceType == ECDeviceType_PC) {//PC 登陆了
                        DDLogInfo(@"有PC登陆");
                        [self PCLoginOutOrIn:1];
                        
                    }else if (deviceState.deviceType == ECDeviceType_Mac) {
                        [self PCLoginOutOrIn:2];
                    }else if (deviceState.deviceType == ECDeviceType_Web) {
                        [self PCLoginOutOrIn:3];
                    }
                }
            }else{
                [self PCLoginOutOrIn:0];
            }
        }];
    }else{
        [self PCLoginOutOrIn:0];
    }
    self.deviceVC = nil;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.searchAllChatView.hidden == YES) {
        self.navigationController.navigationBarHidden = NO;
        [self.view endEditing:YES];
    }
    
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}
-(void)getMsgMute{
    NSString *myAccount = [Common sharedInstance].getAccount;
    [[RestApi sharedInstance] getMsgMuteWithAccount:myAccount didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        NSLog(@"dict");
        if ([[dict objectForKey:@"statusCode"] isEqualToString:@"000000"]) {
            if ([[dict objectForKey:@"state"] intValue] == 1) {
                [AppModel sharedInstance].muteState = @"1";
            }else{
                NSLog(@"静音关闭");
                [AppModel sharedInstance].muteState = @"2";
            }
        }
    } didFailLoaded:^(NSError *error, NSString *path) {
        NSLog(@"error");
    }];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([AppModel sharedInstance].muteState.length<1) {
        [self getMsgMute];
    }
    self.hasDownLoadAddress = NO;
    [self checkPCloginIn];
    if (![AppModel sharedInstance].loginstate) {
        [self setTitleWithString:languageStringWithKey(@"未连接") withAnimated:NO];
    }else{
        if(![self.title isEqualToString:languageStringWithKey(@"消息收取中")])
        {
            [self setTitleWithString:languageStringWithKey(@"消息") withAnimated:NO];
        }
    }
//    //先判断有没有dialing模块
//    NSString *isDialingExisted = [[AppModel sharedInstance] runModuleFunc:@"Dialing" :@"isDialingExisted" :@[]];
//    if (!isHCQ && isDialingExisted.length >0) {
//        [self setBarButtonWithNormalImg:ThemeImage(@"bohao_.png") highlightedImg:ThemeImage(@"bohao_on.png")  target:self action:@selector(joinDialAction) type:NavigationBarItemTypeLeft];
//    }
//    [self setBarButtonWithNormalImg:ThemeImage(@"title_bar_add_01.png") highlightedImg:ThemeImage(@"title_bar_add_on_01.png")  target:self action:@selector(createNavAction:) type:NavigationBarItemTypeRight];
//
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil];
    [self updateListAllData];
    //获取当前网络情况
    [self changeNetStateViewWith:[self getNetState]];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     DDLogInfo(@"eagle1 sessionviewC viewDidAppear");
    WS(weakSelf)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        
        dispatch_async(queue, ^{//dispatch_get_main_queue()
            
            // 下面这个方法不要删掉。这个方法执行后，可以让第一次进入Chatvc界面，从1.8秒优化到0.7秒。因为图片编解码需要时间，先异步加载一次，下次真正使用的时候，会快很多。
            [weakSelf getImageArray];
        });
    });
}

// 这个方法用来提前加载一些图片资源，真正用的时候，能快一点
-(void)getImageArray{
    
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    
    dispatch_async(defaultQueue, ^{
        
        DDLogInfo(@"eagle.获取照片before");
        ThemeImage(@"title_bar_bohao_on");
        ThemeImage(@"title_bar_bohao");
        ThemeImage(@"title_bar_detail_on");
        ThemeImage(@"title_bar_detail");
        ThemeImage(@"message_icon_mute");
        ThemeImage(@"title_bar_back");
        ThemeImage(@"title_bar_more_normal");
        ThemeImage(@"chating_right_02");
        ThemeImage(@"choose_icon");
        ThemeImage(@"message_icon_voice");
        ThemeImage(@"messageSendFailed");
        ThemeImage(@"choose_icon_on");
        ThemeImage(@"im_icon_burn");
        ThemeImage(@"icon_whiteboard");
        ThemeImage(@"chating_left_01_on");
        ThemeImage(@"chating_left_01");
        ThemeImage(@"burn_lock_icon");
        ThemeImage(@"icon_whiteboard_green");
        ThemeImage(@"message_icon_voice_pressed");
        ThemeImage(@"im_icon_images");
        ThemeImage(@"message_secretchat_icon_picture");
        ThemeImage(@"message_icon_playvoice1_right");
        ThemeImage(@"message_icon_playvoice2_right");
        ThemeImage(@"message_icon_playvoice3_right");
        ThemeImage(@"chating_right_02—image");
        ThemeImage(@"chat_play_gif");
        ThemeImage(@"chating_richText_right");
        ThemeImage(@"chat_placeholder_image");
        
        ThemeImage(@"message_icon_secret_playvoice1_right");
        ThemeImage(@"message_icon_secret_playvoice2_right");
        ThemeImage(@"message_icon_secret_playvoice3_right");
        ThemeImage(@"message_secretchat_icon_picture_pressed");
        ThemeImage(@"message_secretchat_icon_close_pressed");
        ThemeImage(@"message_secretchat_icon_close");
        ThemeImage(@"burn_input_accessory_icon");
        ThemeImage(@"im_icon_camera");
        ThemeImage(@"message_btn_file_normal");
        ThemeImage(@"burn_input_accessory_icon");
        ThemeImage(@"im_icon_camera");
        ThemeImage(@"im_icon_video");
        ThemeImage(@"message_icon_more");
        ThemeImage(@"message_btn_position_normal");
        ThemeImage(@"im_icon_card");
//        ThemeImage(@"im_icon_moreLianjie");
        ThemeImage(@"im_icon_pic_txt");
        ThemeImage(@"burn_input_accessory_icon_on");
        ThemeImage(@"burn_input_expression_icon");
        ThemeImage(@"im_icon_collection");
        ThemeImage(@"message_icon_more_pressed");
        ThemeImage(@"burn_input_expression_icon_on");
        ThemeImage(@"message_icon_facialexpression");
        ThemeImage(@"message_icon_facialexpression_pressed");
        ThemeImage(@"btn_forward_normal");
        ThemeImage(@"btn_forward_disable");
        ThemeImage(@"btn_collect_normal");
        ThemeImage(@"btn_collect_disable");
        ThemeImage(@"btn_delete_normal");
        ThemeImage(@"btn_delete_disable");
        ThemeImage(@"press_speak_icon_01");
        ThemeImage(@"press_speak_icon_02");
        ThemeImage(@"press_speak_icon_03");
        ThemeImage(@"press_speak_icon_04");
        ThemeImage(@"press_speak_icon_05");
        ThemeImage(@"press_speak_icon_06");
        ThemeImage(@"press_speak_icon_07");
        ThemeImage(@"cancel_send_voice");
        ThemeImage(@"icon_upward");
        DDLogInfo(@"eagle.获取照片end --");
        
    });
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.tableView.frame = CGRectMake(0.0f, iOS11 ? 54 :44, kScreenWidth, self.view.bounds.size.height - (iOS11 ? 54 :44));
    self.watermarkView.frame = _tableView.frame;
}

//创建表格
- (void)createTableView{
    if (self.tabBarController) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, iOS11 ? 54 :44, kScreenWidth, kScreenHeight - kTotalBarHeight - TAB_BAR_HEIGHT - (iOS11 ? 54 :44)) style:UITableViewStylePlain];
    } else {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, iOS11 ? 54 :44, kScreenWidth, kScreenHeight - (iOS11 ? 54 :44)) style:UITableViewStylePlain];
    }
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView setSeparatorColor:[UIColor colorWithHexString:@"D9D9D9"]];
    [self.view addSubview:self.tableView];
    
    if (iOS11) {
        // 这里代码针对ios11之后，tableveiw 刷新时候，闪动，跳动的问题
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }

}

-(void)createHeaderView{
    if (!self.headerView) {
        self.headerView =  [[UIView alloc]init];
        self.headerView.backgroundColor = [UIColor colorWithRed:1.00f green:0.87f blue:0.87f alpha:1.00f];
        
    }
    if (!self.deviceView) {
        self.deviceView = [[UIView alloc] init];
        self.deviceView.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
        UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(17, 10, 26, 26)];
        image.image = ThemeImage(@"messageSendFailed.png");
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(55, 0, kScreenWidth-55 , 45)];
        label.backgroundColor = [UIColor clearColor];
        label.font = ThemeFontMiddle;
        label.textColor =[UIColor colorWithRed:0.46f green:0.40f blue:0.40f alpha:1.00f];
        label.text = languageStringWithKey(@"PC端已登录，手机通知已关闭");
        [self.deviceView addSubview:image];
        [self.deviceView addSubview:label];
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickDeviceView:)];
        [self.deviceView addGestureRecognizer:tap];
        self.deviceView.hidden = YES;
        [self.headerView addSubview:self.deviceView];
    }
    if (!self.linkview) {
        self.linkview = [[UIView alloc]initWithFrame:CGRectMake(0, 0.0, kScreenWidth, 45.0f)];
        self.linkview.backgroundColor = [UIColor colorWithRed:1.00f green:0.87f blue:0.87f alpha:1.00f];
        UIImageView * linkImage = [[UIImageView alloc]initWithFrame:CGRectMake(17, 10, 26, 26)];
        linkImage.image = ThemeImage(@"messageSendFailed.png");
        UILabel * linkLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 0, kScreenWidth-55 , 45)];
        linkLabel.backgroundColor = [UIColor clearColor];
       
        if (isEnLocalization) {
             linkLabel.font =ThemeFontSmall;
        }else{
             linkLabel.font = ThemeFontMiddle;
        }
        linkLabel.textColor = [UIColor colorWithRed:0.46f green:0.40f blue:0.40f alpha:1.00f];
        linkLabel.text = languageStringWithKey(@"当前网络不可用，请检查你的网络设置");
        [_linkview addSubview:linkImage];
        [_linkview addSubview:linkLabel];
        self.linkview.hidden = YES;
        [self.headerView addSubview:self.linkview];
    }
    self.isMultiDevice = YES;
    if (self.isMultiDevice) {
        self.deviceView.hidden = NO;
        if (self.isDisconnect) {//断网
            self.linkview.hidden = NO;
            self.headerView.frame = CGRectMake(0, 0, kScreenWidth, 90);
            self.linkview.frame = CGRectMake(0, 0, kScreenWidth, 45);
            self.deviceView.frame = CGRectMake(0, 45, kScreenWidth, 45);
        }else{
            self.linkview.hidden = YES;
            self.headerView.frame = CGRectMake(0, 0, kScreenWidth, 45);
            self.deviceView.frame = CGRectMake(0, 0, kScreenWidth, 45);
        }
    }else{
        self.deviceView.hidden = YES;
        if (self.isDisconnect) {
            self.linkview.hidden = NO;
            self.headerView.frame =CGRectMake(0, 0, kScreenWidth, 45);
            self.linkview.frame = CGRectMake(0, 0, kScreenWidth, 45);
        }else{
            self.linkview.hidden = YES;
            self.headerView.frame = CGRectZero;
        }
    }
    self.tableView.tableHeaderView = self.headerView;
}

//拨号
- (void)joinDialAction {
    
    UIViewController *dialingVC = [[AppModel sharedInstance] runModuleFunc:@"Dialing" :@"getDialingViewWithViewController" :@[]];
    [self pushViewController:dialingVC];

}
// 快速编译方法，无需调用
- (void)injected{
    NSLog(@"eagle.injected");
    [self.tableView reloadData];
}
#pragma mark  - barItem
- (void)createNavItems {
    //先判断有没有dialing模块
    NSString *isDialingExisted = [[AppModel sharedInstance] runModuleFunc:@"Dialing" :@"isDialingExisted" :@[]];
    if (!isHCQ && isDialingExisted.length >0) {
        [self setBarButtonWithNormalImg:ThemeImage(@"bohao_.png") highlightedImg:ThemeImage(@"bohao_on.png")  target:self action:@selector(joinDialAction) type:NavigationBarItemTypeLeft];
    }
    [self setBarButtonWithNormalImg:ThemeImage(@"title_bar_add_01.png") highlightedImg:ThemeImage(@"title_bar_add_on_01.png")  target:self action:@selector(createNavAction:) type:NavigationBarItemTypeRight];
    
    @weakify(self)
    if ([[Chat sharedInstance].componentDelegate respondsToSelector:@selector(configSessionListNavigationItemsWithBlock:)]) {//插件层自定义接口，配置会话列表导航栏按钮
         @strongify(self)
        [[Chat sharedInstance].componentDelegate configSessionListNavigationItemsWithBlock:^(NSArray<UIBarButtonItem *> *leftItems, NSArray<UIBarButtonItem *> *rightItems) {
            if (leftItems) {
                self.navigationItem.leftBarButtonItems = leftItems;
            }
            if (rightItems) {
                self.navigationItem.rightBarButtonItems = rightItems;
            }
        }];
    }
}

#pragma mark 创建searchVC

- (void)setupSearchBar{
    if (self.searchController) {
        self.searchController = nil;
    }
    _searchLinkView = [[UIView alloc] init];
    _searchLinkView.backgroundColor = [UIColor colorWithHexString:@"F2F2F2"];
    _searchLinkView.frame = CGRectMake(0, 0, kScreenWidth, iOS11 ? 54 :44);
    [self.view addSubview:_searchLinkView];
    
    // 创建searchBar
    self.searchbar = [[UISearchBar alloc] init];
    self.searchbar.delegate = self;
    self.searchbar.frame = CGRectMake(0, (_searchLinkView.height-44)/2, kScreenWidth, 44);
    [self.searchLinkView addSubview:self.searchbar];
    [self setupCancelButton];

    self.searchbar.placeholder = languageStringWithKey(@"搜索");
    self.searchbar.searchBarStyle = UISearchBarStyleMinimal;
      
    UITextField *txfSearchField = [self.searchbar rx_getSearchTextFiled];
    txfSearchField.borderStyle = UITextBorderStyleNone;
    txfSearchField.layer.cornerRadius = 3;
    txfSearchField.clipsToBounds = YES;
    txfSearchField.font = SystemFontLarge;
    txfSearchField.backgroundColor = [UIColor whiteColor];
    

    //搜索显示控制器
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self];
   
}

#pragma mark -UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    _isNavigationTransform = 1;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self cancelButtonClickEvent];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length > 0) {
        self.searchAllChatView.hidden = NO;
        self.searchAllChatView.frame = CGRectMake(0, _searchLinkView.height, kScreenWidth, self.view.bounds.size.height - _searchLinkView.height);
        [self.view bringSubviewToFront:self.searchAllChatView];
        [self.searchAllChatView reloadSearchText:searchBar.text withSessions:_sessionArray withVC:self withSearchB:searchBar];
    }else{
        self.searchAllChatView.hidden = YES;
    }
}

- (void)setupPopView{
    self.searchAllChatView = [[SearchAllChatView alloc] init];
    self.searchAllChatView.frame = CGRectMake(0, kScreenHeight-kTotalBarHeight, kScreenWidth, kScreenHeight-kTotalBarHeight-TAB_BAR_HEIGHT);
    self.searchAllChatView.delegate = self;
    [self.view addSubview:self.searchAllChatView];
}
- (void)didSelectSearch:(NSString *)sessionId {
    ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:sessionId];
    [self pushViewController:chatVC];
}
- (void)setupCancelButton{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[NSForegroundColorAttributeName] = ThemeColor;
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:dic forState:UIControlStateNormal];


//    UIButton *cancelButton = [self.searchbar valueForKey:@"_cancelButton"];
//    [cancelButton setTitleColor:ThemeColor forState:UIControlStateNormal];
//    [cancelButton addTarget:self action:@selector(cancelButtonClickEvent) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didScrollRegisBoad {
    if ([self.searchbar isFirstResponder]) {
        [self.searchbar resignFirstResponder];
        [self changeSearchBarCancelBtnTitleColor:self.searchbar];
    }
}

- (void)changeSearchBarCancelBtnTitleColor:(UIView *)view{
    
    if (view) {
        
        if ([view isKindOfClass:[UIButton class]]) {
            
            UIButton *getBtn = (UIButton *)view;
            
            [getBtn setEnabled:YES];//设置可用
            
            [getBtn setUserInteractionEnabled:YES];
            
            //设置取消按钮字体的颜色
            
//            [getBtn setTitleColor:[UIColor colorWithHexString:@"#0374f2"] forState:UIControlStateReserved];
//            
//            [getBtn setTitleColor:[UIColor colorWithHexString:@"#0374f2"] forState:UIControlStateDisabled];
            
            return;
            
        }else{
            
            for (UIView *subView in view.subviews) {
                
                [self changeSearchBarCancelBtnTitleColor:subView];
                
            }
            
        }
        
    }else{
        
        return;
        
    }
    
}

- (void)cancelButtonClickEvent{
    [self.searchbar endEditing:YES];
   
    [self.searchAllChatView dismissThePopView];

    self.searchAllChatView.hidden = YES;

    _isNavigationTransform = 0;
    self.searchbar.placeholder = languageStringWithKey(@"搜索");
    [self.searchbar setImage:ThemeImage(@"search") forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
}

    
- (void)willDismissSearchController:(UISearchController *)searchController {
    self.tabBarController.tabBar.hidden=NO;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
}


#pragma mark 弹窗  创建群聊、语音和视频会议
-(void)createNavAction:(id)sender
{
    RXNaviMenuView *naviMenuView =[RXNaviMenuView presentModalDialogWithRect:CGRectZero WidthDelegate:nil withPos:EContentPosTOPWithNaviK withTapAtBackground:YES maskColor:[UIColor clearColor]];
    
    __block NSArray *imagesArr;
    __block NSArray *textArr;
    __block NSMutableArray *selectorArr = [NSMutableArray array];
    if ([Chat sharedInstance].componentDelegate && [[Chat sharedInstance].componentDelegate respondsToSelector:@selector(getSessionMoreArrayWithCurrentVc:completion:)]) {
        [[Chat sharedInstance].componentDelegate getSessionMoreArrayWithCurrentVc:self completion:^(NSArray *myImagesArr, NSArray *myTextArr, NSArray *mySelectorArr) {
            imagesArr = myImagesArr;
            textArr = myTextArr;
            [selectorArr addObjectsFromArray:mySelectorArr];
        }];
    }
    
    CGFloat naviMenuViewHeight = 0;
    if (textArr.count == 1) {
        naviMenuViewHeight = 49.5*FitThemeFont;
    } else if (textArr.count > 1) {
        naviMenuViewHeight = 91*FitThemeFont + 43*(textArr.count-2)*FitThemeFont;
    }
    if (isEnLocalization) {
        [naviMenuView updateSubViewLayout:CGRectMake(kScreenWidth - 160*FitThemeFont - 5, kTotalBarHeight, 160*FitThemeFont, naviMenuViewHeight)];
    }else{
        [naviMenuView updateSubViewLayout:CGRectMake(kScreenWidth - 122*FitThemeFont - 5, kTotalBarHeight, 122*FitThemeFont, naviMenuViewHeight)];
    }
    
    naviMenuView.fetchTitleArray =  ^ NSArray*(void) {
        return textArr.count>0?textArr:[NSArray arrayWithObjects:languageStringWithKey(@"发起群聊"),nil];
    };
    naviMenuView.fetchImageArray=^NSArray*(void)
    {
        return imagesArr.count>0?imagesArr:[NSArray arrayWithObjects:@"icon_groupchat",nil];
    };
    selectorArr = selectorArr.count>0?selectorArr:[NSMutableArray arrayWithObjects:@"startGroupChat",nil];
    
    naviMenuView.selectRowAtIndex =  ^(RXNaviMenuView *naviMenuView,NSInteger index){
        
        for (int i=0; i<selectorArr.count; i++) {
            if (index == i+100) {
                NSString *selectorStr = selectorArr[i];
                //如果用户实现了点击方法 就走用户的 没有就走默认的
                if ([AppModel sharedInstance].appModelDelegate && [[AppModel sharedInstance].appModelDelegate respondsToSelector:NSSelectorFromString(selectorStr)]) {
                    
                    [[AppModel sharedInstance].appModelDelegate performSelector:NSSelectorFromString(selectorStr)];
                } else {
                    [self performSelector:NSSelectorFromString(selectorStr)];
                }
            }
        }
    };
}

//vidyo视频会议
- (void)vidyoConference {
    UIActionSheet *sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:languageStringWithKey(@"取消") destructiveButtonTitle:nil otherButtonTitles:languageStringWithKey(@"拨号视频会议"),languageStringWithKey(@"恒信视频会议"),nil];
    sheet.tag = 257;
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag==205) {
        if(buttonIndex==0) {
            DDLogInfo(@"点击了.....录入指纹");
            UIViewController *touchView = [[AppModel sharedInstance]runModuleFunc:@"UserCenter" :@"getTouchIdViewController" :nil];
            [self pushViewController:touchView];
        }else if (buttonIndex==1) {
            DDLogInfo(@"点击了.....身份验证");
            YxpidVerificationAlert *alertView = [[YxpidVerificationAlert alloc]initWithAlert:YES withPrompt:languageStringWithKey(@"身份验证")];
            alertView.verifyDelegate = self;
            [self.view addSubview:alertView];
        }
    }
}

//发起群聊
- (void)startGroupChat {
    //发起群聊
    DDLogInfo(@"---------------发起群聊");
//    NSMutableArray *members = [[NSMutableArray alloc]init];
//
//        [members addObject:[Common sharedInstance].getAccount];
//    NSDictionary *exceptData = @{@"members":members};
    UIViewController *groupVC = [[Chat sharedInstance].componentDelegate getChooseMembersVCWithExceptData:@{} WithType:SelectObjectType_CreateGroupChatSelectMember];
    [self pushViewController:groupVC];
}

//视频会议
-(void)videoMeeting{
    UIViewController *listVC = [[AppModel sharedInstance] runModuleFunc:@"YHCConference" :@"getConflistVC" :nil];
    RXBaseNavgationController *nav = [[RXBaseNavgationController alloc] initWithRootViewController:listVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - 扫一扫
//扫一扫 add by keven.
- (void)scan{
    void(^callBack)(id response) = ^(id response){
        DDLogInfo(@"---------------扫一扫结果:%@",response);
        if ([response isKindOfClass:[NSString class]]) {
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            if (![jsonDic[@"status"] integerValue] && [jsonDic hasValueForKey:@"data"]) {
                 NSDictionary *QRcodeDic = [NSJSONSerialization JSONObjectWithData:[jsonDic[@"data"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                    //扫一扫二维码加群
                if ([QRcodeDic[@"url"] isEqualToString:@"joinGroup"] && [QRcodeDic hasValueForKey:@"data"]){
                    [self scanToJoinGroupChat:QRcodeDic];
                }
                //pc扫码登录
                else if ([QRcodeDic[@"url"] isEqualToString:@"confirmLoginForPc"] ){
                    [self scanToconfirmLoginForPc:QRcodeDic];
                }
            }
        }
    };
    [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"openSweepYard:" :@[@{@"callBack":callBack}]];
}

//扫码加群
- (void)scanToJoinGroupChat:(NSDictionary *)QRcodeDic{
    [[AppModel sharedInstance] runModuleFunc:@"Chat" :@"qrcodeToJoinGroupChat:controller:" :@[QRcodeDic,self] hasReturn:NO];
}

//设备锁 PC扫码登录 isOpenDeviceSafe
- (void)scanToconfirmLoginForPc:(NSDictionary *)QRcodeDic{
    Class classname = NSClassFromString(@"RXAuthoritytoLoginForPCController");
    BaseViewController * vc = [[classname alloc] init];
    vc.data = QRcodeDic;
    RXBaseNavgationController * nav = [[RXBaseNavgationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
//end

#pragma mark -

-(void)setTopSessionLists
{
    if([AppModel sharedInstance].isHaveGetTopList){
        [self topviewshow];
    }else{
        [AppModel sharedInstance].isHaveGetTopList = YES;
        WS(weakSelf)
        
        [[AppModel sharedInstance] getTopSessionLists:^(ECError *error, NSArray *topContactLists) {
            if (error.errorCode == ECErrorType_NoError) {
                DDLogInfo(@"获取置顶列表成功 topContactLists = %@",topContactLists);
                // 更改沙盒
                [weakSelf delTopContactListsInUserDefaultsWithTopContactLists:topContactLists];
                [weakSelf reSetTopContactListsInUserDefaultsWithArray:topContactLists];
                //          [self setTopViewWithTopContactLists:topContactLists];
                [weakSelf topviewshow];
            }else{
                DDLogInfo(@"获取置顶列表失败 error.error.code = %ld",(long)error.errorCode);
                //           [self setTopViewWithTopContactLists:nil];
                [weakSelf topviewshow];
            }
            
            
        }];
    }
    
}
// 删除沙盒多余的置顶的消息
-(void)delTopContactListsInUserDefaultsWithTopContactLists:(NSArray *)topContactLists{
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSDictionary* defaults = [defs dictionaryRepresentation];
    for (id key in defaults) {
        if ([key hasPrefix:SETUPTOP] || [key hasPrefix:SETUPTOPNEWTIME]) {
            // 沙盒有这个数据 然后判断是否在列表里面
                BOOL hasTheKey = NO;
                for (NSString *sessionID in topContactLists) {
                    if ([key hasSuffix:sessionID]) {
                        hasTheKey = YES;
                         DDLogInfo(@"沙盒里面有这个 key = %@",key);
                        break;
                    }
                }
            if (!hasTheKey) {
                [defs removeObjectForKey:key];
                [defs synchronize];
//                  DDLogInfo(@"删除沙盒里面多余的 key = %@",key);
            }
            
        } else {
//            NSLog(@"沙盒的Key  %@",[defs objectForKey:key]);
        }
        
    }
}
// 重置沙盒消息置顶
-(void)reSetTopContactListsInUserDefaultsWithArray:(NSArray *)topContactLists{
    // 如果沙盒保存了置顶时间，就按照这个时间，如果没有，就说明是PC置顶的，然后获取当前时间来保存
    for (NSString *sessionId in topContactLists) {
        
        NSString *top_key = [NSString stringWithFormat:@"%@_cur_top", sessionId];
        NSString *top_str =[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,sessionId]];
        if([top_key isEqualToString:top_str]){
            // 置顶消息和置顶
            NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,sessionId]];
            if ([str isKindOfClass:[NSDate class]]) {
                str = [NSDate getTimeStrWithDate:(NSDate *)str];
                NSLog(@"11");//.
            }
            if (!str) {
                // 如果没有data 就把置顶时间设置为当前时间
                str = [NSDate getCurrentTimeStr];
                [[NSUserDefaults standardUserDefaults]setObject:str forKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,sessionId]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }else{
            
            [[NSUserDefaults standardUserDefaults] setObject:top_key forKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,sessionId]];
//            NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
            NSString *str = [NSDate getCurrentTimeStr];
            [[NSUserDefaults standardUserDefaults]setObject:str forKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,sessionId]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
}
-(void)setTopViewWithTopContactLists:(NSArray *)topContactLists
{
    if(self.sessionArray && self.sessionArray.count>0)
    {
        NSMutableArray *timeArray = [[NSMutableArray alloc]init];
        NSMutableDictionary *sessionDic =[[NSMutableDictionary alloc]init];
        NSMutableArray *topSessionArray = [[NSMutableArray alloc]init];
        NSMutableArray *noTopSessionArray = [[NSMutableArray alloc]init];
        
        for(NSUInteger i =self.sessionArray.count-1; i<self.sessionArray.count;i--)
        {
            ECSession* session=self.sessionArray[i];
            NSString *strTop =[NSString stringWithFormat:@"%@_cur_top",session.sessionId];
            NSString *topStr=[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,session.sessionId]];
                            if([topStr isEqualToString:strTop])
            {
                //置顶
                [self.sessionArray removeObjectAtIndex:i];
                
                NSString *dateStr = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,session.sessionId]];
                if ([dateStr isKindOfClass:[NSDate class]]) {
                    dateStr = [NSDate getTimeStrWithDate:(NSDate *)dateStr];
                    NSLog(@"11");//.
                }
                
                [timeArray addObject:dateStr];
                [sessionDic setObject:session forKey:dateStr];
            }else{
            }
        }
        
        NSArray *sortArray =[timeArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            NSComparisonResult result = [obj1 compare:obj2];
            switch(result)
            {
                case NSOrderedAscending:
                    return NSOrderedDescending;
                case NSOrderedDescending:
                    return NSOrderedAscending;
                case NSOrderedSame:
                    return NSOrderedSame;
                default:
                    return NSOrderedSame;
            }
        }];
        
        for(int i=0;i<sortArray.count;i++)
        {
            NSString *dateStr =sortArray[i];
            for(NSString *dateSess in sessionDic.allKeys)
            {
                if([dateStr isEqualToString:dateSess])
                {
                    ECSession* session =[sessionDic objectForKey:dateSess];
                    [self.sessionArray insertObject:session atIndex:i];
                }
            }
            

        }
        
        [self.tableView reloadData];
    }
}

// 获取当前置顶消息数量
-(NSInteger)getCurrentTopCession{
    NSInteger num = 0;
    if(self.sessionArray && self.sessionArray.count>0)
    {
        for(NSUInteger i =self.sessionArray.count-1; i<self.sessionArray.count;i--)
        {
            ECSession* session=self.sessionArray[i];
            NSString *strTop =[NSString stringWithFormat:@"%@_cur_top",session.sessionId];
            NSString *topStr=[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,session.sessionId]];
            if([topStr isEqualToString:strTop]) {
                num++;
            }
        }
    }
    return num;
}



-(void)topviewshow
{
    if(self.sessionArray && self.sessionArray.count>0)
    {
        NSMutableArray *timeArray = [[NSMutableArray alloc]init];
        NSMutableDictionary *sessionDic =[[NSMutableDictionary alloc]init];
        for(NSUInteger i =self.sessionArray.count-1; i<self.sessionArray.count;i--)
        {
            ECSession* session=self.sessionArray[i];
            NSString *strTop =[NSString stringWithFormat:@"%@_cur_top",session.sessionId];
            NSString *topStr=[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,session.sessionId]];
            
            if([topStr isEqualToString:strTop])
            {
                //置顶
                [self.sessionArray removeObjectAtIndex:i];
                
                NSArray *msgArr = [[KitMsgData sharedInstance] getAllMessageWithSessionId:session.sessionId];
//                NSDate *date = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,session.sessionId]];
                
                NSString *dateStr = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,session.sessionId]];
                if ([dateStr isKindOfClass:[NSDate class]]) {
                    dateStr = [NSDate getTimeStrWithDate:(NSDate *)dateStr];
                    NSLog(@"11");//.
                }
//                NSString *dateStr2 = [NSDate getTimeStrWithDate:date];
                if (msgArr.count > 0) {
                    ECMessage *msg = msgArr.lastObject;
//                    date = [NSDate dateWithTimeIntervalSince1970:msg.timestamp.longLongValue/1000];
                    dateStr = msg.timestamp;
                }
                
//                [timeArray addObject:date];
//                  [sessionDic setObject:session forKey:date];
                [timeArray addObject:dateStr];
                [sessionDic setObject:session forKey:dateStr];
                //break;
            }
        }
        
        NSArray *sortArray =[timeArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            NSComparisonResult result = [obj1 compare:obj2];
            switch(result)
            {
                case NSOrderedAscending:
                    return NSOrderedDescending;
                case NSOrderedDescending:
                    return NSOrderedAscending;
                case NSOrderedSame:
                    return NSOrderedSame;
                default:
                    return NSOrderedSame;
            }
        }];
        
        for(int i=0;i<sortArray.count;i++)
        {
//            NSDate *date =sortArray[i];
//            for(NSDate *dateSess in sessionDic.allKeys)
//            {
//                if([date isEqualToDate:dateSess])
//                {
//                    ECSession* session =[sessionDic objectForKey:dateSess];
//                    [self.sessionArray insertObject:session atIndex:i];
//                }
//            }
             NSString *dateStr =sortArray[i];
            for(NSString *dateSess in sessionDic.allKeys)
            {
                if([dateStr isEqualToString:dateSess])
                {
                    ECSession* session =[sessionDic objectForKey:dateSess];
                    [self.sessionArray insertObject:session atIndex:i];
                }
            }
            
        }
    }
    [self.tableView reloadData];
}

//外界关闭控制器的方法
-(void)shouldDismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 获取群组列表个数
- (void)getGroupListCount{
    [[ECDevice sharedInstance].messageManager queryOwnGroupsWith:ECGroupType_All completion:^(ECError *error, NSArray *groups) {
        if (error.errorCode == ECErrorType_NoError) {
            if(groups.count > 0){
                [[KitMsgData sharedInstance] addGroupIDs:groups];
            }else{
                [[KitMsgData sharedInstance] deleteAllGroupInfo];
            }
        } else {
            if(error&&error.errorDescription){
                DDLogInfo(@"群组列表获取失败----reason:%@",error);
            }
        }
    }];
}


#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.tableView.contentInset.top != 0 && self.sessionArray.count != 0) {
        
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    [self didScrollRegisBoad];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [Chat sharedInstance].isSessionEdgQueue =YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sessionArray.count == 0) {
        return tableView.height;
    }
    return 72.0f*self.scaleDevice*FitThemeFont;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat porHeightFloat = self.scaleDevice*FitThemeFont;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 30 + 50.0f * porHeightFloat, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 30 + 50.0f * porHeightFloat, 0, 0)];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DDLogInfo(@"before didSelectRowAtIndexPath sessionviewController");
    
    /// eagle 先放在这，这是取消所有e未读消息的
//    [[KitMsgData sharedInstance] setAllUnreadMessageCountZero];
//    [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_update_session_im_message_num object:nil];
//    [self prepareWithNewDisplay];
//    return;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.sessionArray.count == 0 || (self.sessionArray.count <= indexPath.row)) {
        return;
    }
    ECSession * session = [self.sessionArray objectAtIndex:indexPath.row];
    session.isAt = NO;
    //消息条数不能直接更新
    if(session.type ==100 || session.type==105 || [session.sessionId isEqualToString:FileTransferAssistant] || [session.sessionId isEqualToString:YHC_CONFMSG])
    {
        session.unreadCount = 0;
    }
    DDLogInfo(@"before   [[KitMsgData sharedInstance] updateSession:session];");
    [[KitMsgData sharedInstance] updateSession:session];
     DDLogInfo(@"after   [[KitMsgData sharedInstance] updateSession:session];");
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    if (session.type == 100) {
        //系统通知

    } else if (session.type==105) {
        if ([[Chat sharedInstance].componentDelegate respondsToSelector:@selector(getHXPublicViewController)]) {
            UIViewController *vc = [[Chat sharedInstance].componentDelegate getHXPublicViewController];
            [self pushViewController:vc];
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:KPublicMessCount];
        }
    }else if ([session.sessionId isEqualToString:@"rx4"]) {
        
        UIViewController *attNotiView = [[AppModel sharedInstance] runModuleFunc:@"Work"
                                                                               :@"getAttenNotifyViewControll:"
                                                                               :@[session.sessionId]];
        [self pushViewController:attNotiView];
        
    } else if ([session.sessionId isEqualToString:YHC_CONFMSG]) {
        UIViewController * SVCConfMsgListVC = [[AppModel sharedInstance] runModuleFunc:@"FusionMeeting" :@"getConferenceMessageListViewController":nil];
        [self pushViewController:SVCConfMsgListVC];
    } else {
        if ([session.sessionId isEqualToString:FileTransferAssistant]) {
            //文件传输
            ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:session.sessionId];
            [self pushViewController:chatVC];
        }else if(session.type == HXOAMessageTypePublicNum){
            [self pushViewController:@"OAShowDetailVC" withData:@{@"session":session} withNav:YES];
        }else if([session.sessionId hasPrefix:KOAMessage_sessionIdentifer]){
            NSRange range = [session.sessionId rangeOfString:KOAMessage_sessionIdentifer];
            NSDictionary *oneDic = [NSDictionary dictionary];
            if(range.location !=NSNotFound) {
                NSString *oaAppId = [session.sessionId substringFromIndex:range.location+range.length];
                if([oaAppId isEqualToString:KOAMessage_verify]) {
                    //add2017yxp9.4 保存一下选中的
                    self.selectSession = session;
                    //endyxp
                    NSNumber *touchidNum = [[AppModel sharedInstance]runModuleFunc:@"UserCenter" :@"getSmileAuthenticationStatus:":@[self]];
                    if (![touchidNum boolValue]) {
                        
                        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:languageStringWithKey(@"取消") destructiveButtonTitle:nil otherButtonTitles:languageStringWithKey(@"录入指纹"),languageStringWithKey(@"身份认证"), nil];
                        actionSheet.tag = 205;
                        [actionSheet showInView:self.view];
                    }else {
                        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(veridySuccess:) name:@"PostAaCheckNeedVeridyMessage" object:nil];
                        objc_setAssociatedObject(@"oaCheckNeedVeridy", @"oaCheckNeedVeridy", [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    }
                    return;
                }
                oneDic =  [[AppModel sharedInstance] runModuleFunc:@"AppStore" :@"getAppStoreParamsWithAppId: appType:" :@[oaAppId, @(1)]];
            }
            [self pushViewController:@"OAShowDetailVC" withData:@{@"session":session,@"oaData":oneDic?oneDic:[NSDictionary dictionary]} withNav:YES];
        }
        //请知晓 现在去掉等级权限控制 直接进入聊天界面进行逻辑判断
        else {
              DDLogInfo(@"eagle.聊天界面入口 before");
            //聊天界面入口
            ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:session.sessionId];
              DDLogInfo(@"eagle.聊天界面入口 after1");
            [self pushViewController:chatVC];
              DDLogInfo(@"eagle.聊天界面入口 after2");
        }
    }
    DDLogInfo(@"after didSelectRowAtIndexPath sessionviewController");
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    if (self.sessionArray.count == 0) {
        return 1;
    }else{
        return _sessionArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //搜索和正常的 用同一种cell 根据searchMessageArr的count做判断
    if (self.sessionArray.count == 0) {
        static NSString *noMessageCellid = @"sessionnomessageCellidentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noMessageCellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noMessageCellid];
        }
        [self.noMsgImageView removeFromSuperview];
        UIImage * noMsgImage = ThemeImage(languageStringWithKey(@"nosession"));
        self.noMsgImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - noMsgImage.size.width)/2, (tableView.height-noMsgImage.size.height-60)/2, noMsgImage.size.width, noMsgImage.size.height)];
        self.noMsgImageView.image = noMsgImage;
        [cell.contentView addSubview:self.noMsgImageView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }

    static NSString *sessioncellid = @"sessionCellidentifier";
    SessionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sessioncellid];
    
    if (cell == nil) {
        cell = [[SessionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sessioncellid withDeviceScale:self.scaleDevice];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.portraitImg.hidden = NO;
    cell.groupHeadView.hidden = YES;
    //cell复用时取消当前异步下载线程，解决头像错乱问题
    //[cell.portraitImg sd_cancelCurrentImageLoad];
    
    if (_sessionArray.count > indexPath.row ) {
        ECSession* session = [_sessionArray objectAtIndex:indexPath.row];
        /// eagle 服务号不去查
        if (![session.sessionId isEqualToString:KPublicMessList_publicId]) {
            // 判断本地有没有
            NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId: ([session.sessionId hasPrefix:@"g"]?session.fromId:session.sessionId) withType:0];
            NSString *str = companyInfo[Table_User_member_name];
            /// eagle 也可能是手机通讯录
            if (str.length<1 && ![session.sessionId hasPrefix:@"g"] && isOpenPhoneContact) {
                // 如果通讯录没有这个人，去下载通讯录
                id addBook = [[AppModel sharedInstance]runModuleFunc:@"KitAddressBookManager" :@"checkAddressBook:" :@[[session.sessionId hasPrefix:@"g"]?session.fromId:session.sessionId] hasReturn:YES];
                //   KitAddressBook *addBook = [[KitAddressBookManager sharedInstance] checkAddressBook:account];
                NSLog(@"addbook = %@",addBook);
                if (addBook) {
                    str = @"联系人是手机通讯录的";
                }
            }
            if (str.length < 1) {
                // 如果通讯录没有这个人，去下载通讯录
                self.downLoadAddress = YES;
            }
        }
        cell.session = session;
        
        //代理
        cell.delegate  = self;
    }
    if (indexPath.row == _sessionArray.count-1 && self.downLoadAddress && !self.hasDownLoadAddress) {
        DDLogInfo(@"sessionVC updateCompanyData");
        [self updateCompanyData];
        self.hasDownLoadAddress = YES;
        ///如果后台新增用户 当前用户一直在此页面会导致不请求数据
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.hasDownLoadAddress = NO;
        });
    }
    return cell;
}

- (void)updateCompanyData {
    NSLog(@"通讯录取值为空 sessionviewcontroller updateCompanyData");
    [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"KitAddressBookManagerUpdateCompangAddress" :nil];
}

#pragma mark 编辑按钮
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (tableView == self.searchController.searchResultsTableView || self.sessionArray.count == 0) {
//        return NO;
//    };
    
    if (self.sessionArray.count == 0) {
        return NO;
    }
    return YES;
}

//侧滑删除置顶功能
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < 0){
        return nil;
    }
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:languageStringWithKey(@"删除") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self deleteCell:indexPath];
    }];
    deleteRowAction.backgroundColor = [UIColor colorWithHexString:@"FF3A30"];

    __weak ECSession *session = [_sessionArray objectAtIndex:indexPath.row];
    UITableViewRowAction *topRowAction;
    if(session.type != 100){
        NSString *top_key = [NSString stringWithFormat:@"%@_cur_top", session.sessionId];
        NSString *top_str = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,session.sessionId]];
        typeof(self)weak_self = self;
        if([top_str isEqualToString:top_key]){
            topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:languageStringWithKey(@"取消置顶") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
               
                
                [[AppModel sharedInstance] setSession:session.sessionId IsTop:NO completion:^(ECError *error, NSString *seesionId) {
                    if (error.errorCode == ECErrorType_NoError) {
                        DDLogInfo(@"取消置顶成功 seesionId = %@  error.errorCode = %ld",seesionId,(long)error.errorCode);
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,session.sessionId]];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,session.sessionId]];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [weak_self sendIMMessageIsTop:NO sessionId:session.sessionId];
                        //                        [weak_self prepareDisplay];
                    }
                }];
            }];
        } else {
            topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:languageStringWithKey(@"置顶") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
               

                [[AppModel sharedInstance] setSession:session.sessionId IsTop:YES completion:^(ECError *error, NSString *seesionId) {
                    if (error.errorCode == ECErrorType_NoError) {
                        [[NSUserDefaults standardUserDefaults] setObject:top_key forKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,session.sessionId]];
                        NSString *str = [NSDate getCurrentTimeStr];
                        [[NSUserDefaults standardUserDefaults] setObject:str forKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,session.sessionId]];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        DDLogInfo(@"设置置顶成功 seesionId = %@  error.errorCode = %ld",seesionId,(long)error.errorCode);
                        [weak_self sendIMMessageIsTop:YES sessionId:session.sessionId];
                        //                         [weak_self prepareDisplay];
                    }
                }];
            }];
        }
        topRowAction.backgroundColor = [UIColor colorWithHexString:@"c9c9c9"];
        return @[deleteRowAction,topRowAction];
    }
    return @[deleteRowAction];
}


//   置顶/取消置顶之后，发送CMD消息
- (void)sendIMMessageIsTop:(BOOL)isTop sessionId:(NSString *)sessionId{
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"isTop"] = @(isTop);
    mDic[@"sessionId"] = sessionId;
    mDic[@"type"] = @(ChatMessageTypeTopterminal);
    [[ChatMessageManager sharedInstance] sendCmdMessageByDic:mDic];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (tableView == self.searchController.searchResultsTableView) {
    //        return;
    //    };
    
    if(editingStyle==UITableViewCellEditingStyleDelete && !iOS8)
    {
        [self deleteCell:indexPath];
    }
}

- (void)deleteCell:(NSIndexPath *)indexPath{
    if(indexPath.row < 0){
        return;
    }
    ECSession* session = [self.sessionArray objectAtIndex:indexPath.row];
    
    if (session.type == 100) {
        [[KitMsgData sharedInstance] clearGroupMessageTable];
    } else {
        [[Common sharedInstance] deleteAllMessageOfSession:session.sessionId];
        //暂时屏蔽
//            if ([[Chat sharedInstance].componentDelegate respondsToSelector:@selector(deletePublicIMListWihtId:)]) {
//                [[Chat sharedInstance].componentDelegate deletePublicIMListWihtId:session.sessionId];
//            }
    }
    
    //删除cell的时候 顺便取消对人员的订阅
    NSMutableArray *mArr = @[].mutableCopy;
    if (![session.fromId hasPrefix:@"g"] && session.fromId) {
        [mArr addObject:session.fromId];
    }
    [[RestApi sharedInstance] subscribeModifyByAccount:[Chat sharedInstance].getAccount type:@"1" eventType:@"1" publisherUserAccs:mArr didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        NSLog(@"取消订阅成功");
    } didFailLoaded:^(NSError *error, NSString *path) {
        NSLog(@"取消订阅失败");
    }];
    
    [self.sessionArray removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}

#pragma mark - 通知相关
//刷新列表 回到主线程 不需要异步回  刷新有延迟 yuxp
-(void)prepareDisplay {
 
        [self.sessionArray removeAllObjects];
        [self.sessionArray addObjectsFromArray:[[KitMsgData sharedInstance] getMyCustomSession]];
    
        [self setTopSessionLists];
        [Chat sharedInstance].isSessionEdgQueue =NO;
        //        [self.tableView reloadData];
    
    
    NSMutableArray *mArr = @[].mutableCopy;
    for (ECSession *session in self.sessionArray) {
        if (![session.fromId hasPrefix:@"g"] && ![mArr containsObject:session.fromId] && session.fromId && ![session.fromId isEqualToString:[Chat sharedInstance].getAccount] && ![session.fromId isEqualToString:FileTransferAssistant]) {
            [mArr addObject:session.fromId];
        }
    }
    if (mArr.count == 0) return; //如果没有人 则订阅没有意义
    //分组订阅 每组最多100个
    NSArray *arr = [self splitArray:mArr.copy withSubSize:100];
    for (NSArray *subArr in arr) {
        [[RestApi sharedInstance] subscribeModifyByAccount:[Chat sharedInstance].getAccount type:@"0" eventType:@"1" publisherUserAccs:subArr didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            NSLog(@"订阅成功");
        } didFailLoaded:^(NSError *error, NSString *path) {
            NSLog(@"订阅失败");
        }];
    }
    
    DDLogInfo(@"after prepareDisplay SessionViewController");
}

- (NSArray *)splitArray:(NSArray *)array withSubSize:(int)size {
    NSInteger count = array.count % size == 0 ? array.count / size : (array.count / size) + 1;
    NSMutableArray *mArr = @[].mutableCopy;
    for (int i = 0; i < count; i ++) {
        int idx = i * size;
        NSMutableArray *arr = @[].mutableCopy;
        [arr removeAllObjects];
        int j = idx;
        while (i < size * (i + 1) && j < array.count) {
            [arr addObject:array[j]];
            j +=1;
        }
        [mArr addObject:arr.copy];
    }
    return mArr.copy;
}

#pragma mark - 根据sessionID 刷新cell
-(void)prepareDisplayOfSessionId:(NSNotification *)not{
    NSString *sessionId = not.object;
    NSIndexPath *indexPath ;
    for (int i = 0; i<self.sessionArray.count; i++) {
        ECSession *session = self.sessionArray[i];
        if ([session.sessionId isEqualToString:sessionId]) {
            indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            DDLogInfo(@"eagle.刷新cell   sessionid = %@, indexPath = %@",sessionId,indexPath);
            break;
        }
    }
    
    if (indexPath) {
        if (indexPath.row == [self getCurrentTopCession]) {
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }else {
            [self  prepareDisplay];
        }
    }else{
        [self  prepareDisplay];
    }
}

//刷新列表 回到主线程 不需要异步回  刷新有延迟 yuxp
-(void)prepareWithNewDisplay{
    [self.sessionArray removeAllObjects];
    [self.sessionArray addObjectsFromArray:[[KitMsgData sharedInstance] getMyNewCustomSession]];
    
    [self setTopSessionLists];
    [Chat sharedInstance].isSessionEdgQueue =NO;
}
#pragma mark =============================================================
#pragma mark 网络强度
-(void)updateNetWord:(NSNotification*)notification
{
    ECNetworkType netType = (ECNetworkType)[notification.object integerValue];
    // 0:当前无网络 1:WIFI 2:4G 3:3G 4:GPRS 5:LAN类型 6:其他
    [self changeNetStateViewWith:netType];
}
- (NSInteger)getNetState{
//    UIApplication *app =[UIApplication sharedApplication];
//    NSArray *children =[[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
//    int netWorkType = 0;
//    for (id child in children) {
//        if ([child isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
//            netWorkType = [[child valueForKeyPath:@"dataNetworkType"] intValue];
//        }
//    }
    return  [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
//    return (NSInteger)[[[UIApplication sharedApplication]delegate] performSelector:NSSelectorFromString(@"getCurrentNetState")];;
}
///0 未登录 1pc 2mac
-(void)PCLoginOutOrIn:(NSInteger )PCLoginState{
    self.loginState = PCLoginState;
    if (PCLoginState == 1 || PCLoginState == 2 || PCLoginState == 3) {
         [AppModel sharedInstance].isPCLogin = YES;
        [_PCloginView removeFromSuperview];
        _PCloginView = nil;
        
        _PCloginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, kScreenWidth, 45.0f)];
        //        _PCloginView.backgroundColor = [UIColor colorWithRed:1.00f green:0.87f blue:0.87f alpha:1.00f];
        _PCloginView.backgroundColor = [UIColor colorWithHexString:@"#F2F2F2"];
        UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(17, 10, 26, 26)];
        image.image = ThemeImage(@"message_icon_multiplexlogin");
        image.contentMode = UIViewContentModeScaleAspectFit;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, kScreenWidth-55 , 45)];
        label.backgroundColor = [UIColor clearColor];
        
        if (isEnLocalization) {
            label.font =ThemeFontSmall;
        }else{
            label.font = ThemeFontMiddle;
        }
        label.textColor = [UIColor colorWithHexString:@"666666"];
        
        NSString *text = PCLoginState == 1 ? languageStringWithKey(@"PC 容信已登录") : PCLoginState == 2 ? languageStringWithKey(@"Mac 容信已登录") :languageStringWithKey(@"WEB 容信已登录");
        if ([[AppModel sharedInstance].muteState isEqualToString:@"2"]) {
            label.text = text;
        }else {
            label.text = [NSString stringWithFormat:@"%@，%@",text,languageStringWithKey(@"手机通知静音已开启")];
        }
        
        [_PCloginView addSubview:image];
        [_PCloginView addSubview:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickDeviceView:)];
        [self.PCloginView addGestureRecognizer:tap];
        //        self.deviceView.hidden = YES;
        [self.PCloginView addSubview:self.deviceView];
        
        _tableView.tableHeaderView = _PCloginView;
    }else{
         [AppModel sharedInstance].isPCLogin = NO;
        if (_tableView.tableHeaderView == _PCloginView) {
            _tableView.tableHeaderView = nil;
            [_PCloginView removeFromSuperview];
            _PCloginView = nil;
        }
    }
}
// PC登陆
- (void)changePCLoginViewWith:(NSNotification *)notification{
    DDLogInfo(@"notification = %@",notification);
    [self checkPCloginIn];
}
- (void)changeNetStateViewWith:(NSInteger)netWorkType{
    if (netWorkType == 0) {
        [_linkview removeFromSuperview];
        _linkview = nil;

        _linkview = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, kScreenWidth, 45.0f)];
        _linkview.backgroundColor = [UIColor colorWithHexString:@"FFDFDF"];
        
        _linkview.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(networkTap)];
        [_linkview addGestureRecognizer:tap];
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(17, 10, 26, 26)];
        image.image = ThemeImage(@"message_icon_nonetwork");
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, kScreenWidth-55 , 45)];
        label.backgroundColor = [UIColor clearColor];
       
        if (isEnLocalization) {
            label.font = ThemeFontSmall;
        }else{
            label.font = ThemeFontMiddle;
        }
        label.textColor = [UIColor colorWithRed:0.46f green:0.40f blue:0.40f alpha:1.00f];
        label.text = languageStringWithKey(@"当前网络不可用，请检查你的网络设置");
        [_linkview addSubview:image];
        [_linkview addSubview:label];

        _tableView.tableHeaderView = _linkview;
    }else{
        if (_tableView.tableHeaderView == _linkview) {        
            _tableView.tableHeaderView = nil;
            [_linkview removeFromSuperview];
            _linkview = nil;
        }
    }
}

- (void)networkTap {
    NSLog(@"networkTap");
    [self pushViewController:@"WebViewController" withData:@{@"HTMLString":@"network.html"} withNav:YES];
}

-(void)linkSuccess:(NSNotification *)link {
    ECError* error = link.object;
    if (error.errorCode == ECErrorType_NoError) {
        [self updateLoginStates:success];
    } else if (error.errorCode == ECErrorType_Connecting) {
        [self updateLoginStates:linking];
    }else if (error.errorCode == 999998) {
        [self updateLoginStates:relinking];
    }
    else {
        [self updateLoginStates:failed];
    }
}

//kitOnReceiveOfflineCompletion
-(void)onReceiveOfflineStates:(NSNotification*)offlineStates
{
    NSNumber *numOffReciver =(NSNumber *)offlineStates.object;
    NSInteger statues =[numOffReciver integerValue];
    if(statues==0)
    {
        //wangjianbo start 2017/09/26
        [self setTitleWithString:languageStringWithKey(@"消息收取中") withAnimated:YES];
        //wangjianbo end
 
    }else if(statues==1)
    {
        [self performSelector:@selector(setTitleStringSuccess) withObject:nil afterDelay:0.15];

    }else if(statues==2)
    {
        [self performSelector:@selector(setTitleStringSuccess) withObject:nil afterDelay:0.15];
    }
}
- (void)setTitleStringSuccess
{
    [self setTitleWithString:languageStringWithKey(@"消息")withAnimated:NO];

}

-(void)updateLoginStates:(LinkJudge)link {
    
    if (link == success) {
        [self setTitleWithString:languageStringWithKey(@"消息")withAnimated:NO];
        [KitGlobalClass sharedInstance].isLogin=YES;
        
        // hanwei 不传0 yxp 不需要去监测
        [self changeNetStateViewWith:1];

    } else if (link==failed) {
        //wangjianbo start 2017/09/27
        [self setTitleWithString:languageStringWithKey(@"未连接") withAnimated:NO];
        [KitGlobalClass sharedInstance].isLogin=NO;
    } else if(link == linking) {
        [self setTitleWithString:languageStringWithKey(@"连接中...") withAnimated:YES];
    }else if(link == relinking) {
        [self setTitleWithString:languageStringWithKey(@"连接中...") withAnimated:YES];
        //wangjianbo end
    }
    
}

//wwl 刷新沟通界面显示群组信息
- (void)ReloadSessionGroup:(NSNotification *)not{
    NSString* groupId = not.object;
    if (KCNSSTRING_ISEMPTY(groupId)) {
        [self.tableView reloadData];
    }else{
        for (int i = 0; i<_sessionArray.count; i++) {
            
            ECSession* session = [_sessionArray objectAtIndex:i];
            if ([session.sessionId isEqualToString:groupId]) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

#pragma mark SessionViewCellDelegate
-(void)updateListAllData//刷新列表所有的数据
{
    [self prepareDisplay];
}
//add2017yxp9.4
#pragma mark YxpidVerificationAlertDelegate

- (void)verifyRequestSuccess
{
    [self veridyPushNextViewController];
}

#pragma mark  notification

- (void)veridySuccess:(NSNotification *)noti
{
    [self veridyPushNextViewController];
}

#pragma mark  -veridy 需要身份验证的应用跳转
- (void)veridyPushNextViewController
{
    if(self.selectSession && [_sessionArray containsObject:self.selectSession])
    {
        NSRange range = [self.selectSession.sessionId rangeOfString:KOAMessage_sessionIdentifer];
        NSDictionary *oneDic = [NSDictionary dictionary];
        if(range.location !=NSNotFound)
        {
            NSString *oaAppId = [self.selectSession.sessionId substringFromIndex:range.location+range.length];
            oneDic =  [[AppModel sharedInstance] runModuleFunc:@"AppStore" :@"getAppStoreParamsWithAppId: appType:" :@[oaAppId, @(1)]];
        }
        [self pushViewController:@"OAShowDetailVC" withData:@{@"session":self.selectSession,@"oaData":oneDic?oneDic:[NSDictionary dictionary]} withNav:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PostAaCheckNeedVeridyMessage" object:nil];

    }
}
//endyxp
@end
