//
//  GroupVotingViewController.m
//  ECSDKDemo_OC
//
//  Created by 王文龙 on 16/6/27.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "GroupVotingViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "KCConstants_API.h"

@interface GroupVotingViewController ()<UIWebViewDelegate>

@end

@implementation GroupVotingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([UIDevice currentDevice].systemVersion.integerValue>7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    _webView.backgroundColor=[UIColor clearColor];
    _webView.clipsToBounds = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    NSDictionary *dic = self.data;
    
    NSString *groupId = [dic objectForKey:@"groupId"];
    NSString *account = [dic objectForKey:@"account"];
    NSString *votingUrl = [dic objectForKey:@"votingUrl"];
    if (!KCNSSTRING_ISEMPTY(votingUrl)) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",votingUrl,account]];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }else{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:7772/2015-03-26/Corp/yuntongxun/inner/groupvote/index?groupId=%@&account=%@",kHOST,groupId,account]];

        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    [SVProgressHUD showWithStatus:languageStringWithKey(@"正在加载...请稍后")];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:ThemeColorImage(ThemeImage(@"title_bar_back"), [UIColor blackColor]) style:UIBarButtonItemStylePlain target:self action:@selector(willPopViewController)];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _webView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight);
}

- (void)willPopViewController
{
    if ([_webView canGoBack]) {
        [_webView goBack];
    }else{
        [self popViewController];
    }
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    DDLogInfo(@"加载完成....webView.....");
    [SVProgressHUD dismiss];
    
//        typeof(self)weak_self=self;
    JSContext *context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"exitjs"] = ^() {
        [self willPopViewController];
    };
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DDLogInfo(@"加载失败....webView.....");
    [SVProgressHUD dismiss];
    
    NSString *errStr =languageStringWithKey(@"加载失败");
    
    if([error.domain isEqualToString:@"NSURLErrorDomain"])
    {
        errStr =[error localizedDescription];
    }else
    {
        errStr =error.domain;
    }
    
    [UIAlertView showAlertView:languageStringWithKey(@"提示") message:errStr click:^{
        [self willPopViewController];
        
    } okText:languageStringWithKey(@"确定")];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
