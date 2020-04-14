//
//  ChatToolView.m
//  ECSDKDemo_OC
//
//  Created by zhangmingfei on 2016/10/18.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatToolView.h"
//系统框架
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
//第三方框架 文本框自适应
#import "NSString+containsString.h"
#pragma mark - zmf 表情云相关 先屏蔽
//#import <BQMM/BQMM.h>

#import "ChatEmojiManager.h"
//照相相关
#import "RX_MLSelectPhotoAssets.h"
#import "RX_MLSelectPhotoPickerViewController.h"
//小视频相关
#import "TakeMovieViewController.h"
#import "YXPCameraViewController.h"
#pragma mark - 语音通话 视频聊天相关
//语音通话相关
//#import "KitCallViewController.h"
//视频聊天相关
//#import "KitVideoViewController.h"
//位置按钮相关
#import "ECLocationViewController.h"
//发送文件相关
#import "RXChooseFilesViewController.h"
#import "AlbumManager.h"
#import "HXFileCacheManager.h"
#import "SendFileData.h"
//自定义的textView  单例模式
#import "chatInputTextView.h"

//获取控制器  做跳转用
#import "UIView+CurrentController.h"
#import "ChatViewController.h"

//获取当前View的controller
#import "UIView+CurrentController.h"

#import "NSString+AES.h"
#import "NSData+Ext.h"

#import "CommonUserTools.h"

#import "DynamicEditViewController.h"
#import "CodecsetViewController.h"
//位置按钮相关
#import "ECLocationViewController.h"
#import "NewLocationViewController.h"
#import "UIImage+deal.h"
#import "ResolutionAndViewModeController.h"

#import "RXWeakProxy.h"
//枚举 对应菜单栏上的三个按钮
typedef enum {
    ToolbarDisplay_None=0,
    ToolbarDisplay_Emoji,   //表情
    ToolbarDisplay_More,    //更多 就是加号
    ToolbarDisplay_Record   //语音
}ToolbarDisplay;

//发文件类型
typedef enum {
    Normal_Type=0,//正常文件
    Secret_Type   //加密文件
}FileType;

#pragma mark - 宏
//录音倒计时开关
#define StartCountDown 1

//键盘弹出视图的高度
#define ToolbarInputViewHeight 50.0f
//点击加号视图的高度
#define ToolbarMoreViewHeight 169.0f*fitScreenWidth
//表情视图的高度
#define ToolbarEmojiViewHeight 216.0f*fitScreenWidth

#pragma mark - zmf 表情云相关 先屏蔽
//#define BQMM_AppKey @"60136eb629984b5d8578cb75a2aba692"
//#define BQMM_AppSecret @"958873a7f8a742c2ad065445d7af1bba"


@interface ChatToolView ()<HPGrowingTextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,TakeMovieViewControllerDelegate,ECLocationViewControllerDelegate/*,MMEmotionCentreDelegate*/,ChooseFileDelegate,CustomEmojiViewDelegate,HXSendFileViewControllerDelegate,UIScrollViewDelegate,NewLocationViewControllerDelegate,RX_TZImagePickerControllerDelegate>

//判断是否是群聊
@property (nonatomic, assign) BOOL isGroup;

//由chatViewController传过来
@property (nonatomic, copy) NSString* sessionId;

//判断是否是阅后即焚
@property (nonatomic, assign) BOOL isBurnAfterRead;

#pragma mark - UI控件
//语音按钮
@property (nonatomic, strong) UIButton *switchVoiceBtn;
//加号按钮
@property (nonatomic, strong) UIButton *moreBtn;
//表情按钮
@property (nonatomic, strong) UIButton *emojiBtn;
//文本输入框
@property (nonatomic, strong) RX_HPGrowingTextView *inputTextView;
//文本输入框背景框
@property (nonatomic, strong) UIImageView *inputMaskImage;
//语音界面
@property (nonatomic, strong) UIView *voiceAnView;



//阅后即焚的删除按钮
@property (nonatomic, strong) UIButton *deleteBurnBtn;
//阅后即焚的图片按钮
@property (nonatomic, strong) UIButton *burnPicBtn;

//按住说话 按钮
@property (nonatomic, strong) UIButton *recordBtn;

//录音计时的label
@property (nonatomic, strong) UILabel *timeLabel;
//按住说话 按钮
@property (nonatomic, strong) UIButton *imgviewBtn;
//麦克风图片框
@property (nonatomic, strong) UIImageView *flameAnimation;
//状态?
@property (nonatomic, strong) UILabel *recordInfoLabel;
//点击加号后出现的那些按钮下面的视图

@property (nonatomic, strong) UIPageControl *moreViewPage;

//菜单栏枚举
@property (nonatomic, assign) ToolbarDisplay toolbarDisplay;
//用户状态枚举
@property (nonatomic, assign) UserState userInputState;
//记录隐藏状态
@property (nonatomic, assign) BOOL ishidden;

//未知的bool值
@property (nonatomic, assign) BOOL isOpenMembersList;

//未知视图的高
@property (nonatomic, assign) CGFloat viewHeight;
//表示删除的字符串
@property (nonatomic, copy) NSString *deleteAtStr;
//光标?????
@property (nonatomic, assign) NSInteger arrowLocation;
//被选择人数组
//@property (nonatomic, strong) NSMutableArray *MemberNickNameGroup;

@property (copy,nonatomic) NSString *memberId;
@property (copy,nonatomic) NSString *memberName;


//录音相关 定时器
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer * startRecordTimer;


//群聊相关
@property (nonatomic, strong) NSMutableArray *selectedList;

//当前群聊成员
@property (nonatomic, strong) NSMutableArray *curMemberList;

////菜单栏本来的frame
//@property (nonatomic, assign) CGRect originalFrame;
//
////有了表情视图后 菜单栏的frame
//@property (nonatomic, assign) CGRect changedFrame;

@property (nonatomic, strong) NSMutableArray *redPacketAccountArr;

//录音相关
@property (nonatomic, assign) BOOL isCanceling; //录音处于松手取消的状态

@property (nonatomic, assign) BOOL isTimeOut;   //录音超过60秒 但是手指还没抬起

// hanwie start-- 回收键盘
@property (nonatomic, assign) BOOL isKeyBoardReceive;
@property (nonatomic, assign) float inputTextViewNewHeight;      //inputTextView变化后的高度
@property (nonatomic, assign) float inputTextViewOriginHeight; //inputTextView最开始的高度
// hanwei end

///用来记录 0.5s内不允许连续@
@property (nonatomic, assign) BOOL canPushAt;
@property (nonatomic,strong) NSTimer *testTimer;

@end

//是否正在通话中
extern bool globalisVoipView;

@implementation ChatToolView {
    dispatch_source_t _stimer;
    
    int hhInt;
    int mmInt;
    int ssInt;
    
    BOOL isMcm;
    FileType _fileType;//文件类型 0、正常 1、加密
    
}

#pragma mark - 初始化方法
- (id)initWithframe:(CGRect)rect andSessionId:(NSString *)sessionId andIsGroup:(BOOL)isGroup {
    if (self = [super initWithFrame:rect]) {
        _canPushAt = YES;
        _sessionId = sessionId;
        _isGroup = isGroup;
        //初始化状态
        _toolbarStatus = ToolbarStatus_None;
        //设置UI
        //        [self setupUI];
        //        dispatch_queue_t addNewMsgQueue = dispatch_queue_create("addNewMsgQueue", NULL);
        //        dispatch_async(addNewMsgQueue, ^{
        //             [self setupUI];
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //
        //            });
        //        });
        [self performSelector:@selector(setupUI) withObject:nil afterDelay:0.0f inModes:@[NSRunLoopCommonModes]];
        
    }
    return self;
}

- (void)chatViewDidAppear {
    //更多的附加功能
    [self createMoreView];
    DDLogInfo(@"eagle.createMoreView --- after");
    //表情界面
    [self createEmojiView];
    DDLogInfo(@"eagle.createEmojiView --- after");
    if (_recordBtn == nil) {
        
        [self changeBurnTypeTo:_isBurnAfterRead];
        DDLogInfo(@"eagle.changeBurnTypeTo --- after");
        CGFloat frame_x = _switchVoiceBtn.right+5.0f;
        _recordBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame_x, 5.0f, _emojiBtn.frame.origin.x-frame_x-5.0f, 38.0f)];
        [_recordBtn setBackgroundColor:RGBA(241, 242, 244, 1) forState:UIControlStateNormal];
        [_recordBtn setBackgroundColor:[UIColor colorWithHexString:@"#CFCFCF"] forState:UIControlStateHighlighted];
        [_recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _recordBtn.titleLabel.font = SystemFontMiddle;
        [_recordBtn setTitle:languageStringWithKey(@"按住 说话") forState:UIControlStateNormal];
        [_recordBtn setTitle:languageStringWithKey(@"松开 结束") forState:UIControlStateHighlighted];
        [self addSubview:_recordBtn];
        
        _recordBtn.layer.borderWidth = 1.0f;
        _recordBtn.layer.cornerRadius = 4;
        _recordBtn.layer.masksToBounds = YES;
        _recordBtn.layer.borderColor = [UIColor colorWithHexString:@"#DBDBDD"].CGColor;
        
        [_recordBtn addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [_recordBtn addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [_recordBtn addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [_recordBtn addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragOutside];
        [_recordBtn addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragInside];
        [_recordBtn addTarget:self action:@selector(recordDragCancel) forControlEvents:UIControlEventTouchCancel];
        _recordBtn.hidden = YES;
        DDLogInfo(@"eagle.changeBurnTypeTo22 --- after");
    }
    
}

#pragma mark - 设置UI
- (void)setupUI {
    //    [[self rac_valuesForKeyPath:@"frame" observer:self] subscribeNext:^(id x) {
    //        DDLogInfo(@"111111 chattoolview.frame.size.width = %f  chattoolview.frame.size.height = %f  self.originY == %f",self.frame.size.width,self.frame.size.height,self.originY);
    //    }];
    DDLogInfo(@"eagle. chattoolview.setupUI");
    self.isCanceling = NO;
    self.isTimeOut = NO;
    
    //  获取@选择人数组
    [self getAtPersons];
    
    _viewHeight = kScreenHeight-kTotalBarHeight;
    //删除字符串
    //    char myBuffer[5] = {'\xe2','\x80','\x85',0,'\x20'};
    //    _deleteAtStr = [NSString stringWithCString:myBuffer encoding:NSUTF8StringEncoding];
    _deleteAtStr = @" ";
    //背景色
    self.backgroundColor = RGBA(241, 242, 244, 1);
    
    
    //聊天的基础功能
    //语音按钮
    _switchVoiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _switchVoiceBtn.tag = ToolbarDisplay_Record;
    [_switchVoiceBtn addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
    
    dispatch_queue_t addNewMsgQueue = dispatch_queue_create("addNewMsgQueue", NULL);
    dispatch_async(addNewMsgQueue, ^{
        //message_icon_voice  message_icon_voice_pressed
        UIImage *image = ThemeImage(@"message_icon_voice");
        UIImage *imageon = ThemeImage(@"message_icon_voice_pressed");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_switchVoiceBtn setImage:image forState:UIControlStateNormal];
            [self->_switchVoiceBtn setImage:imageon forState:UIControlStateHighlighted];
        });
    });
    
    
    _switchVoiceBtn.frame = CGRectMake(5.0f, 9.0f, 31.0f, 31.0f);
    [self addSubview:_switchVoiceBtn];
    
    //加号按钮 (更多)
    _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreBtn addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
    
    dispatch_async(addNewMsgQueue, ^{
        UIImage *image = ThemeImage(@"message_icon_more");
        UIImage *imageon = ThemeImage(@"message_icon_more_pressed");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_moreBtn setImage:image forState:UIControlStateNormal];
            [self->_moreBtn setImage:imageon forState:UIControlStateHighlighted];
        });
    });
    _moreBtn.frame = CGRectMake(self.frame.size.width-36.0f, 9.0f, 31.0f, 31.0f);
    //    _moreBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _moreBtn.tag = ToolbarDisplay_More;
    [self addSubview:_moreBtn];
    
    //表情按钮
    _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _emojiBtn.tag = ToolbarDisplay_Emoji;
    [_emojiBtn addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
    
    dispatch_async(addNewMsgQueue, ^{//message_icon_facialexpression message_icon_facialexpression_pressed
        UIImage *image = ThemeImage(@"message_icon_facialexpression");
        UIImage *imageon = ThemeImage(@"message_icon_facialexpression_pressed");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_emojiBtn setImage:image forState:UIControlStateNormal];
            [self->_emojiBtn setImage:imageon forState:UIControlStateHighlighted];
        });
    });
    
    _emojiBtn.frame = CGRectMake(_moreBtn.frame.origin.x-36.0f, 9.0f, 31.0f, 31.0f);
    [self addSubview:_emojiBtn];
    
    CGFloat frame_x = _switchVoiceBtn.right+5.0f;
    //文本输入框
    _inputTextView = [[RX_HPGrowingTextView alloc]init];
    _inputTextView.frame = CGRectMake(frame_x, 7, _emojiBtn.frame.origin.x-frame_x-5.0f, 25.0f);
    _inputTextView.backgroundColor = [UIColor whiteColor];
    _inputTextView.minNumberOfLines = 1;
    _inputTextView.maxNumberOfLines = 5;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.font = SystemFontLarge;
    _inputTextView.delegate = self;
    _inputTextView.layer.borderWidth = 0.5f;
    _inputTextView.layer.cornerRadius = 4;
    _inputTextView.layer.masksToBounds = YES;
    _inputTextView.layer.borderColor = [UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f].CGColor;
    //    _inputTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _inputTextView.enablesReturnKeyAutomatically = YES;
    [self addSubview:_inputTextView];
    _inputTextViewOriginHeight = _inputTextView.height;
    
    //草稿
    ECSession *session = [[KitMsgData sharedInstance] loadSessionWithID:_sessionId];
    if (session && session.draft &&
        ![session.draft isEqualToString:@""]) {
        _inputTextView.text = session.draft;
    } else {
        _inputTextView.text = nil;
    }
    
    
    //文本输入框背景框
    //    _inputMaskImage = [[UIImageView alloc] initWithImage:[ThemeImage(@"input_txt") stretchableImageWithLeftCapWidth:95.0f topCapHeight:-5.0f]];
    //    _inputMaskImage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    //    _inputMaskImage.frame = CGRectMake(0, 30.0f, _inputView.width, 7.0f);
    //    [_inputView addSubview:_inputMaskImage];
    
    
