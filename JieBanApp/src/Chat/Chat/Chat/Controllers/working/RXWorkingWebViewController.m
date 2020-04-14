//
//  RXWorkingWebViewController.m
//  ECSDKDemo_OC
//
//  Created by 杨大为 on 2016/11/10.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "RXWorkingWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <CommonCrypto/CommonDigest.h>
#import <WebKit/WebKit.h>
#import "KCConstants_string.h"
#import "RXColorExChange.h"

@interface RXWorkingWebViewController ()<UIWebViewDelegate,WKUIDelegate,WKNavigationDelegate>
@property(nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong)UIWebView* webView;
@property(nonatomic,strong)WKWebView *wkWebView;
@end

@implementation RXWorkingWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(iOS7)
    {
        self.edgesForExtendedLayout =UIRectEdgeNone;
    }
    
   // self.title =[[DemoGlobalClass sharedInstance] checkUserAuth:ApprovalAuth]?@"审批":@"请假";
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake (0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight)];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backgroundView];
    self.view.backgroundColor = ThemeColor;
    self.backgroundView.hidden = YES;
    
//    if (iOS8) {
//        _wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 20, kScreenWidth, kScreenHeight-20)];
//        _wkWebView.UIDelegate = self;
//        _wkWebView.navigationDelegate = self;
//        _wkWebView.backgroundColor = [UIColor clearColor];
//        [self.view addSubview:_wkWebView];
//    }else{
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight)];
        _webView.delegate = self;
        _webView.backgroundColor=[UIColor clearColor];
          [self.view addSubview:_webView];
//    }
    
   NSString *urlString;
    //马祥202环境 密码用明文；恒丰用加密后的密码
    urlString = [NSString stringWithFormat:@"http://%@/public/checkUser/u/%@/p/%@",[Common sharedInstance].getApproval,[Common sharedInstance].getAccount,/*[Common sharedInstance].getOutlookPwd*/[Common sharedInstance].getPassMd5];
    DDLogInfo(@"urlString is :%@",urlString);
    ECMessage *msg = (ECMessage *)self.data;
    if (msg) {
        NSDictionary* userDict =[msg.userData coverDictionary];
        NSString * aprovestr = userDict[@"APRV_ID"];
        if (aprovestr.length > 0) {
             self.backgroundView.hidden = NO;
            [self.backgroundView bringToFront];
            _webView.hidden = YES;
            _wkWebView.hidden = YES;
        }
    }
    [SVProgressHUD showWithStatus:languageStringWithKey(@"正在进入,请稍后...")];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    if (iOS8) {
//        [_wkWebView loadRequest:request];
//    }else{
    [_webView loadRequest:request];
//    }
    [self setBarButtonWithNormalImg:ThemeImage(@"title_bar_back")
                     highlightedImg:ThemeImage(@"title_bar_back")
                             target:self
                             action:@selector(onClickLeftBarButtonItem)
                               type:NavigationBarItemTypeLeft];

}
- (void)onClickLeftBarButtonItem {
    if (_isPop) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 设置NavigationController的左右按钮
-(void)setBarButtonWithNormalImg:(UIImage *)normalImg
                  highlightedImg:(UIImage *)highlightedImg
                          target:(id)target
                          action:(SEL)action
                            type:(NavigationBarItemType)type
{
    
    CGRect btnFrame = CGRectMake(0, 0, 40, 40);
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:btnFrame];
    [button setImage:normalImg forState:UIControlStateNormal];
    [button setImage:highlightedImg forState:UIControlStateHighlighted];
    [button.imageView setContentMode:UIViewContentModeCenter];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    if (type == NavigationBarItemTypeLeft) {
        button.frame = CGRectMake(0, 0, 40, 40);
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 15)];
        self.navigationItem.leftBarButtonItem = buttonItem;
    }
    else{
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -15)];
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
    
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
     [SVProgressHUD dismiss];
    [webView goBack];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
     [SVProgressHUD dismiss];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    JSContext *context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"exitjs"] = ^() {
        
        [super popViewController];
    };
    ECMessage *msg = (ECMessage *)self.data;
    if (msg) {
        [NSThread sleepForTimeInterval:1];
        NSDictionary* userDict =[msg.userData coverDictionary];
        NSString * aprovestr = userDict[@"APRV_ID"];
        NSString *urlString;
        if (aprovestr.length > 0) {
            self.data = nil;
            urlString = [NSString stringWithFormat:@"http://%@/Index/info_approval/id/%@",[Common sharedInstance].getApproval,aprovestr];
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            [webView loadRequest:request];
        }
    }
    else if (webView.hidden) {
        [SVProgressHUD dismiss];
         self.backgroundView.hidden = YES;
        [self.backgroundView sendToBack];
        webView.hidden = NO;
    }
    else{
        [SVProgressHUD dismiss];
    }
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
    
    NSString *errStr =languageStringWithKey(@"加载失败");
    
    if([error.domain isEqualToString:@"NSURLErrorDomain"])
    {
        errStr =[error localizedDescription];
    }else
    {
        errStr =error.domain;
    }
//     [webView reload];
    if(error.code == NSURLErrorCancelled)  {
        return;
    }
    
    [UIAlertView showAlertView:languageStringWithKey(@"提示") message:errStr click:^{
    
       // [self backViewController];
    
    } okText:languageStringWithKey(@"确定")];

}
-(void)backViewController
{
    [super popViewController];
}


@end
