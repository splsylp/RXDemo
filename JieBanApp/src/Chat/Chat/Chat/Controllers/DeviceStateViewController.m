//
//  DeviceStateViewController.m
//  Chat
//
//  Created by 杨大为 on 2018/1/10.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "DeviceStateViewController.h"
#import "ChatViewController.h"
#define DeviceBtnWidth (80*iPhone6FitScreenWidth)
@interface DeviceStateViewController ()
@property (nonatomic,strong) UIImageView *deviceImageView;
@property (nonatomic,strong) UIButton *hasLoginBtn;//容信已登录
@property (nonatomic,strong) UIButton *muteBtn;//静音按钮
@property (nonatomic,strong) UILabel *muteLab;//静音label
@property (nonatomic,strong) UIButton *sendFileBtn;//传文件按钮
@property (nonatomic,strong) UILabel *sendFileLab;//传文件lab
@property (nonatomic,strong) UIButton *closeBtn;//关闭按钮
@property (nonatomic ,assign) BOOL isMute;//是否已经静音
@end

@implementation DeviceStateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
    //创建UI视图
    [self createUI];
}
- (void)createUI{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (isIPhoneX) {
        backBtn.frame = CGRectMake(20, 74, 60, 40);
    }else{
        backBtn.frame = CGRectMake(20, 30, 60, 40);
    }
    
    [backBtn setTitle:languageStringWithKey(@"关闭") forState:UIControlStateNormal];
    [backBtn setTitleColor:ThemeColor forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(dismissCurrentVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    [self.view addSubview:self.deviceImageView];
    [self.view addSubview:self.hasLoginBtn];
    [self.view addSubview:self.muteBtn];
    [self.view addSubview:self.muteLab];

    [self.view addSubview:self.sendFileBtn];
    [self.view addSubview:self.sendFileLab];
    [self.view addSubview:self.closeBtn];
    [self getMyMuteState];
//    [self changeImage];
}
// pc设备view
-(UIImageView *)deviceImageView{
    if (!_deviceImageView) {
        UIImageView *deviceImageView = [[UIImageView alloc]initWithImage:ThemeImage(@"icon_computer")];
        deviceImageView.frame = CGRectMake((kScreenWidth-120)/2, 180*iPhone6FitScreenWidth, 120*iPhone6FitScreenWidth, 80*iPhone6FitScreenWidth);
        //        [self.view addSubview:deviceImageView];
        _deviceImageView = deviceImageView;
    }
    return _deviceImageView;
}
- (UIButton *)hasLoginBtn{
    if (!_hasLoginBtn) {
        
        UIButton *hasLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        hasLoginBtn.frame = CGRectMake((kScreenWidth-210*FitThemeFont)/2, self.deviceImageView.bottom + 30, 210*FitThemeFont, 40);
        [hasLoginBtn.titleLabel setFont:ThemeFontLarge];
        hasLoginBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        NSString *loginBtnTitle = self.deviceType == 1 ? languageStringWithKey(@"PC 容信已登录") :self.deviceType == 2 ?languageStringWithKey(@"Mac 容信已登录") :languageStringWithKey(@"WEB 容信已登录");
        [hasLoginBtn setTitle:loginBtnTitle forState:UIControlStateNormal];
        [hasLoginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _hasLoginBtn = hasLoginBtn;
    }
    return _hasLoginBtn;
}
//静音按钮
- (UIButton *)muteBtn{
    if (!_muteBtn) {
        UIButton *muteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        muteBtn.frame = CGRectMake((kScreenWidth-DeviceBtnWidth*2)/3, self.deviceImageView.bottom + 150*iPhone6FitScreenWidth, DeviceBtnWidth, DeviceBtnWidth);
        muteBtn.imageView.contentMode = UIViewContentModeCenter;
        [muteBtn setImage:ThemeImage(@"btn_nomute_normal") forState:UIControlStateNormal];
        [muteBtn addTarget:self action:@selector(muteMessageNoti) forControlEvents:UIControlEventTouchUpInside];
        _muteBtn = muteBtn;
    }
    return _muteBtn;
}

- (UILabel *)muteLab{
    if (!_muteLab) {
        UILabel *muteLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.muteBtn.left, self.muteBtn.bottom+10, self.muteBtn.width, 30)];
        muteLabel.text = languageStringWithKey(@"手机通知静音");
        muteLabel.adjustsFontSizeToFitWidth = YES;
        muteLabel.textAlignment = NSTextAlignmentCenter;
        muteLabel.font = SystemFontSmall;
        muteLabel.textColor = [UIColor darkGrayColor];
        muteLabel.backgroundColor = [UIColor clearColor];
        _muteLab = muteLabel;
    }
    return _muteLab;
}
//传文件
- (UIButton *)sendFileBtn{
    if (!_sendFileBtn) {
        UIButton *sendFileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendFileBtn.frame = CGRectMake((kScreenWidth-DeviceBtnWidth*2)/3*2+DeviceBtnWidth, self.deviceImageView.bottom + 150*iPhone6FitScreenWidth, DeviceBtnWidth, DeviceBtnWidth);
        sendFileBtn.imageView.contentMode = UIViewContentModeCenter;
        [sendFileBtn setImage:ThemeImage(@"message_btn_file_normal") forState:UIControlStateNormal];
        [sendFileBtn setImage:ThemeImage(@"message_btn_file_pressed") forState:UIControlStateSelected];
        [sendFileBtn addTarget:self action:@selector(sendMessageToMyself) forControlEvents:UIControlEventTouchUpInside];
        _sendFileBtn = sendFileBtn;
    }
    return _sendFileBtn;
}

- (UILabel *)sendFileLab{
    if (!_sendFileLab) {
        UILabel *sendFileLab = [[UILabel alloc] initWithFrame:CGRectMake(self.sendFileBtn.left, self.sendFileBtn.bottom+10, self.sendFileBtn.width, 30)];
        sendFileLab.text = languageStringWithKey(@"传文件");
        sendFileLab.adjustsFontSizeToFitWidth = YES;
        sendFileLab.textAlignment = NSTextAlignmentCenter;
        sendFileLab.font = SystemFontSmall;
        sendFileLab.textColor = [UIColor darkGrayColor];
        sendFileLab.backgroundColor = [UIColor clearColor];
        _sendFileLab = sendFileLab;
    }
    return _sendFileLab;
}

- (UIButton *)closeBtn{
    if (!_closeBtn) {
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake((kScreenWidth-180*FitThemeFont)/2, kScreenHeight - 110*iPhone6FitScreenWidth, 180*FitThemeFont, 40);
        
        NSString *closeBtnTitle = self.deviceType == 1 ? languageStringWithKey(@"退出 PC 容信") :self.deviceType == 2 ?languageStringWithKey(@"退出 Mac 容信") :languageStringWithKey(@"退出 WEB 容信");
        [closeBtn setTitle:closeBtnTitle forState:UIControlStateNormal];
        [closeBtn.titleLabel setFont:ThemeFontLarge];
        [closeBtn setTitleColor:ThemeColor forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(showExitAlert) forControlEvents:UIControlEventTouchUpInside];
        closeBtn.backgroundColor = [UIColor whiteColor];
        closeBtn.layer.cornerRadius = 4;
//        closeBtn.layer.borderColor = ThemeColor.CGColor;
        _closeBtn = closeBtn;
    }
    return _closeBtn;
}


// 快速编译方法，无需调用
- (void)injected{
    [self createUI];
    NSLog(@"eagle.injected");
}
-(void)dismissCurrentVC:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// 传文件
-(void)sendMessageToMyself{
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *sessionId = FileTransferAssistant;
          [[NSNotificationCenter defaultCenter] postNotificationName:@"sendToChatVc" object:sessionId];
    }];
}
- (UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {if ([next isKindOfClass:[UIViewController class]]) {
        return (UIViewController *)next;
    }
        next = [next nextResponder];
    } while (next !=nil);
    return nil;
}