#pragma mark - zmf 表情云相关 先屏蔽
    //    [[MMEmotionCentre defaultCentre] setAppId:BQMM_AppKey secret:BQMM_AppSecret];
    //    MMTheme * mm = [[MMTheme alloc] init];
    //    mm.navigationBarTintColor = [UIColor colorWithRed:61/255.0 green:198/255.0 blue:124/255.0 alpha:1];
    //    mm.navigationBarColor = [UIColor whiteColor];
    //    //    mm.navigationBarColor = [UIColor colorWithRed:61/255.0 green:198/255.0 blue:124/255.0 alpha:1];
    //    mm.orderBtnColor = [UIColor colorWithRed:61/255.0 green:198/255.0 blue:124/255.0 alpha:1];
    //    [[MMEmotionCentre defaultCentre] setTheme:mm];
    //    [MMEmotionCentre defaultCentre].delegate = self;
    //
    //    //表情云
    //    if(_toolbarDisplay==ToolbarDisplay_None && _isDisplayKeyborad==YES)
    //    {
    //        [_inputTextView becomeFirstResponder];
    //    }else if(_toolbarDisplay==ToolbarDisplay_Emoji){
    //        [_inputTextView becomeFirstResponder];
    //        [[MMEmotionCentre defaultCentre] attachEmotionKeyboardToInput:_inputTextView.internalTextView];
    //    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurMemberListWithNumbers:) name:kNotification_memberChange_Group object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doubleTextCellEndEdit:) name:@"doubleTextCellEndEdit" object:nil];
    //红包控制器发过来的 改变用户输入状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldChangeUserInputState) name:@"shouldChangeUserInputState" object:nil];
    //侧滑手势开始的时候 停止录音
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordVoiceShouldStop) name:@"panGestureShouldBegin" object:nil];
    // hanwei start
    _isKeyBoardReceive = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVoice:) name:@"homeVoice" object:nil];
    
    // hanwei end
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerShouldStart:) name:KNOTIFICATION_onRecordingAmplitude object:nil];
    DDLogInfo(@"eagle. chattoolview.setupUI--end");
}
//接收到通知后调用
-(void)timerShouldStart:(NSNotification*)notification {
    
    if (![self.timer isValid])
    {
        self.timer = [NSTimer timerWithTimeInterval:1.0f target:[RXWeakProxy proxyWithTarget:self] selector:@selector(updateRealtimeLabel) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        [self.timer fire];
    }
}

- (void)updateRealtimeLabel
{
    ssInt +=1;
    
    if (ssInt >= 50 && ssInt <= 60) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
            if (self.isCanceling == NO && StartCountDown == 1) {
                
                [self.delegate voiceViewShouldGoWithString:[NSString stringWithFormat:@"last_%02d",60-ssInt] andRecordInfoLabelText:ssInt == 60?  languageStringWithKey(@"说话时间超长"):languageStringWithKey(@"手指上滑,取消发送") ];
            }
        }
    }
}
-(void)changeCurMemberListWithNumbers:(NSNotification *)not{
    NSString *sessionId = not.object;
    if ([self.sessionId isEqualToString:sessionId]) {
        
        if (self.curMemberList) {
            
            NSArray *alMembers =[KitGroupMemberInfoData getAllmemberInfoWithGroupId:self.sessionId];
            
            [self.curMemberList removeAllObjects];
            for (KitGroupMemberInfoData *groupMember in alMembers) {
                //                if (![groupMember.memberId isEqualToString:[Chat sharedInstance].getAccount]) {
                //                    NSDictionary * info = [[Common sharedInstance].componentDelegate getDicWithId:groupMember.memberId withType:0];
                //                    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:info];
                //                    if (!KCNSSTRING_ISEMPTY(groupMember.memberName)) {
                //                        [userInfo setObject:groupMember.memberName forKey:Table_User_member_name];
                //                    }
                //                    [userInfo setObject:@"1" forKey:@"isVoip"];
                //                    [_curMemberList addObject:userInfo];
                //                }
                
                NSDictionary * info = [[Common sharedInstance].componentDelegate getDicWithId:groupMember.memberId withType:0];
                NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:info];
                if (!KCNSSTRING_ISEMPTY(groupMember.memberName)) {
                    [userInfo setObject:groupMember.memberName forKey:Table_User_member_name];
                }
                [userInfo setObject:@"1" forKey:@"isVoip"];
                [_curMemberList addObject:userInfo];
            }
        }
    }
}

- (void)doubleTextCellEndEdit:(NSNotification *)noti {
    self.toolbarStatus = ToolbarStatus_None;
    [self endEditing:YES];
}

- (void)createEmojiView {
    if(!_emojiView) {
        _emojiView = [CustomEmojiView shardInstance];
        _emojiView.backgroundColor = RGBA(241, 242, 244, 1);
        _emojiView.delegate = self;
        if (isIPhoneX) {
            _emojiView.frame = CGRectMake(0, ToolbarInputViewHeight-IphoneXBottom, self.frame.size.width, ToolbarEmojiViewHeight);
        }else{
            _emojiView.frame = CGRectMake(0, ToolbarInputViewHeight, self.frame.size.width, ToolbarEmojiViewHeight);
        }
        _emojiView.hidden = YES;
        _moreView.hidden = YES;
        [self addSubview:_emojiView];
    }
}

-(void)createMoreView {
    if (_moreView) {
        return;
    }
    
    __block NSMutableArray *imagesArr = [NSMutableArray array];
    __block NSMutableArray *textArr = [NSMutableArray array];
    __block NSMutableArray *selectorArr = [NSMutableArray array];
    NSString *picStr = languageStringWithKey(@"图片");
    NSString *cameraStr =languageStringWithKey(@"拍摄");
    NSString *fileStr =languageStringWithKey(@"文件");
    NSString *collectionStr =languageStringWithKey(@"收藏");
//    NSString *linkStr =languageStringWithKey(@"链接分享");
    NSString *videoStr =languageStringWithKey(@"拍摄");
    NSString *ptStr =languageStringWithKey(@"发送图文");
    NSString *locationStr =languageStringWithKey(@"位置");
    NSString *burnStr =languageStringWithKey(@"阅后即焚");
    if ([self.sessionId isEqualToString:FileTransferAssistant] || [self.sessionId isEqualToString:Common.sharedInstance.getAccount]) {
        if ([Chat sharedInstance].componentDelegate && [[Chat sharedInstance].componentDelegate respondsToSelector:@selector(getChatMoreArrayWithIsGroup:andMembers:completion:)]) {
            NSDictionary *fileTransfer = [[NSDictionary alloc] initWithObjectsAndKeys:FileTransferAssistant, @"FileTransferAssistant", nil];
            self.curMemberList = [NSMutableArray array];
            [_curMemberList addObject:fileTransfer];
            [[Chat sharedInstance].componentDelegate getChatMoreArrayWithIsGroup:_isGroup andMembers:_curMemberList  completion:^(NSArray *myImagesArr,NSArray *myTextArr,NSArray *mySelectorArr) {
                [imagesArr addObjectsFromArray:myImagesArr];
                [textArr addObjectsFromArray:myTextArr];
                [selectorArr addObjectsFromArray:mySelectorArr];
            }];
        } else {
            
            [imagesArr addObjectsFromArray:@[@"im_icon_images", @"im_icon_camera",@"message_btn_file_normal", @"im_icon_camera", @"im_icon_collection"]];
            [textArr addObjectsFromArray:@[picStr, videoStr, fileStr, cameraStr, collectionStr]];
            [selectorArr addObjectsFromArray:@[@"pictureBtnTap:", @"littleVideoBtnTap:", @"document_collaborationBtnTap:", @"cameraBtnTap:", @"collectionBtnTap:"]];
            
        }
    } else {
        //如果用户在代理里实现了方法 就用用户返回的数组 如果没有实现 就用默认的
        if ([Chat sharedInstance].componentDelegate && [[Chat sharedInstance].componentDelegate respondsToSelector:@selector(getChatMoreArrayWithIsGroup:andMembers:completion:)]) {
            if (_isGroup) {
                NSArray *allMembers = [KitGroupMemberInfoData getChatGroupAllMemberInfoWithGroupId:self.sessionId];
                self.curMemberList = [NSMutableArray array];
                for (NSDictionary *groupMember in allMembers) {
                    //                        if (![groupMember[Table_User_account] isEqualToString:[Chat sharedInstance].getOneAccount]) {
                    //                            NSDictionary * info = [[Common sharedInstance].componentDelegate getDicWithId:groupMember[Table_User_account] withType:0];
                    //                            NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:info];
                    //                            [userInfo setObject:groupMember[Table_User_member_name] forKey:Table_User_member_name];
                    //                            [userInfo setObject:@"1" forKey:@"isVoip"];
                    //                            [_curMemberList addObject:userInfo];
                    //                        }
                    
                    //keven修改
                    NSDictionary * info = [[Common sharedInstance].componentDelegate getDicWithId:groupMember[Table_User_account] withType:0];//account
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:info];
                    [userInfo setObject:groupMember[Table_User_member_name] forKey:Table_User_member_name];//member_name
                    [userInfo setObject:@"1" forKey:@"isVoip"];
                    [_curMemberList addObject:userInfo];
                }
                DDLogInfo(@"eagle.getChatMoreArrayWithIsGroup -- before");
                [[Chat sharedInstance].componentDelegate getChatMoreArrayWithIsGroup:_isGroup andMembers:self.curMemberList  completion:^(NSArray *myImagesArr,NSArray *myTextArr,NSArray *mySelectorArr) {
                    [imagesArr addObjectsFromArray:myImagesArr];
                    [textArr addObjectsFromArray:myTextArr];
                    [selectorArr addObjectsFromArray:mySelectorArr];
                    
                }];
                DDLogInfo(@"eagle.getChatMoreArrayWithIsGroup -- after");
                
            } else {
                NSString *callerNickname = [[Common sharedInstance] getOtherNameWithPhone:self.sessionId];
                NSString *callerNumber = self.sessionId;
                NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"callType",callerNumber,@"caller",callerNickname,@"nickname",[NSNumber numberWithInt:EOutgoing],@"callDirect",nil];
                NSMutableArray *members = [NSMutableArray array];
                [members addObject:dict];
                
                [[Chat sharedInstance].componentDelegate getChatMoreArrayWithIsGroup:_isGroup andMembers:members  completion:^(NSArray *myImagesArr,NSArray *myTextArr,NSArray *mySelectorArr) {
                    [imagesArr addObjectsFromArray:myImagesArr];
                    [textArr addObjectsFromArray:myTextArr];
                    [selectorArr addObjectsFromArray:mySelectorArr];
                    
                }];
            }
            
        } else {
            if(_isGroup)
            {
                //暂时屏蔽群投票
                [imagesArr addObjectsFromArray:@[@"im_icon_images",@"im_icon_camera",@"message_btn_file_normal",@"im_icon_pic_txt",@"message_btn_position_normal"]];
                [textArr addObjectsFromArray:@[picStr,videoStr,fileStr,ptStr,locationStr]];
                [selectorArr addObjectsFromArray:@[@"pictureBtnTap:",@"littleVideoBtnTap:",@"document_collaborationBtnTap:",@"pictureWhithTextBtnTap:",@"locationBtnTap:"]];
                
            }else
            {
                [imagesArr addObjectsFromArray:@[@"im_icon_images",@"im_icon_camera",@"message_btn_file_normal",@"im_icon_pic_txt",@"message_btn_position_normal",@"im_icon_burn"]];
                [textArr addObjectsFromArray:@[picStr,videoStr,fileStr,ptStr,locationStr,burnStr]];
                [selectorArr addObjectsFromArray:@[@"pictureBtnTap:",@"littleVideoBtnTap:",@"document_collaborationBtnTap:",@"pictureWhithTextBtnTap:",@"locationBtnTap:",@"burnAfterReadBtnTap:"]];
                
                
            }
        }
    }
    
    //        dispatch_async(dispatch_get_main_queue(), ^{
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    if (isIPhoneX) {
        _moreView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, ToolbarInputViewHeight-IphoneXBottom, self.frame.size.width, ToolbarMoreViewHeight)];
    }else{
        _moreView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, ToolbarInputViewHeight, self.frame.size.width, ToolbarMoreViewHeight)];
    }
    _moreView.delegate = self;
    _moreView.scrollEnabled = YES;
    _moreView.pagingEnabled = YES;
    _moreView.tag = EXPRESSION_SCROLL_VIEW_TAG;
    _moreView.showsHorizontalScrollIndicator = NO;
    
    NSInteger cou = imagesArr.count;
    NSInteger scrollCount = ceil(1.0*cou/8);
    if (imagesArr.count <= 8) {
        _moreView.contentSize = CGSizeMake(self.frame.size.width, ToolbarMoreViewHeight);
        
    }else{
        _moreView.contentSize = CGSizeMake(self.frame.size.width * scrollCount, ToolbarMoreViewHeight);
    }
    _moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _moreView.backgroundColor = RGBA(241, 242, 244, 1);
    [self addSubview:_moreView];
    DDLogInfo(@"eagle.addSubview -- after");
    if (scrollCount>1) {
        _moreViewPage = [[UIPageControl alloc]initWithFrame:CGRectMake(0, _moreView.height-18, _moreView.width, 18)];
        [_moreView addSubview:_moreViewPage];
        _moreViewPage.numberOfPages = scrollCount;
        _moreViewPage.pageIndicatorTintColor = RGBA(187, 187, 187, 1);
        _moreViewPage.currentPageIndicatorTintColor = RGBA(153, 153, 153, 1);
    }
    
    for (NSInteger index = 0; index<imagesArr.count; index++) {
        
        UIButton *extenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        SEL selector = NSSelectorFromString(selectorArr[index]);
        
        //如果用户实现了点击方法 就走用户的 没有就走默认的
        if ([AppModel sharedInstance].appModelDelegate && [[AppModel sharedInstance].appModelDelegate respondsToSelector:selector]) {
            
            [extenBtn addTarget:[AppModel sharedInstance].appModelDelegate action:selector forControlEvents:UIControlEventTouchUpInside];
        } else {
            
            [extenBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        }
        
        dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
        dispatch_async(defaultQueue, ^{
            UIImage *image = ThemeImage(imagesArr[index]);
            dispatch_async(dispatch_get_main_queue(), ^{
                 [extenBtn setImage:image forState:UIControlStateNormal];
            });
        });
//        [extenBtn setImage:ThemeImage(imagesArr[index]) forState:UIControlStateNormal];
        //        [extenBtn setImage:ThemeImage(imageLight) forState:UIControlStateHighlighted];
        
        int left = (width - 200*fitScreenWidth)/5 + ((width - 50*fitScreenWidth*4)/5 + 50*fitScreenWidth)*index;
        int top = 10.0f*fitScreenWidth;
        NSInteger t = index/4; //行数 0 1 2 3 4 ....
        NSInteger d = fmod(index, 4); //第几个 0.1.2.3
        NSInteger scrollC = ceil(1.0*(index + 1)/8);
        
        left = (width - 200*fitScreenWidth)/5*(d+1) + 50 *fitScreenWidth*d + (scrollC-1)*width;
        if ((t%2) == 1) {
            // 第二行
            top = 10.0f*fitScreenWidth+25 + 1*50.0f*fitScreenWidth;
        } else {
            // 第一行
            top = 10.0f*fitScreenWidth;
        }
        
        extenBtn.frame = CGRectMake(left, top, 50.0f*fitScreenWidth, 50.0f*fitScreenWidth);
        [_moreView addSubview:extenBtn];
        
        UILabel *btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(extenBtn.frame.origin.x-5, extenBtn.frame.origin.y + extenBtn.frame.size.height+5.0f*fitScreenWidth, extenBtn.frame.size.width+10, 15.0f*fitScreenWidth)];
        btnLabel.textColor = [UIColor grayColor];
        btnLabel.font = SystemFontSmall;
        
        btnLabel.textAlignment = NSTextAlignmentCenter;
        [_moreView addSubview:btnLabel];
        btnLabel.text = textArr[index];
        
    }
    DDLogInfo(@"eagle.createMoreView -- after");
    
    _moreView.hidden=YES;
    //        });
    //    });
    
}

#pragma mark - 更多页面页标
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _moreView) {
        _moreViewPage.left = scrollView.contentOffset.x;
        _moreViewPage.currentPage = scrollView.contentOffset.x/_moreView.width;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"eagle === scrollViewDidEndDecelerating");
}

