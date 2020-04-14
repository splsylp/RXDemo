//
//  IMChatViewController.m
//  IMKitDemo
//
//  Created by zhangmingfei on 2016/11/22.
//  Copyright © 2016年 zhangmingfei. All rights reserved.
//

#import "IMChatViewController.h"
#import "Chat.h"
#import "AppModel.h"
#import "SVProgressHUD.h"
#import "Common.h"
#import "RXBaseNavgationController.h"
#import "RXAddressBook.h"

@interface IMChatViewController () <AppModelDelegate>
//自己账号
@property (nonatomic, copy) NSString *myAccount;

@property (weak, nonatomic) UITextField *otherAccounttextField;

@property (weak, nonatomic) IBOutlet UILabel *loginedTipLabel;

//获取会话列表按钮
@property (nonatomic, weak) IBOutlet UIButton *getSessionsButton;
//群聊
@property (nonatomic, weak) IBOutlet UIButton *getGroupListButton;
//单聊
@property (nonatomic, weak) IBOutlet UIButton *startChattingButton;

@property (nonatomic, assign) BOOL logoutSuccess;

@end

@implementation IMChatViewController

- (instancetype)initWithAccount:(NSString *)account {
    if (self = [super init]) {
        _myAccount = account;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置代理 很重要
    [AppModel sharedInstance].appModelDelegate = self;
    
    //UI布局
    [self setupUI];
    
    self.loginedTipLabel.text = [NSString stringWithFormat:@"登录账号：%@",_myAccount];
}

//UI布局
- (void)setupUI {
    //背景色
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.getSessionsButton.layer.borderColor =
    self.getGroupListButton.layer.borderColor =
    self.startChattingButton.layer.borderColor =
    [UIColor colorWithRed:72/255.0 green:203/255.0 blue:131/255.0 alpha:1/1.0].CGColor;
    self.getSessionsButton.layer.borderWidth =
    self.getGroupListButton.layer.borderWidth =
    self.startChattingButton.layer.borderWidth = 1;
    
    //标题栏
    self.navigationItem.title = @"IM";
    

    
    //获取会话列表按钮
    [_getSessionsButton addTarget:self action:@selector(getSessionsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    //新建群组聊天
    [_getGroupListButton addTarget:self action:@selector(getGroupSessionsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    //单聊
    [_startChattingButton addTarget:self action:@selector(startChattingButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 45, 40);
    [btn setImage:[UIImage imageNamed:@"title_bar_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(popController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)popController {
 [self.navigationController popViewControllerAnimated:YES];
    
}

//获取会话列表
- (void)getSessionsButtonClick {
    UIViewController *sessionVC = [[Chat sharedInstance] getSessionViewController];
    [self.navigationController pushViewController:sessionVC animated:YES];
}

//新建群组聊天  push or present 都可以使用
- (void)getGroupSessionsButtonClick {
    UIViewController *groupChat  = [self getChooseMembersVCWithExceptData:nil WithType:SelectObjectType_CreateGroupChatSelectMember];
    [self.navigationController pushViewController:groupChat animated:YES];
}

//开始聊天
- (void)startChattingButtonClick {
    //弹窗
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"开始聊天", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    //文本框
    __weak typeof(self) weakSelf = self;
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = NSLocalizedString(@"请输入对方账号", nil);
        weakSelf.otherAccounttextField = textField;
    }];
    //取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    //确定按钮
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"开始聊天");
        NSString *otherAccount = weakSelf.otherAccounttextField.text;
        if (otherAccount.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入对方账号"];
            return;
        }
        
        if ([weakSelf.otherAccounttextField.text isEqualToString:weakSelf.myAccount]) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"不能与自己聊天", nil)];
            return ;
        }
        UIViewController *chatVC = [[Chat sharedInstance] getChatViewControllerWithSessionId:weakSelf.otherAccounttextField.text];
        [weakSelf.navigationController pushViewController:chatVC animated:YES];
        
    }];
    
    [alertVC addAction:cancelAction];
    [alertVC addAction:doneAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
 @brief 获取联系人信息
 @param id 联系人的个人信息
 @param type 0:根据account获取，1:根据手机号获取
 @return 联系人信息
 */
- (NSDictionary*)getDicWithId:(NSString*)Id withType:(int) type{
    if (!Id) {
        return nil;
    }
    NSDictionary* dict = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getCompanyAddressWithId:withType:" :[NSArray arrayWithObjects:Id,[NSNumber numberWithInt:type], nil]];
    return dict;
}

/*
 @brief 选择联系人界面
 @param exceptData需要传进选择联系人界面的数据, @"members"：单聊再选人时原有人组成的数
 组，@"message"：转发的消息，@"groupId"：群聊再选人的groupId
 @return 选择联系人界面
 */
- (UIViewController *)getChooseMembersVCWithExceptData:(NSDictionary *)exceptData WithType:(SelectObjectType)type {
    
    if ([exceptData allKeys].count > 0) {
        UIViewController *groupVC = [[RXAddressBook sharedInstance] getChooseMembersVCWithExceptData:exceptData WithType:[NSNumber numberWithInteger:SelectObjectType_GroupChatSelectMember]];
        return groupVC;
    }else{
        UIViewController *groupVC = [[RXAddressBook sharedInstance] getChooseMembersVCWithExceptData:@{} WithType:[NSNumber numberWithInteger:SelectObjectType_CreateGroupChatSelectMember]];
        return groupVC;
    }
  
    return nil;
}

/*
 @brief 联系人详情界面
 @param data:联系人账号(字符串类型，对方的账号)
 @return 详情界面
 */
- (UIViewController *)getContactorInfosVCWithData:(id)data {
   UIViewController *contactorInfosVC = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getContactorInfosVCWithData:" :@[data]];
    if (contactorInfosVC) {
        return contactorInfosVC;
    }
    return nil;
}

/*
 @brief 定制聊天界面点击加号后的功能
 @param isGroup:是群组界面还是点对点界面
 @param members:群聊是群成员id，单聊是对方的id
 @param myImagesArr：图片数组 ，textArr:标题数组，selectorArr:点击事件数组
 @param completion(imagesArr, textArr, selectorArr);
 */
- (void)getChatMoreArrayWithIsGroup:(BOOL)isGroup andMembers:(NSArray *)members completion:(void (^)(NSArray *, NSArray *, NSArray *))completion {
    NSArray *imagesArr;
    NSArray *textArr;
    NSArray *selectorArr;
    if(isGroup) {
        //暂时屏蔽群投票
        imagesArr = @[@"im_icon_images",
                      @"im_icon_camera",
                      @"message_btn_file_normal",
                      @"im_icon_pic_txt",
                      @"message_btn_position_normal",
                      @"im_icon_video.png"];
        textArr = @[NSLocalizedString(@"图片", nil),
                    NSLocalizedString(@"小视频", nil),
                    NSLocalizedString(@"发送文件", nil),
                    NSLocalizedString(@"发送图文", nil),
                    NSLocalizedString(@"位置", nil),
                    NSLocalizedString(@"视频会议",nil)];
        selectorArr = @[@"pictureBtnTap:",
                        @"littleVideoBtnTap:",
                        @"document_collaborationBtnTap:",
                        @"pictureWhithTextBtnTap:",
                        @"locationBtnTap:",
                        @"videoMeetBtnTap:"];
    } else {
        imagesArr = @[@"im_icon_images",
                      @"im_icon_camera",
                      @"message_btn_file_normal",
                      @"im_icon_pic_txt",
                      @"message_btn_position_normal",
                      @"im_icon_call",
                      @"im_icon_video"
                      /*@"im_icon_burn"*/];
        textArr = @[NSLocalizedString(@"图片", nil),
                    NSLocalizedString(@"小视频", nil),
                    NSLocalizedString(@"发送文件", nil),
                    NSLocalizedString(@"发送图文", nil),
                    NSLocalizedString(@"位置", nil),
                    NSLocalizedString(@"语音通话", nil),
                    NSLocalizedString(@"视频聊天", nil),
                    /*NSLocalizedString(@"阅后即焚", nil)*/];
        selectorArr = @[@"pictureBtnTap:",
                        @"littleVideoBtnTap:",
                        @"document_collaborationBtnTap:",
                        @"pictureWhithTextBtnTap:",
                        @"locationBtnTap:",
                        @"callBtnTap:",
                        @"videoBtnTap:"
                        /*@"burnAfterReadBtnTap:"*/];
    }
    completion(imagesArr,textArr,selectorArr);
}

/*
 @brief 定制会话列表界面右上角"+"号功能列表
 @param currentVC:当前的会话列表界面
 @param myImagesArr：图片数组 ，myTextArr:标题数组，mySelectorArr:点击事件数组
 @param completion(myImagesArr, myTextArr, mySelectorArr);
 */
- (void)getSessionMoreArrayWithCurrentVc:(UIViewController *)currentVC completion:(void(^)(NSArray *myImagesArr,NSArray *myTextArr,NSArray *mySelectorArr))completion {
    NSArray *imagesArr   = @[@"icon_groupchat.png",
                           @"icon_videoconference.png"];
    NSArray *textArr     = @[NSLocalizedString(@"发起群聊", nil),
                         NSLocalizedString(@"视频会议",nil)];
    NSArray *selectorArr = @[@"startGroupChat",@"videoMeeting"];
    completion(imagesArr,textArr,selectorArr);
}

@end
