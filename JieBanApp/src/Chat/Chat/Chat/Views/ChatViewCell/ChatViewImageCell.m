//
//  ChatViewImageCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/16.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ChatViewImageCell.h"
#import "RXThirdPart.h"
#import "UIImage+deal.h"
//#import "RXPicturePreviewViewController.h"
//获取控制器  做跳转用
#import "UIView+CurrentController.h"
#import "ChatViewController.h"

#import "LoopProgressView.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define kCGImageAlphaPremultipliedLast  (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast)
#else
#define kCGImageAlphaPremultipliedLast  kCGImageAlphaPremultipliedLast
#endif

#define BubbleMaxSize CGSizeMake(180.0f * fitScreenWidth, 1000.0f)
#define progressWidth 50
NSString *const KResponderCustomChatViewImageCellBubbleViewEvent = @"KResponderCustomChatViewImageCellBubbleViewEvent";
@interface ChatViewImageCell() {
    BOOL isBurn;
    CAShapeLayer * borderLayer;
    CAShapeLayer * borderLayerBack;

}

@property (nonatomic, strong)NSDataDetector *detector;
@property (nonatomic, strong) NSArray *urlMatches;
@property (nonatomic,strong) LoopProgressView *progressView;//进度条
@property (nonatomic,strong) UIImageView *blurView;//蒙版
@end

@implementation ChatViewImageCell


- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        self.bubbleView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];

        _displayImage = [[FLAnimatedImageView alloc] init];
        _displayImage.backgroundColor = [UIColor clearColor];
        _displayImage.contentMode = UIViewContentModeScaleAspectFill;

        _displayImage.clipsToBounds = YES;
        //        self.bubleimg.alpha = 0;
        if (self.isSender) {
            _displayImage.frame = CGRectMake(5, 5, 110.0f, 120.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-140.0f, self.portraitImg.frame.origin.y, 130.0f, 130.0f);
            UIImage *backImage = ThemeImage(@"chating_right_02—image");
            self.bubleimg.image = backImage;
        } else {
            _displayImage.frame = CGRectMake(15, 5, 110.0f, 120.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x + 10.0f + self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 130.0f, 130.0f);
            UIImage *backImage = ThemeImage(@"chating_left_01");
            self.bubleimg.image = backImage;
        }
        [self.bubbleView addSubview:_displayImage];

        _gifFlagImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 50.0f, 50.0f)];
        _gifFlagImage.center = CGPointMake(_displayImage.frame.size.width * 0.5, _displayImage.frame.size.height * 0.5);
        _gifFlagImage.image = ThemeImage(@"chat_play_gif");
        _gifFlagImage.hidden = YES;
        //[_displayImage addSubview:_gifFlagImage];

        self.detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];

        _maskLabel = [[UILabel alloc] initWithFrame:self.displayImage.frame];
        _maskLabel.backgroundColor = [UIColor clearColor];
        _maskLabel.text= languageStringWithKey(@"点击查看");
        _maskLabel.textAlignment = NSTextAlignmentCenter;
        _maskLabel.userInteractionEnabled = NO;
        _maskLabel.adjustsFontSizeToFitWidth = YES;
        _maskLabel.font = ThemeFontLarge;
        _maskLabel.textColor = [UIColor whiteColor];
        _maskLabel.hidden = YES;
        _maskImageView.hidden = YES;
        if (self.burnIcon) {
            [self.bubbleView insertSubview:self.burnIcon aboveSubview:_displayImage];
        }
        if (isSender) {
            _maskLabel.textColor = [UIColor whiteColor];
        }else{
            _maskLabel.textColor = [UIColor blackColor];
        }
        [self.bubbleView insertSubview:_maskLabel aboveSubview:_displayImage];

        self.burnIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.bubbleView.originX + self.bubbleView.width - 8, self.bubbleView.originY - 4, 16, 16)];
        self.burnIcon.layer.cornerRadius = 8;
        self.burnIcon.image = ThemeImage(@"burn_lock_icon");
        self.burnIcon.hidden = YES;
        [self.contentView addSubview:self.burnIcon];
        if (self.timeLab) {
            [self.timeLab removeFromSuperview];
            self.timeLab.frame = CGRectMake(self.bubbleView.originX + self.bubbleView.width - 9, self.bubbleView.originY - 4, 18, 18);
            [self.contentView addSubview:self.timeLab];
        }

        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        maskLayer.strokeColor = [UIColor clearColor].CGColor;
        maskLayer.frame = self.bubbleView.bounds;
        maskLayer.contentsCenter = CGRectMake(0.5, 0.8, 0.1, 0.1);
        maskLayer.contentsScale = [UIScreen mainScreen].scale;                 //非常关键设置自动拉伸的效果且不变形

        if (self.isSender) {
            maskLayer.contents = (id)ThemeImage(@"chating_right_02").CGImage;
        } else {
            maskLayer.contents = (id)ThemeImage(@"chating_left_01").CGImage;
        }
        self.bubbleView.layer.mask = maskLayer;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileTransProgressChanged:) name:KNOTIFICATION_fileTranProgressChanged object:nil];
       
    }
    return self;
}
#pragma mark - 点击手势
- (void)bubbleViewTapGesture:(UITapGestureRecognizer *)tap{
    [self dispatchCustomEventWithName:KResponderCustomChatViewImageCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:tap];
    if (![Common sharedInstance].isIMMsgMoreSelect) {
        [self imageCellBubbleViewTap:self.displayMessage];
        NSDictionary *userdata = [MessageTypeManager getCusDicWithUserData:self.displayMessage.userData];
        if ([userdata hasValueForKey:kRonxinBURN_MODE]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"burnMode" object:userdata];
        }
    }
}
#pragma mark - 供外部获取cell高度
+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)messageBody{
    return 150.0f * fitScreenWidth;
}
///add by 李晓杰
+ (CGFloat)getHightOfCellViewWithMessage:(ECMessage *)message{
    if (message.getImageHeight) {
//        return message.getImageHeight + 30 * fitScreenWidth;
        return message.getImageHeight + 20;
    }
    return 130 * iPhone6FitScreenHeight + 30 * fitScreenWidth;
}
#pragma mark - set方法
- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;

    ECImageMessageBody *mediaBody = (ECImageMessageBody *)message.messageBody;
    if (message.isBurnWithMessage){
        isBurn = YES;
        if (!self.isSender) {
            self.maskImageView.hidden = NO;
            _displayImage.alpha = 0.03;
            self.bubbleView.alpha = 1;
            self.maskLabel.hidden = NO;
        }else{
            self.maskImageView.hidden = YES;
            self.maskLabel.hidden = YES;
            _displayImage.alpha = 1;
            self.bubbleView.alpha = 1;
        }
    }else{
        isBurn = NO;
        self.maskImageView.hidden = YES;
        self.maskLabel.hidden = YES;
        _displayImage.alpha = 1;
        self.bubbleView.alpha = 1;
    }
    ///初始化页面
    self.bubleimg.alpha = 0;
    self.displayImage.image = nil;
    if(!isBurn){
        self.displayImage.image = ThemeImage(@"chat_placeholder_image");
    }
    if (isBurn && !self.isSender) {//阅后即焚接收方
        self.bubleimg.alpha = 1;
        [self getImageWithwidth:message.getImageWight andgetImageWithhight:message.getImageHeight];
        return;
    }
    ///拿到消息先设置图片的frame

    [self getImageWithwidth:message.getImageWight andgetImageWithhight:message.getImageHeight];
    
    // 获取Caches目录路径  因为获取的localPath 路径不对
    NSString *newCachesPath = [NSCacheDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",mediaBody.localPath.lastPathComponent.length > 0 ?mediaBody.localPath.lastPathComponent:mediaBody.remotePath.lastPathComponent]];
    if ([mediaBody.localPath containsString:KKFileCacheManager_CacheDirectoryOfRoot]) {
        NSString *str = [mediaBody.localPath componentsSeparatedByString:KKFileCacheManager_CacheDirectoryOfRoot][1];
        newCachesPath = [NSString stringWithFormat:@"%@/%@%@",NSCacheDirectory(),KKFileCacheManager_CacheDirectoryOfRoot,str];
    }
    mediaBody.localPath = newCachesPath;
    if (mediaBody.localPath.length > 0 &&
        [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath] &&
        (mediaBody.mediaDownloadStatus == ECMediaDownloadSuccessed || message.messageState != ECMessageState_Receive)) {
        [self showWithImage];
    }else{
        [self downloadHDImageMessage];
    }
    [super bubbleViewWithData:message];
    self.timeLab.frame = CGRectMake(self.bubbleView.originX + self.bubbleView.width - 9, self.bubbleView.originY - 4, 18, 18);
    self.burnIcon.frame = CGRectMake(self.bubbleView.originX + self.bubbleView.width - 8, self.bubbleView.originY - 4, 16, 16);
   
}
-(UIImageView *)blurView{
    if (!_blurView) {
        _blurView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bubbleView.size.width, self.bubbleView.size.height)];
        
        _blurView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        _blurView.alpha = 0.3;
        [self.bubbleView insertSubview:_blurView belowSubview:_progressView];
    }
    return _blurView;
}
-(LoopProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[LoopProgressView alloc]initWithFrame:CGRectMake((self.bubbleView.size.width -progressWidth)/2.0, (self.bubbleView.size.height -progressWidth)/2.0, progressWidth, progressWidth)];
        _progressView.progress = 0;
        _progressView.hidden = YES;
        [self.bubbleView addSubview:_progressView];
    }
    return _progressView;
}
///下载高清图片
- (void)downloadHDImageMessage{
    [[ChatMessageManager sharedInstance] downloadMediaMessage:self.displayMessage andCompletion:^(ECError *error, ECMessage *message) {
        if (error.errorCode != ECErrorType_NoError) {
            DDLogInfo(@"图片下载失败  error.errorCode = %ld", (long)error.errorCode);
            return ;
        }
        if (![self.displayMessage.messageId isEqualToString:message.messageId]) {
            return;
        }
        ECFileMessageBody *msgBody = (ECFileMessageBody *)message.messageBody;
        ///更新下载好的状态
        [[KitMsgData sharedInstance] updateMessageLocalPath:message.messageId withPath:msgBody.localPath withDownloadState:msgBody.mediaDownloadStatus];
        NSData *imageData = [NSData dataWithContentsOfFile:msgBody.localPath];
        UIImage *image = [UIImage imageWithData:imageData];
        NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:msgBody.localPath error:nil];
        long long fileSize = [attr[NSFileSize] longLongValue];
        if (fileSize/1024 > 1000) {
            CGSize size = CGSizeMake(1536, 1536);
            [image compressAndSaveImageWithNewSize:size andFilePath:msgBody.localPath];
        }
        ///更新高度
        CGSize size = [[KitMsgData sharedInstance] caculateImageSize:imageData];
        [message setImageWight:size.width];
        [message setImageHeight:size.height];
        [[KitMsgData sharedInstance] updateImageSize:size ofMessageId:message.messageId];

        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DownloadMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:message}];
    }];
}
///显示图片
- (void)showWithImage{
    ECMessage *message = self.displayMessage;
    ECImageMessageBody *mediaBody = (ECImageMessageBody *)message.messageBody;
    if (self.isSender || !isBurn) {
        [self.displayImage sd_setImageWithURL:mediaBody.localPath.length>0?[NSURL fileURLWithPath:mediaBody.localPath]:nil placeholderImage:ThemeImage(@"chat_placeholder_image") options:SDWebImageRefreshCached|SDWebImageRetryFailed];
    }else{
        [super updateMessageSendStatus:self.displayMessage.messageState];
    }
}
///设置图片的frame
- (void)getImageWithwidth:(CGFloat)width andgetImageWithhight:(CGFloat)height{
    if (width == 0) {
        width = 120 * iPhone6FitScreenWidth;
    }
    if (height == 0) {
        height = 130 * iPhone6FitScreenHeight;
    }
    _displayImage.frame = CGRectMake(1, 1, width - 2, height - 2);
    NSString *mmaskLayerImage;
    if (self.isSender) {
        mmaskLayerImage = @"chating_richText_right";
    }else{
        mmaskLayerImage = @"chating_left_01";
    }
    CAShapeLayer *mmaskLayer = [CAShapeLayer layer];
    mmaskLayer = [CAShapeLayer layer];
    mmaskLayer.fillColor = [UIColor whiteColor].CGColor;
    mmaskLayer.strokeColor = [UIColor clearColor].CGColor;
    mmaskLayer.frame = _displayImage.bounds;
    mmaskLayer.contentsCenter = CGRectMake(0.5, 0.8, 0.1, 0.1);
    //非常关键设置自动拉伸的效果且不变形
    mmaskLayer.contentsScale = [UIScreen mainScreen].scale;
    mmaskLayer.contents = (id)ThemeImage(mmaskLayerImage).CGImage;
    _displayImage.layer.mask = mmaskLayer;
    _maskLabel.frame = _displayImage.frame;

    if (self.isSender) {
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x - width - 10, self.portraitImg.frame.origin.y, width, height);
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.bubbleView.bounds;
        maskLayer.contentsCenter = CGRectMake(0.5, 0.8, 0.1, 0.1);
        maskLayer.contentsScale = [UIScreen mainScreen].scale;                 //非常关键设置自动拉伸的效果且不变形
        maskLayer.contents = (id)ThemeImage(@"chating_richText_right").CGImage;
        self.bubbleView.layer.mask = maskLayer;
        if (isBurn) {
            _displayImage.frame = CGRectMake(0.25, 0.25, width - 0.5, height - 0.5);
            if (!borderLayer) {
                borderLayer = [CAShapeLayer layer];
            }
            borderLayer.frame = self.bubbleView.bounds;
            borderLayer.contentsCenter = CGRectMake(0.5, 0.8, 0.1, 0.1);
            borderLayer.contentsScale = [UIScreen mainScreen].scale;                 //非常关键设置自动拉伸的效果且不变形
            borderLayer.contents = (id)ThemeImage(@"burn_chating_right_01").CGImage;
            [self.bubbleView.layer addSublayer:borderLayer];
        }else{
            if (borderLayer) {
                [borderLayer removeFromSuperlayer];
            }
        }
    } else {
        CGFloat imageFrameY = self.portraitImg.frame.origin.y;
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x + 10.0f + self.portraitImg.frame.size.width, imageFrameY, width, height);
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.fillColor = [UIColor whiteColor].CGColor;
        maskLayer.strokeColor = [UIColor clearColor].CGColor;
        maskLayer.frame = self.bubbleView.bounds;
        maskLayer.contentsCenter = CGRectMake(0.5, 0.8, 0.1, 0.1);
        maskLayer.contentsScale = [UIScreen mainScreen].scale;                 //非常关键设置自动拉伸的效果且不变形
        maskLayer.contents = (id)ThemeImage(@"chating_left_01").CGImage;

        self.bubbleView.layer.mask = maskLayer;
        self.bubleimg.frame = self.bubbleView.bounds;
        self.bubleimg.image = [ThemeImage(@"chating_left_01") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    }

    ECMessage *message = self.displayMessage;
    ECImageMessageBody *mediaBody = (ECImageMessageBody *)message.messageBody;
    if ([mediaBody.localPath.pathExtension.lowercaseString isEqualToString:@"gif"]) {
        _gifFlagImage.hidden = NO;
        _gifFlagImage.center = CGPointMake(_displayImage.frame.size.width * 0.5, _displayImage.frame.size.height * 0.5);
    } else {
        _gifFlagImage.hidden = YES;
    }

    [super bubbleViewWithData:message];
    if (!self.isSender) {
        self.timeLab.frame = CGRectMake(self.bubbleView.originX + self.bubbleView.width - 9, self.bubbleView.originY - 4, 18, 18);
        self.burnIcon.frame = CGRectMake(self.bubbleView.originX + self.bubbleView.width - 8, self.bubbleView.originY - 4, 16, 16);
    }
}

