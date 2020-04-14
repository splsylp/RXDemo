//
//  ShowDocumentOfficeView.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/2.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ShowDocumentOfficeView.h"
#import "HXFileCacheManager.h"
#import "NSString+AES.h"
#import "HXWaterStainLayer.h"
#import "KCConstants_API.h"
#import "HXQLPreviewController.h"
#import "HYTApiClient+Ext.h"
@implementation ShowDocumentOfficeView
{
    NSString *_filePath;
    UIDocumentInteractionController *_myDocumentInteractionController;
    NSString *_decodeFilePath;
}
- (instancetype)initWithFrame:(CGRect)frame fileMessage:(ECMessage *)message;
{
    if(self =[super initWithFrame:frame])
    {
        _message =message;
        [self initUI];
    }
    return self;
}
-(void)initUI
{
    ECFileMessageBody *fileBody =(ECFileMessageBody *)_message.messageBody;
    

    NSDictionary *fileDic =[[SendFileData sharedInstance]getCacheFileData:fileBody.remotePath];
//    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    
    if(fileDic.count>0)
    {
        _filePath = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
        
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        DDLogInfo(@"%@", pathArray);
        [pathArray firstObject];
        
#pragma warning

        NSDictionary* userData =[MessageTypeManager getCusDicWithUserData:_message.userData];
        if ([userData hasValueForKey:@"encryption"]) {
            if ([[userData valueForKey:@"encryption"] isEqual:@"EnTrue"]) {
                [SVProgressHUD showWithStatus:languageStringWithKey(@"文件解密中")];

                NSString *key = _message.to;
                NSRange rang = [_filePath rangeOfString:@"." options:NSBackwardsSearch];
                NSString *fileDirectory = [_filePath substringToIndex:rang.location];
                NSString *fileType = [_filePath substringFromIndex:rang.location];
                
                
                NSString *directryPath = [[pathArray firstObject] stringByAppendingPathComponent:@"tempDocuments"];
                
                NSRange rang1 = [_filePath rangeOfString:@"/" options:NSBackwardsSearch];
                NSString *fileDirectory1 = [_filePath substringFromIndex:rang1.location];
                NSString *copyToString = [directryPath stringByAppendingPathComponent:fileDirectory1];

                
//                NSString *data = [NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:NULL];
//                DDLogInfo(@"******************%@",data);

                NSData *imageData = [NSData dataWithContentsOfFile:_filePath];
                
                //文件解密
                NSString *dataString = [[NSString alloc] initWithData:imageData  encoding:NSUTF8StringEncoding];

                NSString *encodeData = [NSString decodeData:dataString withKey:key];
                NSData *fileData = [[NSData alloc]initWithBase64EncodedString:encodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
                if ([fm createFileAtPath:copyToString contents:fileData attributes:nil]) {
                    DDLogInfo(@"******************%@",@"写入成功");
                }
                [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"解密完成")];
                _filePath = copyToString;
            }
        }
        
        
        if(!KCNSSTRING_ISEMPTY(_filePath))
        {
            //恒信所有
//            [self loadWebView:_filePath];
//            [self otherOpenFile];
//            return;
            
            NSString *fileUUid = [fileDic objectForKey:cachefileUuid];
            NSString *fileKey  = [fileDic objectForKey:cachefileKey];
            NSString *fileName = [fileDic objectForKey:cachefileDisparhName];
            //判断有没有UUid
            if(!KCNSSTRING_ISEMPTY(fileUUid) && KCNSSTRING_ISEMPTY(fileKey))
            {
                [self getFileKey:fileUUid dispathName:fileName];
                
            }else if (!KCNSSTRING_ISEMPTY(fileKey))
            {
                //解密 显示
                [self decodeFile:fileKey dispathName:fileName];
                
            }else
            {
                [SVProgressHUD showWithStatus:nil];
                //测试代码
                [self loadWebView:_filePath];
                 
//                [self otherOpenFile];
            }
            
            return;

        }
    }
    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"本地文件不存在")];
    
}

- (void)loadQLPreview
{
    HXQLPreviewController *qlPC = [[HXQLPreviewController alloc]init];
    //设置代理
    qlPC.dataSource = self;
    qlPC.delegate  =self;
    [self addSubview:qlPC.view];
    qlPC.view.frame = self.bounds;
    HXWaterStainLayer *overLayer = [HXWaterStainLayer initLayer];
    [qlPC.view.superview.layer addSublayer:overLayer];
    // [self.layer insertSublayer:overLayer below:qlPC.view.maskView.layer];
    
}

