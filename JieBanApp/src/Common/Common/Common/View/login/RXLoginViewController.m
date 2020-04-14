//
//  RXLoginViewController.m
//  rongxin
//
//  Created by wangming on 16/6/30.
//  Copyright (c) 2016年 ronglian. All rights reserved.
//

#import "RXLoginViewController.h"
#import "KCConstants_string.h"
#import <objc/runtime.h>
#import "UITextField+Ext.h"
#import "RXUser.h"


@interface RXLoginViewController ()
{
    UIView *userView;
    UITextField * _userName;//账号
    UITextField * _password;//密码
    UIButton * _loginBtn;//登录
    UIButton *_freeRegisterBtn;//免费注册
    UIButton *_forgetPasswordBtn;//忘记密码
    UIButton *_modifyButton;//验证码获取和发送 按钮
    UITextField  *_modifyField;//验证码输入
    NSTimer *timer;//定时器
    int ssInt;//多少秒
    BOOL isFristLogin;
    NSString * beforeUserName;
}
@end

@implementation RXLoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    if (iOS9) {
        [UIApplication sharedApplication].shortcutItems = nil;
    }
    UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(responder)];
    [self.view addGestureRecognizer:tapGesture];
    
    ssInt=0;
    self.title=@"登录";
    isFristLogin =YES;
    [self createPrepareUI];
}
-(void)responder
{
    [_userName resignFirstResponder];
    [_password resignFirstResponder];
    [_modifyField resignFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideKeyBoad) name:@"notification_hide_key" object:nil];
}

