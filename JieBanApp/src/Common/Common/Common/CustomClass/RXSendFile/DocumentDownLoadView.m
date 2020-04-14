//
//  DocumentDownLoadView.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/3.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "DocumentDownLoadView.h"
#import "BaseViewController.h"
#import "HXFileCacheManager.h"
#import "KitMsgData.h"

#define KNOTIFICATION_DownloadMessageCompletion   @"KNOTIFICATION_DownloadMessageCompletion"
#define KErrorKey   @"kerrorkey"

@interface DocumentDownLoadView()<ECProgressDelegate>
@property (nonatomic,retain)UIView  *progressViewReceived;
@property (nonatomic,retain)UIView  *progressViewExpected;
@property (nonatomic,retain)NSURLConnection *DownloadConnection;
@property (nonatomic,retain)NSMutableData   *receivedData;
@property (nonatomic,assign)long long bytesReceived;//已接收大小
@property (nonatomic,assign)long long bytesExpected;//文件总大小

@property (nonatomic,retain)UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic,retain)UILabel *waitLabel;
//@property (nonatomic,strong) UIButton *startBtn;


@end

@implementation DocumentDownLoadView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.startBtn.centerX = self.width/2;
}

-(instancetype)initWithFrame:(CGRect)frame filemessage:(ECMessage *)fileMessage
{
    self =[super initWithFrame:frame];
    
    if(self)
    {
        _fileMessage =fileMessage;
        [self chickDownLoad];
    }
    
    return self;
}
-(void)initUI :(CGFloat)originY
{
    
   // ECFileMessageBody *fileBody =(ECFileMessageBody *)_fileMessage.messageBody;
//    
//    CGFloat Height = 0;
//    
//    //图片
//    Height = Height + 63;
//    
//    //间隙
//    Height = Height + 15;
//
//    
//    CGSize size =[[Common sharedInstance]widthForContent:fileBody.displayName withLableWidth:self.frame.size.width-30 withLableFont:13];
//    //文件名
//    Height = Height + size.height;
//    
//    //间隙
//    Height = Height + 30;
//    
//    //进度条
//    Height = Height + 5;
//    
//    //间隙
//    Height = Height + 10;
//    
//    //等待+文字
//    Height = Height + 20;
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-50)/2.0, (self.frame.size.height-Height)/2.0, 50, 63)];
//    
//  
//    imageView.image = [self iconImage:fileBody.remotePath];
//    [self addSubview:imageView];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(imageView.frame)+15, self.frame.size.width-30, size.height)];
//    label.backgroundColor=[UIColor clearColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.lineBreakMode = NSLineBreakByTruncatingMiddle;
//    label.font = ThemeFontMiddle;
//    label.text = fileBody.displayName;
//    [self addSubview:label];
    
    _progressViewExpected = [[UIView alloc] initWithFrame:CGRectMake(60, originY+20, self.frame.size.width-120, 5)];
    _progressViewExpected.layer.cornerRadius=2.5;
    _progressViewExpected.backgroundColor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
//    [self addSubview:_progressViewExpected];
    _progressViewReceived = [[UIView alloc] initWithFrame:CGRectMake(20, originY+20, 0, 5)];
    _progressViewReceived.layer.cornerRadius=2.5;
    _progressViewReceived.backgroundColor = [UIColor colorWithRed:0.48f green:0.66f blue:0.26f alpha:1.00f];
    [self addSubview:_progressViewReceived];
    
    
    
    NSString *waitString = languageStringWithKey(@"加载中");
    
    CGSize sizeWait = [[Common sharedInstance] widthForContent:waitString withSize:CGSizeMake(self.width - 30, CGFLOAT_MAX) withLableFont:ThemeFontMiddle.pointSize];

    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.frame = CGRectMake((self.frame.size.width-sizeWait.width-20-5)/2.0, CGRectGetMaxY(_progressViewExpected.frame)+10, 20, 20);
    [_activityIndicatorView startAnimating];
    [self addSubview:_activityIndicatorView];
    
    _waitLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_activityIndicatorView.frame)+5, CGRectGetMaxY(_progressViewExpected.frame)+10+(20-sizeWait.height)/2.0, sizeWait.width, 20)];
    _waitLabel.backgroundColor=[UIColor clearColor];
    _waitLabel.font = ThemeFontMiddle;
    _waitLabel.text = waitString;
    [self addSubview:_waitLabel];
    
    [self startDownload];

}



- (void)chickDownLoad
{
    CGFloat originY = 128*fitScreenWidth;
    ECFileMessageBody *fileBody =(ECFileMessageBody *)_fileMessage.messageBody;
    
    UIImageView *fileImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.width-74)/2, originY, 74, 74)];
    fileImageView.image = [self iconImage:fileBody.remotePath];
    [self addSubview:fileImageView];
    
    [fileImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_offset(0);
        make.top.mas_offset(originY);
        make.size.mas_equalTo(CGSizeMake(74, 74));
    }];
    
    CGSize size = [[Common sharedInstance] widthForContent:fileBody.displayName withSize:CGSizeMake(self.width-30, CGFLOAT_MAX) withLableFont:15];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(fileImageView.frame)+20, self.frame.size.width-30, size.height)];
    label.backgroundColor=[UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByTruncatingMiddle;
    label.font = ThemeFontMiddle;
    label.text = fileBody.displayName;
    [self addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_offset(0);
        make.left.right.mas_offset(0);
        make.top.mas_equalTo(fileImageView.mas_bottom).mas_offset(20);
    }];
    
    
    float totalSize = [[NSString stringWithFormat:@"%lld", (fileBody.originFileLength != 0)?fileBody.originFileLength:fileBody.fileLength] floatValue];
    NSString *totalSizeStr = [NSObject dataSizeFormat:[NSString stringWithFormat:@"%f",totalSize]];
    //文件大小
