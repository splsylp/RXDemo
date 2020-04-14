//
//  HXOnlineReadFileView.m
//  ECSDKDemo_OC
//
//  Created by yuxuanpeng on 2017/4/24.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXOnlineReadFileView.h"
#import "HXWaterStainLayer.h"
#import "HYTApiClient+Ext.h"
#import "HXFileCacheManager.h"
#import "RXThirdPart.h"
@implementation HXOnlineReadFileView

- (instancetype)initWithFrame:(CGRect)frame fileUuid:(NSString *)fileUuid fileKey:(NSString *)fileKey fileRemoteUrl:(NSString *)fileLoadUrl messageId:(NSString *)sessionId fileSize:(NSString *)fileSize filePathName:(NSString *)fileName
{
    if(self =[super initWithFrame:frame])
    {
        _fileUuid = fileUuid;
        _fileLoadUrl =  fileLoadUrl;
        if(!KCNSSTRING_ISEMPTY(fileKey))
        {
            [self pieceTogetherUrl:fileKey];
        }else
        {
            [self showProgressWithMsg:languageStringWithKey(@"文件处理中...")];
            [self getFileKey:_fileUuid messageId:sessionId fileSiez:fileSize filePathName:fileName];
        }        
    }
    return self;
}

- (void)pieceTogetherUrl:(NSString *)fileKey
{
    NSArray *urlArray = [_fileLoadUrl componentsSeparatedByString:@"/"];
    if(urlArray.count>2)
    {
        NSArray *portArr= [urlArray[2] componentsSeparatedByString:@":"];
        if(portArr.count>1)
        {
            NSString *replacePortStr = portArr[1];
            NSString *replaceOther = urlArray[3];
            NSString *newUrl  =    [_fileLoadUrl stringByReplacingOccurrencesOfString:replacePortStr withString:@"8888"];
            NSString *endUrl  =  [newUrl stringByReplacingOccurrencesOfString:replaceOther withString:[NSString stringWithFormat:@"op_server/OnlinePreview"]];
            NSString *extension = [[_fileLoadUrl lastPathComponent] pathExtension];
            NSString *loadUrl = [NSString stringWithFormat:@"%@?suffix=%@&secretKey=%@",endUrl,extension,fileKey];
            [self loadWebView:loadUrl];
        }else
        {
          [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件不存在")];
            return;
        }
       
    }else
    {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件不存在")];
    }
}
-(void)loadWebView:(NSString *)fileUrl
{
    //NSURL *url =[NSURL fileURLWithPath:fileUrl];
    
    [self addSubview:self.wkWebView];
    [self showProgressWithMsg:languageStringWithKey(@"文件加载中...")];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:nil];
    longPress.minimumPressDuration = 0.2;
    longPress.delegate = self;
    [self.wkWebView addGestureRecognizer:longPress];
    
    [_wkWebView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:fileUrl]]];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;  //这里一定要return NO,至于为什么大家去看看这个方法的文档吧。
    //还有就是这个委托在你长按的时候会被多次调用，大家可以用DDLogInfo输出gestureRecognizer和otherGestureRecognizer
    //看看都是些什么东西。
}

-(WKWebView *)wkWebView
{
    if(!_wkWebView)
    {
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, self.originY, self.width, self.height)];
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        _wkWebView.backgroundColor=[UIColor clearColor];
    }
    
    return _wkWebView;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if ([UIMenuController sharedMenuController]) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    } return NO;
}
#pragma mark - WKWebViewDelegate
- (void)webViewDidClose:(WKWebView *)webView {

}
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [self closeProgress];
    [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none'" completionHandler:nil];
    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none'" completionHandler:nil];
    
//    WaterBackView *waterView = [[WaterBackView alloc] initWithFrame:self.bounds mobile:[Common sharedInstance].getStaffNo userName:[Common sharedInstance].getUserName backColor:[UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f]];
//    [self addSubview:waterView];
//    [self sendSubviewToBack:waterView];
    
    HXWaterStainLayer *overLayer = [HXWaterStainLayer initLayer];
    [self.layer insertSublayer:overLayer above:self.wkWebView.layer];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self closeProgress];
}

#pragma mark  getFileKey
#pragma mark 获取文件Key

- (void)getFileKey:(NSString *)fileUUid messageId:(NSString *)sessionId fileSiez:(NSString *)fileSize filePathName:(NSString *)fileName
{
    
    __weak typeof(self)weak_self = self;
    [HYTApiClient getKeyByFileNodeIdWithAccount:[Common sharedInstance].getAccount withNodeId:fileUUid didFinishLoaded:^(NSDictionary *json, NSString *path) {
        
        __strong typeof(weak_self)strong_self = weak_self;
        
        NSDictionary* head = [json objectForKey:@"head"];
        
        NSString *statuscode = [head objectForKey:@"statusCode"];
        
        if([statuscode isEqualToString:@"000000"]){
            
            NSDictionary *bodyJson =[json objectForKey:@"body"];
            
            
            NSString *fileKey = [bodyJson objectForKey:@"fileKey"];
            
            NSDictionary *fileDic =@{cachefileUrl:_fileLoadUrl,cacheimSissionId:sessionId,
                                     cachefileDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument,cachefileIdentifer:[HXFileCacheManager createRandomFileName],cachefileDisparhName:!KCNSSTRING_ISEMPTY(fileName)?fileName:[_fileLoadUrl lastPathComponent],cachefileExtension:[[_fileLoadUrl lastPathComponent] pathExtension]?[[_fileLoadUrl lastPathComponent] pathExtension]:@"",cachefileSize:fileSize,cachefileUuid:KSCNSTRING_ISNIL(fileUUid),cachefileKey:KSCNSTRING_ISNIL(fileKey)};
            [[SendFileData sharedInstance] insertFileinfoData:fileDic];
            [strong_self closeProgress];
            [strong_self pieceTogetherUrl:fileKey];
            
        }else
        {
            [strong_self closeProgress];

            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件处理失败")];
        }
        
    } didFailLoaded:^(NSError *error, NSString *path) {
        [weak_self closeProgress];

        [HYTApiClient showErrorDomain:error];
    }];
}
-(void)showProgressWithMsg:(NSString *)msg{
    [SVProgressHUD showWithStatus:msg];
}
-(void)closeProgress{
    [SVProgressHUD dismiss];
}
- (void)dealloc
{
}

@end
