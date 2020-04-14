//
//  ListViewController.m
//  AddressKitDemo
//
//  Created by apple on 2019/10/23.
//  Copyright © 2019 zhangmingfei. All rights reserved.
//

#import "ListViewController.h"
#import "AppModel.h"
#import "RXAddressBook.h"
#import "UserCenter.h"
#import "SVProgressHUD.h"

@interface ListViewController () <AppModelDelegate>
@property (weak, nonatomic) IBOutlet UILabel *LoginTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *openAddressBookBtn;
@property (weak, nonatomic) IBOutlet UIButton *LookDetailBtn;
@property (strong, nonatomic) NSString *account;
@end

@implementation ListViewController

- (instancetype)initWithAccout:(NSString *)account {
    if (self = [super init]) {
        _account = account;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [AppModel sharedInstance].appModelDelegate = self;
    self.LoginTipLabel.text = [NSString stringWithFormat:@"登录账号：%@", _account];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}



- (IBAction)openAB:(id)sender {
    //获取通讯录界面
    UIViewController *vc= [[RXAddressBook sharedInstance] mainView];
    vc.navigationItem.title = @"通讯录";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)lookDetailInfo:(id)sender {
    UIViewController *contactorInfosVC = [[RXAddressBook sharedInstance] getContactorInfosVCWithData:_account];
    [self.navigationController pushViewController:contactorInfosVC animated:YES];
}



//MARK: - METHOD
- (void)setupUI {
    
    self.title = @"通讯录";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.openAddressBookBtn.layer.borderColor =
    self.LookDetailBtn.layer.borderColor =
    [UIColor colorWithRed:72/255.0 green:203/255.0 blue:131/255.0 alpha:1/1.0].CGColor;
    self.openAddressBookBtn.layer.borderWidth =
    self.LookDetailBtn.layer.borderWidth = 1;
}



//聊天界面
- (void)getChatVCWithAccount:(NSString *)account{
    [SVProgressHUD showErrorWithStatus:@"该功能需要配合IM插件使用"];
}

//插件用的接口，调用音视频呼叫
- (void)startCallForPlugiInViewWithDict:(NSString *)dict {
    [SVProgressHUD showErrorWithStatus:@"该功能需要配合IM插件使用"];
}

#pragma mark - AppModelDelegate
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



@end
