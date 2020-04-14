//
//  ChatViewFileCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/11.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ChatViewFileCell.h"
//获取控制器  做跳转用
#import "UIView+CurrentController.h"
#import "ChatViewController.h"
#define bubbleWidth kScreenWidth -190
#define FileNameLabelFont 13
#define kbubbleViewHight  60

NSString *const KResponderCustomChatViewFileCellBubbleViewEvent = @"KResponderCustomChatViewFileCellBubbleViewEvent";

@implementation ChatViewFileCell{
    ///文件名
    UILabel *_fileNameLabel;
    //文件大小
    UILabel *_fileSizeLabel;
    //文件进度
    //    UILabel *_progressLabel;
    //速度
    //    UILabel *_speedLabel;
    //文件类型图片
    UIImageView *_fileTypeImg;
    ///进度条
    UIProgressView *_progressView;
    
    //是否下载状态
    UILabel *_downLoadStatusLabel;
}
- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        _fileTypeImg = [[UIImageView alloc] initWithImage:ThemeImage(@"attachment")];
        CGFloat frameX = 0.0f;
        if (self.isSender) {
            frameX = 10;
            self.bubbleView.frame = CGRectMake(self.portraitImg.originX - 210.0f - 10.0f, self.portraitImg.originY, 210.0f, 70.0f);
            //            _fileTypeImg.frame = CGRectMake(self.bubbleView.width - 60.0f, 15.0f, 40.0f, 40.0f);
            _fileTypeImg.frame = CGRectMake(frameX, 12.0f, 46.0f, 46.0f);
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileTransProgressChanged:) name:KNOTIFICATION_fileTranProgressChanged object:nil];
            
        } else {
            frameX = 10.0f;
            self.bubbleView.frame = CGRectMake(self.portraitImg.originX + 10.0f + self.portraitImg.width, self.portraitImg.originY, 210.0f, 70.f);
            //            _fileTypeImg.frame = CGRectMake(self.bubbleView.width - 40 -15.0f, 15.0f, 40.0f, 40.0f);
            _fileTypeImg.frame = CGRectMake(frameX+5, 12.0f, 46.0f, 46.0f);
        }
        _fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_fileTypeImg.right + frameX, 5.0f, self.bubbleView.frame.size.width - frameX - 70.0f-6, 20.0f)];
        _fileNameLabel.font = ThemeFontMiddle;
        [self.bubbleView addSubview:_fileNameLabel];
        
        _fileSizeLabel = [[UILabel alloc] init];
        _fileSizeLabel.frame = CGRectMake(_fileNameLabel.left, 30.0, 45, 15);
        _fileSizeLabel.bottom = _fileTypeImg.bottom;
        _fileSizeLabel.backgroundColor = [UIColor clearColor];
        _fileSizeLabel.font = ThemeFontSmall;
        _fileSizeLabel.textColor = [UIColor grayColor];
        [self.bubbleView addSubview:_fileSizeLabel];
        
        
        _downLoadStatusLabel = [[UILabel alloc] init];
        _downLoadStatusLabel.frame = CGRectMake(_fileNameLabel.left, 30.0, 50, 15);
        _downLoadStatusLabel.bottom = _fileTypeImg.bottom;
        _downLoadStatusLabel.right = _fileNameLabel.right;
        _downLoadStatusLabel.textAlignment = NSTextAlignmentRight;
        //        _downLoadStatusLabel.text = @"未下载";
        _downLoadStatusLabel.backgroundColor = [UIColor clearColor];
        _downLoadStatusLabel.font = ThemeFontSmall;
        _downLoadStatusLabel.textColor = [UIColor grayColor];
        [self.bubbleView addSubview:_downLoadStatusLabel];
        
        //        _progressLabel = [[UILabel alloc] init];
        //        _progressLabel.frame = CGRectMake(frameX + 48, 30.0, self.bubbleView.width - frameX - 118.0f, 15);
        //        _progressLabel.backgroundColor = [UIColor clearColor];
        //        _progressLabel.font = ThemeFontSmall;
        //        _progressLabel.textColor = [UIColor redColor];
        //        [self.bubbleView addSubview:_progressLabel];
        //
        //        _speedLabel = [[UILabel alloc] init];
        //        _speedLabel.frame = CGRectMake(frameX, 50.0, self.bubbleView.width - frameX - 70.0f, 15);
        //        _speedLabel.backgroundColor = [UIColor clearColor];
        //        _speedLabel.font = ThemeFontSmall;
        //        _speedLabel.textColor = ThemeColor;
        //        [self.bubbleView addSubview:_speedLabel];
        
        ///图片
        [self.bubbleView addSubview:_fileTypeImg];
        if (self.isSender) {
            _progressView = [[UIProgressView alloc] init];
            _progressView.tintColor = ThemeColor;
            _progressView.progress = 0;
            _progressView.frame = CGRectMake(0,self.bubbleView.height + 3, self.bubbleView.width - 5, 10);
            [self.bubbleView addSubview:_progressView];
        }
    }
    return self;
}
///发送进度改变
- (void)fileTransProgressChanged:(NSNotification *)noti{
    NSDictionary *dataDic = noti.userInfo;
    ECMessage *message = (ECMessage *)[dataDic objectForKey:KMessageKey];
    ///当前进度
    float progress = [(NSNumber *)[dataDic objectForKey:@"progress"] floatValue];
    if ([message.messageId isEqualToString:self.displayMessage.messageId]) {
        _progressView.hidden = NO;
        _downLoadStatusLabel.text = languageStringWithKey(@"发送中");
        //        _progressLabel.hidden = NO;
        //        _speedLabel.hidden = NO;
        //进度条
        _progressView.progress = progress;
        //进度条label
        //        _progressLabel.text = [NSString stringWithFormat:@"%.2f%%",progress * 100];
        //速度label
        //        _speedLabel.text = [NSString stringWithFormat:@"%@/s",[NSObject dataSizeFormat:[NSString stringWithFormat:@"%llu",message.getSpeed]]];
        if (progress == 1) {
            _progressView.hidden = YES;
            _downLoadStatusLabel.text = languageStringWithKey(@"已发送");
            //            _progressLabel.hidden = YES;
            //            _speedLabel.hidden = YES;
        }
    }
}