//    _sizeLabel.text = totalSizeStr;
    
    self.startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.startBtn.frame = CGRectMake(98, CGRectGetMaxY(label.frame)+56, self.width - 2*98, 44);
    [self.startBtn setTitle:[NSString stringWithFormat:@"%@(%@)",languageStringWithKey(@"下载"),totalSizeStr] forState:UIControlStateNormal];
    [self.startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startBtn .titleLabel.font = ThemeFontLarge;
    self.startBtn.backgroundColor = ThemeColor;
    [self addSubview:self.startBtn];
    self.startBtn.layer.cornerRadius = 4;
    self.startBtn.layer.masksToBounds = YES;
    [self.startBtn addTarget:self action:@selector(beginLoadFile:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)beginLoadFile:(UIButton *)loadBtn
{
    loadBtn.hidden = YES;
    [self initUI:loadBtn.originY];
    loadBtn = nil;
}

- (UIImage*)iconImage:(NSString *)remotePath{
    
    NSString *fileExtention = [[remotePath lastPathComponent] pathExtension];
    if ([NSObject isFileType_Doc:fileExtention]) {
        return KKThemeImage(@"icon_file_word_small");
    }
    else if ([NSObject isFileType_PPT:fileExtention]) {
        return KKThemeImage(@"icon_file_ppt_small");
    }
    else if ([NSObject isFileType_XLS:fileExtention]) {
        return KKThemeImage(@"icon_file_xls_small");
    }
    else if ([NSObject isFileType_IMG:fileExtention]) {
        return KKThemeImage(@"FileTypeS_IMG");
    }else if ([NSObject isFileType_PDF:fileExtention]) {
        return KKThemeImage(@"icon_file_pdf_small");
    }
    else if ([NSObject isFileType_TXT:fileExtention]) {
        return KKThemeImage(@"icon_file_txt_small");
    }
    else if ([NSObject isFileType_ZIP:fileExtention]) {
        return KKThemeImage(@"icon_file_zip_small");
    }
    else{
        return KKThemeImage(@"FileTypeS_XXX");
    }
    
    /*
     
     NSString *fileExtention = [[remotePath lastPathComponent] pathExtension];
     if ([NSObject isFileType_Doc:fileExtention]) {
     return KKThemeImage(@"FileTypeS_DOC");
     }
     else if ([NSObject isFileType_PPT:fileExtention]) {
     return KKThemeImage(@"FileTypeS_PPT");
     }
     else if ([NSObject isFileType_XLS:fileExtention]) {
     return KKThemeImage(@"FileTypeS_XLS");
     }
     else if ([NSObject isFileType_IMG:fileExtention]) {
     return KKThemeImage(@"FileTypeS_IMG");
     }
     //    else if ([NSObject isFileType_VIDEO:fileExtention]) {
     //        return KKThemeImage(@"FileTypeS_VIDEO");
     //    }
     //    else if ([NSObject isFileType_AUDIO:fileExtention]) {
     //        return KKThemeImage(@"FileTypeS_AUDIO");
     //    }
     else if ([NSObject isFileType_PDF:fileExtention]) {
     return KKThemeImage(@"FileTypeS_PDF");
     }
     else if ([NSObject isFileType_TXT:fileExtention]) {
     return KKThemeImage(@"FileTypeS_TXT");
     }
     else if ([NSObject isFileType_ZIP:fileExtention]) {
     return KKThemeImage(@"FileTypeS_ZIP");
     }
     else{
     return KKThemeImage(@"FileTypeS_XXX");
     }
     */
}


#pragma mark ========================================
#pragma mark == 文件需要下载
#pragma mark ========================================
- (void)startDownload{
    ECFileMessageBody *fileBody =(ECFileMessageBody *)_fileMessage.messageBody;
    fileBody.uuid = [NSString stringWithFormat:@"%@%@",_fileMessage.to,_fileMessage.timestamp];
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:fileBody.uuid];
    unsigned long long uploadLength = (unsigned)[number longLongValue];
    fileBody.uploadLength = uploadLength;
    
    NSString *fileName;
    NSDictionary* userData =[MessageTypeManager getCusDicWithUserData:_fileMessage.userData];
    if ([userData hasValueForKey:@"fileName"]) {
        fileName = [userData valueForKey:@"fileName"];
    }
     if (KCNSSTRING_ISEMPTY(fileName)){
        
        fileName = fileBody.displayName;
        if (KCNSSTRING_ISEMPTY(fileName)) {
            fileName = [fileBody.remotePath lastPathComponent];
        }
    }
    
    NSString *fileIdentiferTime =[HXFileCacheManager createRandomFileName];
    fileBody.localPath = [HXFileCacheManager createFilePathInCacheDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument dataExtension:fileIdentiferTime sessionId:_fileMessage.sessionId fileName:fileName];
//    fileBody.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]
    DDLogInfo(@"download file url = %@",fileBody.remotePath);
    [[ECDevice sharedInstance].messageManager downloadMediaMessage:_fileMessage progress:self completion:^(ECError *error, ECMessage *message) {
        
        
        if (error.errorCode == ECErrorType_NoError) {
            
            //不更新路径 没有用 因为沙盒路径会变化
           // fileBody.localPath=[NSString stringWithFormat:@"%@&&&&%@",YXP_FileCacheManager_CacheDirectoryOfDocument,fileIdentiferTime];
//
            //恒信所有wjy
//            NSDictionary *fileDic =@{cachefileUrl:fileBody.remotePath,cacheimSissionId:message.sessionId,
//                                     cachefileDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument,cachefileIdentifer:fileIdentiferTime,cachefileDisparhName:fileName,cachefileExtension:[fileName pathExtension]?[fileName pathExtension]:@"",cachefileSize:[NSString stringWithFormat:@"%lld",fileBody.fileLength]};
            //获取userdata中的UUid
            //恒丰新增wjy
            NSString *fileUUid = [NSString fileMessageUUid:_fileMessage.userData];
            
            long long llSize = fileBody.originFileLength;
            if (llSize<=0) {
                llSize = fileBody.fileLength;
            }
            NSDictionary *fileDic =@{cachefileUrl:fileBody.remotePath,cacheimSissionId:message.sessionId,
                                     cachefileDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument,cachefileIdentifer:fileIdentiferTime,cachefileDisparhName:fileName,cachefileExtension:[fileName pathExtension]?[fileName pathExtension]:@"",cachefileSize:[NSString stringWithFormat:@"%lld",llSize],cachefileUuid:!KCNSSTRING_ISEMPTY(fileUUid)?fileUUid:@""};

            [[SendFileData sharedInstance] insertFileinfoData:fileDic];
//路径修改
    
            if (self.delegate && [self.delegate respondsToSelector:@selector(DocumentDownloadView_didFinished:)]) {
                [self.delegate DocumentDownloadView_didFinished:self];
            }else {
                !self.callBack?:self.callBack(error);
            }
            
            [self removeFromSuperview];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DownloadMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:message}];
        } else {
            fileBody.localPath = nil;
            [[KitMsgData sharedInstance] updateMessageLocalPath:message.messageId withPath:@"" withDownloadState:((ECFileMessageBody*)message.messageBody).mediaDownloadStatus];
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"下载失败")];
            [NSTimer scheduledTimerWithTimeInterval:2.1 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
        }
        
    }];
    
}