-(void)getMyMuteState{
    NSString *myAccount = [Common sharedInstance].getAccount;
    [[RestApi sharedInstance] getMsgMuteWithAccount:myAccount didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        NSLog(@"dict");
        if ([[dict objectForKey:@"statusCode"] isEqualToString:@"000000"]) {
            if ([[dict objectForKey:@"state"] intValue] == 1) {
                [AppModel sharedInstance].muteState = @"1";
                NSLog(@"静音开启");
                [self changeImage];
            }else{
                NSLog(@"静音关闭");
                [AppModel sharedInstance].muteState = @"2";
                 [self changeImage];
            }
        }
    } didFailLoaded:^(NSError *error, NSString *path) {
        NSLog(@"error");
         [self changeImage];
    }];
}

-(void)muteMessageNoti{
    NSString *myAccount = [Common sharedInstance].getAccount;

    if ([[AppModel sharedInstance].muteState isEqualToString:@"1"]) {
        WS(weakSelf);
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:languageStringWithKey(@"关闭“手机通知静音”后，手机接收新消息通知将正常提醒") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:languageStringWithKey(@"恢复手机通知") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf setRestMuteWithAccount:myAccount withState:@"2"];
        }];
        UIAlertAction *alertAction3 = [UIAlertAction actionWithTitle:languageStringWithKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertC addAction:alertAction2];
        [alertC addAction:alertAction3];
        [self presentViewController:alertC animated:YES completion:nil];
    }else{
         WS(weakSelf);
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:languageStringWithKey(@"开启“手机通知静音”后，手机接收新消息通知将不再有提醒") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:languageStringWithKey(@"停止手机通知") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf setRestMuteWithAccount:myAccount withState:@"1"];
        }];
        UIAlertAction *alertAction3 = [UIAlertAction actionWithTitle:languageStringWithKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertC addAction:alertAction2];
        [alertC addAction:alertAction3];
        [self presentViewController:alertC animated:YES completion:nil];
        
    }
}

