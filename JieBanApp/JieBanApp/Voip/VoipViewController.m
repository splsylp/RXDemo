//
//  VoipViewController.m
//  VOIPKitDemo
//
//  Created by zhangmingfei on 2016/11/22.
//  Copyright © 2016年 zhangmingfei. All rights reserved.
//

#import "VoipViewController.h"
#import "AppModel.h"
#import "Dialing.h"
#import "SVProgressHUD.h"
#import "Common.h"

@interface VoipViewController () <ComponentDelegate, AppModelDelegate> {
    
}
//自己账号
@property (nonatomic, copy) NSString *myAccount;

@property (weak, nonatomic) IBOutlet UILabel *loginedTipLabel;
@property (weak, nonatomic) IBOutlet UITextField *otherPhoneNumTextField;
@property (nonatomic, weak) IBOutlet UIButton *telBtn;
@property (nonatomic, weak) IBOutlet UIButton *voiceBtn;
@property (nonatomic, weak) IBOutlet UIButton *videoBtn;

@property (nonatomic, assign) BOOL logoutSuccess;
@end

@implementation VoipViewController

- (instancetype)initWithAccount:(NSString *)account {
    if (self = [super init]) {
        _myAccount = account;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //UI布局
    [self setupUI];
    //设置代理
    [AppModel sharedInstance].appModelDelegate = self;
    [AppModel sharedInstance].owner = self.view.window;
    [Dialing sharedInstance].componentDelegate = self;
    
    self.loginedTipLabel.text = [NSString stringWithFormat:@"登录账号：%@",_myAccount];
}

//UI布局
- (void)setupUI {
    //背景色
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.telBtn.layer.borderColor =
    self.voiceBtn.layer.borderColor =
    self.videoBtn.layer.borderColor =
    [UIColor colorWithRed:72/255.0 green:203/255.0 blue:131/255.0 alpha:1/1.0].CGColor;
    self.telBtn.layer.borderWidth =
    self.voiceBtn.layer.borderWidth =
    self.videoBtn.layer.borderWidth = 1;
    
    //标题栏
    self.navigationItem.title = @"VOIP";
        

    [_telBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [_voiceBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];

    [_videoBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
 
}

- (void)btnClicked:(UIButton *)sender {
    [self.view endEditing:YES];
    NSString *otherSide = _otherPhoneNumTextField.text;
    if (otherSide.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请填写对方号码"];
        return;
    }
    
    if (![sender isEqual:_telBtn]) {
          NSDictionary* dict = [self getDicWithId:otherSide withType:1];
          if (dict) {
              if ([sender isEqual:_voiceBtn]) {
                   dict = @{
                           @"callType":@"0",
                           @"caller":dict[@"account"],
                           @"nickname":dict[@"member_name"],
                           @"callDirect":@(0)
                           };
               } else if ([sender isEqual:_videoBtn]) {
                   dict = @{
                           @"callType":@"1",
                           @"caller":dict[@"account"],
                           @"nickname":dict[@"member_name"],
                           @"callDirect":@(0)
                           };
               }
               [[Dialing sharedInstance] startCallViewWithDict:dict];
          }else{
              [SVProgressHUD showErrorWithStatus:@"未找到相关联系人"];
          }
      }else{
          NSDictionary* dict = @{};

           if (otherSide.length != 11) { //简易判断
                 [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
                 return;
             }
             dict = @{
                     @"callType":@"2",
                     @"caller":otherSide,
                     @"nickname":otherSide,
                     @"windowType":@"1" //windowType  0或不传 是正常   1是隐藏缩小按钮  2是自动缩小
                     };
          [[Dialing sharedInstance] startCallViewWithDict:dict];
      }
    

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ======================回调函数==========================
//获取用户信息
- (NSDictionary*)onGetUserInfo {
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
   NSDictionary * rxUserdict = [[AppModel sharedInstance] runModuleFunc:@"RXUser" :@"userForAccount:" :[NSArray arrayWithObject: @"getUserAppModel"]] ;
    if (rxUserdict[@"RX_account_key"]) {
        [dict setObject:rxUserdict[@"RX_account_key"] forKey:@"account"];
    }
 
    if (rxUserdict[@"RX_mobile_key"]) {
        [dict setObject:rxUserdict[@"RX_mobile_key"] forKey:@"mobile"];
    }

    if (rxUserdict[@"username"]) {
        [dict setObject:rxUserdict[@"username"] forKey:@"member_name"];
    }
    
    if (rxUserdict[@"RX_StaffNo"]) {
           [dict setObject:rxUserdict[@"RX_StaffNo"] forKey:@"staffNo"];
       }
    
    return dict;
}

/*
 @brief 获取联系人信息
 @param id 联系人的个人信息
 @param type 0:根据account获取，1:根据手机号获取
 @return 联系人信息
 */
- (NSDictionary*)getDicWithId:(NSString*)Id withType:(int) type {
    if (!Id) {
        return nil;
    }
    NSDictionary* dict = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getCompanyAddressWithId:withType:" :[NSArray arrayWithObjects:Id,[NSNumber numberWithInt:type], nil]];
    return dict;
}

//通话结束返回的信息
- (void)finishedCallWithError:(NSError *)error WithType:(VoipCallType)type WithCallInformation:(NSDictionary *)information  UserData:(NSString *)userData{
    //Call_status
    //100 正常挂断
    //101 主叫时,主叫挂断,未接通
    //102 主叫时,被叫拒绝
    //201 被叫时,对方挂断,未接通
    //202 被叫时,拒绝接听
    NSString *CallInitiatorID = information[@"CallInitiatorID"]; //接听的时候显示的对方号码
    NSString *CallReceiverID = information[@"CallReceiverID"];   //拨打时显示的对方号码
    NSInteger Call_status = [information[@"Call_status"] integerValue];         //状态
    double startTime = [information[@"startTime"] doubleValue];             //开始时间
    double endTime = [information[@"endTime"] doubleValue];                 //结束时间
    
    switch (Call_status) {
        case 100:
            NSLog(@"拨打 对方：%@ 开始时间：%f   结束时间:%f",CallReceiverID, startTime , endTime);
            break;
        case 101: {
            NSLog(@"对方：%@ 未接听", CallReceiverID);
        }   break;
        case 102: {
            NSLog(@"对方：%@ 拒绝接听", CallReceiverID);
        }   break;
        case 201: {
            NSLog(@"来电  对方：%@ 对方挂断，未接通", CallInitiatorID );
        }   break;
        case 202: {
            NSLog(@"拒绝了对方: %@", CallInitiatorID);
        }   break;
        default:
            break;
    }
}

@end