-(void)loadWebView:(NSString *)filePath
{
    NSURL *url = [NSURL fileURLWithPath:filePath];
    [SVProgressHUD showWithStatus:nil];
    
    _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, self.originY, self.width, self.height-40*fitScreenWidth)];
    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
    _wkWebView.backgroundColor=[UIColor clearColor];
    
    
    NSString *body = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    //识别不到，按GBK编码再解码一次.这里不能先按GB18030解码，否则会出现整个文档无换行bug。
    if (!body) {
        body = [NSString stringWithContentsOfFile:filePath encoding:0x80000632 error:nil];
    }
 
  //还是识别不到，按GB18030编码再解码一次.
    if (!body) {
        body = [NSString stringWithContentsOfFile:filePath encoding:0x80000631 error:nil];
    }
    if (body) {
       body = [body stringByAppendingString:@"<head><meta charset=\"utf-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"initial-scale=1.0, width=device-width\"></head>"];
        
        [_wkWebView loadHTMLString:body baseURL: nil];
    }else {
        if(iOS9)
        {
            NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[self fileURLForBuggyWKWebView8:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
            [request addValue:@"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" forHTTPHeaderField:@"Content-Type:"];
            [_wkWebView loadRequest:request];
            //            [_wkWebView loadFileURL:url allowingReadAccessToURL:url];
        }else{
            
            NSURL *fileUrl =[self fileURLForBuggyWKWebView8:url];
            [_wkWebView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
        }
    }
    
    [self addSubview:_wkWebView];
    [_wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0);
    }];
    
    
}

#pragma ios8以上9以下
//将文件copy到tmp目录
- (NSURL *)fileURLForBuggyWKWebView8:(NSURL *)fileURL {
    NSError *error = nil;
    if (!fileURL.fileURL || ![fileURL checkResourceIsReachableAndReturnError:&error]) {
        return nil;
    }
    // Create "/temp/www" directory
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"locationFile"];
    [fileManager createDirectoryAtURL:temDirURL withIntermediateDirectories:YES attributes:nil error:&error];
    
    NSURL *dstURL = [temDirURL URLByAppendingPathComponent:fileURL.lastPathComponent];
    // Now copy given file to the temp directory
    [fileManager removeItemAtURL:dstURL error:&error];
    [fileManager copyItemAtURL:fileURL toURL:dstURL error:&error];
    // Files in "/temp/www" load flawlesly :)
    return dstURL;
}

#pragma mark - WKWebViewDelegate
- (void)webViewDidClose:(WKWebView *)webView {
    
}
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
//    HXWaterStainLayer *overLayer = [HXWaterStainLayer initLayer];
//    [self.layer insertSublayer:overLayer above:_wkWebView.layer];
     [SVProgressHUD dismiss];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [SVProgressHUD dismiss];
}

//第三方软件打开
-(void)otherOpenFile
{
    _otherView =[[UIView alloc]initWithFrame:CGRectMake(0,kScreenHeight-40*fitScreenWidth-kTotalBarHeight, kScreenWidth, 40*fitScreenWidth)];
    _otherView.layer.backgroundColor =[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.6].CGColor;
    [self addSubview:_otherView];
    UIButton *otherButton =[UIButton buttonWithType:UIButtonTypeCustom];
    otherButton.frame=CGRectMake(10*fitScreenWidth, (_otherView.height-30*fitScreenWidth)/2, kScreenWidth/3, 30*fitScreenWidth);
    otherButton.layer.cornerRadius=5;
    otherButton.layer.masksToBounds=YES;
    [otherButton setBackgroundImage:[UIColor createImageWithColor:[UIColor colorWithRed:0.12f green:0.73f blue:0.95f alpha:1.00f] andSize:otherButton.size] forState:UIControlStateNormal];
    [otherButton setBackgroundImage:[UIColor createImageWithColor:[UIColor colorWithRed:0.09f green:0.64f blue:0.84f alpha:1.00f] andSize:otherButton.size] forState:UIControlStateHighlighted];
    [otherButton setTitle:languageStringWithKey(@"其他应用打开") forState:UIControlStateNormal];
    [otherButton setTitle:languageStringWithKey(@"其他应用打开") forState:UIControlStateHighlighted];
    otherButton.titleLabel.font = ThemeFontLarge;
    [_otherView addSubview:otherButton];
    [otherButton addTarget:self action:@selector(otherCheck:) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)otherCheck:(UIButton *)btn
{
    UIButton *button =(UIButton *)btn;
    _myDocumentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:_filePath]];
    _myDocumentInteractionController.delegate = self;
    
    BOOL ret = [_myDocumentInteractionController presentOptionsMenuFromRect:[button frame] inView:self animated:YES];//documentInteractionControllerDidDismissOpenInMenu
    if (!ret){
        [SVProgressHUD showErrorWithStatus:@"open failed"];
    }
    //[_myDocumentInteractionController presentOpenInMenuFromRect:[button frame] inView:self animated:YES];
}