#pragma mark - 图片cell点击事件
- (void)imageCellBubbleViewTap:(ECMessage *)message{
    //获取控制器
    ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];

    if (message.messageBody.messageBodyType >= MessageBodyType_Voice) {
        ECImageMessageBody *mediaBody = (ECImageMessageBody *)message.messageBody;

        if (mediaBody.localPath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath] && (mediaBody.mediaDownloadStatus == ECMediaDownloadSuccessed || message.messageState != ECMessageState_Receive)) {
            [self showImagesWith:message];
            // hanwei start
            if (!isBurn) {
                [self setDisplayMessage:message];
            }
            // hanwei end
        }else if (mediaBody.remotePath.length > 0) {
            [SVProgressHUD showWithStatus:languageStringWithKey(@"正在获取文件")];

            __weak __typeof(self)weakSelf = self;
            mediaBody.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:mediaBody.displayName];
            [[ChatMessageManager sharedInstance] downloadMediaMessage:message andCompletion:^(ECError *error, ECMessage *message) {
                ECImageMessageBody *msgBody =  (ECImageMessageBody *)message.messageBody;
                NSString *thumbnailRemotePath = msgBody.thumbnailRemotePath;
                DDLogInfo(@"下载%lu 路径thumbnailRemotePath %@",(unsigned long)msgBody.thumbnailDownloadStatus,thumbnailRemotePath);

                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [SVProgressHUD dismiss];
                if (error.errorCode == ECErrorType_NoError) {
                    if (self.isHistoryMessage) {//历史消息
                        [[KitMsgData sharedInstance] updateMessageLocalPath:message.messageId withPath:mediaBody.localPath withDownloadState:((ECFileMessageBody *)message.messageBody).mediaDownloadStatus];
                    }else{
                        [[KitMsgData sharedInstance] updateMessageLocalPath:message.messageId withPath:mediaBody.localPath withDownloadState:((ECFileMessageBody *)message.messageBody).mediaDownloadStatus];
                    }
                    [strongSelf showImagesWith:message];
                } else {
                    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"获取文件失败")];
                }
            }];
        }
    }
}