- (void)bubbleViewTapGesture:(UITapGestureRecognizer *)tap{
    NSDictionary *userData = [MessageTypeManager getCusDicWithUserData:self.displayMessage.userData];
    if ([userData hasValueForKey:@"transmit"]) {
        if ([[userData valueForKey:@"transmit"] isEqual:@"TRtrue"]) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"该文件已被别人加密，无法预览")];
            return;
        }
    }
    [self dispatchCustomEventWithName:KResponderCustomChatViewFileCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:tap];
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    ECFileMessageBody *fileBody = (ECFileMessageBody *)message;
    if (KCNSSTRING_ISEMPTY(fileBody.displayName)) {
        fileBody.displayName = languageStringWithKey(@"未知文件名");
    }
    CGSize fileSize =  [[Common sharedInstance] widthForContent:fileBody.displayName withSize:CGSizeMake(bubbleWidth, CGFLOAT_MAX) withLableFont:FileNameLabelFont];
    CGFloat bubleH = kbubbleViewHight + 30;
    if(fileSize.height > 25){
        bubleH = bubleH + 7;
    }
    return bubleH;
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;
    if (message.messageBody.messageBodyType == 26) {
        return;
    }
    _progressView.hidden = YES;
    //    _progressLabel.hidden = YES;
    //    _speedLabel.hidden = YES;
    
    ECFileMessageBody *body = (ECFileMessageBody *)self.displayMessage.messageBody;
    if(KCNSSTRING_ISEMPTY(body.displayName)){
        body.displayName = languageStringWithKey(@"未知文件名");
    }
    ///文件名
    _fileNameLabel.text = body.displayName;
    
    //判断文件本地是否存在
    NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:body.remotePath];
    if (self.isSender) {
        if (message.messageState == ECMessageState_SendFail) {
            _downLoadStatusLabel.text = languageStringWithKey(@"发送失败");
        }
        else {
            _downLoadStatusLabel.text = languageStringWithKey(@"已发送");
        }
    }else {
        if(fileDic.count > 0){
            _downLoadStatusLabel.text = languageStringWithKey(@"已下载");
        }else {
            _downLoadStatusLabel.text = languageStringWithKey(@"未下载");
        }
    }
    
    float totalSize = [[NSString stringWithFormat:@"%lld", (body.originFileLength != 0)?body.originFileLength:body.fileLength] floatValue];
    NSString *totalSizeStr = [NSObject dataSizeFormat:[NSString stringWithFormat:@"%f",totalSize]];
    //文件大小
    _fileSizeLabel.text = totalSizeStr;
    //文件类型图片
    [self setFileTypeImageViewWithFileExtension:[body.displayName pathExtension]];
    
    //文件要是白色图片
    if(self.isSender){
        self.bubleimg.frame = self.bubbleView.bounds;
        self.bubleimg.image = [ThemeImage(@"chating_File_right_02.png") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    }
    ///计算frame
    _fileSizeLabel.width = [[Common sharedInstance] widthForContent:totalSizeStr withSize:CGSizeMake(self.bubbleView.width - 100, 15) withLableFont:ThemeFontSmall.pointSize].width;
    //    _progressLabel.originX = _fileSizeLabel.right+ 5;
    //    _progressLabel.width = self.bubbleView.width - 80 - _fileSizeLabel.width;
    
    NSDictionary *userData = self.displayMessage.userDataToDictionary;
    if ([userData hasValueForKey:@"encryption"] && [[userData valueForKey:@"encryption"] isEqual:@"EnTrue"]) {
        _fileNameLabel.text = languageStringWithKey(@"加密文件");
    }else{
        if ([userData hasValueForKey:@"fileName"]) {
            _fileNameLabel.text = [userData valueForKey:@"fileName"];
        }
        if (KCNSSTRING_ISEMPTY(_fileNameLabel.text)) {
            _fileNameLabel.text = body.displayName;
        }
    }
    [super bubbleViewWithData:message];
}

