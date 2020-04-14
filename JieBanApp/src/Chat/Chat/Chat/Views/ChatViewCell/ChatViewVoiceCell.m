//
//  ChatViewVoiceCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/11.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ChatViewVoiceCell.h"
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>

//获取控制器  做跳转用
#import "UIView+CurrentController.h"
#import "ChatViewController.h"
#import "HXContinueVoicePlayManager.h"
#import <Speech/Speech.h>
//const char VOICE_MESSAGE_CanContinuePlayKey;

NSString *const KResponderCustomChatViewVoiceCellBubbleViewEvent = @"KResponderCustomChatViewVoiceCellBubbleViewEvent";
static float _voicePlayImgViewHeight = 17;

const char KVoiceIsPlayKey;

@interface ChatViewVoiceCell()
@property (nonatomic, strong) UIImageView *voicePlayImgView;
@property (nonatomic, strong) ECMessage *playVoiceMessage;


@end

@implementation ChatViewVoiceCell {
    UILabel *_lengthLabel; //语音时长
    UIImageView *_downloadingImg;
    UIImageView *_isReadVoiceImg;
}
- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        self.isSender = isSender;
        self.bubbleView.backgroundColor = [UIColor clearColor];

        _lengthLabel = [[UILabel alloc] init];
        _voicePlayImgView = [[UIImageView alloc] init];
        _voicePlayImgView.contentMode = UIViewContentModeScaleAspectFit;
        if (self.isSender) {
            _voicePlayImgView.image = ThemeImage(@"message_icon_playvoice3_right");
            _voicePlayImgView.frame = CGRectMake(self.bubbleView.frame.size.width - _voicePlayImgViewHeight - 10.0f - 10.0f - 25, 8.0f, _voicePlayImgViewHeight, _voicePlayImgViewHeight);
            _voicePlayImgView.layer.cornerRadius = _voicePlayImgView.frame.size.width/2;
            _voicePlayImgView.layer.masksToBounds = YES;
            //message_icon_playvoice1_right
            _voicePlayImgView.animationImages = [NSArray arrayWithObjects:ThemeImage(@"message_icon_playvoice2_right"), ThemeImage(@"message_icon_playvoice1_right"), ThemeImage(@"message_icon_playvoice2_right"),ThemeImage(@"message_icon_playvoice3_right"), nil];

            _lengthLabel.textAlignment = NSTextAlignmentLeft;
        } else {
            _voicePlayImgView.image = ThemeImage(@"message_icon_playvoice3_left");
            _voicePlayImgView.frame = CGRectMake(10.0f + 10.0f + 15, 8.0f, 26.0f, 29.0f);
            _voicePlayImgView.animationImages = [NSArray arrayWithObjects:ThemeImage(@"message_icon_playvoice2_left"), ThemeImage(@"message_icon_playvoice1_left"), ThemeImage(@"message_icon_playvoice2_left"),ThemeImage(@"message_icon_playvoice3_left"), nil];

            _downloadingImg = (UIImageView *)[self.bubbleView viewWithTag:1000];
            _downloadingImg.animationDuration = 1.0;
            _downloadingImg.animationImages = @[[ThemeImage(@ "chating_left_01_on") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f],[ThemeImage(@"chating_left_01") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f]];

            _isReadVoiceImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.bubbleView.width + 8, (self.bubbleView.height - 8) / 2.0 ,8, 8)];
            _isReadVoiceImg.backgroundColor = [UIColor colorWithHexString:@"EB4C4A"];
            _isReadVoiceImg.layer.cornerRadius = _isReadVoiceImg.width/2;
            _isReadVoiceImg.layer.masksToBounds = YES;
            [self.bubbleView addSubview:_isReadVoiceImg];
            _isReadVoiceImg.hidden = NO;
            
            _lengthLabel.textAlignment = NSTextAlignmentRight;
        }
        _lengthLabel.backgroundColor = [UIColor clearColor];
        _lengthLabel.font = ThemeFontMiddle;
        _lengthLabel.textColor = [UIColor whiteColor];
        [self.bubbleView addSubview:_lengthLabel];
        ///声音播放图标
        _voicePlayImgView.animationDuration = 1;
        [self.bubbleView addSubview:_voicePlayImgView];


        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClickVoicePlay:) name:KNotification_VoicePlay object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPlayVoice) name:@"voicePlayImgViewStopAnimating" object:nil];
    return self;
}
- (void)stopPlayVoice{
    [_voicePlayImgView stopAnimating];
}