#pragma mark - 阅后即焚相关
- (void)changeBurnTypeTo:(BOOL)burn{
    if (!_deleteBurnBtn) {
        _deleteBurnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBurnBtn.frame = _moreBtn.bounds;
        _deleteBurnBtn.backgroundColor = self.backgroundColor;
        [_deleteBurnBtn setImage:ThemeImage(@"message_secretchat_icon_close") forState:UIControlStateNormal];
        [_deleteBurnBtn setImage:ThemeImage(@"message_secretchat_icon_close_pressed") forState:UIControlStateHighlighted];
        [_deleteBurnBtn addTarget:self action:@selector(deleteBurnBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (!_burnPicBtn) {
        _burnPicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _burnPicBtn.frame = _moreBtn.bounds;
        _burnPicBtn.backgroundColor = self.backgroundColor;
        _burnPicBtn.center = CGPointMake(_emojiBtn.width/2, _emojiBtn.height/2);
//        _burnPicBtn.layer.cornerRadius = _burnPicBtn.width/2;
        [_burnPicBtn setImage:ThemeImage(@"message_secretchat_icon_picture") forState:UIControlStateNormal];
        [_burnPicBtn setImage:ThemeImage(@"message_secretchat_icon_picture_pressed") forState:UIControlStateHighlighted];
        [_burnPicBtn addTarget:self action:@selector(pictureBurnBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (burn) {
        if (_toolbarDisplay == ToolbarDisplay_Record) {
            [self switchToolbarDisplay:_switchVoiceBtn];
        }else if (_toolbarDisplay == ToolbarDisplay_Emoji){
            [self switchToolbarDisplay:_emojiBtn];
        }else if (_toolbarDisplay == ToolbarDisplay_More){
            //            [self switchToolbarDisplay:_moreBtn];
        }
        [self endOperation];
        //        [_inputTextView resignFirstResponder];
        
        [_emojiBtn addSubview:_burnPicBtn];
        [_moreBtn addSubview:_deleteBurnBtn];
        
        //message_secretchat_icon_voice  message_secretchat_icon_voice_pressed
        [_switchVoiceBtn setImage:ThemeImage(@"message_secretchat_icon_voice") forState:UIControlStateNormal];
        [_switchVoiceBtn setImage:ThemeImage(@"message_secretchat_icon_voice_pressed") forState:UIControlStateHighlighted];
        
        [_recordBtn setBackgroundColor:RGBA(241, 242, 244, 1) forState:UIControlStateNormal];
        [_recordBtn setBackgroundColor:[UIColor colorWithHexString:@"#F3CCBB"] forState:UIControlStateHighlighted];
        [_recordBtn setTitleColor:[UIColor colorWithHexString:@"#F3780B"] forState:UIControlStateNormal];
        _recordBtn.layer.borderColor = [UIColor colorWithHexString:@"#F3780B"].CGColor;
        
        //        _inputMaskImage.image = [ThemeImage(@"burn_input_txt") stretchableImageWithLeftCapWidth:95.0f topCapHeight:-5.0f];
        //        [_imgviewBtn setBackgroundImage:ThemeImage(@"burn_press_talk_icon") forState:UIControlStateNormal];
        //        [_imgviewBtn setBackgroundImage:ThemeImage(@"burn_press_talk_icon_on") forState:UIControlStateHighlighted];
        //        _flameAnimation.highlightedAnimationImages = [NSArray arrayWithObjects:
        //                                                     ThemeImage(@"burn_press_talk_icon_on_01.png"),
        //                                                     ThemeImage(@"burn_press_talk_icon_on_02.png"),
        //                                                     ThemeImage(@"burn_press_talk_icon_on_03.png"),nil];
    }else{
        //        [_inputTextView resignFirstResponder];
        
        [_burnPicBtn removeFromSuperview];
        [_deleteBurnBtn removeFromSuperview];
        
        [_switchVoiceBtn setImage:ThemeImage(@"message_icon_voice") forState:UIControlStateNormal];
        [_switchVoiceBtn setImage:ThemeImage(@"message_icon_voice_pressed") forState:UIControlStateHighlighted];
        
        [_recordBtn setBackgroundColor:RGBA(241, 242, 244, 1) forState:UIControlStateNormal];
        [_recordBtn setBackgroundColor:[UIColor colorWithHexString:@"#CFCFCF"] forState:UIControlStateHighlighted];
        [_recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _recordBtn.layer.borderColor = [UIColor colorWithHexString:@"#DBDBDD"].CGColor;
        
        //        [self endOperation];
        
        //        _inputMaskImage.image = [ThemeImage(@"input_txt") stretchableImageWithLeftCapWidth:95.0f topCapHeight:-5.0f];
        //        [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon") forState:UIControlStateNormal];
        //        [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon_on") forState:UIControlStateHighlighted];
        //        _flameAnimation.highlightedAnimationImages = [NSArray arrayWithObjects:
        //                                                     ThemeImage(@"press_talk_icon_on_01"),
        //                                                     ThemeImage(@"press_talk_icon_on_02"),
        //                                                     ThemeImage(@"press_talk_icon_on_03"),nil];
    }
}

- (void)pictureBurnBtnTap:(id)sender {
    //点击tableview，结束输入操作
    [self endBurnPicture];
    
    NSArray *items = @[languageStringWithKey(@"拍照"), languageStringWithKey(@"从相册中选择")];
    MSSBrowseActionSheet *sheet = [[MSSBrowseActionSheet alloc] initWithTitleArray:items cancelButtonTitle:languageStringWithKey(@"取消") didSelectedBlock:^(NSInteger index) {
        if (index == MSSBrowseTypePhotoAlbum) {
            [self cameraBtnTap:nil];
        } else if (index == MSSBrowseTypePhotos) {
            [self gotoSelectPhoto];
        }
    }];

    [sheet showInView:[UIApplication sharedApplication].delegate.window];
   
}

//点击tableview，结束输入操作
-(void)endBurnPicture {
    
    if (_toolbarDisplay == ToolbarDisplay_Record) {
        return;
    }
    _toolbarDisplay = ToolbarDisplay_None;
    self.toolbarStatus = ToolbarStatus_None;
    if (_isDisplayKeyborad || self.timer != nil) {
        [self endEditing:YES];
    }
    
}

- (void)deleteBurnBtnAction:(UIButton *)btn{
    _isBurnAfterRead = NO;
    [self changeBurnTypeTo:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeIsBurnAfterRead" object:nil userInfo:@{@"isBurnAfterRead":@NO}];
}

#pragma mark - 根据按钮改变工具栏的显示布局
//zmf add
- (void)switchToolbarDisplay:(id)sender{
    if (self.isOutGroup == 1) {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"不在群组内，不可发消息")];
        return;
    } else if (self.isOutGroup == 2) {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"群不存在，不可发消息")];
        return;
    }
    _isKeyBoardReceive = YES;
    UIButton *button = (UIButton*)sender;
    if (button && button == _moreBtn) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(showReminderView)]) {
            [self.delegate performSelector:@selector(showReminderView)];
        }
    }
    if (_inputTextView.hidden) {
        _inputTextView.hidden = NO;
    }
    
    //如果上次显示内容为录音，更改显示
    if (_toolbarDisplay == ToolbarDisplay_Record) {
        _recordBtn.hidden = YES;
    }
    //如果两次按钮的相同触发输入文本
    if (button.tag == _toolbarDisplay) {
        self.toolbarStatus = ToolbarStatus_Input;
        _isKeyBoardReceive = NO;
        _toolbarDisplay = ToolbarDisplay_None;
        [_inputTextView becomeFirstResponder];
        
    } else {
        if (button.tag == ToolbarDisplay_More) {
            self.toolbarStatus = ToolbarStatus_More;
            //显示出附件功能页面
        } else if (button.tag == ToolbarDisplay_Emoji) {
            self.toolbarStatus = ToolbarStatus_Emoji;
            
        } else if (button.tag == ToolbarDisplay_Record) {
            self.toolbarStatus = ToolbarStatus_Record;
            //显示录音按钮，并返回默认的布局
            if(_ishidden){
                _inputTextView.hidden = YES;
                _recordBtn.hidden = NO;
                _ishidden = NO;
            }else{
                _inputTextView.hidden = YES;
                _ishidden = YES;
                _recordBtn.hidden = NO;
            }
        }
        _toolbarDisplay = (ToolbarDisplay)button.tag;
        if (_inputTextView.isFirstResponder) {
            [_inputTextView resignFirstResponder];
        }
        [self toolbarDisplayChangedWithStautas:self.toolbarStatus];
    }
    //更换按钮上显示的图片
    if (_toolbarDisplay == ToolbarDisplay_Record) {
        if (_isBurnAfterRead) {//message_secretchat_icon_keyboard message_secretchat_icon_picture_pressed
            [_switchVoiceBtn setImage:ThemeImage(@"message_secretchat_icon_keyboard") forState:UIControlStateNormal];
            [_switchVoiceBtn setImage:ThemeImage(@"message_secretchat_icon_picture_pressed") forState:UIControlStateHighlighted];
        }else{
            [_switchVoiceBtn setImage:ThemeImage(@"message_icon_keyboard") forState:UIControlStateNormal];
            [_switchVoiceBtn setImage:ThemeImage(@"message_icon_keyboard_pressed") forState:UIControlStateHighlighted];
        }
        [_emojiBtn setImage:ThemeImage(@"message_icon_facialexpression") forState:UIControlStateNormal];
        [_emojiBtn setImage:ThemeImage(@"message_icon_facialexpression_pressed") forState:UIControlStateHighlighted];
    } else if (_toolbarDisplay == ToolbarDisplay_Emoji) {
        if (_isBurnAfterRead) {
            [_switchVoiceBtn setImage:ThemeImage(@"message_secretchat_icon_voice") forState:UIControlStateNormal];
            [_switchVoiceBtn setImage:ThemeImage(@"message_secretchat_icon_voice_pressed") forState:UIControlStateHighlighted];
        }else{
            [_switchVoiceBtn setImage:ThemeImage(@"message_icon_voice") forState:UIControlStateNormal];
            [_switchVoiceBtn setImage:ThemeImage(@"message_icon_voice_pressed") forState:UIControlStateHighlighted];
        }
        [_emojiBtn setImage:ThemeImage(@"message_icon_keyboard") forState:UIControlStateNormal];
        [_emojiBtn setImage:ThemeImage(@"message_icon_keyboard_pressed") forState:UIControlStateHighlighted];
        [_moreBtn setImage:ThemeImage(@"message_icon_more") forState:UIControlStateNormal];
        [_moreBtn setImage:ThemeImage(@"message_icon_more_pressed") forState:UIControlStateHighlighted];
    } else if (_toolbarDisplay == ToolbarDisplay_More){
        if (_isBurnAfterRead) {
            [_switchVoiceBtn setImage:ThemeImage(@"message_secretchat_icon_voice") forState:UIControlStateNormal];
            [_switchVoiceBtn setImage:ThemeImage(@"message_secretchat_icon_voice_pressed") forState:UIControlStateHighlighted];
        }else{
            [_switchVoiceBtn setImage:ThemeImage(@"message_icon_voice") forState:UIControlStateNormal];
            [_switchVoiceBtn setImage:ThemeImage(@"message_icon_voice_pressed") forState:UIControlStateHighlighted];
        }
        [_emojiBtn setImage:ThemeImage(@"message_icon_facialexpression") forState:UIControlStateNormal];
        [_emojiBtn setImage:ThemeImage(@"message_icon_facialexpression_pressed") forState:UIControlStateHighlighted];
    }else{
        if (_isBurnAfterRead) {
            [_switchVoiceBtn setImage:ThemeImage(@"message_secretchat_icon_voice") forState:UIControlStateNormal];
            [_switchVoiceBtn setImage:ThemeImage(@"message_secretchat_icon_voice_pressed") forState:UIControlStateHighlighted];
        }else{
            [_switchVoiceBtn setImage:ThemeImage(@"message_icon_voice") forState:UIControlStateNormal];
            [_switchVoiceBtn setImage:ThemeImage(@"message_icon_voice_pressed") forState:UIControlStateHighlighted];
        }
        [_emojiBtn setImage:ThemeImage(@"message_icon_facialexpression") forState:UIControlStateNormal];
        [_emojiBtn setImage:ThemeImage(@"message_icon_facialexpression_pressed") forState:UIControlStateHighlighted];
    }
}


//zmf end
#pragma mark - 键盘通知相关
- (void)registerKeyboardNotification {
    //键盘改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)shouldChangeUserInputState {
    _userInputState = 0;
    if (_stimer) {
        [[ChatMessageManager sharedInstance] sendUserState:UserState_None to:self.sessionId];
    }
    
}

- (BOOL)textViewIsFirstResponder {
    return _inputTextView.isFirstResponder;
}

//TextView失去第一响应者
- (void)textViewResignFirstResponder {
    [_inputTextView resignFirstResponder];
}
- (void)textViewBecomeFirstResponder
{
    [_inputTextView becomeFirstResponder];
    
}
// 键盘的frame更改监听函数
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    /// eagle 不监听会议中的键盘
    if ([AppModel sharedInstance].isInConf) {
        return;
    }
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    _keyBoardH = endFrame.size.height;
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
        //显示键盘
        _toolbarDisplay = ToolbarDisplay_None;
        _isDisplayKeyborad = YES;
        self.toolbarStatus = ToolbarStatus_Input;
    }else if (endFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
        //隐藏键盘
        _isDisplayKeyborad = NO;
        if (self.toolbarStatus == ToolbarStatus_Input) {
            self.toolbarStatus = ToolbarStatus_None;
        }
    }
    if (self.userInteractionEnabled && self.superview.userInteractionEnabled) {
        [self toolbarDisplayChangedWithStautas:self.toolbarStatus];
    }
    
    
}
- (void)keyboardWillHide:(NSNotification*)aNotification
{
    if (_isKeyBoardReceive == NO) {
        self.toolbarStatus = ToolbarStatus_None;
        [self endEditing:YES];
    }
}

//这里需要做两步  1 emojiview和moreview的显示和隐藏
//2 改变自己的frame和传代理出去改变tableview的frame
- (void)toolbarDisplayChangedWithStautas:(ToolbarStatus)toolbarStatus {
    self.toolbarStatus = toolbarStatus;
    
    //这一步主要用于 复制文字在其他app里粘贴后  键盘的代理方法会自己走
    if (toolbarStatus == ToolbarStatus_Input && !self.inputTextView.isFirstResponder && !_resignFirstResponder) {
        [self.inputTextView becomeFirstResponder];
    }
    
    //toolbarY 默认为屏幕高减去 ToolbarInputViewHeight
    //之后随着状态的不同  减去对应的视图的高度(EmojiView/MoreView/keyBoardH)
    CGFloat toolbarY = 0;
    if ([UIApplication sharedApplication].statusBarFrame.size.height == 40 && !isIPhoneX) {
        toolbarY = kScreenHeight-ToolbarInputViewHeight-kTotalBarHeight-20-IphoneXBottom;
    }else{
        toolbarY = kScreenHeight-ToolbarInputViewHeight-kTotalBarHeight-IphoneXBottom;
    }
    
    //toolbarHeight 默认为ToolbarInputViewHeight
    //之后随着状态的不同  加上对应的视图的高度(EmojiView/MoreView/keyBoardH)
    CGFloat toolbarHeight = IphoneXBottom + ToolbarInputViewHeight;
    
    //hogrowingtextview改变的高度
    float diff = (_inputTextViewNewHeight - _inputTextViewOriginHeight);
    
    switch (self.toolbarStatus) {
        case ToolbarStatus_None:
            _moreView.hidden = YES;
            _emojiView.hidden = YES;
            break;
            
        case ToolbarStatus_Emoji:
            toolbarY -= ToolbarEmojiViewHeight;
            toolbarHeight += ToolbarEmojiViewHeight;
            _moreView.hidden = YES;
            _emojiView.hidden = NO;
            break;
            
        case ToolbarStatus_More:
            toolbarY -= ToolbarMoreViewHeight;
            toolbarHeight += ToolbarMoreViewHeight;
            _moreView.hidden = NO;
            _emojiView.hidden = YES;
            break;
            
        case ToolbarStatus_Record://frame恒定
            //textview改变的高度设置为0
            diff = 0;
            _moreView.hidden = YES;
            _emojiView.hidden = YES;
            break;
            
        case ToolbarStatus_Input:
            //iphonx键盘弹起时  不需要加上底部的间距  键盘已经算过了
            //上面加过了 这里减去
            toolbarY -= _keyBoardH - IphoneXBottom;
            toolbarHeight += _keyBoardH;
            _moreView.hidden = YES;
            _emojiView.hidden = YES;
            
            if (_inputTextView.hidden) {
                _inputTextView.hidden = NO;
                _recordBtn.hidden = YES;
                [_switchVoiceBtn setImage:ThemeImage(@"message_icon_voice") forState:UIControlStateNormal];
                [_switchVoiceBtn setImage:ThemeImage(@"message_icon_voice_pressed") forState:UIControlStateHighlighted];
            }
            break;
            
        default:
            _moreView.hidden = YES;
            _emojiView.hidden = YES;
            break;
    }
    
    CGRect newFrame = CGRectMake(0, toolbarY-diff, kScreenWidth, toolbarHeight+diff);
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.25 delay:0.0f options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.frame = newFrame;
            [strongSelf refreshEmojiViewAndMoreViewFrame];
        }
    } completion:nil];
    
    //用代理去改变tableView的frame  并且滚动到最后一条
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeTableViewFrameWithFrame:andDuration:)]) {
        [self.delegate changeTableViewFrameWithFrame:newFrame andDuration:0.25];
    }
    
}


