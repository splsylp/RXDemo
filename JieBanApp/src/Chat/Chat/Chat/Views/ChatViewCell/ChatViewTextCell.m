//
//  ChatViewTextCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/8.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//
#import <CoreText/CoreText.h>

#import "ChatHomeView.h"

#import "ChatViewTextCell.h"
//群聊相关
#import "RXCommonDialog.h"
//获取控制器  做跳转用
#import "UIView+CurrentController.h"
#import "ChatViewController.h"

#pragma mark - zmf 视频会议相关
//#import "MultiVideoConfViewController.h"



NSString *const KResponderCustomChatViewTextCellBubbleViewEvent = @"KResponderCustomChatViewTextCellBubbleViewEvent";
NSString *const KResponderCustomChatViewTextLnkCellBubbleViewEvent = @"KResponderCustomChatViewTextLnkCellBubbleViewEvent";
NSString *const KResponderCustomChatViewTextMobileCellBubbleViewEvent = @"KResponderCustomChatViewTextMobileCellBubbleViewEvent";

#define BubbleMaxSize CGSizeMake(180.0f*fitScreenWidth, 3000.0f)
@interface ChatViewTextCell()
@property (nonatomic, strong)NSRegularExpression *detector;
@property (nonatomic, strong) NSArray *urlMatches; // url 或者电话号码 匹配出来的数组
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) ChatHomeView *chatHomeView;
/** 白板消息的图片 */
@property(nonatomic,strong)UIImageView *boardFlagView;

@end
@implementation ChatViewTextCell{
    UILabel *_label;
}

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        _label = [[UILabel alloc] init];
        if (isSender) {
            _label.frame = CGRectMake(5.0f, 5.0f, self.bubbleView.frame.size.width-15.0f, self.bubbleView.frame.size.height-10.0f);
            _label.textColor = [UIColor whiteColor];
            UIImage *image = [ThemeImage(@"chating_right_02") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.bubleimg.image = image;
            });
        }else{
            _label.frame = CGRectMake(10.0f, 5.0f, self.bubbleView.frame.size.width-15.0f, self.bubbleView.frame.size.height-10.0f);
            _label.textColor = [UIColor blackColor];
            UIImage *image = [ThemeImage(@"chating_left_01") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.bubleimg.image = image;
            });
        }
        _label.numberOfLines = 0;
        _label.font = ThemeFontLarge;
        _label.lineBreakMode = NSLineBreakByCharWrapping;
        _label.backgroundColor = [UIColor clearColor];
        [self.bubbleView addSubview:_label];
        // 匹配出电话号码，链接
        self.detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink error:nil];
    }
    return self;
}

#pragma mark - 点击手势
- (void)bubbleViewTapGesture:(UITapGestureRecognizer *)tap{
    [self dispatchCustomEventWithName:KResponderCustomChatViewTextCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:tap];
    if (![Common sharedInstance].isIMMsgMoreSelect) {
        
        [self clickTextCellWithMessage:self.displayMessage];
        
        CGPoint point = [tap locationInView:_label];
        CFIndex charIndex = [self characterIndexAtPoint:point];
        
        [self highlightLinksWithIndex:NSNotFound];
        
        ECTextMessageBody *body = (ECTextMessageBody *)self.displayMessage.messageBody;
        _url = nil;

        for (NSTextCheckingResult *match in self.urlMatches) {
            NSRange matchRange = [match range];
            if ([self isIndex:charIndex inRange:matchRange]) {
                _url = [body.text substringWithRange:matchRange];
            }
        }
        _url = [_url lowercaseString];
        if (_url.length > 0) {
            //为手机号
            if([self isMobileNumber:_url]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"doubleTextCellEndEdit" object:nil];
                [self dispatchCustomEventWithName:KResponderCustomChatViewTextMobileCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage,@"url":_url} tapGesture:tap];
            }else {
                if ((![_url hasPrefix:@"http://"])&&(![_url hasPrefix:@"https://"])&&(![_url hasPrefix:@"ftp://"])) {
                    _url = [NSString stringWithFormat:@"http://%@",_url];
                }
                [self dispatchCustomEventWithName:KResponderCustomChatViewTextLnkCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage,@"url":_url} tapGesture:tap];
                //收回键盘
                [[NSNotificationCenter defaultCenter] postNotificationName:@"doubleTextCellEndEdit" object:nil];
            }
        }
    }
}