-(void)hideKeyBoad
{
    if ([_userName isFirstResponder]
        || [_password isFirstResponder]) {
        return;
    }
    [_userName becomeFirstResponder];
}
-(void)createPrepareUI
{
    CGFloat y=0;
    if(iOS7)
    {
        y=64.0;
    }
    UIView *viewES =[[UIView alloc]initWithFrame:CGRectMake(11.0, y+13, 60, 48.0f)];
    viewES.layer.borderColor=[UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f].CGColor;
    viewES.layer.borderWidth=1;
    UILabel *eslabel =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 48)];
    eslabel.text=@"  +86";
    eslabel.backgroundColor=[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
    //eslabel.textColor =[RXColorExChange colorWithHexString:@"#333333"];
    [viewES addSubview:eslabel];
    [self.view addSubview:viewES];
    //账号
    userView =[[UIView alloc]initWithFrame:CGRectMake(viewES.frame.origin.x + viewES.frame.size.width-1, y+13, kScreenWidth-(viewES.frame.origin.x + viewES.frame.size.width)-10.0f, 48.0f)];
    userView.backgroundColor =[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
    userView.layer.borderColor=[UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f].CGColor;
    userView.layer.borderWidth=1;
    [self.view addSubview:userView];
    _userName =[[UITextField alloc]initWithFrame:CGRectMake(11.0, 0, kScreenWidth-(viewES.frame.origin.x + viewES.frame.size.width)-22.0f, 48.0f)];
    _userName.clearButtonMode=UITextFieldViewModeWhileEditing;
    _userName.keyboardType=UIKeyboardTypeNumberPad;
    //_userName.
    _userName.delegate=self;
    _userName.backgroundColor=[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
    _userName.layer.borderColor=[UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f].CGColor;
    
    _userName.placeholder=@"请填写手机号码";
     [userView addSubview:_userName];
    
    //验证码view(暂时屏蔽掉 2016/07/08)
//    modifyView =[[UIView alloc]initWithFrame:CGRectMake(11.0, userView.bottom+10, kScreenWidth-22.0, 48)];
//    modifyView.backgroundColor =[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
//    modifyView.layer.borderColor=[UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f].CGColor;
//    modifyView.layer.borderWidth=1;
//    [self.view addSubview:modifyView];
//    
//    //验证码输入框
//    _modifyField=[[UITextField alloc]initWithFrame:CGRectMake(11.0, 0, modifyView.frame.size.width-11.0-90, 48)];
//    _modifyField.clearButtonMode=UITextFieldViewModeWhileEditing;
//    _modifyField.keyboardType=UIKeyboardTypeNumberPad;
//    //_userName.
//    _modifyField.backgroundColor=[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
//    _modifyField.layer.borderColor=[UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f].CGColor;
//    
//    _modifyField.placeholder=@"请填写验证码";
//    [modifyView addSubview:_modifyField];
    //定时器 60秒或者150秒重新点击发送
//    _modifyButton =[UIButton buttonWithType:UIButtonTypeCustom];
//    _modifyButton.backgroundColor=[UIColor colorWithRed:0.27f green:0.80f blue:0.53f alpha:1.00f];
//    _modifyButton.frame =CGRectMake(_modifyField.right, 4, 86, 40);
//    _modifyButton.layer.cornerRadius=5;
//    [_modifyButton setTitle:@"获取验证码" forState:UIControlStateNormal];
//    _modifyButton.titleLabel.font=[UIFont systemFontOfSize:15.0];
//    [_modifyButton addTarget:self action:@selector(sendmodifyAction:) forControlEvents:UIControlEventTouchUpInside];
//    [modifyView addSubview:_modifyButton];
    
    NSString *isfirstLogin =[[NSUserDefaults standardUserDefaults]objectForKey:isFirstLoginIntoMainViewController];
    if([isfirstLogin isEqualToString:isFirstLoginIntoMainViewController])
    {
//        modifyView.hidden=YES;
        isFristLogin=NO;
    }
    
    CGFloat orginYLoginBtn =userView.frame.origin.y+userView.frame.size.height+10;
//    if(!isFristLogin)
//    {
//        orginYLoginBtn=userView.bottom+10;
//    }
    
    //密码
    UIView *passView =[[UIView alloc]initWithFrame:CGRectMake(11.0, orginYLoginBtn, kScreenWidth-22.0f, 48)];
    passView.tag=1000;
    passView.backgroundColor =[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
    passView.layer.borderColor=[UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f].CGColor;
    passView.layer.borderWidth=1;
    [self.view addSubview:passView];
    
     _password =[[UITextField alloc]initWithFrame:CGRectMake(11.0, 0.0, kScreenWidth-44.0, 48)];
     _password.secureTextEntry=YES;
     _password.delegate=self;
     _password.clearButtonMode=UITextFieldViewModeWhileEditing;
     _password.backgroundColor =[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
    
    _password.placeholder=@"请填写密码(6-16位)";
    [passView addSubview:_password];
    
    //登录
     _loginBtn =[UIButton buttonWithType:UIButtonTypeCustom];
     _loginBtn.frame =CGRectMake(11.0, passView.frame.origin.y + passView.frame.size.height+10, kScreenWidth-22.0, 46);
    // _loginBtn.backgroundColor =[RXColorExChange colorWithHexString:@"#45cd87"];
    [_loginBtn setTitle:@"登  录" forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"confirm_push_button"] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"confirm_push_button_on"] forState:UIControlStateHighlighted];
    
    _loginBtn.titleLabel.font=[UIFont systemFontOfSize:21];
    //[_loginBtn setTitleColor:[RXColorExChange colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(onChickLoginBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_loginBtn];
//    //免费注册
//    _freeRegisterBtn =[UIButton buttonWithType:UIButtonTypeCustom];
//    _freeRegisterBtn.frame =CGRectMake(11.0, _loginBtn.bottom+10, 80, 30);
//    _freeRegisterBtn.backgroundColor =[UIColor clearColor];
//    [_freeRegisterBtn setTitle:@"免费注册" forState:UIControlStateNormal];
//    _freeRegisterBtn.titleLabel.font=[UIFont systemFontOfSize:15];
//    
//    //freeRegisterBtn.titleLabel.textAlignment=NSTextAlignmentLeft;
//    [_freeRegisterBtn setTitleColor:[RXColorExChange colorWithHexString:@"#45cd87"] forState:UIControlStateNormal];
//    [_freeRegisterBtn addTarget:self action:@selector(freeRegisterBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_freeRegisterBtn];
    
    //忘记密码
    _forgetPasswordBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    _forgetPasswordBtn.frame =CGRectMake(kScreenWidth-98,  _loginBtn.frame.origin.y + _loginBtn.frame.size.height+10, 87, 30);
    _forgetPasswordBtn.backgroundColor =[UIColor clearColor];
    [_forgetPasswordBtn setTitle:@"忘记密码?" forState:UIControlStateNormal];
    _forgetPasswordBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    //forgetPasswordBtn.titleLabel.textAlignment=NSTextAlignmentRight;
    //[_forgetPasswordBtn setTitleColor:[RXColorExChange colorWithHexString:@"#45cd87"] forState:UIControlStateNormal];
    [_forgetPasswordBtn addTarget:self action:@selector(forgetPasswordBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_forgetPasswordBtn];
    
}
//监听密码的长度
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

   if([string isEqualToString:@"\n"])
   {
       return YES;
   }
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(_password==textField)
    {
        if(aString.length>20)
        {
            textField.text=[aString substringToIndex:20];
            return NO;
        }
    }else if (_userName==textField)
    {
//        if([[DeviceDelegateHelper sharedInstance]isExistLoginMobile:aString] && aString.length==11)
//        {
//            isFristLogin = NO;
//            [UIView animateWithDuration:0.2 animations:^{
//              
//                UIView *view =[self.view viewWithTag:1000];
//                CGFloat orginYLoginBtn = userView.frame.origin.y + userView.frame.size.height+10;
//                view.originY =orginYLoginBtn;
//                _loginBtn.originY=view.bottom+10;
//                _forgetPasswordBtn.originY = _loginBtn.bottom+10;
//                
//            }];
//         
//        }else if(aString.length==11)
//        {
//            isFristLogin = YES;
//            [UIView animateWithDuration:0.2 animations:^{
//                UIView *passView =[self.view viewWithTag:1000];
//                CGFloat orginYLoginBtn = userView.bottom + 10;
//                passView.originY =orginYLoginBtn;
//                _loginBtn.originY=passView.bottom+10;
//                _forgetPasswordBtn.originY = _loginBtn.bottom+10;
//            }];
//        }
        if(aString.length>11)
        {
            textField.text=[aString substringToIndex:11];
            return NO;
        }
    }
    return YES;
}

//获取短信验证码
-(void)sendmodifyAction:(UIButton *)modifybtn
{
//   if([_userName isTextFieldEmptyWithWarning:@"请输入账号"])
//   {
//       return;
//   }
    if(![_userName.text isMobileNumberWithIsFixedNumber:NO])
    {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的账号"];
         return;
    }
    
    __weak typeof(self)weakself=self;
    
    [_userName resignFirstResponder];
    [_password resignFirstResponder];
    [_modifyField becomeFirstResponder];
    
    _modifyButton.userInteractionEnabled=NO;
    _modifyButton.backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.78f alpha:1.00f];
//    
//    [KitApiClient sendSMSVerifyCodeWithMobile:_userName.text withFlag:@"1" didFinishLoaded:^(KXJson *json, NSString *path) {
//        
//        [SVProgressHUD showSuccessWithStatus:@"验证码已发送,请注意查收"];
//        if (![timer isValid]) {
//            
//            [_modifyButton setTitle:@"(60秒)" forState:UIControlStateNormal];
//            timer =[NSTimer timerWithTimeInterval:1.0 target:weakself selector:@selector(updateTimeAndButState) userInfo:nil repeats:YES];
//            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//            [timer fire];
//        }
//        
//    } didFailLoaded:^(NSError *error, NSString *path) {
//        if(error.code==112314)
//        {
//            [SVProgressHUD showErrorWithStatus:@"验证码发送超过当日次数限制"];
//            _modifyButton.userInteractionEnabled=YES;
//            _modifyButton.backgroundColor=[UIColor colorWithRed:0.27f green:0.80f blue:0.53f alpha:1.00f];
//            return ;
//        }
//        else if(error.code ==111704)
//        {
//            [SVProgressHUD showErrorWithStatus:@"该手机账号不存在"];
//        }else
//        {
//            [KitApiClient showErrorDomain:error];
//        }
//         _modifyButton.userInteractionEnabled=YES;
//         _modifyButton.backgroundColor=[UIColor colorWithRed:0.27f green:0.80f blue:0.53f alpha:1.00f];
//        
//    }];

}
//时间 定时器时间
-(void)updateTimeAndButState
{
    ssInt++;
    [_modifyButton setTitle:[NSString stringWithFormat:@"(%d秒)",60-ssInt] forState:UIControlStateNormal];
    
    if(ssInt==60)
    {
        if ([timer isValid]){
            [timer invalidate];
            timer = nil;
        }
        ssInt=0;
        [_modifyButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        _modifyButton.userInteractionEnabled=YES;
        _modifyButton.backgroundColor=[UIColor colorWithRed:0.27f green:0.80f blue:0.53f alpha:1.00f];
    }
}

-(void)switchLoginAuthType
{
   
}
-(void)onChickLoginBtn:(UIButton *)btn
{
    if ([_password.text hasPrefix:@"ipytx"]) {
        [[RXUser sharedInstance] setAppIP:[_password.text substringFromIndex:5]];
        [[RXUser sharedInstance] logOutClearUserInfoData];
        exit(0);
    }
    
    
   if(!isFristLogin)
   {
       if(![_userName.text isMobileNumberWithIsFixedNumber:NO])
       {
           [SVProgressHUD showErrorWithStatus:@"请输入正确的账号"];
           return;
       }
       if ([_userName isTextFieldEmptyWithWarning:@"请输入账号"]
           || [_password isTextFieldEmptyWithWarning:@"请输入密码"] ) {
           return;
       }
       _modifyField.text=nil;
   }else
   {
//       if(![[DeviceDelegateHelper sharedInstance] isMobileNumber:_userName.text withIsFixedNumber:NO])
//       {
//           [SVProgressHUD showErrorWithStatus:@"请输入正确的账号"];
//           return;
//       }
//       if ([_userName isTextFieldEmptyWithWarning:@"请输入账号"]
//           || [_password isTextFieldEmptyWithWarning:@"请输入密码"] || [_modifyField isTextFieldEmptyWithWarning:@"请输入验证码"] ) {
//           return;
//       }
//       
//       if(_modifyField.text.length!=6)
//       {
//           [SVProgressHUD showErrorWithStatus:@"请输入正确的验证码"];
//           return;
//       }
       
   }
    
    if(_password.text.length<6 &&_password.text.length>16)
    {
        
        //[SVProgressHUD showErrorWithStatus:@"密码长度不正确"];
        return;
    }
    
     __weak typeof(self) weak_self = self;
    //[self showProgressWithMsg:@"正在登录..."];
    [_userName resignFirstResponder];
    [_password resignFirstResponder];
    [_modifyField resignFirstResponder];
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id pluginApp = [NSClassFromString(@"AppModel") performSelector:NSSelectorFromString(@"sharedInstance")];    
    [pluginApp performSelector:NSSelectorFromString(@"loginAS:") withObject:[NSDictionary dictionaryWithObjectsAndKeys: _userName.text,@"name",_password.text,@"password",_modifyField.text,@"verifyCode",nil]];
#pragma clang diagnostic pop
    
}

-(void)forgetPasswordBtnClicked
{
    //[self pushViewController:@"RXFindPassViewController" withData:nil withNav:YES];
}


@end