#pragma mark - HPGrowingTextViewDelegate
//根据新的高度来改变当前的页面的的布局
- (void)growingTextView:(RX_HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    _inputTextViewNewHeight = height;
    [self toolbarDisplayChangedWithStautas:self.toolbarStatus];
}

- (BOOL)growingTextView:(RX_HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (growingTextView.text.length > 1024) {
        
        NSString * aString = [growingTextView.text stringByReplacingCharactersInRange:range withString:text];
        _inputTextView.text = [aString substringToIndex:1024];
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"最多可输入1024个字")];
        return NO;
    }
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        [self sendTextMessage];
        if (growingTextView.text.length > 1024) {
            return NO;
        }else{
            growingTextView.text = @"";
            
        }
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    //＠ 中文的@符号 手写可以复现
    if (range.length == 0 || ([self.sessionId hasPrefix:@"g"] && ([text isEqualToString:@"@"] || [text isEqualToString:@"＠"]))) {
        _userInputState = UserState_Write;
        if ([self.sessionId hasPrefix:@"g"] && ([text isEqualToString:@"@"] || [text isEqualToString:@"＠"])) {
            _isOpenMembersList = YES;
            _arrowLocation = range.location + 1;
            
            
            //让chatViewController去push @某个群成员的时候调用
            if (_canPushAt) {
                [self doPushViewController:@"HYTAtGroupMemberViewController" withData:self.sessionId withNav:YES];
                _canPushAt = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.canPushAt = YES;
                });
            }
        }
    }else{
        /**
         *  删除时候判断删除的是标志符则删除整个名字
         */
        NSString *frontStr = [growingTextView.text substringToIndex:range.location+range.length];
        // hanwei start
        if ([self.sessionId hasPrefix:@"g"] && [frontStr hasSuffix:@" "] && [text isEqualToString:@""]) {
            NSRange startRange = [growingTextView.text rangeOfString:@"@" options:NSBackwardsSearch range:NSMakeRange(0, range.location)];
            if (startRange.length == 0) {
                return YES;
            }
            ///处理下 有可能是用户输入过空格 李晓杰
            NSString *rangeText = [growingTextView.text substringFromIndex:startRange.location];
            NSArray *array = [rangeText componentsSeparatedByString:@" "];
            ///看里面如果有超过2个空格 说明不是删除@
            if (array.count != 2) {
                return YES;
            }
            
            self.memberName = nil;
            growingTextView.text = [growingTextView.text stringByReplacingCharactersInRange:NSMakeRange(startRange.location, range.location-startRange.location+range.length) withString:@""];
            
            return NO;
        }
    }
    
    return YES;
}


- (void)growingTextViewDidChange:(RX_HPGrowingTextView *)growingTextView{
    
    // DDLogInfo(@"%@",growingTextView.text);
    if (growingTextView.text.length > 0) {
        if (_userInputState != UserState_Write) {
            _userInputState = UserState_Write;
            if (_stimer) {
                [[ChatMessageManager sharedInstance] sendUserState:_userInputState to:self.sessionId];
            }
        }
    }
    if (growingTextView.text.length > 1024) {
        _inputTextView.text = [growingTextView.text substringToIndex:1024];
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"最多可输入1024个字")];
        return;
    }
}

- (BOOL)growingTextViewShouldBeginEditing:(RX_HPGrowingTextView *)growingTextView {
    if (self.originY > kScreenHeight * 0.7) { //为了判断键盘没有弹起的情况 isFirstresponse 不好用
        if (self.isOutGroup == 1) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"不在群组内，不可发消息")];
            return NO;
        } else if (self.isOutGroup == 2) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"群不存在，不可发消息")];
            return NO;
        }
        return YES;
    }
    return YES;
}

//获取焦点
- (void)growingTextViewDidBeginEditing:(RX_HPGrowingTextView *)growingTextView{
    
    _userInputState = UserState_Write;
    if (_stimer) {
        //如果是自己给自己发消息，就不需要了
        if (![self.sessionId isEqualToString:Common.sharedInstance.getAccount]) {
            [[ChatMessageManager sharedInstance] sendUserState:_userInputState to:self.sessionId];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"menuControllerShouldSetMenuItemsNil" object:nil];
    //获取@选择人数组
    [self getAtPersons];
    
    /**
     *  拼接被@人字符串
     */
    if ([self.sessionId hasPrefix:@"g"] && [_inputTextView.text myContainsString:@"@"] && _isOpenMembersList) {
        _isOpenMembersList = NO;
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@",_inputTextView.text];
        
        if (_inputTextView.text.length < _arrowLocation) {
            _arrowLocation -= 1;
        }
        // hanwei
        if(!KCNSSTRING_ISEMPTY(self.memberName)){
            //            [string insertString:@" " atIndex:_arrowLocation];
            
            [string insertString:_deleteAtStr atIndex:_arrowLocation];
            [string insertString:self.memberName atIndex:_arrowLocation];
        }
        _inputTextView.text = [NSString stringWithFormat:@"%@",string];
        //        _inputTextView.text = [NSString stringWithFormat:@"%@%@",string,_deleteAtStr];
    }
    //    _inputMaskImage.image = [ThemeImage(@"input_txt") stretchableImageWithLeftCapWidth:95.0f topCapHeight:-5.0f];
}

//失去焦点
- (void)growingTextViewDidEndEditing:(RX_HPGrowingTextView *)growingTextView{
    _userInputState = UserState_None;
    if (_stimer) {
        [[ChatMessageManager sharedInstance] sendUserState:_userInputState to:self.sessionId];
    }
    //    _inputMaskImage.image = [ThemeImage(@"input_txt") stretchableImageWithLeftCapWidth:95.0f topCapHeight:-5.0f];
    
}

#pragma mark - 接收到消息后开启定时器
- (void)startTimer{
    
    __weak typeof(self) weakself = self;
    if (_stimer == 0) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _stimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_stimer,dispatch_walltime(NULL, 0), 10.0*NSEC_PER_SEC, 0); //10秒执行
        dispatch_source_set_event_handler(_stimer, ^{
            if (weakself && self->_userInputState!=UserState_None) {
                [[ChatMessageManager sharedInstance] sendUserState:self->_userInputState to:weakself.sessionId];
            }
            
        });
        dispatch_resume(_stimer);
    }
    
}


#pragma mark - 录音操作
//按下操作
-(void)recordButtonTouchDown {
    
    NSNumber *number = [[AppModel sharedInstance] runModuleFunc:@"VidyoHelper" :@"IsVidyoingWhenOtherOperate" :nil];
    if (number.integerValue == 1) {
        return;
    }
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    self.userInteractionEnabled = NO;
    //震动后开始录制
    _startRecordTimer =[NSTimer scheduledTimerWithTimeInterval:0.3 target:[RXWeakProxy proxyWithTarget:self] selector:@selector(startRecordVoice) userInfo:nil repeats:NO];
    
}
//zmf add
-(void)startRecordVoice
{
    BOOL isAgreeRecodePermission = [KKAuthorizedManager isMicrophoneAuthorized_ShowAlert:YES];
    
    if (!isAgreeRecodePermission) {
        /// eagle 没权限就关闭震动和声音 d
        [[Common sharedInstance] stopAVAudio];
        [[Common sharedInstance] stopShakeSoundVibrate];
        return;
    }
    //用代理 让控制器停止播放
    if (self.delegate && [self.delegate respondsToSelector:@selector(stopPlayVoice)]) {
        [self.delegate stopPlayVoice];
    }
    
    static int seedNum = 0;
    if(seedNum >= 1000)
        seedNum = 0;
    seedNum++;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *file = [NSString stringWithFormat:@"tmp%@%03d.amr", currentDateStr, seedNum];
    
    ECVoiceMessageBody * messageBody = [[ECVoiceMessageBody alloc] initWithFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:file] displayName:file];
    
    
    _userInputState = UserState_Record;
    if (_stimer) {
        [[ChatMessageManager sharedInstance] sendUserState:_userInputState to:self.sessionId];
    }
    
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    __weak __typeof(self)weakSelf = self;
    
    [[ECDevice sharedInstance].messageManager startVoiceRecording:messageBody error:^(ECError *error, ECVoiceMessageBody *messageBody) {
        
        if (error.errorCode == ECErrorType_RecordTimeOut) {
            //发送媒体类型消息
            // [weakSelf recordButtonTouchUpOutside];
            [weakSelf sendMediaMessage:messageBody];
            weakSelf.userInteractionEnabled = NO;
            
            if ([weakSelf.timer isValid]){
                [weakSelf.timer invalidate];
                weakSelf.timer = nil;
            }
            if ([_startRecordTimer isValid]) {
                [_startRecordTimer invalidate];
                _startRecordTimer = nil;
            }
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
                [weakSelf.delegate voiceViewShouldGoWithString:@"back" andRecordInfoLabelText:@""];
            }
            
            [_recordBtn setTitle:languageStringWithKey(@"按住 说话") forState:UIControlStateHighlighted];
            [_recordBtn setBackgroundColor:RGBA(241, 242, 244, 1) forState:UIControlStateHighlighted];
            
            weakSelf.isTimeOut = YES;
            
        }
    }];
    
    
    self.userInteractionEnabled = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
        [self.delegate voiceViewShouldGoWithString:@"front" andRecordInfoLabelText:languageStringWithKey(@"手指上滑,取消发送")];
    }
    
    //    _recordInfoLabel.text = @"手指上滑,取消发送";
    
}
//按钮外抬起操作
-(void)recordButtonTouchUpOutside {
    self.isCanceling = NO;
    [_recordBtn setTitle:languageStringWithKey(@"按住 说话") forState:UIControlStateNormal];
    [_recordBtn setBackgroundColor:[UIColor colorWithHexString:@"#CFCFCF"] forState:UIControlStateHighlighted];
    [_recordBtn setTitle:languageStringWithKey(@"松开 结束") forState:UIControlStateHighlighted];
    _userInputState = UserState_None;
    if (_stimer) {
        [[ChatMessageManager sharedInstance] sendUserState:_userInputState to:self.sessionId];
    }
    
    if ([self.timer isValid]){
        [self.timer invalidate];
        self.timer = nil;
    }
    if ([_startRecordTimer isValid]) {
        [_startRecordTimer invalidate];
        _startRecordTimer = nil;
    }
    [_flameAnimation stopAnimating];
    if (_isBurnAfterRead) {
        [_imgviewBtn setBackgroundImage:ThemeImage(@"burn_press_talk_icon") forState:UIControlStateNormal];
        [_imgviewBtn setBackgroundImage:ThemeImage(@"burn_press_talk_icon_on") forState:UIControlStateHighlighted];
    }else{
        [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon") forState:UIControlStateNormal];
        [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon_on") forState:UIControlStateHighlighted];
    }
    
    hhInt=0;
    ssInt=-1;
    mmInt=0;
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager stopVoiceRecording:^(ECError *error, ECVoiceMessageBody *messageBody) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.isTimeOut = NO;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
            [strongSelf.delegate voiceViewShouldGoWithString:@"back" andRecordInfoLabelText:@""];
        }
    }];
    
    self.userInteractionEnabled = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
        [self.delegate voiceViewShouldGoWithString:@"back" andRecordInfoLabelText:@""];
    }
    [_recordBtn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
-(void)disMissViewStopRecode
{
    self.isCanceling = NO;
    self.isTimeOut = NO;
    [_flameAnimation stopAnimating];
    if (_isBurnAfterRead) {
        [_imgviewBtn setBackgroundImage:ThemeImage(@"burn_press_talk_icon") forState:UIControlStateNormal];
        [_imgviewBtn setBackgroundImage:ThemeImage(@"burn_press_talk_icon_on") forState:UIControlStateHighlighted];
    }else{
        [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon") forState:UIControlStateNormal];
        [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon_on") forState:UIControlStateHighlighted];
    }
    
    if ([self.timer isValid]){
        [self.timer invalidate];
        self.timer = nil;
    }
    if ([_startRecordTimer isValid]) {
        [_startRecordTimer invalidate];
        _startRecordTimer = nil;
    }
    
    _timeLabel.text=@"00:00";
    _recordInfoLabel.text=languageStringWithKey(@"按住说话");
    hhInt=0;
    ssInt=-1;
    mmInt=0;
    
    [[ECDevice sharedInstance].messageManager stopVoiceRecording:^(ECError *error, ECVoiceMessageBody *messageBody) {
    }];
    
    self.userInteractionEnabled = YES;
}
- (void)stopVoice:(NSNotification *)noti {
    
    self.isCanceling = NO;
    [_recordBtn setTitle:languageStringWithKey(@"按住 说话") forState:UIControlStateNormal];
    [_recordBtn setBackgroundColor:[UIColor colorWithHexString:@"#CFCFCF"] forState:UIControlStateHighlighted];
    [_recordBtn setTitle:languageStringWithKey(@"松开 结束") forState:UIControlStateHighlighted];
    _userInputState = UserState_None;
    if (_stimer) {
        [[ChatMessageManager sharedInstance] sendUserState:_userInputState to:self.sessionId];
    }
    
    [_flameAnimation stopAnimating];
    if (_isBurnAfterRead) {
        [_imgviewBtn setBackgroundImage:ThemeImage(@"burn_press_talk_icon") forState:UIControlStateNormal];
        [_imgviewBtn setBackgroundImage:ThemeImage(@"burn_press_talk_icon_on") forState:UIControlStateHighlighted];
    }else{
        [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon") forState:UIControlStateNormal];
        [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon_on") forState:UIControlStateHighlighted];
    }
    
    if ([self.timer isValid]){
        [self.timer invalidate];
        self.timer = nil;
    }
    if ([_startRecordTimer isValid]) {
        [_startRecordTimer invalidate];
        _startRecordTimer = nil;
    }
    
    
    //    _timeLabel.text=@"00:00";
    //    _recordInfoLabel.text=@"按住说话";
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
    //        [self.delegate voiceViewShouldGoWithString:@"" andRecordInfoLabelText:@"按住说话"];
    //    }
    
    
    hhInt=0;
    ssInt=-1;
    mmInt=0;
    
    self.userInteractionEnabled = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
        self.toolbarStatus = ToolbarStatus_None;
        [self.delegate voiceViewShouldGoWithString:@"back" andRecordInfoLabelText:@""];
    }
    
    ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager stopVoiceRecording:^(ECError *error, ECVoiceMessageBody *messageBody) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.isTimeOut = NO;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
            self.toolbarStatus = ToolbarStatus_None;
            [strongSelf.delegate voiceViewShouldGoWithString:@"back" andRecordInfoLabelText:@""];
        }
        if (error.errorCode == ECErrorType_NoError) {
            
            
        } else if  (error.errorCode == ECErrorType_RecordTimeTooShort) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"录音时间过短")];
            if ([self.timer isValid]) {
                [self.timer invalidate];
                self.timer = nil;
            }
            [[ECDevice sharedInstance].messageManager stopVoiceRecording:nil];
            //            _timeLabel.text=@"00:00";
            //            _recordInfoLabel.text=@"按住说话";
            self->hhInt=0;
            self->ssInt=-1;
            self->mmInt=0;
            self.userInteractionEnabled = YES;
        }else if (error.errorCode == ECErrorType_RecordStoped) {

            if ([self.timer isValid]) {
                [self.timer invalidate];
                self.timer = nil;
            }
            [[ECDevice sharedInstance].messageManager stopVoiceRecording:^(ECError *error, ECVoiceMessageBody *messageBody) {
            }];
            self.userInteractionEnabled = YES;
            [weakSelf.flameAnimation stopAnimating];
            [weakSelf.imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon") forState:UIControlStateNormal];
            [weakSelf.imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon_on") forState:UIControlStateHighlighted];
            
            //            _timeLabel.text=@"00:00";
            //            _recordInfoLabel.text=@"按住说话";
            self->hhInt=0;
            self->ssInt=-1;
            self->mmInt=0;
        }
        
    }];
    
}
//按钮内抬起操作
-(void)recordButtonTouchUpInside {
    
    self.isCanceling = NO;
    [_recordBtn setTitle:languageStringWithKey(@"按住 说话") forState:UIControlStateNormal];
    [_recordBtn setBackgroundColor:[UIColor colorWithHexString:@"#CFCFCF"] forState:UIControlStateHighlighted];
    [_recordBtn setTitle:languageStringWithKey(@"松开 结束") forState:UIControlStateHighlighted];
    _userInputState = UserState_None;
    if (_stimer) {
        [[ChatMessageManager sharedInstance] sendUserState:_userInputState to:self.sessionId];
    }
    
    [_flameAnimation stopAnimating];
    if (_isBurnAfterRead) {
        [_imgviewBtn setBackgroundImage:ThemeImage(@"burn_press_talk_icon") forState:UIControlStateNormal];
        [_imgviewBtn setBackgroundImage:ThemeImage(@"burn_press_talk_icon_on") forState:UIControlStateHighlighted];
    }else{
        [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon") forState:UIControlStateNormal];
        [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon_on") forState:UIControlStateHighlighted];
    }
    
    if ([self.timer isValid]){
        [self.timer invalidate];
        self.timer = nil;
    }
    if ([_startRecordTimer isValid]) {
        [_startRecordTimer invalidate];
        _startRecordTimer = nil;
    }
    
    
    //    _timeLabel.text=@"00:00";
    //    _recordInfoLabel.text=@"按住说话";
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
    //        [self.delegate voiceViewShouldGoWithString:@"" andRecordInfoLabelText:@"按住说话"];
    //    }
    
    
    hhInt=0;
    ssInt=-1;
    mmInt=0;
    
    self.userInteractionEnabled = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
        [self.delegate voiceViewShouldGoWithString:@"back" andRecordInfoLabelText:@""];
    }
    
    ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager stopVoiceRecording:^(ECError *error, ECVoiceMessageBody *messageBody) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.isTimeOut = NO;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
            [strongSelf.delegate voiceViewShouldGoWithString:@"back" andRecordInfoLabelText:@""];
        }
        if (error.errorCode == ECErrorType_NoError) {
            
            [strongSelf sendMediaMessage:messageBody];
            
        } else if  (error.errorCode == ECErrorType_RecordTimeTooShort) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"录音时间过短")];
            if ([self.timer isValid]) {
                [self.timer invalidate];
                self.timer = nil;
            }
            [[ECDevice sharedInstance].messageManager stopVoiceRecording:nil];
            hhInt=0;
            ssInt=-1;
            mmInt=0;
            self.userInteractionEnabled = YES;
        }else if (error.errorCode == ECErrorType_RecordStoped) {
            
            
            if ([self.timer isValid]) {
                [self.timer invalidate];
                self.timer = nil;
            }
            [[ECDevice sharedInstance].messageManager stopVoiceRecording:^(ECError *error, ECVoiceMessageBody *messageBody) {
            }];
            self.userInteractionEnabled = YES;
            [_flameAnimation stopAnimating];
            [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon") forState:UIControlStateNormal];
            [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon_on") forState:UIControlStateHighlighted];
            
            //            _timeLabel.text=@"00:00";
            //            _recordInfoLabel.text=@"按住说话";
            hhInt=0;
            ssInt=-1;
            mmInt=0;
        }
        
    }];
    
}

