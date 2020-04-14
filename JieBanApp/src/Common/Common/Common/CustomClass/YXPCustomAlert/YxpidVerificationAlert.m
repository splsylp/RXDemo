//
//  YxpidVerificationAlert.m
//  Common
//
//  Created by yuxuanpeng on 2017/7/18.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "YxpidVerificationAlert.h"
#import "RestApi.h"
//#import "LoginLogicHelper.h"
@implementation YxpidVerificationAlert
{
    UIButton *_cancelBtn;//取消
    UILabel *_promptLabel;//提示
    UITextField *_passWordField;//密码输入
    UITextField *_imageCodeFiled;//图片验证码输入框
    UIButton *_updateBtn; //刷新按钮
    UIView *_alertView;//视图
    UIView *_imgCodeView;//图片验证码视图
    UIImageView *_imgCode;//图片验证码
    UIButton *_passWordBtn;//密码验证
    UIButton *_levessenBtn;//人脸验证
    NSString *_codeKey ;//imgKey
    
    BOOL _isNavigator;//是否有导航栏
    NSString *_prompt;//提示语
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:UIKeyboardWillShowNotification];
    [[NSNotificationCenter defaultCenter]removeObserver:UIKeyboardWillHideNotification];
}

- (instancetype)initWithAlert:(BOOL)isNavigator withPrompt:(NSString *)prompt
{
    if(self = [super init])
    {
        _isNavigator =isNavigator;
        _prompt = prompt;
        [self initUI];
        [self addNotification];
        [self updateImgCodeImage];
    }
    
    return self;
}
- (void)initUI
{
    [self setFrame:[UIScreen mainScreen].bounds];
    
    //背景
    UIView *bgView = [[UIView alloc] initWithFrame:self.frame];
    [bgView setBackgroundColor:[UIColor blackColor]];
    [bgView setAlpha:0.3];
    [self addSubview:bgView];
    
    _alertView = [[UIView alloc]initWithFrame:CGRectMake(40*fitScreenWidth, 180*fitScreenWidth-(_isNavigator?kTotalBarHeight:0), kScreenWidth-80*fitScreenWidth, 0)];
    _alertView.layer.cornerRadius= 10;
    _alertView.layer.masksToBounds = YES;
    _alertView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_alertView];
    
    //取消
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelBtn.frame = CGRectMake(_alertView.width-24*fitScreenWidth-5*fitScreenWidth, 5*fitScreenWidth, 24*fitScreenWidth, 24*fitScreenWidth) ;
    [_cancelBtn setImage:ThemeImage(@"verificationCancel") forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:_cancelBtn];
    
    //提示
    _promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 25*fitScreenWidth, 240*fitScreenWidth, 20*fitScreenWidth)];
    _promptLabel.font = ThemeFontLarge;
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.textColor = [UIColor redColor];
    _promptLabel.backgroundColor = [UIColor clearColor];
    _promptLabel.text =_prompt;
    [_alertView addSubview:_promptLabel];
    
    //密码输入
    _passWordField = [[UITextField alloc]initWithFrame:CGRectMake(14*fitScreenWidth, _promptLabel.bottom+15*fitScreenWidth, _alertView.width-28*fitScreenWidth, 38*fitScreenWidth)];
    _passWordField.placeholder = @"请输入恒信账号的密码";
    _passWordField.font = ThemeFontMiddle;
    _passWordField.borderStyle = UITextBorderStyleNone;
    _passWordField.secureTextEntry = YES;
    _passWordField.delegate = self;
    _passWordField.layer.borderWidth =1;
    _passWordField.layer.borderColor = [UIColor colorWithHexString:@"#D3D3D3"].CGColor;
    _passWordField.layer.cornerRadius = 5;
    _passWordField.layer.masksToBounds = YES;
    _passWordField.clearButtonMode=UITextFieldViewModeWhileEditing;
    _passWordField.leftViewMode = UITextFieldViewModeAlways;
    _passWordField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 38*fitScreenWidth)];
    _passWordField.backgroundColor = [UIColor clearColor];
    _passWordField.returnKeyType = UIReturnKeyDone;
    [_alertView addSubview:_passWordField];
    
    //验证码视图
    
    _imgCodeView = [[UIView alloc]initWithFrame:CGRectMake(14*fitScreenWidth, _passWordField.bottom+12*fitScreenWidth, _alertView.width-28*fitScreenWidth, 38*fitScreenWidth)];
    _imgCodeView.layer.cornerRadius = 5;
    _imgCodeView.layer.borderColor = [UIColor colorWithHexString:@"#D3D3D3"].CGColor;
    _imgCodeView.layer.borderWidth = 1;
    _imgCodeView.layer.masksToBounds = YES;
    [_alertView addSubview:_imgCodeView];
    
    //验证码
    _imageCodeFiled=[[UITextField alloc]initWithFrame:CGRectMake(0, 0, _imgCodeView.width-70*fitScreenWidth-30*fitScreenWidth-2, 38*fitScreenWidth)];
    _imageCodeFiled.clearButtonMode=UITextFieldViewModeAlways;
    _imageCodeFiled.delegate=self;
    _imageCodeFiled.returnKeyType=UIReturnKeyDone;
    UIView *paddingView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 38*fitScreenWidth)];
    paddingView.backgroundColor = [UIColor clearColor];
    _imageCodeFiled.leftView=paddingView;
    _imageCodeFiled.leftViewMode = UITextFieldViewModeAlways;
    _imageCodeFiled.font = ThemeFontMiddle;
    
    _imageCodeFiled.placeholder=@"请输入验证码";
    [_imgCodeView addSubview:_imageCodeFiled];
    
    UIView *firstView = [[UIView alloc]initWithFrame:CGRectMake(_imageCodeFiled.right, 0, 1, 38*fitScreenWidth)];
    firstView.backgroundColor = [UIColor colorWithHexString:@"#D3D3D3"];
    [_imgCodeView addSubview:firstView];
    
    //图片验证码
    _imgCode =[[UIImageView alloc]initWithFrame:CGRectMake(firstView.right, 0, 70*fitScreenWidth, 38*fitScreenWidth)];
    _imgCode.backgroundColor = [UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:0.7f];
    [_imgCodeView addSubview:_imgCode];
    
    UIView *twoView = [[UIView alloc]initWithFrame:CGRectMake(_imgCode.right, 0, 1, 38*fitScreenWidth)];
    twoView.backgroundColor = [UIColor colorWithHexString:@"#D3D3D3"];
    [_imgCodeView addSubview:twoView];
    
    //刷新验证码按钮
    _updateBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    _updateBtn.frame =CGRectMake(_imgCode.right + 4*fitScreenWidth, (38*fitScreenWidth-18*fitScreenWidth)/2, 22*fitScreenWidth, 18*fitScreenWidth);
    [_updateBtn setImage:ThemeImage(@"verificationRefresh") forState:UIControlStateNormal];
    [_updateBtn setBackgroundColor:[UIColor whiteColor]];
    
    
    [_updateBtn addTarget:self action:@selector(updateImgCodeImage) forControlEvents:UIControlEventTouchUpInside];
    [_imgCodeView addSubview:_updateBtn];
    
    //密码按钮
    _passWordBtn = [[UIButton alloc]initWithFrame:CGRectMake(14*fitScreenWidth, _imgCodeView.bottom+12*fitScreenWidth, _alertView.width-28*fitScreenWidth, 38*fitScreenWidth)];
    _passWordBtn.backgroundColor = [UIColor colorWithHexString:@"#369BEC"];
    [_passWordBtn setTitle:@"密码验证" forState:UIControlStateNormal];
    [_passWordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    _passWordBtn.titleLabel.font = ThemeFontLarge;
    _passWordBtn.layer.cornerRadius = 5;
    _passWordBtn.layer.masksToBounds =YES;
    [_passWordBtn addTarget:self action:@selector(passLogin:) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:_passWordBtn];
    
    //人脸验证按钮
    _levessenBtn = [[UIButton alloc]initWithFrame:CGRectMake(14*fitScreenWidth, _passWordBtn.bottom+8*fitScreenWidth, _alertView.width-28*fitScreenWidth, 38*fitScreenWidth)];
    [_levessenBtn setTitle:@"人脸验证" forState:UIControlStateNormal];
    [_levessenBtn setTitleColor:[UIColor colorWithHexString:@"#369BEC"] forState:UIControlStateNormal];
    _levessenBtn.titleLabel.font = ThemeFontLarge;
    [_levessenBtn addTarget:self action:@selector(levenssLogin:) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:_levessenBtn];
    
    _alertView.height = _levessenBtn.bottom + 10*fitScreenWidth;
    
}
//刷新验证码
- (void)updateImgCodeImage
{
    if(KCNSSTRING_ISEMPTY(_codeKey)){
        CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
        CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
        NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
        CFRelease(uuid_ref);
        CFRelease(uuid_string_ref);
        _codeKey =[uuid lowercaseString];
    }
    
    _updateBtn.enabled=NO;
    _imageCodeFiled.text = nil;
    [[RestApi sharedInstance] getLoginImageCodeWithUuid:_codeKey didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        NSString *statusStr = [[dict objectForKey:@"head"] objectForKey:@"statusMsg"];
        NSInteger errorCode = [[[dict objectForKey:@"head"] objectForKey:@"statusCode"] intValue];
        
        if (errorCode == 0) {
            NSDictionary  *body =[dict objectForKey:@"body"];
            NSString *base64ImgUrl =[body objectForKey:@"imgBase64"];
            
            NSData *data =[[NSData alloc]initWithBase64EncodedString:base64ImgUrl?base64ImgUrl:@"" options:0];
            UIImage *dataImage =[UIImage imageWithData:data];
            _imgCode.image=dataImage;
            
        }else{
            [SVProgressHUD showErrorWithStatus:statusStr];
        }
        [_updateBtn setSelected:NO];
        _updateBtn.enabled=YES;
        
    } didFailLoaded:^(NSError *error, NSString *path) {
        
        [_updateBtn setSelected:NO];
         _updateBtn.enabled=YES;
        [RestApi showErrorDomain:error];
    }];
}