-(void)removeView
{
   [self removeFromSuperview];
}
/**
 @brief 设置进度
 @discussion 用户需实现此接口用以支持进度显示
 @param progress 值域为0到1.0的浮点数
 @param message  某一条消息的progress
 @result
 */
- (void)setProgress:(float)progress forMessage:(ECMessage *)message{
   
     NSString *fullString = [NSString stringWithFormat:@"%@…… %.1f%%", languageStringWithKey(@"加载中"),progress*100];
    
    CGSize sizeWait = [[Common sharedInstance] widthForContent:fullString withSize:CGSizeMake(self.width - 30, CGFLOAT_MAX) withLableFont:ThemeFontMiddle.pointSize];

    _activityIndicatorView.frame = CGRectMake((self.frame.size.width-sizeWait.width-20-5)/2.0, CGRectGetMaxY(_progressViewExpected.frame)+10, 20, 20);
    
    _waitLabel.frame = CGRectMake(CGRectGetMaxX(_activityIndicatorView.frame)+5, CGRectGetMaxY(_progressViewExpected.frame)+10+(20-sizeWait.height)/2.0, sizeWait.width, 20);
    _waitLabel.text = fullString;
    
    if(_bytesExpected != NSURLResponseUnknownLength) {
        CGFloat width =  (self.frame.size.width-40)*progress;
        CGRect rect = _progressViewReceived.frame;
        rect.size.width = width;
        _progressViewReceived.frame = rect;
    }
    
    ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
    ///接收人+时间戳生成唯一uuid 断点续传标志
    body.uuid = [NSString stringWithFormat:@"%@%@",message.to,message.timestamp];
    [[NSUserDefaults standardUserDefaults] setObject:@(body.uploadLength) forKey:body.uuid];
    [[NSUserDefaults standardUserDefaults]synchronize];
    if (progress>=1.0) {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:body.uuid];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    DDLogInfo(@"DeviceChatHelper setprogress %f,messageId=%@,from=%@,to=%@,session=%@",progress,message.messageId,message.from,message.to,message.sessionId);
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_fileTranProgressChanged object:nil userInfo:@{@"progress":[NSNumber numberWithFloat:progress],KMessageKey:message}];
}




@end