-(void)recordDragCancel{
    
    //    [self disMissViewStopRecode];
    //    [_flameAnimation stopAnimating];
    //    if (_isBurnAfterRead) {
    //        [_imgviewBtn setBackgroundImage:ThemeImage(@"burn_press_talk_icon") forState:UIControlStateNormal];
    //        [_imgviewBtn setBackgroundImage:ThemeImage(@"burn_press_talk_icon_on") forState:UIControlStateHighlighted];
    //    }else{
    //        [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon") forState:UIControlStateNormal];
    //        [_imgviewBtn setBackgroundImage:ThemeImage(@"press_talk_icon_on") forState:UIControlStateHighlighted];
    //    }
    self.isCanceling = NO;
    if ([self.timer isValid]){
        [self.timer invalidate];
        self.timer = nil;
    }
    if ([_startRecordTimer isValid]) {
        [_startRecordTimer invalidate];
        _startRecordTimer = nil;
    }
    
    //    _timeLabel.text=@"00:00";
    //    _recordInfoLabel.text=@"按住说话";
    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
        [self.delegate voiceViewShouldGoWithString:@"back" andRecordInfoLabelText:@""];
    }
    hhInt=0;
    ssInt=-1;
    mmInt=0;
    self.userInteractionEnabled = YES;
    [_recordBtn setTitle:languageStringWithKey(@"按住 说话") forState:UIControlStateNormal];
    [_recordBtn setBackgroundColor:[UIColor colorWithHexString:@"#CFCFCF"] forState:UIControlStateHighlighted];
    [_recordBtn setTitle:languageStringWithKey(@"松开 结束") forState:UIControlStateHighlighted];
    
}
//手指划出按钮
-(void)recordDragOutside {
    self.isCanceling = YES;
    if (self.isTimeOut == NO) {
        
        [_recordBtn setTitle:languageStringWithKey(@"松开 取消") forState:UIControlStateNormal];
        
        [_recordBtn setBackgroundColor:[UIColor colorWithHexString:@"#CFCFCF"] forState:UIControlStateHighlighted];
        [_recordBtn setTitle:languageStringWithKey(@"松开 结束") forState:UIControlStateHighlighted];
        //    _recordInfoLabel.text = @"松开手指,取消发送";
        if (self.delegate && [self.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
            [self.delegate voiceViewShouldGoWithString:@"cancel" andRecordInfoLabelText:languageStringWithKey(@"松开手指,取消发送")];
        }
    }
}

//手指划入按钮
-(void)recordDragInside {
    //    _recordInfoLabel.text = @"手指上滑,取消发送";
    //    if (!self.timer) {
    //        _timeLabel.text=@"00:00";
    //        _recordInfoLabel.text=@"按住说话";
    //        hhInt=0;
    //        ssInt=-1;
    //        mmInt=0;
    //        [_flameAnimation stopAnimating];
    //    }
    self.isCanceling = NO;
    if (self.isTimeOut == NO && ssInt <50) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(voiceViewShouldGoWithString:andRecordInfoLabelText:)]) {
            [self.delegate voiceViewShouldGoWithString:@"front" andRecordInfoLabelText:languageStringWithKey(@"手指上滑,取消发送")];
        }
        [_recordBtn setTitle:languageStringWithKey(@"按住 说话") forState:UIControlStateNormal];
        //        self.userInteractionEnabled = YES;
        
    }
}

//侧滑手势开始的时候 停止录音
- (void)recordVoiceShouldStop {
    [self recordButtonTouchUpInside];
}

//zmf end


#pragma mark - 图片按钮点击事件

-(void)pictureBtnTap:(id)sender {
    //点击tableview，结束输入操作
    //    [self endOperation];
    [self gotoSelectPhoto];
    return;
    if (!IsHengFengTarget) {
        [self gotoSelectPhoto];
    }else{
        UIActionSheet *sheet;
        // 判断是否支持相机
        NSString *cancelStr = languageStringWithKey(@"取消");
        NSString *picStr = languageStringWithKey(@"拍照");
        NSString *photoStr = languageStringWithKey(@"从相册选择");
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelStr destructiveButtonTitle:nil otherButtonTitles:picStr,photoStr, nil];
            sheet.tag = 255;
        }else {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelStr destructiveButtonTitle:nil otherButtonTitles:photoStr, nil];
            sheet.tag = 256;
        }
        [sheet showInView:self];
    }
    
}


#pragma mark actionsheet delegate
-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex == buttonIndex) {
        return;
    }
    NSNumber *number = nil;
    if (actionSheet.tag == 255) {
        switch (buttonIndex) {
            case 0:    // 相机
                // hanwei fix
                if (IsHengFengTarget) {
                    number = [[AppModel sharedInstance] runModuleFunc:@"VidyoHelper" :@"IsVidyoingWhenOtherOperate" :nil];
                    if(number.integerValue ==1){
                        return;
                    }
                }
                
                [self cameraBtnTap:nil];
                break;
            case 1:    // 相册
            {
                [self gotoSelectPhoto];
            }
                break;
        }
    } else if (actionSheet.tag == 256) {
        [self gotoSelectPhoto];
    } else if (actionSheet.tag == 257) {
        if ([[actionSheet buttonTitleAtIndex:buttonIndex]isEqualToString:languageStringWithKey(@"语音通话")]) {
            [self callBtnTap:nil];
        }else if ([[actionSheet buttonTitleAtIndex:buttonIndex]isEqualToString:languageStringWithKey(@"视频通话")]) {
            [self videoBtnTap:nil];
        }
    }
}
#pragma mark - 选择图片 RX_TZImagePickerController
- (void)gotoSelectPhoto{
    // 最多选取的图片个数
    NSInteger MaxImageCount = 9;
    // 每行显示的图片个数
    NSInteger columnNumber = 4;
    
    RX_TZImagePickerController *imagePickerVc = [[RX_TZImagePickerController alloc] initWithMaxImagesCount:MaxImageCount columnNumber:columnNumber delegate:self pushPhotoPickerVc:YES];
    //    pragma mark - 个性化设置，这些参数都可以不传，此时会走默认设置
    
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowTakeVideo = NO;   // 在内部显示拍视频按
    imagePickerVc.videoMaximumDuration = 10; // 视频最大拍摄时间
    [imagePickerVc setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }];
    
    // imagePickerVc.photoWidth = 1000;
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }];
    
    
    // 3. 设置是否可以选择视频/图片/原图
    //阅后即焚模式下 暂时 不支持发gif和视频
    imagePickerVc.allowPickingVideo = _isBurnAfterRead ?NO :YES;
    imagePickerVc.allowPickingGif = _isBurnAfterRead ?NO :YES;
    
    imagePickerVc.allowPickingMultipleVideo = _isBurnAfterRead ?NO :YES; // 是否可以多选视频
    imagePickerVc.allowPickingOriginalPhoto = YES;
    // 设置竖屏下的裁剪尺寸
    NSInteger left = 30;
    NSInteger widthHeight = kScreenWidth - 2 * left;
    NSInteger top = (kScreenHeight - widthHeight) / 2;
    imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = YES;
    [self doPresentViewController:imagePickerVc];
    
    
}

// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 你可以通过一个asset获得原图，通过这个方法：[[RX_TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(RX_TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    for (PHAsset *phasset in assets) {
        [self afterGetGifImage:phasset isSelectOriginalPhoto:isSelectOriginalPhoto];
    }
    
    
}
// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(RX_TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(PHAsset *)asset{
    NSLog(@"animatedImage = %@",animatedImage);
    [self calulateImageFileSize:animatedImage];
    [self afterGetGifImage:asset isSelectOriginalPhoto:YES ];
    
}
// If user picking a video, this callback will be called.
// 如果用户选择了一个视频，下面的handle会被执行
- (void)imagePickerController:(RX_TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset{
    NSLog(@"coverImage = %@ ",coverImage);
}
-(void)afterGetGifImage:(PHAsset *)asset isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    NSArray *resourceList = [PHAssetResource assetResourcesForAsset:asset];
    NSArray *newReSourceList;
    if (resourceList.count > 1) {
        newReSourceList = [NSArray arrayWithObject:resourceList.firstObject];
    }
    
    [newReSourceList.count > 0 ?newReSourceList:resourceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAssetResource *resource = obj;
        PHAssetResourceRequestOptions *option = [[PHAssetResourceRequestOptions alloc] init];
        option.networkAccessAllowed = YES;
        if ([resource.uniformTypeIdentifier isEqualToString:@"com.compuserve.gif"]) {
            NSLog(@"gif大爷");
            // 首先,需要获取沙盒路径
            //            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            // 拼接图片名为resource.originalFilename的路径
            
            NSDateFormatter* formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
            NSString* fileName = [NSString stringWithFormat:@"%@.gif", [formater stringFromDate:[NSDate date]]];
            NSString* path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
            
            //            NSString *imageFilePath = [path stringByAppendingPathComponent:resource.originalFilename];
            
            NSString *imageFilePath = path;
            __block NSData *data = [[NSData alloc] init];
            WS(weakSelf);
            [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:[NSURL fileURLWithPath:imageFilePath]  options:option completionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"error:%@",error);
                    if(error.code == -1){//文件已存在
                        data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imageFilePath]];
                        ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imageFilePath displayName:imageFilePath.lastPathComponent];
                        //发送媒体类型消息
                        [self sendMediaMessage:mediaBody];
                    }
                    //NSLog(@"data%@",data);
                    //                    if (completion) completion(data,nil,NO);
                } else {
                    data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imageFilePath]];
                    //NSLog(@"data%@",data);
                    //                    if (completion) completion(data,nil,NO);
                    
                    ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imageFilePath displayName:imageFilePath.lastPathComponent];
                    //发送媒体类型消息
                    [weakSelf sendMediaMessage:mediaBody];
                }
            }];
            
        }else if ([resource.uniformTypeIdentifier isEqualToString:@"com.apple.quicktime-movie"] && asset.mediaType == PHAssetMediaTypeImage) {
            
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            };
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                UIImage *resultImage = [UIImage imageWithData:imageData];
                NSString *imagePath = [self saveToDocumentWithNoThum:resultImage];
                ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
                //发送媒体类型消息
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendMediaMessage:mediaBody];
                });
            }];
        }
        else if ([resource.uniformTypeIdentifier containsString:@"movie"] || [resource.uniformTypeIdentifier containsString:@"mpeg"]){
            NSLog(@"视频");
            NSLog(@"resource = %@",resource);
            
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            options.networkAccessAllowed = true;
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                if ([asset isKindOfClass:[AVURLAsset class]]) {
                    AVURLAsset* urlAsset = (AVURLAsset*)asset;
                    NSNumber *size;
                    [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                    NSLog(@"size is %f",[size floatValue]/(1024.0*1024.0)); //size is 43.703005
                    
                    [self onSendUserVideoUrl:urlAsset.URL];
                    
                    //                    NSString *localID = resource.assetLocalIdentifier;
                    //                    NSURL *url = urlAsset.URL;
                    //                    NSArray *temp = [localID componentsSeparatedByString:@"/"];
                    //                    NSString *uploadVideoFilePath = nil;
                    //                    if (temp.count > 0) {
                    //                        NSString *assetID = temp[0];
                    //                        NSString *ext = url.pathExtension;
                    //                        if (assetID && ext) {
                    //                            uploadVideoFilePath = [NSString stringWithFormat:@"assets-library://asset/asset.%@?id=%@&ext=%@", ext, assetID, ext];
                    //                        }
                    //                    }
                    
                    
                }}];
        }
        else{
            NSLog(@"jepg大爷");
            if (isSelectOriginalPhoto) {
                [self fetchImageWithAsset:asset imageBlock:^(NSData *imageData, NSDictionary *info) {
                    UIImage *photo = [UIImage imageWithData:imageData];
                    NSString *imagePath = [self saveToDocumentWithNoThum:photo];
                    ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
                    //发送媒体类型消息
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self sendMediaMessage:mediaBody];
                    });
                }];
            }else{
                [[RX_TZImageManager manager] getPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    if (!isDegraded) {
                        NSString *imagePath = [self saveToDocument:photo];
                        ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
                        //发送媒体类型消息i
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self sendMediaMessage:mediaBody];
                        });
                    }
                }];
            }
        }
    }];
}
- (void)fetchImageWithAsset:(PHAsset *)mAsset imageBlock:(void(^)(NSData *imageData,NSDictionary *info))imageBlock {
    
    [[PHImageManager defaultManager] requestImageDataForAsset:mAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        // 直接得到最终的 NSData 数据
        if (imageBlock) {
            imageBlock(imageData,info);
        }
    }];
}
- (void)calulateImageFileSize:(UIImage *)image {
    NSData *data = UIImagePNGRepresentation(image);
    if (!data) {
        data = UIImageJPEGRepresentation(image, 0.7);
    }
    double dataLength = [data length] * 1.0;
    NSArray *typeArray = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB",@"ZB",@"YB"];
    NSInteger index = 0;
    while (dataLength > 1024) {
        dataLength /= 1024.0;
        index ++;
    }
    NSLog(@"image = %.3f %@",dataLength,typeArray[index]);
}
// eagle 下面的方法不用了
//去选择照片
- (void)gotoSelectPhoto2 {
    // fixbug by liyijun 2017/08/08
    // 访问相册受限时添加提示语
    if (IsHengFengTarget) { // 容信添加相册权限判断
        if (![CommonUserTools userPhotosAuthorizationForAlert]) { // 用户未受权
            DDLogInfo(@"用户未受权相册访问权限");
            return;
        }
    }
    
    RX_MLSelectPhotoPickerViewController *imagePicker = [[RX_MLSelectPhotoPickerViewController alloc] init];
    
    imagePicker.status =  PickerViewShowStatusCameraRoll;
    imagePicker.minCount = 9;
    //让控制器去弹出
    [self doPresentViewController:imagePicker];
    [imagePicker show];
    imagePicker.callBack = ^(NSArray *imageSelects){
        
        dispatch_queue_t systemQueue =dispatch_queue_create("systemImageQueue", NULL);
        for (RX_MLSelectPhotoAssets *asset in imageSelects) {
            
            dispatch_async(systemQueue, ^{
                
                NSURL *imageURL = asset.asset.defaultRepresentation.url;
                NSString* ext = imageURL.pathExtension.lowercaseString;
                
                if ([ext isEqualToString:@"gif"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self saveGifToDocument:imageURL];
                    });
                } else {
                    //2017yxp7月28
                    
                    NSString *imagePath = nil;
                    
                    if(isSendOriginImageData)
                    {
                        NSData *imgData = [NSData getSelectImageData:asset.asset];
                        if(!imgData)
                        {
                            return ;
                        }
                        imagePath = [NSString saveImageDataToFilePath:imgData];
                        
                    }else
                    {
                        UIImage *orgImage = [RX_MLSelectPhotoPickerViewController getImageWithImageObj:asset];
                        imagePath = [self saveToDocument:orgImage];
                    }
                    
                    ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
                    //发送媒体类型消息
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self sendMediaMessage:mediaBody];
                    });
                    
                }
            });
            
            
        }
    };
}