- (void)showImagesWith:(ECMessage *)message{
    //获取图片索引
    __weak typeof(ECMessage *)weakMessage = message;
    __weak typeof(self)weakSelf = self;

    if(!message.isRead){
        [[AppModel sharedInstance] readedMessage:message completion:^(ECError *error, ECMessage *amessage) {
            if (error.errorCode == ECErrorType_NoError) {
                weakMessage.isRead = YES;
            }
        }];
        //阅后即焚相关 在控制器里做
        if (weakMessage.isBurnWithMessage) {
            weakMessage.isRead = YES;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(addReceviceDataWithBurnMessage:)]) {
                [weakSelf.delegate addReceviceDataWithBurnMessage:weakMessage];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewShouldReloadData" object:nil];
        [[KitMsgData sharedInstance] updateMessageReadStateByMessageId:message.messageId isRead:YES];
    }

    ECImageMessageBody *mediaBody = (ECImageMessageBody *)message.messageBody;
    NSMutableArray *imgArray = [NSMutableArray array];
    NSInteger indexRow = 0;
    
    if (self.isHistoryMessage) {//历史消息
        MSSBrowseModel *yxpModel = [[MSSBrowseModel alloc] init];
        yxpModel.bigImageUrl = mediaBody.remotePath?mediaBody.remotePath:@"";
        yxpModel.locImgUrl = mediaBody.localPath;
        yxpModel.authId = message.from;
        yxpModel.messageId = message.messageId;
        yxpModel.isBurnMessage = isBurn;
        yxpModel.isHistoryMsg = YES;
        CGRect imgRect = [_displayImage.superview convertRect:_displayImage.frame toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
        yxpModel.smallimageViewFrame = imgRect;
        yxpModel.smallImageView = _displayImage;
        [imgArray addObject:yxpModel];

        MSSBrowseViewController *bvc = [[MSSBrowseViewController alloc] initWithBrowseItemArray:imgArray currentIndex:indexRow];
        bvc.clickArr = @[MSSBrowseTypeString(MSSBrowseTypeSave)];
        bvc.isLoadLoc = YES;
        [self showImageInBrowsViewController:bvc];
    }else{
        imgArray = [self getImageMessage];
        indexRow = [self getImageMessageIndex:message];
        if (imgArray.count == 0) return;
        MSSBrowseViewController *bvc = [[MSSBrowseViewController alloc]initWithBrowseItemArray:imgArray currentIndex:indexRow];
        bvc.clickArr = @[MSSBrowseTypeString(MSSBrowseTypeForward),MSSBrowseTypeString(MSSBrowseTypeSave)];
        bvc.isLoadLoc = YES;
        
        [self showImageInBrowsViewController:bvc];
    }
}

- (void)showImageInBrowsViewController:(MSSBrowseViewController *)bvc {
    //全局查找该方法都只用了RootViewController
    [bvc showBrowseViewController];
//    return;
//    ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
//    
//    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//
//    if ([rootViewController isKindOfClass:[NSClassFromString(@"CYLTabBarController") class]]) {
//        [bvc showBrowseViewController];
//    } else{
//        [chatVC presentViewController:bvc animated:YES completion:^{
//            [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
//        }];
//    }
}


///发送进度改变
- (void)fileTransProgressChanged:(NSNotification *)noti{
    NSDictionary *dataDic = noti.userInfo;
    ECMessage *message = (ECMessage *)[dataDic objectForKey:KMessageKey];
    ///当前进度
    float progress = [(NSNumber *)[dataDic objectForKey:@"progress"] floatValue];
    if ([message.messageId isEqualToString:self.displayMessage.messageId]) {
        self.progressView.hidden = NO;
        self.blurView.hidden = NO;
        //进度条
        self.progressView.progress = progress;
        if (progress == 1) {
            self.blurView.hidden = YES;
             self.progressView.hidden = YES;
        }
    }
}
//获取会话消息里面为图片消息的路径数组
- (NSMutableArray *)getImageMessage{
    ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];

    NSMutableDictionary *showCellImageDic = [NSMutableDictionary dictionary];
    //查询当前显示的图片cell 用来获取显示图片的坐标
    if (chatVC.tableView.visibleCells && chatVC.tableView.visibleCells.count > 0 ) {
        for (id temp in [chatVC.tableView.visibleCells copy]) {
            @try {
                if(chatVC.messageArray.count > 0 && temp){
                    if([temp isKindOfClass:[ChatViewImageCell class]]){
                        ChatViewImageCell *imgCell = (ChatViewImageCell *)temp;
                        [showCellImageDic setObject:imgCell forKey:imgCell.displayMessage.messageId];
                    }
                }
            } @catch (NSException *exception) {

            } @finally {

            }
        }
    }

    NSArray *imageMessage = [[KitMsgData sharedInstance] getAllImageMessageOfSessionId:chatVC.sessionId];

    NSMutableArray *imageMessageArray = [NSMutableArray array];
    for (ECMessage *message in imageMessage) {
        NSDictionary *im_modeDic =  [MessageTypeManager getCusDicWithUserData:message.userData];
        NSString *localPath = nil;
        if ([[im_modeDic objectForKey:kRonxinBURN_MODE] isEqualToString:kRONGXINBURN_OFF] ||
            ![im_modeDic hasValueForKey:kRonxinBURN_MODE] ||
            [im_modeDic hasValueForKey:@"isRead"] ||
            [message.from isEqualToString:[[Chat sharedInstance] getAccount]] ||
            message.isRead){
            ECImageMessageBody *imageBody = (ECImageMessageBody *)message.messageBody;
            localPath = imageBody.localPath;
            if (localPath) {//图片路径
                localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:localPath.lastPathComponent];

                MSSBrowseModel *yxpModel =[[MSSBrowseModel alloc] init];
                yxpModel.bigImageUrl = imageBody.remotePath?imageBody.remotePath:@"";
                yxpModel.locImgUrl = localPath;
                yxpModel.authId = message.from;
                yxpModel.messageId = message.messageId;
                yxpModel.isBurnMessage = message.isBurnWithMessage;
                if([showCellImageDic.allKeys containsObject:message.messageId]){
                    ChatViewImageCell *showimgCell = showCellImageDic[message.messageId];
                    CGRect imgRect = [showimgCell.displayImage.superview convertRect:showimgCell.displayImage.frame toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
                    yxpModel.smallimageViewFrame = imgRect;
                    yxpModel.smallImageView = showimgCell.displayImage;
                }
                [imageMessageArray addObject:yxpModel];
            }
        }
    }
    return imageMessageArray;
}

// 返回点击图片的索引号
- (NSInteger)getImageMessageIndex:(ECMessage *)message{
    NSArray *imageMessage = [self getImageMessage];
    NSInteger index = 0;
    for (int i= 0;i<imageMessage.count;i++) {
        ECMessage * imageMsg = imageMessage[i];
        if ([imageMsg.messageId isEqualToString:message.messageId]) {
            index = i;
            break;
        }
    }
    return index;
}
@end
