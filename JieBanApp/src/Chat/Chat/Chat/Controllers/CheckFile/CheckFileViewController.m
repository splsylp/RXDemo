//
//  CheckFileViewController.m
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/12/16.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "CheckFileViewController.h"
#import "ShowDocumentOfficeView.h"
#import "DocumentDownLoadView.h"
#import "ShowDocumentImageView.h"
#import "CanNotOpenDocumentView.h"
#import "SendFileData.h"
#import "KCConstants_API.h"
#import "UIImage+deal.h"

@interface CheckFileViewController ()<ShowDocumentImageViewDelegate,DocumentDownloadViewDelegate,UIActionSheetDelegate>

@property(nonatomic,strong)UIImage *savedImage;
@property(nonatomic,strong)NSString *filePath;
@property(nonatomic,strong)ECMessage *message;
@property(nonatomic,strong)UIView *otherView;
@property(nonatomic,copy)NSString *cachePathString;

@end

@implementation CheckFileViewController

- (void)popViewController {
    [SVProgressHUD dismiss];
    [super popViewController];
    
    NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
   // DDLogInfo(@"%@", pathArray);
    [pathArray firstObject];
    NSString *directryPath = [[pathArray firstObject] stringByAppendingPathComponent:@"tempDocuments"];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directryPath];
    for (NSString *fileName in enumerator) {
       BOOL isMove = [[NSFileManager defaultManager] removeItemAtPath:[directryPath stringByAppendingPathComponent:fileName] error:nil];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(iOS7)
    {
        self.edgesForExtendedLayout =UIRectEdgeNone;
    }
    [self setTitle:languageStringWithKey(@"查看文档")];
    
    if([self.data isKindOfClass:[ECMessage class]])
    {
        _message =(ECMessage *)self.data;
        
        [self showDocumentFile];
    }
    NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
   // DDLogInfo(@"%@", pathArray);
    [pathArray firstObject];
    NSString *directryPath = [[pathArray firstObject] stringByAppendingPathComponent:@"tempDocuments"];

    [[NSFileManager defaultManager] createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];

}

-(void)showDocumentFile
{
    
    //判断文件本地是否存在
    
    ECFileMessageBody *fileBody =(ECFileMessageBody *)_message.messageBody;
    
    NSDictionary *fileDic =[[SendFileData sharedInstance]getCacheFileData:fileBody.remotePath];
    
    if(fileDic.count>0)
    {
        NSDictionary* userData =[MessageTypeManager getCusDicWithUserData:_message.userData];
        if ([userData hasValueForKey:@"fileName"]) {
            self.title = [userData valueForKey:@"fileName"];
            
        } else {
        
            self.title =[fileDic objectForKey:cachefileDisparhName]?[fileDic objectForKey:cachefileDisparhName]:languageStringWithKey(@"查看文档");
        }
        
        [self showLocationFileDocument:fileDic];
        
    }else
    {
        if(KCNSSTRING_ISEMPTY(fileBody.remotePath))
        {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件不存在")];
            return;
        }
        
        [self downloadFile:_message filePath:fileBody.remotePath];
    }
}

-(void)downloadFile:(ECMessage *)messAge filePath:(NSString *)filePath
{
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
//        [self.view addSubview:subview];
        
    }else
    {
        DocumentDownLoadView *subview = [[DocumentDownLoadView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight) filemessage:messAge];
        subview.delegate = self;
        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:subview];
    }
}

-(void)showLocationFileDocument:(NSDictionary *)fileDic
{
    
    NSString *fileExtention = [fileDic objectForKey:cachefileExtension];
    
    if ([NSObject isFileType_Doc:fileExtention] ||
        [NSObject isFileType_PPT:fileExtention] ||
        [NSObject isFileType_XLS:fileExtention] ||
        [NSObject isFileType_PDF:fileExtention] ||
        [NSObject isFileType_TXT:fileExtention]
        ) {
        
        ShowDocumentOfficeView *subview = [[ShowDocumentOfficeView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight) fileMessage:_message];
        
        [self.view addSubview:subview];
        
        
    }else if ([NSObject isFileType_IMG:fileExtention])
    {
        ShowDocumentImageView *subview = [[ShowDocumentImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,  kScreenHeight-kTotalBarHeight) fileMessage:_message];
        
        subview.delegate = self;
        [self.view addSubview:subview];
    }else
    {
        //用第三方打开  或者提示无法打开
        
        CanNotOpenDocumentView *subview = [[CanNotOpenDocumentView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight) fileMessage:_message];
        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:subview];
        
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

- (void)ShowDocumentImageViewLongPressed:(ShowDocumentImageView*)itemView {
    if ([itemView.myImageView.image isKindOfClass:[UIImage class]] && itemView.myImageView.image) {
//        if (IsHengFengTarget) {
//            self.savedImage = [UIImage addImage:itemView.myImageView.image addMsakImage:ThemeImage(@"恒丰银行水印")];
//        }else{
//            NSString *name = [Common sharedInstance].getUserName;
//            if (name.length > 2) {
//                name = [name substringFromIndex:(name.length - 2)];
//            }
//            NSString *mobile = [Common sharedInstance].getMobile;
//            if (mobile.length > 4) {
//                mobile = [mobile substringFromIndex:(mobile.length -4)];
//            }
//            
//            self.savedImage = [itemView.myImageView.image watermarkImage:[NSString stringWithFormat:@"%@%@",name,mobile]];
//        }
        self.savedImage = itemView.myImageView.image;
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:languageStringWithKey(@"提示") delegate:self cancelButtonTitle:languageStringWithKey(@"取消")
                                                   destructiveButtonTitle:languageStringWithKey(@"保存图片") otherButtonTitles:nil, nil];
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        [self saveImageToPhotos:self.savedImage];
    }
}

- (void)saveImageToPhotos:(UIImage*)savedImage{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    
    if(error != NULL){
        msg = languageStringWithKey(@"保存图片失败") ;
    }else{
        msg = languageStringWithKey(@"保存图片成功");
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:languageStringWithKey(@"确定")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

-(void)dealloc
{
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

@end