/**
 *@brief 照相按钮
 */
- (void)cameraBtnTap:(id)sender {
    //点击tableview，结束输入操作
    [self endOperation];
    
    if(IsHengFengTarget && !_isBurnAfterRead) {
        NSNumber *number = [[AppModel sharedInstance] runModuleFunc:@"VidyoHelper" :@"IsVidyoingWhenOtherOperate" :nil];
        if(number.integerValue ==1){
            return;
        }
        YXPCameraViewController *cameraView = [[YXPCameraViewController alloc]init];
        cameraView.recordTime = 15;
        cameraView.promptTitle = languageStringWithKey(@"轻触拍照，按住摄像");
        cameraView.takeBlock = ^(id selectItem){
            
            if([selectItem isKindOfClass:[NSURL class]]) {
                //视频url
                [self onSendUserVideoUrl:selectItem];
            } else {
                //图片
                UIImage *orgImage =(UIImage *) selectItem;
                if(!orgImage) {
                    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"相机聚焦失败")];
                    return ;
                }
                NSString *imagePath = [self saveToDocument:orgImage];
                ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
                //发送媒体类型消息
                [self sendMediaMessage:mediaBody];
            }
        };
        
        [self doPresentViewController:cameraView];
        return;
    }
    
    //相机权限受限提示
    if (![CommonUserTools userCameraAuthorizationForAlert]) {
        return;
    }
    
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    if(iOS8)
    {
        imagePicker.modalPresentationStyle=UIModalPresentationCurrentContext;
    }
    
#if 1
    //只照相
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
#else
    //支持视频功能
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
    imagePicker.videoMaximumDuration = 30;
#endif
    //未允许的状态不能打开拍照页面
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self doPresentViewController:imagePicker];
                });
            }
        }];
        return;
    }
    [self doPresentViewController:imagePicker];
}

#pragma Mark - 文件小助手
/**
 *@brief 收藏
 */
- (void)collectionBtnTap:(id)sender {
    /**
     这里是收藏的界面，该界面在个人中心插件里，回调获取
     */
    if ([[Chat sharedInstance].componentDelegate respondsToSelector:@selector(getCollectionViewControllerWithData:)]) {
        UIViewController *vc = [[Chat sharedInstance].componentDelegate getCollectionViewControllerWithData:@{@"forwardAcount":self.sessionId, @"from":@"IM_PUSH"}];
        RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:vc];
        //让chatViewController去模态
        [self doPresentViewController:nav];
    }
}
/**
 *@brief 链接
 */
- (void)previewBtnTap:(id)sender {
    /**
     这里是点击链接进去智能提取的界面，该界面在朋友圈插件里，回调获取，
     */
    if ([[Chat sharedInstance].componentDelegate respondsToSelector:@selector(sendWebLinkViewControllerWithDic:)]) {
        UIViewController *vc = [[Chat sharedInstance].componentDelegate sendWebLinkViewControllerWithDic:@{@"sessionId":self.sessionId}];
        RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:vc];
        //让chatViewController去模态
        [self doPresentViewController:nav];
    }
    
}


//保存图片到本地
-(void)saveGifToDocument:(NSURL *)srcUrl {
    
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset) {
        
        if (asset != nil) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *imageBuffer = (Byte*)malloc((unsigned long)rep.size);
            NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:(unsigned long)rep.size error:nil];
            NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
            
            NSDateFormatter* formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
            NSString* fileName =[NSString stringWithFormat:@"%@.gif", [formater stringFromDate:[NSDate date]]];
            NSString* filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
            
            [imageData writeToFile:filePath atomically:YES];
            
            ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:filePath displayName:filePath.lastPathComponent];
            //发送媒体类型消息
            [self sendMediaMessage:mediaBody];
            
        } else {
        }
    };
    
    ALAssetsLibrary* assetLibrary = [[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:srcUrl
                  resultBlock:resultBlock
                 failureBlock:^(NSError *error){
                 }];
}
- (NSString *)saveToDocumentWithNoThum:(UIImage *)image {
    return [image saveToDocument];
}
- (NSString *)saveToDocument:(UIImage *)image {
    return [image saveToDocumentAndThum];
}
///根据最大宽度高度，返回对应比例的size
- (CGSize)fixSizeWithImage:(UIImage *)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight{
    CGSize size;
    CGFloat imageW = image.size.width;
    CGFloat imageH = image.size.height;
    CGFloat fitW = imageW / maxWidth;
    CGFloat fitH = imageH / maxHeight;
    if (fitW > 1 || fitH > 1) {//宽或高超过比例
        CGFloat fit = fitW > fitH ? fitW : fitH;
        size = CGSizeMake(imageW / fit , imageH / fit);
    }else{
        size = CGSizeMake(imageW,imageH);
    }
    return size;
}
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        // we will convert it to mp4 format
        NSURL *mp4 = [self convertToMp4:videoURL videoPathCallback:nil];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                // DDLogInfo(@"failed to remove file, error:%@.", error);
            }
        }
        
        NSString *mp4Path = [mp4 relativePath];
        ECVideoMessageBody *mediaBody = [[ECVideoMessageBody alloc] initWithFile:mp4Path displayName:mp4Path.lastPathComponent];
        [self sendMediaMessage:mediaBody];
        
    } else {
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        NSString* ext = imageURL.pathExtension.lowercaseString;
        
        if ([ext isEqualToString:@"gif"]) {
            [self saveGifToDocument:imageURL];
        } else {
            NSString *imagePath = [self saveToDocument:orgImage];
            ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
            //发送媒体类型消息
            [self sendMediaMessage:mediaBody];
            
        }
        
    }
}

#pragma mark 保存音视频文件
- (NSURL *)convertToMp4:(NSURL *)movUrl videoPathCallback:(void (^)(NSString *sandBoxFilepath))videoPathCallback {
    
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset
                                                                               presetName:AVAssetExportPresetMediumQuality];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSString* fileName = [NSString stringWithFormat:@"%@.mp4", [formater stringFromDate:[NSDate date]]];
        NSString* path = [NSString stringWithFormat:@"file:///private%@",[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]];
        mp4Url = [NSURL URLWithString:path];
        !videoPathCallback?:videoPathCallback(mp4Url.relativePath);
        
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    // DDLogInfo(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    //DDLogInfo(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    //DDLogInfo(@"completed.");
                } break;
                default: {
                    // DDLogInfo(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            //DDLogInfo(@"timeout.");
        }
        
        if (wait) {
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    return [aImage fixOrientation];
}

#pragma mark - 小视频按钮点击事件
- (void)littleVideoBtnTap:(id)sender{
    NSNumber *number = [[AppModel sharedInstance] runModuleFunc:@"VidyoHelper" :@"IsVidyoingWhenOtherOperate" :nil];
    if(number.integerValue ==1){
        return;
    }
    // 判断是否支持相机
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"您的设备不支持相机")];
        return;
    }
    //点击tableview，结束输入操作
    [self endOperation];
    
    //相机权限受限提示
    if (![CommonUserTools userCameraAuthorizationForAlert]) {
        return;
    }
    
    TakeMovieViewController *TMVC = [[TakeMovieViewController alloc]init];
    TMVC.frameNum = 20;
    TMVC.cameraTime = 15;
    TMVC.delegate = self;
    RXBaseNavgationController *nav = [[RXBaseNavgationController alloc] initWithRootViewController:TMVC];
    //让chatViewController去模态
    [self doPresentViewController:nav];
    
}

#pragma mark TakeMovieViewControllerDelegate
- (void)onSendImage:(UIImage *)image{
    NSString *imagePath = [self saveToDocumentWithNoThum:image];
    ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
    //发送媒体类型消息
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendMediaMessage:mediaBody];
    });
    
}

-(void)onSendUserVideoUrl:(NSURL *)videoURL{
    
    /*
     发送视频的步骤：
        1.先将视频文件转存到沙盒目录，再调api开始发送，UI展示。如果视频过大，转存的步骤耗时，体验不好
        2.优化后先展示UI，然后转存视频到沙盒，转存完成后再调api发送，发送完成更新数据
     */
//    NSString *relativePath = [videoURL relativePath];
//    [SVProgressHUD show];
    WS(weakSelf)
    NSURL *mp4 = [self convertToMp4:videoURL videoPathCallback:^(NSString *sandBoxFilepath) {
        [weakSelf sendPlaceholderVideoMessage:videoURL sandBoxFilepath:sandBoxFilepath];
    }];
//    [SVProgressHUD dismiss];
    NSFileManager *fileman = [NSFileManager defaultManager];
    if ([fileman fileExistsAtPath:videoURL.path]) {
        NSError *error = nil;
        [fileman removeItemAtURL:videoURL error:&error];
        if (error) {
            // DDLogInfo(@"failed to remove file, error:%@.", error);
        }
    }
    
    NSString *mp4Path = [mp4 relativePath];
    ECVideoMessageBody *mediaBody = [[ECVideoMessageBody alloc] initWithFile:mp4Path displayName:mp4Path.lastPathComponent];
    //发送媒体类型消息
    [self sendMediaMessage:mediaBody];
}

//发送一个视频占位消息,只本地入库
- (void)sendPlaceholderVideoMessage:(NSURL *)videoURL sandBoxFilepath:(NSString *)sandBoxFilepath  {
    NSString *relativePath = [videoURL relativePath];
    NSURL *mp4 = [NSURL fileURLWithPath:relativePath];
    NSString *mp4Path = [mp4 relativePath];
    ECVideoMessageBody *mediaBody = [[ECVideoMessageBody alloc] initWithFile:mp4Path displayName:mp4Path.lastPathComponent];
    ECMessage *message = [[ECMessage alloc] init];
    ///传来的参数
    message.messageBody = mediaBody;
    message.sessionId = self.sessionId;
    message.to = self.sessionId;
    message.messageState = ECMessageState_Sending;
    message.messageId = sandBoxFilepath;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    [[KitMsgData sharedInstance] addNewMessage:message andSessionId:message.sessionId];
}

- (void)callVideoBtnTap:(id)sender{
    
    NSNumber *number = [[AppModel sharedInstance] runModuleFunc:@"VidyoHelper" :@"IsVidyoingWhenOtherOperate" :nil];
    if(number.integerValue ==1){
        return;
    }
    
    UIActionSheet *sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:languageStringWithKey(@"取消") destructiveButtonTitle:nil otherButtonTitles:languageStringWithKey(@"视频通话"),languageStringWithKey(@"语音通话"), nil];
    
    sheet.tag = 257;
    [sheet showInView:self];
}
#pragma mark - 语音通话按钮点击事件
- (void)callBtnTap:(id)sender {
    if (![KKAuthorizedManager isMicrophoneAuthorized_ShowAlert:NO]) {
//        return;
    }
    
    if (globalisVoipView) {
        [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"当前正在通话中")];
        return;
    }
    //点击tableview，结束输入操作
    
    [self endOperation];
    
    NSString *callerNickname = [[Common sharedInstance] getOtherNameWithPhone:self.sessionId];
    NSString *callerNumber = self.sessionId;
    
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"callType",callerNumber,@"caller",callerNickname,@"nickname",[NSNumber numberWithInt:EOutgoing],@"callDirect",nil];
    
    [[AppModel sharedInstance] runModuleFunc:@"Dialing" :@"startCallViewWithDict:" :@[dict]];
    
    
}

#pragma mark - 视频聊天按钮点击事件
-(void)videoBtnTap:(id)sender {
    
     if (![KKAuthorizedManager isMicrophoneAuthorized_ShowAlert:YES]) {
//         return;
     }
    
    if (![KKAuthorizedManager isCameraAuthorized_ShowAlert:YES]) {
//        return;
    }
    
    if (globalisVoipView) {
        [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"当前正在通话中")];
        return;
    }
    //点击tableview，结束输入操作
    [self endOperation];
    
    NSString *callerNickname = [[Common sharedInstance] getOtherNameWithPhone:self.sessionId];
    NSString *callerNumber = self.sessionId;
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"callType",callerNumber,@"caller",callerNickname,@"nickname",[NSNumber numberWithInt:EOutgoing],@"callDirect",nil];
    [[AppModel sharedInstance] runModuleFunc:@"Dialing" :@"startCallViewWithDict:" :@[dict]];
}

