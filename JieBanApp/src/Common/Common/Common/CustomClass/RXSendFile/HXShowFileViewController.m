//
//  HXShowFileViewController.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/2.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "HXShowFileViewController.h"
#import "ShowDocumentOfficeView.h"
#import "ShowDocumentImageView.h"
#import "MSSBrowseActionSheet.h"
#import "CanNotOpenDocumentView.h"
#import "DocumentDownLoadView.h"
#import "HXOnlineReadFileView.h"
#import "HXQLPreviewController.h"
#import "HXFileCacheManager.h"
#import "UIImage+deal.h"
#import "RX_MKNetworkEngine.h"
@interface HXShowFileViewController ()<ShowDocumentImageViewDelegate,UIDocumentInteractionControllerDelegate,DocumentDownloadViewDelegate>
@property(nonatomic,strong)NSString *filePath;
@property(nonatomic,strong)ECMessage *message;
@property(nonatomic,strong)UIView *otherView;

@end

@implementation HXShowFileViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setTitle:languageStringWithKey(@"查看文档")];
    
    if([self.data isKindOfClass:[ECMessage class]]){
        _message = (ECMessage *)self.data;
        [self showDocumentFile];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)showDocumentFile{
    //判断文件本地是否存在
    ECFileMessageBody *fileBody = (ECFileMessageBody *)_message.messageBody;
    
    NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:fileBody.remotePath];
    if(fileDic.count > 0){
        self.title = [fileDic objectForKey:cachefileDisparhName]?[fileDic objectForKey:cachefileDisparhName]:languageStringWithKey(@"查看文档");
        [self showLocationFileDocument:fileDic];
    }else{
        if(KCNSSTRING_ISEMPTY(fileBody.remotePath)){
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件不存在")];
            return;
        }
        [self downloadFile:_message filePath:fileBody.remotePath];
    }
    if (!KCNSSTRING_ISEMPTY(fileBody.displayName)) {
        self.title = fileBody.displayName;
    }
}

//在线浏览文件
- (void)onlineReadFile:(ECMessage *)message filePath:(NSString *)filePath fileUuid:(NSString *)fileUuid fileKey:(NSString *)fileKey fileSize:(NSString *)fileSize fileName:(NSString *)fileName{
    NSString *fileExtention = [[filePath lastPathComponent] pathExtension];
    if ([NSObject isFileType_Doc:fileExtention] ||
        [NSObject isFileType_PPT:fileExtention] ||
        [NSObject isFileType_XLS:fileExtention] ||
        [NSObject isFileType_IMG:fileExtention] ||
        [NSObject isFileType_PDF:fileExtention] ||
        [NSObject isFileType_TXT:fileExtention] ||
        [NSObject isFileType_ZIP:fileExtention]
        ) {
        HXOnlineReadFileView *subview = [[HXOnlineReadFileView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight) fileUuid:fileUuid fileKey:fileKey fileRemoteUrl:filePath messageId:message.sessionId fileSize:fileSize filePathName:fileName];
        //subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:subview];
    }else{
        DocumentDownLoadView *subview = [[DocumentDownLoadView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight) filemessage:message];
        subview.delegate = self;
       // subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:subview];
    }
}

//下载文件
- (void)downloadFile:(ECMessage *)messAge filePath:(NSString *)filePath{
     NSString *fileExtention = [[filePath lastPathComponent] pathExtension];
    if ([NSObject isFileType_Doc:fileExtention] ||
        [NSObject isFileType_PPT:fileExtention] ||
        [NSObject isFileType_XLS:fileExtention] ||
        [NSObject isFileType_IMG:fileExtention] ||
        [NSObject isFileType_PDF:fileExtention] ||
        [NSObject isFileType_TXT:fileExtention] ||
        [NSObject isFileType_ZIP:fileExtention]
        ) {
        DocumentDownLoadView *subview = [[DocumentDownLoadView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight) filemessage:messAge];
        subview.delegate = self;
        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:subview];
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(0);
        }];
        subview.callBack = ^(ECError *error) {
            if (error.errorCode == ECErrorType_NoError) {
                ECFileMessageBody *fileBody =(ECFileMessageBody*)_message.messageBody;
                NSDictionary *fileDic =[[SendFileData sharedInstance]getCacheFileData:fileBody.remotePath];
                [self showLocationFileDocument:fileDic];
            }
        };
    }else
    {
        DocumentDownLoadView *subview = [[DocumentDownLoadView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight) filemessage:messAge];
        subview.delegate = self;
        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:subview];
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(0);
        }];
        subview.callBack = ^(ECError *error) {
            if (error.errorCode == ECErrorType_NoError) {
                ECFileMessageBody *fileBody =(ECFileMessageBody*)_message.messageBody;
                NSDictionary *fileDic =[[SendFileData sharedInstance]getCacheFileData:fileBody.remotePath];
                [self showLocationFileDocument:fileDic];
            }
        };
    }
}