#pragma mark ========================================
#pragma mark == 代理协议
#pragma mark ========================================
- (void)setFileTypeImageViewWithFileExtension:(NSString*)fileExtention{
    if ([NSObject isFileType_Doc:fileExtention]) {
        _fileTypeImg.image = ThemeImage(@"FileTypeS_DOC");
    }
    else if ([NSObject isFileType_PPT:fileExtention]) {
        _fileTypeImg.image = ThemeImage(@"FileTypeS_PPT");
    }
    else if ([NSObject isFileType_XLS:fileExtention]) {
        _fileTypeImg.image = ThemeImage(@"FileTypeS_XLS");
    }
    else if ([NSObject isFileType_IMG:fileExtention]) {
        _fileTypeImg.image = ThemeImage(@"FileTypeS_IMG");
    }
    //    else if ([NSObject isFileType_VIDEO:fileExtention]) {
    //        _fileTypeImg.image = ThemeImage(@"FileTypeS_VIDEO");
    //    }
    //    else if ([NSObject isFileType_AUDIO:fileExtention]) {
    //        _fileTypeImg.image = ThemeImage(@"FileTypeS_AUDIO");
    //    }
    else if ([NSObject isFileType_PDF:fileExtention]) {
        _fileTypeImg.image = ThemeImage(@"FileTypeS_PDF");
    }
    else if ([NSObject isFileType_TXT:fileExtention]) {
        _fileTypeImg.image = ThemeImage(@"FileTypeS_TXT");
    }
    else if ([NSObject isFileType_ZIP:fileExtention]) {
        _fileTypeImg.image = ThemeImage(@"FileTypeS_ZIP");
    }
    else{
        _fileTypeImg.image = ThemeImage(@"FileTypeS_XXX");
    }
}
@end