#pragma mark vidyo视频
- (void)vidyoBtnTap:(id)sender {
    
    NSNumber *number = [[AppModel sharedInstance] runModuleFunc:@"VidyoHelper" :@"IsVidyoingWhenOtherOperate" :nil];
    if (number.integerValue == 1) {
        return;
    }
    if (globalisVoipView) {
        [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"当前正在通话中")];
        return;
    }
    [self endOperation];
    [self vidyoWithPTP:!_isGroup];
}


- (void)vidyoWithPTP:(BOOL)PTP {
    
    if (PTP) {
        [[AppModel sharedInstance] runModuleFunc:@"Vidyo" :@"vidyoSingleCallWithCaller:" :@[self.sessionId]];
    } else {
        UIViewController * vidyoSelectVC = [[AppModel sharedInstance] runModuleFunc:@"Vidyo" :@"createVidyoConferenceParamInfo:" :@[@{@"isGroup":@"1",@"groupId":self.sessionId,@"groupMembers":_curMemberList}]];
        if (vidyoSelectVC) {
            [self doPresentViewController:vidyoSelectVC];
        }
    }
    
}

#pragma mark - 发送文件按钮点击事件
/**
 *@brief 文件协同
 */
-(void)document_collaborationBtnTap:(id)sender{
    _fileType = 0;
    
    [self fileSendBtnTap];
}
#pragma mark 发送文件
- (void)fileSendBtnTap{
    HXSendFileViewController *sendFile = [[HXSendFileViewController alloc] init];
    sendFile.delegate=self;
    sendFile.limitSelectCount=9;
    sendFile.isFromHFSendFile = YES;
    RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:sendFile];
    [self doPresentViewController:nav];
    
}
#pragma mark - 选择文件
- (void)SelectCacheDocumentViewController:(HXSendFileViewController *)viewControllerr didSelectCacheObjects:(NSArray *)aCacheObjects albumObjects:(NSArray *)aAlbumObjects{
    for (NSInteger i = 0; i < aCacheObjects.count; i++) {
        [self sendFileMessageByFileDic:aCacheObjects[i]];
    }
    
    for (NSInteger i = 0; i < aAlbumObjects.count; i++) {
        NSDictionary *dic = aAlbumObjects[i];
        NSURL *fileURL = [dic objectForKey:@"url"];
        [AlbumManager loadAlbumFullScreenImageWithURL:fileURL resultBlock:^(UIImage *image) {
            [self sendFileMessageByImage:image dic:dic];
        } failureBlock:^(NSError *error) {
            
        }];
    }
}
#pragma mark - 发送文件 李晓杰
///发送文件 非图片
- (void)sendFileMessageByFileDic:(NSDictionary *)fileDic{
    NSDictionary *fileInfomationDic = [fileDic objectForKey:cacheFileInfoKey];
    ///文件路径
    NSString *filePath = [fileDic objectForKey:cacheFileLocatPath];
    ///文件大小
    long long fileSize = [fileInfomationDic longlongValueForKey:cachefileSize];
    ///服务器文件路径
    NSString *remotePath = [fileInfomationDic objectForKey:cachefileUrl];
    ///文件名
    NSString *fileName = [fileInfomationDic objectForKey:cachefileDisparhName];
    if (_fileType == 1) {//加密
        NSRange rang = [filePath rangeOfString:@"." options:NSBackwardsSearch];
        NSString *fileDirectory = [filePath substringToIndex:rang.location];
        NSString *fileType = [filePath substringFromIndex:rang.location];
        
        NSString *copyToSource = [NSString stringWithFormat:@"%@_copy%@",fileDirectory,fileType];
        DDLogInfo(@"copy source :%@",copyToSource);
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        DDLogInfo(@"%@", pathArray);
        [pathArray firstObject];
        //文件加密
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSString *dataString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        NSString *encodeData = [NSString encodedData:dataString withKey:self.sessionId];
        if ([fm createFileAtPath:copyToSource contents:[encodeData dataUsingEncoding:NSUTF8StringEncoding] attributes:nil]) {
            DDLogInfo(@"******************%@",@"写入成功");
        }
        filePath = copyToSource;
    }
    ECFileMessageBody *mediaBody = [[ECFileMessageBody alloc] initWithFile:filePath displayName:fileName];
    mediaBody.localPath = filePath;
    mediaBody.remotePath = remotePath;
    mediaBody.displayName = fileName;
    mediaBody.fileLength = fileSize;
    mediaBody.originFileLength = fileSize;
    mediaBody.isCompress = NO;
    
    
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"sessionId"] = self.sessionId;
    mDic[@"type"] = @(ChatMessageTypeFile);
    [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:mediaBody dic:mDic];
}
- (void)sendFileMessageByImage:(UIImage *)image dic:(NSDictionary *)dic{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *imgData = image.fixCurrentImage;
        NSString *timePath = [HXFileCacheManager createRandomFileName];
        NSString *displayName = dic[AlbumManagerKey_name];
        if(!displayName){
            displayName = [NSString stringWithFormat:@"%@.png",timePath];
        }
        NSString *filePath = [HXFileCacheManager saveData:imgData toCacheDirectory:YXP_ChatCacheManager_CacheDirectoryOfAlbumImage fileIdentifer:timePath displayName:displayName ImSessionId:self.sessionId aExtension:[displayName pathExtension]?[displayName pathExtension]:@"png"];
        if (filePath == nil ||
            [filePath isEqualToString:@""]) {
            [SVProgressHUD showErrorWithStatus:@"获取图片文件失败"];
            return ;
        }
        NSTimeInterval fileSize = [HXFileCacheManager fileSizeAtPath:filePath];
        NSString *postFilePath = filePath;
        if (self->_fileType == 1) {
            NSRange rang = [filePath rangeOfString:@"." options:NSBackwardsSearch];
            NSString *fileDirectory = [filePath substringToIndex:rang.location];
            NSString *fileType = [filePath substringFromIndex:rang.location];
            
            NSString *copyToSource = [NSString stringWithFormat:@"%@_copy%@",fileDirectory,fileType];
            DDLogInfo(@"copy source :%@",copyToSource);
            NSFileManager *fm = [NSFileManager defaultManager];
            
            NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            DDLogInfo(@"%@", pathArray);
            [pathArray firstObject];
            
            UIImage *imgFromUrl3 = [[UIImage alloc]initWithContentsOfFile:filePath];
            NSData *imageData = UIImagePNGRepresentation(imgFromUrl3);
            //文件加密
            NSString *aString = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
            
            DDLogInfo(@"******************%@",aString);
            NSString *encodeData = [NSString encodedData:aString withKey:self.sessionId];
            
            if ([fm createFileAtPath:copyToSource contents:[encodeData dataUsingEncoding:NSUTF8StringEncoding] attributes:nil]) {
                DDLogInfo(@"******************%@",@"写入成功");
            }
            postFilePath = copyToSource;
        }
        NSString *remotePath = [NSString stringWithFormat:@"YXPLocationSendFile%@",timePath];
        [[SendFileData sharedInstance] insertFileinfoData:@{cachefileUrl:remotePath,cacheimSissionId:self.sessionId,cachefileDirectory:YXP_ChatCacheManager_CacheDirectoryOfAlbumImage,cachefileIdentifer:timePath,cachefileDisparhName:displayName?displayName:timePath,cachefileExtension:[displayName pathExtension]?[displayName pathExtension]:@"png",cachefileSize:[NSString stringWithFormat:@"%f",fileSize]}];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ECFileMessageBody *mediaBody = [[ECFileMessageBody alloc] initWithFile:postFilePath displayName:displayName];
            mediaBody.remotePath = remotePath;
            mediaBody.displayName = displayName;
            mediaBody.localPath = filePath;
            mediaBody.fileLength = fileSize;
            mediaBody.originFileLength = fileSize;
            
            NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
            mDic[@"sessionId"] = self.sessionId;
            mDic[@"type"] = @(ChatMessageTypeFile);
            [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:mediaBody dic:mDic];
        });
    });
}
#pragma mark - 发送图文按钮点击事件
- (void)pictureWhithTextBtnTap:(id)sender {
    
    DynamicEditViewController * DynamicEditVC = [[DynamicEditViewController alloc] init];
    DynamicEditVC.data = self.sessionId;
    RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:DynamicEditVC];
    [self doPresentViewController:nav];
}



#pragma mark - 位置按钮点击事件
-(void)locationBtnTap:(id)sender {
    //    ECLocationViewController *locationVC = [[ECLocationViewController alloc] init];
    //    locationVC.delegate = self;
    //    ECLocationViewController *locationVC = [[ECLocationViewController alloc] init];
    //    locationVC.delegate = self;
    //    RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:locationVC];
    //    [self doPresentViewController:nav];
    
    // 判断是否定位可以使用
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
        
        //定位功能可用
        
    }else if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied) {
        
        //定位不能用
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        NSString *showMessage = [NSString stringWithFormat:@"请在“设置-隐私-定位服务”选项中允许[%@]访问你的定位",app_Name];
        
        RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
        [dialog showTitle:languageStringWithKey(@"无法使用定位服务功能") subTitle:showMessage ensureStr:languageStringWithKey(@"确定") cancalStr:nil selected:^(NSInteger index) {
            
        }];
        return;
        
    }
    
    
    //    self.isClickPickAndText = YES;
    
    NewLocationViewController *locationVC = [[NewLocationViewController alloc] init];
    locationVC.NewLocationDelegate = self;
    RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:locationVC];
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(changeIsFirstAndReload)]) {
    //        [self.delegate changeIsFirstAndReload];
    //    }
    //让chatViewController去模态
    [self doPresentViewController:nav];
}

#pragma mark ECLocationViewControllerDelegate
- (void)onSendUserLocation:(ECLocationPoint *)point {
    ECLocationMessageBody *messageBody = [[ECLocationMessageBody alloc] initWithCoordinate:point.coordinate andTitle:point.title];
    
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"sessionId"] = self.sessionId;
    mDic[@"type"] = @(ChatMessageTypeLocation);
    [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:messageBody dic:mDic];
}

#pragma mark - 阅后即焚按钮点击事件
- (void)burnAfterReadBtnTap:(UIButton *)btn{
    //    [self switchToolbarDisplay:_moreBtn];
    
    _isBurnAfterRead = YES;
    [self changeBurnTypeTo:_isBurnAfterRead];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeIsBurnAfterRead" object:nil userInfo:@{@"isBurnAfterRead":@YES}];
}

#pragma mark - 红包按钮点击事件
- (void)redPacketTap:(id)sender {
    self.redPacketAccountArr = [[NSMutableArray alloc] init];
    NSDictionary *dic = [[Chat sharedInstance].componentDelegate getDicWithId:self.sessionId withType:0];
    if (!_isGroup) {
        //zmf add
        //        self.redPacketAccountArr = [NSMutableArray arrayWithObjects:self.sessionId, nil];
        [self.redPacketAccountArr addObject:self.sessionId];
        //zmf end
        if ([Chat sharedInstance].componentDelegate && [[Chat sharedInstance].componentDelegate respondsToSelector:@selector(redPacketTapWithArray:withPersonDic:withCountType:withController:isGroup:completeBlock:)]) {
            [[Chat sharedInstance].componentDelegate redPacketTapWithArray:self.redPacketAccountArr withPersonDic:dic withCountType:0 withController:self.viewController isGroup:_isGroup completeBlock:^(NSString *text, NSString *userData) {
                DDLogInfo(@"**************红包信息:%@",text);
            }];
            
        }
    } else {
        __weak typeof(self) weak_self = self;
        [[ECDevice sharedInstance].messageManager queryGroupMembers:self.sessionId completion:^(ECError *error, NSString *groupId, NSArray *members) {
            __strong typeof(weak_self)strongSelf=weak_self;
            for (ECGroupMember *member in members) {
                
                NSString *userAvatar = [[AppModel sharedInstance] runModuleFunc:@"Common" :@"getIMageUrlWithPhone:" :@[member.memberId] hasReturn:YES];
                NSString *display = [[Common sharedInstance] getOtherNameWithPhone:member.memberId];
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setObject:member.memberId forKey:@"memberId"];//可唯一标识用户的ID
                [userInfo setObject:display?display:member.memberId forKey:@"display"];//用户昵称
                if (!KCNSSTRING_ISEMPTY(userAvatar)) {
                    [userInfo setObject:userAvatar forKey:@"userAvatar"];//用户头像地址
                }
                [strongSelf.redPacketAccountArr addObject:[userInfo copy]];
            }
            [strongSelf.redPacketAccountArr insertObject:strongSelf.sessionId atIndex:0];
            [SVProgressHUD dismiss];
            if (error.errorCode == ECErrorType_NoError && [strongSelf.sessionId isEqualToString:groupId]) {
                if ([Chat sharedInstance].componentDelegate && [[Chat sharedInstance].componentDelegate respondsToSelector:@selector(redPacketTapWithArray:withPersonDic:withCountType:withController:isGroup:completeBlock:)]) {
                    [[Chat sharedInstance].componentDelegate redPacketTapWithArray:self.redPacketAccountArr withPersonDic:nil withCountType:3 withController:self.viewController isGroup:_isGroup completeBlock:^(NSString *text, NSString *userData) {
                        DDLogInfo(@"**************红包信息:%@",text);
                        
                    }];
                }
                //                if ([Chat sharedInstance].componentDelegate && [[Chat sharedInstance].componentDelegate respondsToSelector:@selector(redPacketTapWithArray:withController:isGroup:completeBlock:)]) {
                //                    [[Chat sharedInstance].componentDelegate redPacketTapWithArray:strongSelf.redPacketAccountArr withController:strongSelf.viewController isGroup:_isGroup completeBlock:^(NSString *text, NSString *userData) {
                //                        DDLogInfo(@"**************红包信息:%@",text);
                //                    }];
                //                }
            }else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:languageStringWithKey(@"网络故障，请稍后") delegate:self cancelButtonTitle:languageStringWithKey(@"确定") otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
}
#pragma mark - 转账
- (void)transferTap:(id)sender {
    NSDictionary *dic = [[Chat sharedInstance].componentDelegate getDicWithId:self.sessionId withType:0];
    self.redPacketAccountArr = [NSMutableArray arrayWithObjects:self.sessionId, nil];
    if ([Chat sharedInstance].componentDelegate && [[Chat sharedInstance].componentDelegate respondsToSelector:@selector(redPacketTapWithArray:withPersonDic:withCountType:withController:isGroup:completeBlock:)]) {
        [[Chat sharedInstance].componentDelegate redPacketTapWithArray:self.redPacketAccountArr withPersonDic:dic withCountType:2 withController:self.viewController isGroup:_isGroup completeBlock:^(NSString *text, NSString *userData) {
            DDLogInfo(@"**************转账信息:%@",text);
        }];
    }
    
    //    [[ECDevice sharedInstance] getOtherPersonInfoWith:self.sessionId completion:^(ECError *error, ECPersonInfo *person) {
    //        if ([Chat sharedInstance].componentDelegate && [[Chat sharedInstance].componentDelegate respondsToSelector:@selector(transformMoneyWithPerson:withSessionId:withVC:)]) {
    //            [[Chat sharedInstance].componentDelegate transformMoneyWithPerson:dic withSessionId:self.sessionId withVC:self.viewController];
    //        }
    //
    ////    }];
    
}
#pragma mark - 个人名片
- (void)businessCardShareTap:(id)sender{
    if ([Chat sharedInstance].componentDelegate && [[Chat sharedInstance].componentDelegate respondsToSelector:@selector(getChooseMembersVCWithExceptData:WithType:)]) {
        UIViewController *groupVC = [[Chat sharedInstance].componentDelegate getChooseMembersVCWithExceptData:@{@"sessionId":self.sessionId} WithType:SelectObjectType_SendCardSelectMember];
        //         [self. pushViewController:groupVC];
        //        DDLogInfo(@"%@ : ",self.sessionId);
        RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:groupVC];
        [[self getCurrentViewController] presentViewController:nav animated:YES completion:nil];
    }
}
#pragma mark - 白板共享
- (void)boardBtnTap:(id)sender{
    //ydw modify 行方要求
    NSNumber *number = [[AppModel sharedInstance] runModuleFunc:@"VidyoHelper" :@"IsVidyoingWhenOtherOperate" :nil];
    if(number.integerValue ==1){
        return;
    }
    [self endOperation];
    //恒丰 - hw
    ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
    if (self.isGroup) {
        UIViewController *groupMemberVC = [[AppModel sharedInstance] runModuleFunc:@"Chat" :@"getGroupListViewControllerWithParam:" :@[@{@"conferenceType":@"4",@"groupId":self.sessionId,@"chatVC":chatVC,@"allMembers":self.curMemberList}]];
        RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:groupMemberVC];
        [chatVC presentViewController:nav animated:YES completion:nil];
    } else {
        //创建白板
        NSMutableArray *userPhones = [NSMutableArray array];
        [userPhones addObject:self.sessionId];
        NSDictionary *params = @{USERID: [[Chat sharedInstance] getAccount],PASSWORD:@"123456", ROOMTYPE:@"1", BOARDTYPE:@"0", USERS:userPhones, SendIMWhenExit:@"1", BOARDURL: [Chat sharedInstance].getBoardUrl};
        [[AppModel sharedInstance] runModuleFunc:@"Board":@"createBoardWithParams:andPresentVC:":@[params, chatVC]];
    }
}

