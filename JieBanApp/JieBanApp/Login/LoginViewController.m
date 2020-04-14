//
//  LoginViewController.m
//  FriendCircleDemo
//
//  Created by yongzhen on 17/3/7.
//  Copyright © 2017年 yongzhen. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "SVProgressHUD.h"
#import "UserCenter.h"
#import "RXAddressBook.h"
#import "AppModel.h"
#import "YHCManager.h"
#import "YHCConferenceHelper.h"
#import "Chat.h"
#import "IMConst.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

//登录按钮
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *loginAccount = [self getAccount];
    
    if (loginAccount) {
        _accountTextField.text = loginAccount;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"登录";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [YHCManager sharedInstance].delegate = [YHCConferenceHelper sharedInstance];

}

- (IBAction)loginButtonClick:(UIButton *)sender {

    if (_passwordTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        return;
    }
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          _accountTextField.text,@"name",
                          _passwordTextField.text,@"password",nil];
       
    [self loginWithDic:info];
}

- (void)loginWithDic:(NSDictionary *)info {
    NSString *loginAccount = info[@"name"];
    [self saveAccount:loginAccount];
    __block NSString *sdkAccount = info[@"account"];
    [[UserCenter sharedInstance] loginAS:info didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        NSDictionary *body = dict[@"body"];
        if (body[@"account"]) {
            sdkAccount = body[@"account"]; //这个账号包含了前缀
        }
        
        [self saveSDKAccount:sdkAccount];
        NSMutableDictionary *loginDict = [[NSMutableDictionary alloc] initWithCapacity:10];
        [loginDict setObject:body[@"account"] forKey:Table_User_account];
        [loginDict setObject:body[@"username"] forKey:Table_User_member_name];
        [loginDict setObject:body[@"phonenum"] forKey:Table_User_mobile];
        [[YHCManager sharedInstance] saveLoginInfoData:loginDict];
        [[YHCBoard sharedInstance] saveAppInfomationWithUserID:loginAccount AppId:@"ff8080815dbc080c015dbc9d7cd4000s" wbssAddress:@[@"114.255.119.167:5001"]];
        
        //更新通讯录部门信息
        [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getAllDepartInfo" :nil];
         
        //向SDK设置个人信息，推送使用
        [[Chat sharedInstance] setPersonInfoWithUserName:loginAccount withUserAcc:loginAccount];
         [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"登录成功", nil)];
         HomeViewController *homeVC = [[HomeViewController alloc] init];
         homeVC.sdkAccount =sdkAccount;
         homeVC.account =loginAccount;
         [self.navigationController pushViewController:homeVC animated:YES];
     } didFailLoaded:^(NSError *error, NSString *path) {
         self.passwordTextField.text = @"";
         [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"登录失败:%@",error.domain]];
     }];
}



- (NSString *)getAccount {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"loggedAccount"];
}

- (NSString *)getSDKAccount {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"sdkAccount"];
}

- (void)saveAccount:(NSString *)account {
    [[NSUserDefaults standardUserDefaults] setObject:account forKey:@"loggedAccount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveSDKAccount:(NSString *)account {
    [[NSUserDefaults standardUserDefaults] setObject:account forKey:@"sdkAccount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