- (void)doubleTextTapGesture:(UITapGestureRecognizer *)tap {
    if (isHaveIMBigText == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doubleTextCellEndEdit" object:nil];
        
        _chatHomeView = [[[NSBundle mainBundle] loadNibNamed:@"ChatHomeView" owner:nil options:nil] firstObject];
        _chatHomeView.frame = CGRectMake(0.0, 0.0, kScreenWidth, kScreenHeight);
        [[[UIApplication sharedApplication] keyWindow] addSubview:_chatHomeView];
        ECTextMessageBody *body = (ECTextMessageBody *)self.displayMessage.messageBody;
        [_chatHomeView getText:body.text];
        _chatHomeView.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            self->_chatHomeView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)messageBody{
    CGFloat height = 0.0f;
    ECTextMessageBody *body = (ECTextMessageBody *)messageBody;
    CGSize bubbleSize = [[Common sharedInstance] widthForContent:body.text withSize:BubbleMaxSize withLableFont:ThemeFontLarge.pointSize];
    height = bubbleSize.height + 47.0f;
    return height;
}

- (CFIndex)characterIndexAtPoint:(CGPoint)point {
    NSMutableAttributedString *optimizedAttributedText = [_label.attributedText mutableCopy];
    [_label.attributedText enumerateAttributesInRange:NSMakeRange(0, [_label.attributedText length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (!attrs[(NSString *)kCTFontAttributeName]) {
            [optimizedAttributedText addAttribute:(NSString *)kCTFontAttributeName value:self->_label.font range:NSMakeRange(0, [self->_label.attributedText length])];
        }
        if (!attrs[(NSString *)kCTParagraphStyleAttributeName]) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineBreakMode:self->_label.lineBreakMode];
            [optimizedAttributedText addAttribute:(NSString *)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
        }
    }];
    [optimizedAttributedText enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [optimizedAttributedText length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        NSMutableParagraphStyle *paragraphStyle = [value mutableCopy];
        if ([paragraphStyle lineBreakMode] == NSLineBreakByTruncatingTail) {
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        }
        [optimizedAttributedText removeAttribute:(NSString *)kCTParagraphStyleAttributeName range:range];
        [optimizedAttributedText addAttribute:(NSString *)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
     }];
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    CGRect textRect = _label.frame;
    textRect.origin.x -=10;
    textRect.origin.y -=10;
    textRect.size.width +=10;
    textRect.size.height+=10;
    if (!CGRectContainsPoint(textRect, point)) {
        return NSNotFound;
    }
    point = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    point = CGPointMake(point.x, textRect.size.height - point.y);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)optimizedAttributedText);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [_label.attributedText length]), path, NULL);
    CFRelease(framesetter);
    
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = _label.numberOfLines > 0 ? MIN(_label.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    NSUInteger idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        if (point.y > yMax) {
            break;
        }
        if (point.y >= yMin) {
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                break;
            }
        }
    }
    CFRelease(frame);
    CFRelease(path);
    return idx;
}

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    return index > range.location && index < range.location+range.length;
}


- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString *attributedString = [_label.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in self.urlMatches) {
        NSRange matchRange = [match range];
        if ([self isIndex:index inRange:matchRange]) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
        } else {
            //匹配出的链接，电话号码的颜色
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"1B7BD3"] range:matchRange];
        }
         //匹配出的链接，电话号码的下划线 UI说 不需要下划线at
       // [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];

    }
    _label.attributedText = attributedString;
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;
    
    NSDictionary* userData = [MessageTypeManager getCusDicWithUserData:message.userData];
    NSInteger state = [userData[SMSGTYPE] integerValue];
    NSInteger sendState = [userData[@"sendState"] integerValue];
    if (state == 27 && sendState == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bubleimg.image = [ThemeImage(@"chating_right_02") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
        });
    }
    else {
        if (self.isSender) {
            if (message.isBurnWithMessage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.bubleimg.image = [ThemeImage(@"burn_chating_right_02") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.bubleimg.image = [ThemeImage(@"chating_right_02") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
                });
            }
        }
        else {
            UIImage *image = [ThemeImage(@"chating_left_01") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.bubleimg.image = image;
            });
        }
    }
    
    ECTextMessageBody *body = (ECTextMessageBody *)self.displayMessage.messageBody;
    if (body.text == nil) {
        body.text = @"";
    }
    //根据detector包含电话号码和链接，把body.text 匹配出来，放在urlMatches数组里面
    self.urlMatches = [self.detector matchesInString:body.text options:0 range:NSMakeRange(0, body.text.length)];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:body.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [body.text length])];
    [attributedString addAttribute:NSFontAttributeName value:ThemeFontLarge range:NSMakeRange(0, [body.text length])];
    [_label setAttributedText:attributedString];
    [self highlightLinksWithIndex:NSNotFound];


    CGSize bubbleSize;
    if ([self.displayMessage getHeight] <= 0) {
        if (self.displayMessage.isGroupNoticeMessage) {
            bubbleSize = [[Common sharedInstance] widthForContent:body.text withSize:CGSizeMake(kScreenWidth - 80 * fitScreenWidth, MAXFLOAT) withLableFont:ThemeFontSmall.pointSize];
        }else{
            bubbleSize = [[Common sharedInstance] widthForContent:body.text withSize:BubbleMaxSize withLableFont:ThemeFontLarge.pointSize];
        }
        [self.displayMessage setHeight:bubbleSize.height];
    }else{
        if (self.displayMessage.isGroupNoticeMessage) {
            bubbleSize = [[Common sharedInstance] widthForContent:body.text withSize:CGSizeMake(kScreenWidth - 80 * fitScreenWidth, MAXFLOAT) withLableFont:ThemeFontSmall.pointSize];
        }else{
            bubbleSize = [[Common sharedInstance] widthForContent:body.text withSize:BubbleMaxSize withLableFont:ThemeFontLarge.pointSize];
        }
        [self.displayMessage setHeight:bubbleSize.height];
    }
    if (isnan(bubbleSize.height)) {
        bubbleSize = [[Common sharedInstance] widthForContent:body.text withSize:BubbleMaxSize withLableFont:ThemeFontLarge.pointSize];
    }
    
    CGFloat boardImgW = 20.f;
    CGFloat gap = 5.f;//图片到文字 label 的间距
    if (message.isBoardMessage) {
        bubbleSize = CGSizeMake(bubbleSize.width+boardImgW+gap, bubbleSize.height);
    }else {
        self.boardFlagView.hidden = YES;
    }
    if (bubbleSize.width < 17) {
        bubbleSize.width = 17;
    }
    if (self.isSender && ![message.sessionId isEqualToString:IMSystemLoginSessionId]) {
        dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
        dispatch_async(defaultQueue, ^{
            UIImage *image = ThemeImage(@"icon_whiteboard_green");
            dispatch_async(dispatch_get_main_queue(), ^{
                self.boardFlagView.image =image;
            });
        });
//        self.boardFlagView.image = ThemeImage(@"icon_whiteboard_green");
        self.bubbleView.frame = CGRectMake(self.portraitImg.left -bubbleSize.width - 25.0f - 10.0f, self.portraitImg.top, bubbleSize.width + 25.0f, bubbleSize.height + 21);
        _label.frame = CGRectMake(10.0f, 8, bubbleSize.width + 5, bubbleSize.height + 5);
        self.boardFlagView.frame = CGRectMake(9.f, 11, boardImgW, _label.height);
    } else {
        dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
        dispatch_async(defaultQueue, ^{
            UIImage *image = ThemeImage(@"icon_whiteboard");
            dispatch_async(dispatch_get_main_queue(), ^{
                self.boardFlagView.image =image;
            });
        });
//        self.boardFlagView.image = ThemeImage(@"icon_whiteboard");
        self.bubbleView.frame = CGRectMake(self.portraitImg.left + self.portraitImg.width + 10.0f, self.portraitImg.top, bubbleSize.width + 20.0f, bubbleSize.height + 21);
        _label.frame = CGRectMake(10.0f+(message.isBoardMessage?gap:0), 8, bubbleSize.width, bubbleSize.height + 5);
        self.boardFlagView.frame = CGRectMake(13.f, 11, boardImgW, _label.height);
    }
    
    if (message.isBoardMessage) {
        self.boardFlagView.hidden = NO;
        _label.left = _boardFlagView.right+gap;
        _label.width = _label.width-boardImgW-gap;
    }else {
        self.boardFlagView.hidden = YES;
    }
    [super bubbleViewWithData:message];
    DDLogInfo(@"eagle.chatviewtextcell.bubbleViewWithData after");
}