- (void)chatVCEndKeyBoard {
    [self endOperation];
}

#pragma mark -  音视频会议
-(void)callMeetBtnTap:(id)sender {
    if (globalisVoipView) {
        [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"当前正在通话中")];
        return;
    }
    [self endOperation];
    __weak typeof(self) weak_self = self;
    [[ECDevice sharedInstance].messageManager queryGroupMembers:self.sessionId completion:^(ECError *error, NSString* groupId, NSArray *members) {
        __strong typeof(weak_self)strongSelf = self;
        strongSelf.selectedList = [NSMutableArray arrayWithCapacity:0];
        if(error.errorCode == ECErrorType_NoError){
            if (members.count > 25) {//超过人数限制
                [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"当前会议最多只能选择25人")];
            }else{
                if (strongSelf.selectedList && strongSelf.selectedList.count > 0) {
                    [strongSelf.selectedList removeAllObjects];
                }
                //点击tableview，结束输入操作
                [self endOperation];
                NSString *myPhone = [[Chat sharedInstance] getAccount];
                NSMutableArray *arr = [NSMutableArray array];
                for (ECGroupMember *member in members) {
                    if (![member.memberId isEqualToString:myPhone]) {
                        NSString *memberName = [[Common sharedInstance] getOtherNameWithPhone:member.memberId];
                        [arr addObject:@{Table_User_member_name:memberName,Table_User_account:member.memberId,@"isVoip":@"1"}];
                    }
                }
                [[AppModel sharedInstance] runModuleFunc:@"VoiceMeeting" :@"startVoiceMeetingView:Type:" :@[arr,[NSNumber numberWithInt:1]]];
            }
        }else{
            if(error.errorCode == 171139){
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"开启失败,请检查网络设置")];
                return ;
            }
            if(!KCNSSTRING_ISEMPTY(error.errorDescription)){
                [SVProgressHUD showErrorWithStatus:error.errorDescription];
                return;
            }
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"会议开启失败")];
            //if(error.errorCode==)
        }
    }];
}

- (void)videoMeetBtnTap:(id)sender{
    if (globalisVoipView) {
        [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"当前正在通话中")];
        return;
    }
    [self endOperation];
//    [[Chat sharedInstance] getGroupListViewControllerWithMembexrs:_curMemberList withType:[NSNumber numberWithInt:1]];
    UIViewController *listVC = [[AppModel sharedInstance] runModuleFunc:@"YHCConference" :@"getConflistVC" :nil];
      RXBaseNavgationController *nav = [[RXBaseNavgationController alloc] initWithRootViewController:listVC];
      nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self doPresentViewController:nav];
    
}
#pragma mark - 群投票

- (void)groupVotingTap:(UIButton *)btn{
    [self endOperation];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self.sessionId,@"groupId",[[Chat sharedInstance] getAccount],@"account",nil];
    //让chatViewController去push
    [self doPushViewController:@"GroupVotingViewController" withData:dic withNav:YES];
}

#pragma mark - 发送文本消息
/**
 *@brief 发送文本消息
 */
- (void)sendTextMessage{
    _userInputState = UserState_None;
    if (_stimer) {
        [[ChatMessageManager sharedInstance] sendUserState:_userInputState to:self.sessionId];
    }
    NSString *textString = _inputTextView.text;
    DDLogInfo(@"%@", textString);
    
    // 检查text 如果是rongxin://codecset 则打开音视频编码设置界面
    if ([textString isEqualToString:@"rongxin://codecset"]) {
        DDLogInfo(@"打开音视频编码设置界面");
        [self doPushViewController:@"CodecsetViewController" withData:self.sessionId withNav:YES];
        return ;
    }
    int k = 0;
#if DEBUG
    if ([textString containsString:@"yyz."]) {
        DDLogInfo(@"发送200条消息");
        k = 1;
    }
    // 压测的
    if ([textString containsString:@"yc."]) {
        DDLogInfo(@"压测，");
        k = 2;
    }
    
#endif
    // 分辨率、视频显示模式设置
    if ([textString isEqualToString:@"rongxin://ResolutionSet"] || [textString isEqualToString:@"rongxin://AspectMode"]) {
        [self doPushViewController:@"ResolutionAndViewModeController" withData:self.sessionId withNav:YES];
        return ;
    }
    
    if (textString.length > 1024) {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"字数超过上限")];
        return;
    }
    
    if ([textString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        self.toolbarStatus = ToolbarStatus_None;
        [self endEditing:YES];
        [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"不能发送空白消息")];
        return;
    }
    
    //保存或删除草稿
    [[KitMsgData sharedInstance] updateDraft:@"" withSessionID:_sessionId];
    ///发送消息
    NSString *text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:textString];
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:text];

    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"sessionId"] = self.sessionId;
    mDic[@"type"] = @(ChatMessageTypeText);
    mDic[@"isBurn"] = @(_isBurnAfterRead);
    
    //加个判断 是否为网址
    if ([textString isWebUrl] && !_isBurnAfterRead) {
        NSMutableDictionary *userData = @{}.mutableCopy;
        userData[SMSGTYPE] = @"26";
        ECTextMessageBody *msgBody = [ECTextMessageBody new];
        msgBody.text = textString;
        ECMessage *message = [[ECMessage alloc] init];
        ///传来的参数
        message.messageBody = msgBody;
        message.messageState = EMessageState_Sending;
        NSString *sessionId = self.sessionId;

        message.from = [Common sharedInstance].getAccount;
        ///收消息的人
        message.sessionId = sessionId;
        message.to = sessionId;
        message.messageId = textString;

        //时间戳
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp = [date timeIntervalSince1970] * 1000;
        message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];

        message.userData = userData.jsonEncodedKeyValueString;
        [[KitMsgData sharedInstance] addNewMessage:message andSessionId:message.sessionId];
        return;
    }
    
    if (_isGroup) {//群组可能有@的人 还有匿名模式
        NSMutableCharacterSet *set = [NSMutableCharacterSet whitespaceCharacterSet];
        [set removeCharactersInString:_deleteAtStr];
        NSString *textString = [_inputTextView.text stringByTrimmingCharactersInSet:set];
        ///被@的人名称数组
        NSMutableArray *array = [[NSMutableArray alloc] init];
        NSArray *temp = [textString componentsSeparatedByString:_deleteAtStr];
        for (NSString *atStr in temp) {
            [array addObject:[atStr stringByReplacingOccurrencesOfString:@"@" withString:@""]];
        }
        NSMutableArray *personArray = [NSMutableArray array];
        ///所有被@的人
        NSMutableArray *allPersonArray = [ChatMessageManager sharedInstance].AtPersonArray;
        //截取字符串中名字并判断@人数组中ID获得的名字是否包含在内
        for (NSDictionary *dict in allPersonArray) {
            if (dict == nil) {
                continue;
            }
            if (![dict hasValueForKey:@"memberId"]) {
                continue;
            }
            NSString *memberId = dict[@"memberId"];
            if ([memberId containsString:@"g"]) {
                [personArray addObject:memberId];
            }else{
                NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:memberId withType:0];
                NSString *name =  companyInfo[Table_User_member_name] ? companyInfo[Table_User_member_name] : companyInfo[Table_User_mobile];
                if (!KCNSSTRING_ISEMPTY(name) && [array containsObject:name]) {
                    [personArray addObject:memberId];
                }
            }
        }
        if (personArray && personArray.count > 0) {
            messageBody.atArray = personArray;
        }
        KitGroupInfoData *groupinfo = [KitGroupInfoData getGroupInfoWithGroupId:self.sessionId];
        if (groupinfo.isAnonymity) {
            mDic[@"isBurn"] = @(NO);
        }else{
            mDic[@"isBurn"] = @(_isBurnAfterRead);
        }
        [[ChatMessageManager sharedInstance].AtPersonArray removeAllObjects];
    }
    [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:messageBody dic:mDic];
    
#if DEBUG
    //    /// eagle 发送200条消息
    if (k == 1) {
        for (int i = 0; i<200; i++) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:messageBody dic:mDic];
                
                
            });
        }
    }
    
    if (k == 2) {

        
        [NSTimer scheduledTimerWithTimeInterval:0.5f repeats:YES block:^(NSTimer * _Nonnull timer) {
              [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:messageBody dic:mDic];
        }];
        
    }
    
    
#endif
    
}

#pragma mark - CustomEmojiViewDelegate 表情
- (void)emojiBtnInput:(NSInteger)emojiTag{
    _inputTextView.text =  [_inputTextView.text stringByAppendingString:[ChatEmojiManager getExpressionStrByIdCommon:emojiTag]];
}

- (void)backspaceText{
    if(_inputTextView.text.length > 0) {
        [_inputTextView deleteBackward];
    }
}

- (void)emojiSendBtn:(id)sender{
    [self sendTextMessage];
    _inputTextView.text = @"";
}

- (void)refreshEmojiViewAndMoreViewFrame {
    float diff = (_inputTextViewNewHeight - _inputTextViewOriginHeight);
    if (self.toolbarStatus == ToolbarStatus_Record) {
        diff = 0;
    }
    
    CGRect frame = _emojiView.frame;
    frame.origin.y = ToolbarInputViewHeight +diff;
    _emojiView.frame=frame;
    
    frame = _moreView.frame;
    frame.origin.y = ToolbarInputViewHeight +diff;
    _moreView.frame=frame;
    
    _switchVoiceBtn.frame = CGRectMake(5.0f, 9.0f+diff, 31.0f, 31.0f);
    _moreBtn.frame = CGRectMake(self.frame.size.width-36.0f, 9.0f+diff, 31.0f, 31.0f);
    _emojiBtn.frame = CGRectMake(_moreBtn.frame.origin.x-36.0f, 9.0f+diff, 31.0f, 31.0f);
}

#pragma mark - zmf 表情云相关MMEmotionCentreDelegate 先屏蔽
////表情云
//- (void)didSelectEmoji:(MMEmoji *)emoji {
//    [self sendBigEmojiMessageWith:emoji];
//}
//
////这个方法就是用来发小表情的
//- (void)didSendWithInput:(UIResponder<UITextInput> *)input {
//        [self sendTextMessage];
//        _inputTextView.text = @"";
//}

/**
 *@brief 发送大表情消息
 */
//- (void)sendBigEmojiMessageWith:(MMEmoji *)emoji {
//    _userInputState = UserState_None;
//    if (_stimer) {
//        [[ChatMessageManager sharedInstance] sendUserState:_userInputState to:self.sessionId];
//    }
//    BOOL isBurn = _isBurnAfterRead;
//    if (_isGroup) {
//        KitGroupInfoData *groupinfo = [KitGroupInfoData getGroupInfoWithGroupId:self.sessionId];
//        if (groupinfo.isAnonymity) {
//            isBurn = NO;
//        }
//    }
//    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] init];
//    messageBody.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:emoji.emojiName];
//    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
//    mDic[@"sessionId"] = self.sessionId;
//    mDic[@"type"] = @(ChatMessageTypeBigEmoji);
//    mDic[@"isBurn"] = @(isBurn);
//    mDic[@"isBurn"] = @(isBurn);
//    mDic[@"emojiCode"] = emoji.emojiCode;
//    [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:messageBody dic:mDic];
//}

#pragma mark 发送媒体消息
/**
 *@brief 发送媒体类型消息
 */
- (void)sendMediaMessage:(ECFileMessageBody *)mediaBody{
    _userInputState = UserState_None;
    
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"sessionId"] = self.sessionId;
    mDic[@"type"] = @(ChatMessageTypeMedia);
    
    KitGroupInfoData *groupinfo = [KitGroupInfoData getGroupInfoWithGroupId:self.sessionId];
    if (groupinfo.isAnonymity) {
        mDic[@"isBurn"] = @(NO);
    }else{
        mDic[@"isBurn"] = @(_isBurnAfterRead);
    }
    [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:mediaBody dic:mDic];
}

//点击tableview，结束输入操作
- (void)endOperation{
    self.toolbarStatus = ToolbarStatus_None;
    [self toolbarDisplayChangedWithStautas:self.toolbarStatus];
}
- (void)setIsDis:(BOOL)isDis {
    _isDis = isDis;
}

#pragma mark - 让控制器去push和modal控制器
- (void)doPushViewController:(NSString *)className withData:(id)data withNav:(BOOL)nav {
    [self removeKeyboardNotification];
    ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
    [chatVC pushViewController:className withData:data withNav:nav];
}

- (void)doPresentViewController:(UIViewController *)viewController {
    [self removeKeyboardNotification];
    ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
    [chatVC presentViewController:viewController animated:YES completion:nil];
}

//  获取@选择人数组
- (void)getAtPersons{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"GroupMemberNickNameList"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *nameIdDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"GroupMemberNickNameList"];
        if (nameIdDict) {
            if ([nameIdDict hasValueForKey:@"memberName"]) {
                self.memberName = nameIdDict[@"memberName"];
            }
            if ([nameIdDict hasValueForKey:@"memberId"]) {
                self.memberId = nameIdDict[@"memberId"];
            }
        }else{
            self.memberName = nil;
        }
        
        if([ChatMessageManager sharedInstance].AtPersonArray.count < 1 &&
           nameIdDict.count > 0){
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GroupMemberNickNameList"];
        }
    }else{
        self.memberName = nil;
    }
    
}
#pragma mark - 密件相关
- (void)secretBtnTap:(UIButton *)sender {
    _fileType = 1;
    [self fileSendBtnTap];
}
- (void)dealloc{
    //    [self disMissViewStopRecode];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_stimer) {
        dispatch_source_cancel(_stimer);
        _stimer = 0;
    }
}

- (void)chatVCDisaWillAppear {
    [self disMissViewStopRecode];
}
- (void)setIsBurn {
    // hanwei start
    if (_isBurnAfterRead == YES) {
        [[KitMsgData sharedInstance]updateDraft:nil withSessionID:_sessionId];
    }
    // hanwei end
}
//更新草稿
- (void)updateDraftData{
    //保存或删除草稿
    if (_inputTextView.text.length>0) {
        [[KitMsgData sharedInstance] updateDraft:_inputTextView.text withSessionID:_sessionId];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SessionRefreshDraft" object:nil];
    }
}
//yxp2017
- (void)setCurInputTextView:(NSString *)text{
    _inputTextView.text = text;
}
- (NSString *)getTextViewText{
    return _inputTextView.text;
}

@end
