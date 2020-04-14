//
//  HomeViewController.m
//  RX-Plugin
//
//  Created by 刘某某 on 2020/3/27.
//  Copyright © 2020 刘某某. All rights reserved.
//

#import "HomeViewController.h"
#import "ListViewController.h"
#import "VoipViewController.h"
#import "AppModel.h"
#import "SVProgressHUD.h"
#import "YHCConference.h"
#import "RXBaseNavgationController.h"
#import "IMChatViewController.h"
@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"RX-Plugin";
   
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 45, 40);
    [btn setImage:[UIImage imageNamed:@"title_bar_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(popController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)popController {
    [self logoutClick:nil];
}


- (IBAction)logoutClick:(id)sender {
    [[AppModel sharedInstance] logout:^(NSError *error) {
        if (error.code == 200) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"退出成功", nil)];
            [self.navigationController popViewControllerAnimated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLogin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"退出失败", nil)];
        }
    }];
}

- (IBAction)address:(id)sender {
    ListViewController *listVC = [[ListViewController alloc] initWithAccout:self.sdkAccount];
    [self.navigationController pushViewController:listVC animated:YES];
}

- (IBAction)voip:(id)sender {
    VoipViewController *voipVc = [[VoipViewController alloc] initWithAccount:self.account];
    [self.navigationController pushViewController:voipVc animated:YES];
}

- (IBAction)confence:(id)sender {
    UIViewController *vc = [[YHCConference sharedInstance] getConflistVC];
    RXBaseNavgationController *nav = [[RXBaseNavgationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)IM:(id)sender {
    IMChatViewController *chatVc = [[IMChatViewController alloc] initWithAccount:self.account];
    [self.navigationController pushViewController:chatVc animated:YES];
}
@end