#pragma mark btn Event

- (void)cancelAction
{
    [_passWordField resignFirstResponder];
    [_imageCodeFiled resignFirstResponder];
    [self removeFromSuperview];
}

//- (void)passLogin:(UIButton *)sender
//{
//
//    if(KCNSSTRING_ISEMPTY(_passWordField.text))
//    {
//        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
//        return;
//    }
//    if(KCNSSTRING_ISEMPTY(_imageCodeFiled.text))
//    {
//        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
//        return;
//    }
//
//    [_passWordField resignFirstResponder];
//    [_imageCodeFiled resignFirstResponder];
//     [[LoginLogicHelper shardInstance] loginTypePassWord:[Common sharedInstance].getOaAccount verifyCode:nil passwd:_passWordField.text userType:1 imageCodeKey:_codeKey imageCode:_imageCodeFiled.text compId:nil loginType:HXloginType_update_token prompt:@"正在验证用户信息..."];
//}
//
//- (void)levenssLogin:(UIButton *)sender
//{
//    [_passWordField resignFirstResponder];
//    [_imageCodeFiled resignFirstResponder];
//    [[LoginLogicHelper shardInstance] checkLevenessRegisterUserId:[Common sharedInstance].getOaAccount];
//
//}

#pragma mark -------网络请求回调---------