#pragma mark - 点击cell
- (void)clickTextCellWithMessage:(ECMessage *)message{
    NSString *type;
    NSDictionary *userData = message.userDataToDictionary;
    type = [userData objectForKey:kRonxinMessageType];
    //等于1的时候 语音会议入口 创建手势
    if([type isEqualToString:kRONGXINVOICEMEETTING] || [type isEqualToString:kRONGXINVIDEOMEETTING]){
        if(![message.from isEqualToString:[[Chat sharedInstance] getAccount]]){
            [self textCellBubbleViewTap:message];
        }
    }
}


- (void)textCellBubbleViewTap:(ECMessage *)message{
    ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
    NSString *type;
    NSDictionary* userData = [MessageTypeManager getCusDicWithUserData:message.userData];
    if ([userData hasValueForKey:kRonxinMessageType]) {
        type = [userData objectForKey:kRonxinMessageType];
        if([type isEqualToString:kRONGXINVOICEMEETTING]){
            //加入语音群聊
            NSString *name = @"";
            if([message.to hasPrefix:@"g"]){
                name = [[Common sharedInstance] getOtherNameWithPhone:message.from];
            }else{
               name = chatVC.titleLabel.text;
            }
            RXCommonDialog *dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
            if (name) {
            } else{
                dialog.textLabel.text = [NSString stringWithFormat:@"确认要加入电话会议吗"];
            }
            dialog.selectButtonAtIndex = ^(NSInteger index){
                if(index != 1){
                    return ;
                }
                [[ECDevice sharedInstance].meetingManager queryMeetingMembersByMeetingType:ECMeetingType_MultiVoice andMeetingNumber:[userData objectForKey:kCCPInterphoneConfNo] completion:^(ECError *error, NSArray *members) {
                    if(error.errorCode == ECErrorType_NoError){
                        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:message.messageId,@"messageId",message.sessionId,@"sessionId",[userData objectForKey:kCCPInterphoneConfNo],@"roomNo",@"joinMeetRoom",@"style",kRONGXINVOICEMEETTING,@"roomType",nil];
                        [chatVC pushViewController:@"RXMeettingViewController" withData: info withNav:NO];
                    } else {
                        if (error.errorCode == 111703){
                            error.errorDescription = languageStringWithKey(@"房间已解散或者不存在！");
                            if (message == chatVC.messageArray.lastObject && chatVC.messageArray.count > 1) {
                                //删除最后消息才需要刷新session
                                if (message == chatVC.messageArray.firstObject) {
                                    [[KitMsgData sharedInstance] deleteMessage:message.messageId andSession:message.sessionId];
                                } else {
                                    //使用前一个消息刷新session
                                    ECMessage *textMess = [chatVC.messageArray objectAtIndex:chatVC.messageArray.count-2];

                                    [[KitMsgData sharedInstance] deleteMessage:message andPre:textMess];
                                }
                            } else {
                                [[KitMsgData sharedInstance] deleteMessage:message.messageId andSession:chatVC.sessionId];
                            }
                            [chatVC.messageArray removeObject:message];
                        }else if (error.errorCode == 113709){
                            error.errorDescription = languageStringWithKey(@"会议人数上限");
                        }else if (error.errorCode == 111710){
                            error.errorDescription = languageStringWithKey(@"创建者退出");
                        }else if (error.errorCode == 171139){
                            error.errorDescription = languageStringWithKey(@"网络不给力");
                        }
                        NSString *msg = [NSString stringWithFormat:@"%@",error.errorDescription.length>0?error.errorDescription:languageStringWithKey(@"未知")];
                        [UIAlertView showAlertView:languageStringWithKey(@"提示") message:msg click:^{
                            //让控制器刷新
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewShouldReloadData" object:nil];
                        } okText:languageStringWithKey(@"确定")];
                    }
                }];
            };
        }else if ([type isEqualToString:kRONGXINVIDEOMEETTING]){
            //加入视频会议
            RXCommonDialog *dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
            NSString *name = @"";
            if([message.to hasPrefix:@"g"]){
                name = [[Common sharedInstance] getOtherNameWithPhone:message.from];
            }else{
                name = chatVC.titleLabel.text;
            }
            if (chatVC.titleLabel.text) {
                dialog.textLabel.text = [NSString stringWithFormat:languageStringWithKey(@"确认要加入%@邀请的视频会议吗"),name];
            }else{
                dialog.textLabel.text = languageStringWithKey(@"确认要加入邀请的视频会议吗");
            }
            dialog.selectButtonAtIndex = ^(NSInteger index){
                if(index == 1){
#pragma mark - zmf 视频会议入口
//                    [Common sharedInstance].isCallBusy = YES;
//                    MultiVideoConfViewController *VideoConfview = [[MultiVideoConfViewController alloc] init];
//                    VideoConfview.navigationItem.hidesBackButton = YES;
//                    VideoConfview.curVideoConfId = [userData objectForKey:kCCPInterphoneConfNo];
//                    VideoConfview.Confname = @"视频会议";
//                    VideoConfview.backView = chatVC;
//                    VideoConfview.isCreator = NO;
//                    [chatVC.navigationController pushViewController:VideoConfview animated:YES];
//                    [VideoConfview joinInVideoConf];
                }
            };
        }
    }
}

#pragma mark isPhone add yuxp
- (BOOL)isMobileNumber:(NSString *)mobileString{
    NSString *nameRegex = @"^[1-9]\\d*|0$";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nameRegex];
    return [pre evaluateWithObject:mobileString];
    
//    if(mobileString){
//        NSError *error;
//        NSArray *mobileArray  =  [[NSRegularExpression regularExpressionWithPattern:@"(1[3578][0-9]{9})|(0[127][0-9][-][0-9]{4,5})|(0[127][0-9]{5,6})" options:NSRegularExpressionCaseInsensitive error:&error] matchesInString:mobileString options:0 range:NSMakeRange(0, mobileString.length)];
//        if(mobileArray.count > 0){
//            return YES;
//        }
//    }
//    return NO;
}
#pragma mark isUrl add yxp
- (BOOL)isUrlWithString:(NSString *)currString{
    NSString *regex =@"[a-zA-z]+://[^\\s]*";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:currString];
}

- (UIImageView *)boardFlagView {
    if (_boardFlagView == nil) {
        _boardFlagView = [UIImageView new];
        _boardFlagView.contentMode = UIViewContentModeScaleAspectFit;
        [self.bubbleView addSubview:_boardFlagView];
    }
    return _boardFlagView;
}

@end
