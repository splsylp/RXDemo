//
//  ChatTextImageCell.m
//  Chat
//
//  Created by zhouwh on 2017/12/25.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ChatTextImageCell.h"
#import "ChatViewController.h"
#import "UIView+CurrentController.h"
#import "RXThirdPart.h"
#import "UIImage+deal.h"

#define BubbleMaxSize CGSizeMake(180.0f*fitScreenWidth, 1000.0f)

@implementation ChatTextImageCell

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        _displayImage = [[UIImageView alloc] init];
        _displayImage.contentMode = UIViewContentModeScaleAspectFit;
        _displayImage.backgroundColor = [UIColor clearColor];
        _displayImage.clipsToBounds = YES;
        
        if (self.isSender) {
            _displayImage.frame = CGRectMake(5, 5, 110.0f, 120.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.originX - 140.0f, self.portraitImg.originY, 130.0f, 130.0f);
            UIImage *backImage = ThemeImage(@"chating_right_02");
            self.bubleimg.image = [backImage stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
            
            _label = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 5.0f, self.bubbleView.width - 15.0f, 20.0f)];
            _label.textColor = [UIColor whiteColor];
        } else {
            _displayImage.frame = CGRectMake(15, 5, 110.0f, 120.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.originX + 10.0f + self.portraitImg.width, self.portraitImg.originY, 130.0f, 130.0f);
            UIImage *backImage = ThemeImage(@"chating_left_01");
            self.bubleimg.image = [backImage stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
            
            _label = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 5.0f, self.bubbleView.width - 15.0f, 20.0f)];
            _label.textColor = [UIColor blackColor];
        }
        [self.bubbleView addSubview:_displayImage];
        
        _label.numberOfLines = 0;
        _label.font = ThemeFontLarge;
        _label.lineBreakMode = NSLineBreakByCharWrapping;
        _label.backgroundColor = [UIColor clearColor];
        [self.bubbleView addSubview:_label];
    }
    return self;
}

#pragma mark - 点击手势
- (void)bubbleViewTapGesture:(UITapGestureRecognizer *)tap{
    if (![Common sharedInstance].isIMMsgMoreSelect) {
        [self imageCellBubbleViewTap:self.displayMessage];
    }
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 150.0f * fitScreenWidth;
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;

    ECImageMessageBody *mediaBody = (ECImageMessageBody *)message.messageBody;
    NSDictionary *userData = [MessageTypeManager getCusDicWithUserData:message.userData];
    if (message.isRichTextMessage) {
        NSString *text = [userData hasValueForKey:@"content"] ? userData[@"content"]:userData[@"Rich_text"];
        _label.text = text.base64DecodingString;
    }
    NSString *newCachesPath = [NSCacheDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",mediaBody.localPath.lastPathComponent]];
    mediaBody.localPath = newCachesPath;
    __weak __typeof(self)weakSelf = self;
    if (mediaBody.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath] && (mediaBody.mediaDownloadStatus == ECMediaDownloadSuccessed || message.messageState != ECMessageState_Receive)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            NSData *imageData = [NSData dataWithContentsOfFile:mediaBody.localPath options:NSDataReadingMappedIfSafe error:nil];
            UIImage *image = nil;
            if ([[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath]) {
                image = [UIImage imageWithContentsOfFile:mediaBody.localPath];
            } else {
                image = [UIImage imageWithData:imageData];
            }
            NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:mediaBody.localPath error:nil];
            long long fileSize = [attr[NSFileSize] longLongValue];
            if (fileSize/1024 > 1000) {
                CGSize size = CGSizeMake(1536, 1536);
                imageData = [image compressAndSaveImageWithNewSize:size andFilePath: mediaBody.localPath];
                image = [UIImage imageWithData:imageData];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showWithImage:image];
                [super bubbleViewWithData:self.displayMessage];
            });
            
        });
    } else {
        self.displayImage.image = ThemeImage(@"chat_placeholder_image");
        self.bubleimg.alpha = 1;
        [self getImageWithwidth:130 andgetImageWithhight:120];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[ChatMessageManager sharedInstance] downloadMediaMessage:message andCompletion:^(ECError *error, ECMessage *message) {
                if (error.errorCode == ECErrorType_NoError) {
                    if ([weakSelf.displayMessage.messageId isEqualToString:message.messageId]) {
                        ECFileMessageBody *msgBody = (ECFileMessageBody *)message.messageBody;
                        NSData *imageData = [NSData dataWithContentsOfFile:msgBody.localPath];
                        UIImage *image = [UIImage imageWithData:imageData];
                        NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:msgBody.localPath error:nil];
                        long long fileSize = [attr[NSFileSize] longLongValue];
                        if (fileSize/1024 > 1000) {
                            CGSize size = CGSizeMake(1536, 1536);
                            imageData = [image compressAndSaveImageWithNewSize:size andFilePath: msgBody.localPath];
                            image = [UIImage imageWithData:imageData];
                        }dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf showWithImage:image];
                            [super bubbleViewWithData:self.displayMessage];
                        });
                    }
                }
            }];
        });
    }
}
// 解决的问题：接受的图片显示缩略图，
- (void)reloadImage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ECDevice sharedInstance].messageManager downloadHDImageMessage:self.displayMessage progress:nil completion:^(ECError *error, ECMessage *message) {
            if (error.errorCode == ECErrorType_NoError) {
                if ([self.displayMessage.messageId isEqualToString:message.messageId]) {
                    ECFileMessageBody *msgBody = (ECFileMessageBody *)message.messageBody;
                    NSData *imageData = [NSData dataWithContentsOfFile:msgBody.localPath];
                    UIImage *image = [UIImage imageWithData:imageData];
                    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:msgBody.localPath error:nil];
                    long long fileSize = [attr[NSFileSize] longLongValue];
                    if (fileSize/1024 > 1000) {
                        CGSize size = CGSizeMake(1536, 1536);
                        imageData = [image compressAndSaveImageWithNewSize:size andFilePath: msgBody.localPath];
                        image = [UIImage imageWithData:imageData];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (image) {
                            [self showWithImage:image];
                        }
                    });
                }
            }
        }];
    });
}