#pragma mark 获取文件Key

- (void)getFileKey:(NSString *)fileUUid dispathName:(NSString *)fileName
{
    
    __weak typeof(self)weak_self = self;
    [HYTApiClient getKeyByFileNodeIdWithAccount:[Common sharedInstance].getAccount withNodeId:fileUUid didFinishLoaded:^(NSDictionary *json, NSString *path) {
        
        __strong typeof(weak_self)strong_self = weak_self;
        
        NSDictionary* head = [json objectForKey:@"head"];
        
        NSString *statuscode = [head objectForKey:@"statusCode"];
        
        if([statuscode isEqualToString:@"000000"]){
            
            NSDictionary *bodyJson =[json objectForKey:@"body"];
            
            
            NSString *fileKey = [bodyJson objectForKey:@"fileKey"];
            
            [[SendFileData sharedInstance]updateFileKey:fileKey withFileUUid:fileUUid];
            
            [strong_self decodeFile:fileKey dispathName:fileName];
            
        }else
        {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件处理失败")];
        }
        
    } didFailLoaded:^(NSError *error, NSString *path) {
        [HYTApiClient showErrorDomain:error];
    }];
}

#pragma mark 对文件进行解密

- (void)decodeFile:(NSString *)fileKey dispathName:(NSString *)fileName
{
    [SVProgressHUD showWithStatus:languageStringWithKey(@"文件处理中...")];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *fileData  = [NSData dataWithContentsOfFile:_filePath options:NSDataReadingMappedIfSafe error:nil];
        // NSString *decodeString =   [AESCrypt decrypt:[[NSString alloc]initWithData:fileData encoding:NSUTF8StringEncoding] password:fileKey];
        NSData *decodeData =[NSString decoded_aseData :fileData withKey:fileKey];
        
        NSString *tmpPath =  [HXFileCacheManager createAndSavaTmpFilecache:decodeData dispathName:fileName];
        //decodeData = nil;
        _decodeFilePath = tmpPath;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(!KCNSSTRING_ISEMPTY(tmpPath))
            {
                //[self loadWebView:tmpPath];
                [self loadQLPreview];
                [SVProgressHUD dismiss];
            }else
            {
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件暂时无法查看")];
            }
        });
        
    });
}

#pragma mark -- datasource协议方法
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    
    
    if ([_decodeFilePath hasSuffix:@"txt"] || [_decodeFilePath hasSuffix:@"TXT"]) {
        // 处理txt格式内容显示有乱码的情况
        NSData *fileData = [NSData dataWithContentsOfFile:_decodeFilePath];
        // 判断是UNICODE编码
        NSString *isUNICODE = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        // 还是ANSI编码（-2147483623，-2147482591，-2147482062，-2147481296）encoding 任选一个就可以了
        NSString *isANSI = [[NSString alloc] initWithData:fileData encoding:-2147483623];
        if (isUNICODE) {
        } else {
            NSData *data = [isANSI dataUsingEncoding:NSUTF8StringEncoding];
            [data writeToFile:_decodeFilePath atomically:YES];
        }
        return [NSURL fileURLWithPath:_decodeFilePath];
    } else {
        NSURL *fileURL = nil;
        fileURL = [NSURL fileURLWithPath:_decodeFilePath];
        return fileURL;
    }
    
    // return [NSURL fileURLWithPath:_decodeFilePath];
    
}


@end