//显示本地缓存
- (void)showLocationFileDocument:(NSDictionary *)fileDic{
    NSString *fileExtention = [fileDic objectForKey:cachefileExtension];
    
    if ([NSObject isFileType_Doc:fileExtention] ||
        [NSObject isFileType_PPT:fileExtention] ||
        [NSObject isFileType_XLS:fileExtention] ||
        [NSObject isFileType_PDF:fileExtention] ||
        [NSObject isFileType_TXT:fileExtention]
        ) {
        
        NSString *remoteUrl = [fileDic objectForKey:cachefileUrl];
        //增加一个新的逻辑 判断是否有uuid 有的话就是在线浏览模式 图片形式就不需要在线阅读
        NSString *fileUUid = [NSString fileMessageUUid:_message.userData];
        if(!KCNSSTRING_ISEMPTY(fileUUid) && !KCNSSTRING_ISEMPTY(remoteUrl) && ![NSObject isFileType_IMG:fileExtention])
        {
            [self onlineReadFile:_message filePath:[fileDic objectForKey:cachefileUrl] fileUuid:fileUUid fileKey:[fileDic objectForKey:cachefileKey] fileSize:[fileDic objectForKey:cachefileSize] fileName:[fileDic objectForKey:cachefileDisparhName]];
            return;
        }
        
        ShowDocumentOfficeView *subview = [[ShowDocumentOfficeView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight) fileMessage:_message];
        [self.view addSubview:subview];
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(0);
        }];
    }else if ([NSObject isFileType_IMG:fileExtention])
    {
        ShowDocumentImageView *subview = [[ShowDocumentImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,  kScreenHeight-kTotalBarHeight) fileMessage:_message];
        subview.delegate = self;
        [self.view addSubview:subview];
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(0);
        }];
    }else{
        //用第三方打开  或者提示无法打开
        CanNotOpenDocumentView *subview = [[CanNotOpenDocumentView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight) fileMessage:_message];
        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:subview];
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(0);
        }];
    }
    
    //下载完成后 刷新查看的cell的下载状态
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewShouldReloadData" object:_message];
}

#pragma 代理协议 

- (void)ShowDocumentImageViewLongPressed:(ShowDocumentImageView*)itemView{
    NSString *fileExtention = [[_filePath lastPathComponent] pathExtension];
    if ( [[fileExtention lowercaseString] isEqualToString:@"gif"]) {
        return;
    }else{
        if (itemView.myImageView.image && [itemView.myImageView.image isKindOfClass:[UIImage class]]) {
         __weak __typeof(self)weakSelf = self;
            
         MSSBrowseActionSheet   *browseActionSheet = [[MSSBrowseActionSheet alloc]initWithTitleArray:@[MSSBrowseTypeString(MSSBrowseTypeSave)] cancelButtonTitle:languageStringWithKey(@"取消") didSelectedBlock:^(NSInteger index) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
             
             //加水印图片 itemView.myImageView.image
             
             [strongSelf browseActionSheetDidSelectedAtIndex:index saveImg:[UIImage addImage:itemView.myImageView.image addMsakImage:nil]];
            }];
            [browseActionSheet showInView:self.view];
        }
    }
}

#pragma DocumentDownloadViewDelegate

- (void)DocumentDownloadView:(DocumentDownLoadView*)aView didFailWithError:(NSError *)error{
    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"下载失败")];
}

- (void)DocumentDownloadView_didFinished:(DocumentDownLoadView*)aView{
    
    ECFileMessageBody *fileBody =(ECFileMessageBody*)_message.messageBody;
    
    NSDictionary *fileDic =[[SendFileData sharedInstance]getCacheFileData:fileBody.remotePath];
    
    [self showLocationFileDocument:fileDic];

}

#pragma mark MSSActionSheetClick
- (void)browseActionSheetDidSelectedAtIndex:(NSInteger)index saveImg:(UIImage *)img {
    if (index == MSSBrowseTypeSave) {//保存
        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error) {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"保存图片失败")];
    }
    else
    {
        [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"保存图片成功")];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    [HXFileCacheManager deleteFileTmpCachePath];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    [HXFileCacheManager deleteFileTmpCachePath];
//    [MKNetworkEngine cancelOperationsContainingURLString:[NSString stringWithFormat:@"%@%@",KHostURL==2?[NSString stringWithFormat:@"%@://%@:%d",kRequestHttp,[DemoGlobalClass sharedInstance].PBSAddress,kPORT]:NewRequestUrl,[NSString stringWithFormat:@"%@",KAPI_File_getKeyByNodeId]]];
    if ([[[UIDevice currentDevice] systemVersion] intValue ] > 8) {
        NSArray * types = @[WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeDiskCache,WKWebsiteDataTypeCookies];  // 9.0之后才有的
        NSSet *websiteDataTypes = [NSSet setWithArray:types];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        }];
    }else{
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        DDLogInfo(@"%@", cookiesFolderPath);
        NSError *errors;
        
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }
}


@end