-(void)setRestMuteWithAccount:(NSString *)myAccount withState:(NSString *)myAccountMsgRule{
    NSString *oldState = myAccountMsgRule;
    [[RestApi sharedInstance]setMsgRuleUserAccount:myAccount withState:myAccountMsgRule withType:myAccountMsgRule  didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        NSLog(@"eagle.setMsgRule dict == %@",dict);
        if ([[dict objectForKey:@"statusCode"] isEqualToString:@"000000"]) {
            [AppModel sharedInstance].muteState = oldState;
            [self changeImage];
        }else{
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"设置失败")];
        }
    } didFailLoaded:^(NSError *error, NSString *path) {
        NSLog(@"eagle.setMsgRule error.code == %ld",(long)error.code);
    }];
}

-(void)changeImage{
//     NSString *myAccountMsgRule = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"MsgRule_%@",myAccount]];
    if ([[AppModel sharedInstance].muteState isEqualToString:@"2"]) {
        self.deviceImageView.image = ThemeImage(@"message_icon_computer");
        [self.muteBtn setImage:ThemeImage(@"message_btn_nomute_normal") forState:UIControlStateNormal];
    }else{
        self.deviceImageView.image = ThemeImage(@"message_icon_phone");
        [self.muteBtn setImage:ThemeImage(@"message_btn_mute_normal") forState:UIControlStateNormal];
    }
}

- (void)showExitAlert {
    WS(weakSelf)
    NSString *title = self.deviceType == 1 ? languageStringWithKey(@"退出 PC 容信") :self.deviceType == 2 ?languageStringWithKey(@"退出 Mac 容信") :languageStringWithKey(@"退出 WEB 容信");
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@?",title] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:languageStringWithKey(@"退出") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf exitLoginOutHCQ];
    }];
    UIAlertAction *alertAction3 = [UIAlertAction actionWithTitle:languageStringWithKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertC addAction:alertAction2];
    [alertC addAction:alertAction3];
    [self presentViewController:alertC animated:YES completion:nil];
}

-(void)exitLoginOutHCQ{
    //发送cmd消息 通知多终端已读消息
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"sessionId"] = [Common sharedInstance].getAccount;
    mDic[@"type"] = @(ChatMessageTypePCLoginout);
    [[ChatMessageManager sharedInstance] sendCmdMessageByDic:mDic callBack:^(ECError *error, ECMessage *amessage) {
        if (error.errorCode == ECErrorType_NoError) {
            self.isExitPC = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            NSString *title = self.deviceType == 1 ? languageStringWithKey(@"PC退出失败"):languageStringWithKey(@"Mac退出失败");
            [SVProgressHUD showErrorWithStatus:title];
        }
    }];
}


@end