#pragma mark - cell点击手势
- (void)bubbleViewTapGesture:(UITapGestureRecognizer *)tap{
    [self dispatchCustomEventWithName:KResponderCustomChatViewVoiceCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:tap];
    if (![Common sharedInstance].isIMMsgMoreSelect) {
        //视频会议时，不可播放视频
        NSNumber *number = [[AppModel sharedInstance] runModuleFunc:@"VidyoHelper" :@"IsVidyoingWhenOtherOperate" :nil];
        if(number.integerValue ==1){
            return;
        }
        [self voiceCellBubbleViewTap:self.displayMessage];
        _isReadVoiceImg.hidden = YES;
        if (!self.isSender) {
            self.displayMessage.isRead = YES;
        }
    }
}

- (void)onClickVoicePlay:(NSNotification *)notification {
    ECMessage *msg = (ECMessage *)notification.object;
    if (msg.messageId) {
        NSNumber *isplay = objc_getAssociatedObject(msg, &KVoiceIsPlayKey);
        if (isplay && isplay.boolValue) {
            [_voicePlayImgView startAnimating];
        } else {
            [_voicePlayImgView stopAnimating];
        }
    }
    
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 65.0f;
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;

    if (self.isSender) {
        if (message.isBurnWithMessage) {
            _lengthLabel.textColor = [UIColor whiteColor];
            self.bubleimg.image = [ThemeImage(@"burn_chating_right_02") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
            _voicePlayImgView.image = ThemeImage(@"message_icon_secret_playvoice3_right");
            _voicePlayImgView.animationImages = [NSArray arrayWithObjects:ThemeImage(@"message_icon_secret_playvoice2_right"), ThemeImage(@"message_icon_secret_playvoice1_right"), ThemeImage(@"message_icon_secret_playvoice2_right"),ThemeImage(@"message_icon_secret_playvoice3_right"), nil];
        }else {
            _lengthLabel.textColor = [UIColor colorWithHexString:@"666666"];
            self.bubleimg.image = [ThemeImage(@"chating_right_02") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
            _voicePlayImgView.image = ThemeImage(@"message_icon_playvoice3_right");
            _voicePlayImgView.animationImages = [NSArray arrayWithObjects:ThemeImage(@"message_icon_playvoice2_right"), ThemeImage(@"message_icon_playvoice1_right"), ThemeImage(@"message_icon_playvoice2_right"),ThemeImage(@"message_icon_playvoice3_right"), nil];
        }
    }else {
         _lengthLabel.textColor = [UIColor colorWithHexString:@"666666"];
    }
    
    
    ECVoiceMessageBody *mediaBody = (ECVoiceMessageBody *)self.displayMessage.messageBody;
    // 获取Caches目录路径  因为这个路径是一直变化的
    NSString *newCachesPath = [NSCacheDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",mediaBody.localPath.lastPathComponent.length>0?mediaBody.localPath.lastPathComponent:mediaBody.remotePath.lastPathComponent]];
    mediaBody.localPath = newCachesPath;
    // && (mediaBody.mediaDownloadStatus==ECMediaDownloadSuccessed || self.displayMessage.messageState != ECMessageState_Receive)
    if ([[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath] ) {
        NSMutableDictionary *userData = [MessageTypeManager getCusDicWithUserData:message.userData];
        NSInteger duration = [userData[@"duration"] integerValue];
        
        unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:mediaBody.localPath error:nil] fileSize];
        mediaBody.duration = duration ? duration : (int)(((fileSize/650)>60)?60:ceil(fileSize/650.f));
        _lengthLabel.text = [NSString stringWithFormat:@"%d″",(int)mediaBody.duration];
        _lengthLabel.hidden = NO;
    } else {
        if (self.isHistoryMessage) {
            [self downloadMediaMessage:self.displayMessage andCompletion:nil];
        }else{
            mediaBody.duration = 0;
            _lengthLabel.hidden = YES;
        }
    }
    
    CGFloat width = [self getWidthWithTime:mediaBody.duration];
    
    if (self.isSender) {
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x - width - 10.0f, self.portraitImg.frame.origin.y, width, 39.0f);
        self.voicePlayImgView.frame = CGRectMake(self.bubbleView.width-_voicePlayImgViewHeight - 14, (self.bubbleView.height -_voicePlayImgViewHeight)/2, _voicePlayImgViewHeight, _voicePlayImgViewHeight);

        _lengthLabel.frame = CGRectMake(-5 - 25 * FitThemeFont,0,25 * FitThemeFont, self.bubbleView.height);
        _lengthLabel.textAlignment = NSTextAlignmentRight;
        _isReadVoiceImg.hidden = YES;
        
        //秒放在气泡上
        _lengthLabel.right = _voicePlayImgView.left-5;
        _lengthLabel.centerY = _voicePlayImgView.centerY;
    } else {
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x + 10.0f + self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, width, 39.0f);
        self.voicePlayImgView.frame = CGRectMake(14, (self.bubbleView.height -_voicePlayImgViewHeight)/2, _voicePlayImgViewHeight, _voicePlayImgViewHeight);
        _lengthLabel.frame = CGRectMake(self.bubbleView.width + 7,  self.bubbleView.height / 2, 25 * FitThemeFont, self.bubbleView.height / 2);
        _lengthLabel.textAlignment = NSTextAlignmentLeft;
        
        self.voicePlayImgView.hidden = _lengthLabel.hidden;
        if (_lengthLabel.hidden) {
            [_downloadingImg startAnimating];
        } else {
            [_downloadingImg stopAnimating];
        }
        _isReadVoiceImg.hidden = self.displayMessage.isRead;
        
        //秒放在气泡上
        _lengthLabel.left = _voicePlayImgView.right+5;
        _lengthLabel.centerY = _voicePlayImgView.centerY;
    }
    self.timeLab.frame = CGRectMake(self.bubbleView.frame.size.width - 8, -4, 16, 16);
    self.burnIcon.frame = CGRectMake(self.bubbleView.frame.size.width - 8, -4, 16, 16);
    if (self.displayMessage.isBurnWithMessage) {
        _isReadVoiceImg.hidden = YES;
    }

    NSNumber *isplay = objc_getAssociatedObject(message, &KVoiceIsPlayKey);
    if (isplay && isplay.boolValue) {
        [_voicePlayImgView startAnimating];
    } else {
        [_voicePlayImgView stopAnimating];
    }
    [super bubbleViewWithData:message];
    _isReadVoiceImg.originX = self.bubbleView.width + 8;
    _isReadVoiceImg.originY = (self.bubbleView.height - 8) / 2.0;
}