- (void)requestSucceed
{
   if(self.verifyDelegate && [self.verifyDelegate respondsToSelector:@selector(verifyRequestSuccess)])
   {
       [self.verifyDelegate verifyRequestSuccess];
   }
    [self cancelAction];
}

#pragma --------系统控件代理事件---------
#pragma mark - SystemDelegate
#pragma ------UITextFieldDelegate------------------------

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==_passWordField)
    {
        [_passWordField resignFirstResponder];
        
    }else if (textField==_imageCodeFiled)
    {
        [_imageCodeFiled resignFirstResponder];
    }
    
    return YES;
}

#pragma mark systemEvent
-(void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestSucceed)
                                                 name:@"HXloginType_update_token"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestSucceed)
                                                 name:@"HXLoginType_verify_dignity"
                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(updateImgCodeImage)
//                                                 name:HXupdateImageCode
//                                               object:nil];
}

-(void) keyboardWillShow:(NSNotification*)note
{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    CGRect containerFrame = _alertView.frame;
    containerFrame.origin.y =self.bounds.size.height - keyboardBounds.size.height  - _alertView.height-(_isNavigator?kTotalBarHeight:0);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    _alertView.frame = containerFrame;
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification*)note
{
    CGRect containerFrame = _alertView.frame;
    containerFrame.origin.y =180*fitScreenWidth-(_isNavigator?kTotalBarHeight:0);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    _alertView.frame = containerFrame;
    [UIView commitAnimations];
}

@end