- (void)showWithImage:(UIImage *)image{
    if (image == nil) {
        self.displayImage.image = ThemeImage(@"chat_placeholder_image");
        self.bubleimg.alpha = 1;
        [self getImageWithwidth:130 andgetImageWithhight:120];
        [self reloadImage];
        return;
    }
    _displayImage.image = image;
    [self getImageWithwidth:image.size.width andgetImageWithhight:image.size.height];
}

- (void)getImageWithwidth:(CGFloat)width andgetImageWithhight:(CGFloat)hight {
    CGFloat newWidth = 120 * (width / hight) * fitScreenWidth;
    CGFloat imgWidth = newWidth;
    newWidth = (newWidth > BubbleMaxSize.width)?BubbleMaxSize.width:newWidth;
    CGFloat imgHeight = 120*fitScreenWidth;
    if (imgWidth > BubbleMaxSize.width) {
        imgHeight = newWidth * (hight/width);
    }
    
    CGFloat margin = 10.f;
    _label.width = BubbleMaxSize.width;
    [_label sizeToFit];
    _label.originX = margin;//(self.isSender ? 5.0f : 5.0f);
    _label.originY = margin;//5.0f;

    float addHeight = _label.height + margin;
    if (self.isSender) {
        //图片改成居左显示
//        newWidth = (newWidth > _label.width) ? newWidth : _label.width;
//        _displayImage.frame = CGRectMake(5 + ((_label.width > (newWidth + 10)) ? _label.width - 5 - newWidth : 0), 5 + addHeight, newWidth, 120.0f * fitScreenWidth);
        _displayImage.frame = CGRectMake(margin, addHeight+margin, newWidth, imgHeight);
        CGFloat width = (_label.width<newWidth?newWidth:_label.width) + margin*2;
        self.bubbleView.frame = CGRectMake(self.portraitImg.originX - width - margin, self.portraitImg.originY, width,imgHeight+margin*2 + addHeight);
        self.bubleimg.alpha = 1;
    } else {
        CGFloat imageFrameY = self.portraitImg.originY;
        self.bubbleView.frame = CGRectMake(self.portraitImg.originX + 10.0f + self.portraitImg.width, imageFrameY, (_label.width<newWidth?newWidth:_label.width) + margin*2,imgHeight+ margin*2 + addHeight);
        _displayImage.frame = CGRectMake(_label.origin.x, addHeight+margin, newWidth, imgHeight);
    }
}
#pragma mark - 图片cell点击事件
- (void)imageCellBubbleViewTap:(ECMessage*)message {
    //获取控制器
    ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
    if (message.messageBody.messageBodyType >= MessageBodyType_Voice) {
        ECImageMessageBody *mediaBody = (ECImageMessageBody *)message.messageBody;
        
        if (mediaBody.localPath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath]) {
            [self showImagesWith:message];
            [self setDisplayMessage:message];
        } else if (mediaBody.remotePath.length>0) {
            [SVProgressHUD showWithStatus:languageStringWithKey(@"正在获取文件")];
            
            __weak __typeof(self)weakSelf = self;
            mediaBody.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:mediaBody.displayName];
            [[ChatMessageManager sharedInstance] downloadMediaMessage:message andCompletion:^(ECError *error, ECMessage *message) {
                
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [SVProgressHUD dismiss];
                if (error.errorCode == ECErrorType_NoError) {
                    if (self.isHistoryMessage) {//历史消息
                         [[KitMsgData sharedInstance] updateMessageLocalPath:message.messageId withPath:mediaBody.localPath withDownloadState:((ECFileMessageBody*)message.messageBody).mediaDownloadStatus];
                    }else{
                        [[KitMsgData sharedInstance] updateMessageLocalPath:message.messageId withPath:mediaBody.localPath withDownloadState:((ECFileMessageBody*)message.messageBody).mediaDownloadStatus];
                    }
                    [strongSelf  showImagesWith:message];
                } else {
                    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"获取文件失败")];
                }
            }];
        }
    }
}
- (void)showImagesWith:(ECMessage*)message {
    //获取图片索引
    __weak typeof(ECMessage *)weakMessage = message;
    if(!message.isRead) {
        [[AppModel sharedInstance] readedMessage:message completion:^(ECError *error, ECMessage *amessage) {
            if (error.errorCode == ECErrorType_NoError) {
                weakMessage.isRead = YES;
            }
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewShouldReloadData" object:nil];
        [[KitMsgData sharedInstance] updateMessageReadStateByMessageId:message.messageId isRead:YES];
    }
    ECImageMessageBody *mediaBody = (ECImageMessageBody *)message.messageBody;
    NSMutableArray *imgArray = [NSMutableArray array];
    NSInteger indexRow = 0;
    ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
    if (self.isHistoryMessage) {//历史消息
        MSSBrowseModel *yxpModel =[[MSSBrowseModel alloc]init];
        yxpModel.bigImageUrl = mediaBody.remotePath?mediaBody.remotePath:@"";
        yxpModel.locImgUrl = mediaBody.localPath;
        yxpModel.authId = message.from;
        yxpModel.messageId = message.messageId;
        yxpModel.isBurnMessage = NO;
        yxpModel.isHistoryMsg = YES;
        CGRect imgRect = [_displayImage.superview convertRect:_displayImage.frame toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
        yxpModel.smallimageViewFrame = imgRect;
        yxpModel.smallImageView = _displayImage;
        [imgArray addObject:yxpModel];
        
        MSSBrowseViewController *bvc = [[MSSBrowseViewController alloc] initWithBrowseItemArray:imgArray currentIndex:indexRow];
        bvc.clickArr = @[MSSBrowseTypeString(MSSBrowseTypeSave)];
        bvc.isLoadLoc = YES;
        [bvc showBrowseViewController];
//        [chatVC presentViewController:bvc animated:YES completion:nil];
    }else{
        imgArray = [self getImageMessage];
        indexRow = [self getImageMessageIndex:message];
        MSSBrowseViewController *bvc = [[MSSBrowseViewController alloc] initWithBrowseItemArray:imgArray currentIndex:indexRow];
        bvc.clickArr = @[MSSBrowseTypeString(MSSBrowseTypeForward),MSSBrowseTypeString(MSSBrowseTypeCollect),MSSBrowseTypeString(MSSBrowseTypeSave)];
        bvc.isLoadLoc = YES;
        [bvc showBrowseViewController];
//        [chatVC presentViewController:bvc animated:YES completion:nil];
    }
}

//获取会话消息里面为图片消息的路径数组
- (NSMutableArray *)getImageMessage{
    ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
    NSMutableDictionary *showCellImageDic = [NSMutableDictionary dictionary];
    //查询当前显示的图片cell 用来获取显示图片的坐标
    if (chatVC.tableView.visibleCells && chatVC.tableView.visibleCells.count > 0) {
        for (id temp in [chatVC.tableView.visibleCells copy]) {
            @try {
                if(chatVC.messageArray.count > 0 && temp){
                    if([temp isKindOfClass:[ChatTextImageCell class]]){
                        ChatTextImageCell *imgCell = (ChatTextImageCell *)temp;
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
        BOOL isBurnMsg = message.isBurnWithMessage;
        if (!isBurnMsg ||
            [im_modeDic hasValueForKey:@"isRead"] ||
            [message.from isEqualToString:[[Chat sharedInstance] getAccount]] ||
            message.isRead){
            ECImageMessageBody *imageBody = (ECImageMessageBody *)message.messageBody;
            localPath = imageBody.localPath;
            if (localPath) {//图片路径
                localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:localPath.lastPathComponent];
                
                MSSBrowseModel *yxpModel = [[MSSBrowseModel alloc] init];
                yxpModel.bigImageUrl = imageBody.remotePath ?imageBody.remotePath:@"";
                yxpModel.locImgUrl = localPath;
                yxpModel.authId = message.from;
                yxpModel.messageId = message.messageId;
                yxpModel.isBurnMessage = isBurnMsg;
                if([showCellImageDic.allKeys containsObject:message.messageId]){
                    ChatTextImageCell *showimgCell = showCellImageDic[message.messageId];
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
    for (int i= 0;i < imageMessage.count;i++) {
        ECMessage *imageMsg = imageMessage[i];
        if ([imageMsg.messageId isEqualToString:message.messageId]) {
            index = i;
            break;
        }
    }
    return index;
}

@end