- (CGFloat)getWidthWithTime:(NSInteger)time {
    if (time <= 0)
        return 140.0f;
    else if (time <= 2)
        return 80.0f;
    else if (time < 10)
        return (80.0f + 9.0f * (time - 2));
    else if (time < 60)
        return (80.0f + 9.0f * (7 + time / 10));
    return 200.0f;
}

#pragma mark - 播放语音
- (void)playVoiceMessage:(ECMessage *)message {
    UIViewController *chat = [self getCurrentViewController];
    UITableView *tableView;
    NSArray *messageArray;
    if ([chat isKindOfClass:[ChatViewController class]]) {
        ChatViewController *chatVC = (ChatViewController *)chat;
        tableView = chatVC.tableView;
        messageArray = chatVC.messageArray;
        self.playVoiceMessage = chatVC.voiceMessage;
    }else if ([chat isKindOfClass:[RXChatRecordsViewController class]]) {
        RXChatRecordsViewController *chatVC = (RXChatRecordsViewController *)chat;
        tableView = chatVC.recordTableView;
        messageArray = chatVC.messageArray;
        self.playVoiceMessage = chatVC.voiceMessage;
    }else{
        return;
    }
    [Chat sharedInstance].isChatViewScroll = NO;
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];//开启感应
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
  
    //当前正在播放语音，暂停当前播放
    if(self.playVoiceMessage && [self.playVoiceMessage.messageId isEqualToString:message.messageId] == NO){
        NSNumber* isplay = objc_getAssociatedObject(self.playVoiceMessage, &KVoiceIsPlayKey);
        if (isplay.boolValue) {
            objc_setAssociatedObject(self.playVoiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
            NSUInteger index = [messageArray indexOfObject:self.playVoiceMessage];
  
            if (index != NSNotFound) {
//                [tableView beginUpdates];
//                [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                [tableView endUpdates];
                [tableView reloadData];//1
            }
        }
    }
    
    
    NSNumber *isplay = objc_getAssociatedObject(message, &KVoiceIsPlayKey);
    if (isplay == nil && !message.isRead) {
        //首次点击
        isplay = @YES;
        self.playVoiceMessage = [self setVoicePlayStateWithMsg:message];
        //消息回执
        __weak typeof(ECMessage *)weakMessage = message;
        [[AppModel sharedInstance] readedMessage:message completion:^(ECError *error, ECMessage *amessage) {
            if (error.errorCode == ECErrorType_NoError) {
                
                weakMessage.isRead = YES;
                self->_isReadVoiceImg.hidden = YES;
                NSUInteger index = [messageArray indexOfObject:self.playVoiceMessage];
                if (index != NSNotFound) {
                    [tableView beginUpdates];
                    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [tableView endUpdates];
//                    [tableView reloadData];//2
                }
                [[KitMsgData sharedInstance] updateMessageReadStateByMessageId:amessage.messageId isRead:amessage.isRead];
            }
        }];
    } else {
        isplay = @(!isplay.boolValue);
        self.playVoiceMessage = message;
    }
    
    if ((!self.isHistoryMessage) && [chat isKindOfClass:[ChatViewController class]]) {
        [(ChatViewController *)chat setVoiceMessage:self.playVoiceMessage];
        
        if (self.playVoiceMessage) {
            
            NSMutableDictionary *userData = [MessageTypeManager getCusDicWithUserData:self.playVoiceMessage.userData];
            
            NSString *isRead = userData[KVoicePlayIsSure];
            if(isRead == nil || isRead.length == 0|| ![isRead isEqualToString:@"1"]){
                //以前没播放过，可以连续播放
                objc_setAssociatedObject(self.playVoiceMessage, &VOICE_MESSAGE_CanContinuePlayKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else{
                //以前播放过，不能连续播放
                objc_setAssociatedObject(self.playVoiceMessage, &VOICE_MESSAGE_CanContinuePlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            //阅读
            //如果前一个在播放
            if(![self.playVoiceMessage.from isEqualToString:[[Chat sharedInstance] getAccount]])
            {
                ECVoiceMessageBody *mediaBody = (ECVoiceMessageBody *)self.playVoiceMessage.messageBody;
                if(!mediaBody.isPlay)
                {
                    mediaBody.isPlay = YES;
                    [userData setValue:@"1" forKey:KVoicePlayIsSure];
                    NSString *userdataStr = [NSString stringWithFormat:@"UserData={%@}",[userData coverString]];
                    message.userData = userdataStr;
                    self.playVoiceMessage.userData = userdataStr;
                    [[KitMsgData sharedInstance] updateMessageState:message.sessionId andUserData:message.userData];
                    
                }
            }
            //语音播放断点
            objc_setAssociatedObject(self.playVoiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
            NSUInteger index = [messageArray indexOfObject:self.playVoiceMessage];
  ;            if (index != NSNotFound) {
//                [tableView beginUpdates];
//                [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                [tableView endUpdates];
                [tableView reloadData]; //3
            }
            self.playVoiceMessage = nil;
        }
    }else if (self.isHistoryMessage && [chat isKindOfClass:[RXChatRecordsViewController class]]){
        [(RXChatRecordsViewController *)chat setVoiceMessage:self.playVoiceMessage];
    }
    
    __weak __typeof(self) weakSelf = self;
    
    if (isplay.boolValue) {
        self.playVoiceMessage = message;
        objc_setAssociatedObject(message, &KVoiceIsPlayKey, isplay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if ([KitGlobalClass sharedInstance].isPlayEar) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        } else {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
        }
        

        [[ECDevice sharedInstance].messageManager playVoiceMessage:(ECVoiceMessageBody *)message.messageBody completion:^(ECError *error) {
            
            DDLogInfo(@"***********%@",error);
            if (weakSelf) {
                if(![weakSelf.playVoiceMessage.from isEqualToString:[[Chat sharedInstance] getAccount]])
                {
                    ECVoiceMessageBody *mediaBody = (ECVoiceMessageBody *)weakSelf.playVoiceMessage.messageBody;
                    if(!mediaBody.isPlay)
                    {
                        mediaBody.isPlay = YES;
                        NSMutableDictionary *userData = [MessageTypeManager getCusDicWithUserData:weakSelf.playVoiceMessage.userData];
                        
                        [userData setValue:@"1" forKey:KVoicePlayIsSure];
                        NSString *userdataStr=[NSString stringWithFormat:@"UserData={%@}",[userData coverString]];
                        message.userData = userdataStr;
                        weakSelf.playVoiceMessage.userData = userdataStr;
                        [[KitMsgData sharedInstance] updateMessageState:message.sessionId andUserData:message.userData];

                    }
                    [[KitMsgData sharedInstance] updateMessageReadStateByMessageId:message.messageId isRead:message.isRead];
                }
                
                
                if (message.isBurnWithMessage && [chat isKindOfClass:[ChatViewController class]])
                {
                    ChatViewController *chatVC = (ChatViewController *)chat;
                    NSString * timeStr = [[NSUserDefaults standardUserDefaults] valueForKey:message.messageId];
                    if (!timeStr) {
                        [[NSUserDefaults standardUserDefaults] setValue:chatVC.time forKey:message.messageId];
                    }
                    [chatVC addReceviceDataWithBurnMessage:message];
                    //播放完成了，删除发送端的消息
                    [[ECDevice sharedInstance].messageManager deleteMessage:message completion:nil];
                }
                objc_setAssociatedObject(weakSelf.playVoiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                NSUInteger index = [messageArray indexOfObject:self.playVoiceMessage];
  ;                if (index != NSNotFound) {
//                    [tableView beginUpdates];
//                    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                    [tableView endUpdates];
                    [tableView reloadData];
                }
                
                weakSelf.playVoiceMessage = nil;
                [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
                if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
                }
                [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];//关闭感应

                //继续播放下一条
                
                if ((!weakSelf.isHistoryMessage) && [chat isKindOfClass:[ChatViewController class]]) {
                    ChatViewController *chatVC = (ChatViewController *)chat;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        DDLogInfo(@"测试语音连续");
                        ECMessage *nextVoiceMessage = [[HXContinueVoicePlayManager shardDefaultManager] findNextMessageToContinuePlayWithCurrentVoiceMessage:message];
                        if(nextVoiceMessage){
                            [weakSelf playVoiceMessage:nextVoiceMessage];    //播放下一条
                            chatVC.voiceMessage = nextVoiceMessage;
                        }
                    });
                }
                
            }
        }];
        
        NSUInteger index = [messageArray indexOfObject:self.playVoiceMessage];
  ;        if (index != NSNotFound) {
//            [tableView beginUpdates];
//            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//            [tableView endUpdates];
            [tableView reloadData];
        }
    }
}

//记录语音是否播放过的状态
- (ECMessage *)setVoicePlayStateWithMsg:(ECMessage *)message
{
    
    BOOL isSender = (message.messageState==ECMessageState_Receive?NO:YES);
    if (!isSender) {
        NSDictionary *im_modeDic =  [MessageTypeManager getCusDicWithUserData:message.userData];
        ChatViewController *chatViewC = (ChatViewController *)[self getCurrentViewController];
        NSInteger index = [chatViewC.messageArray indexOfObject:message];
        if (index != NSNotFound) {
            if (![im_modeDic hasValueForKey:KVoicePlayIsSure]) {
                [im_modeDic setValue:@"isPlay" forKey:KVoicePlayIsSure];
                NSString *userdataStr=[NSString stringWithFormat:@"UserData={%@}",[im_modeDic coverString]];
                message.userData = userdataStr;
                [chatViewC.messageArray replaceObjectAtIndex:index withObject:message];
                  [[KitMsgData sharedInstance] updateMessageState:message.sessionId andUserData:message.userData];
                
            }
        }
    }
    
    return message;
    
}
#pragma mark - cell点击事件
-(void)voiceCellBubbleViewTap:(ECMessage*)message{
    ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
   
    ECVoiceMessageBody* mediaBody = (ECVoiceMessageBody*)message.messageBody;
    if (mediaBody.localPath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath]) {
        [self playVoiceMessage:message];//播放语音
    } else if (message.messageState == ECMessageState_Receive && mediaBody.remotePath.length>0){
        [SVProgressHUD showWithStatus:languageStringWithKey(@"正在获取文件")];
        
        mediaBody.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:mediaBody.displayName];
        
        [[ChatMessageManager sharedInstance] downloadMediaMessage:message andCompletion:^(ECError *error, ECMessage *message) {
            [SVProgressHUD dismiss];
            if (error.errorCode != ECErrorType_NoError) {
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"获取文件失败")];
            }else{
                [[KitMsgData sharedInstance] updateMessageLocalPath:message.messageId withPath:mediaBody.localPath withDownloadState:((ECFileMessageBody*)message.messageBody).mediaDownloadStatus];
            }
        }];
    }
}

- (void)downloadMediaMessage:(ECMessage*)curmessage andCompletion:(void(^)(ECError *error, ECMessage* message))completion{
    
    ECFileMessageBody *mediaBody = (ECFileMessageBody *)curmessage.messageBody;
    
    
    if(!mediaBody.displayName)
    {
        mediaBody.displayName = mediaBody.remotePath.lastPathComponent;
    }
    
    mediaBody.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:mediaBody.displayName];
    mediaBody.mediaDownloadStatus = ECMediaDownloading;
    
    [[ECDevice sharedInstance].messageManager downloadMediaMessage:curmessage progress:nil completion:^(ECError *error, ECMessage *amessage) {
        if (error.errorCode == ECErrorType_NoError) {
            
            [self setNeedsLayout];
        }
        
        if (completion != nil) {
            completion(error, amessage);
        }
        [_downloadingImg stopAnimating];
        
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 处理近距离监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)//黑屏
    {
        DDLogInfo(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else//没黑屏幕
    {
        DDLogInfo(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
       
    }
}

@end
