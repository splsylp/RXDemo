//
//  ChatCallNoticeCell.m
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/9/14.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "ChatCallNoticeCell.h"

@interface ChatCallNoticeCell (){
    UIImageView * icon;
}

@end

@implementation ChatCallNoticeCell

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        if (isSender) {
            icon = [[UIImageView alloc] initWithFrame:CGRectMake(self.bubbleView.size.width - 30.0f, 12, 20, 20)];
            [self.bubbleView addSubview:icon];
            icon.contentMode = UIViewContentModeScaleAspectFit;
            
            self.callTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(5, 8.0f, self.bubbleView.frame.size.width-15.0f - 20.0f,29)];
            self.callTimeLab.textColor = [UIColor whiteColor];
            if (isEnLocalization) {
                self.callTimeLab.font = ThemeFontMiddle;
            }else{
                self.callTimeLab.font = ThemeFontLarge;
            }
            self.callTimeLab.backgroundColor = [UIColor clearColor];
            [self.bubbleView addSubview:self.callTimeLab];
            self.receipteBtn.hidden = YES;
        }else{
            icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 20, 20)];
            [self.bubbleView addSubview:icon];
            icon.contentMode = UIViewContentModeScaleAspectFit;
            
            self.callTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(icon.right + 10, 8.0f, self.bubbleView.frame.size.width-15.0f-icon.size.width,29)];
            self.callTimeLab.textColor = [UIColor blackColor];
            self.callTimeLab.font = ThemeFontLarge;
            self.callTimeLab.backgroundColor = [UIColor clearColor];
            [self.bubbleView addSubview:self.callTimeLab];
        }
        
    }
    return self;
}
+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 80.0f;
}

- (void)bubbleViewWithData:(ECMessage *)message{
    [super bubbleViewWithData:message];
    self.displayMessage = message;

    NSString *showText = [[NSString alloc] init];
    if (message.messageBody.messageBodyType == MessageBodyType_Call) {
        ECCallMessageBody *body = (ECCallMessageBody *)self.displayMessage.messageBody;
        if (body.calltype == VOICE) {
            showText = languageStringWithKey(@"语音通话 未接通");
        }else if (body.calltype == VIDEO){
            showText = languageStringWithKey(@"视频通话 未接通");
        }
    } else {
        ECTextMessageBody *body = (ECTextMessageBody *)self.displayMessage.messageBody;
        self.receipteBtn.hidden = YES;
        if (body.text == nil) {
            body.text = @"";
        }
        showText = body.text;
    }
    if (isEnLocalization) {
        _callTimeLab.font = ThemeFontMiddle;
    }else{
        _callTimeLab.font = ThemeFontLarge;
    }
    CGSize bubbleSize = [[Common sharedInstance] widthForContent:showText withSize:CGSizeMake(180.0f, 1000.0f) withLableFont:_callTimeLab.font.pointSize];
    if (bubbleSize.height < 40.0f) {
        bubbleSize.height = 40.0f;
    }
    [_callTimeLab setText:showText];
    
    NSDictionary *im_modeDic = self.displayMessage.userDataToDictionary;
    NSInteger status = [im_modeDic[@"status"] integerValue];
    if (self.isSender) {
        if (message.messageBody.messageBodyType == MessageBodyType_Call){
            ECCallMessageBody *body = (ECCallMessageBody *)self.displayMessage.messageBody;
            if (body.calltype == VOICE) {
                icon.image = ThemeImage(@"message_icon_voicecall_right");
            }else if (body.calltype == VIDEO){
                icon.image = ThemeImage(@"message_icon_videocall_right");
            }
        } else {
            if ([im_modeDic[@"callType"] integerValue] == 1) {
                icon.image = ThemeImage(@"message_icon_voicecall_right");
            }else{
                icon.image = ThemeImage(@"message_icon_videocall_right");
            }
        }
        _callTimeLab.textColor = [UIColor whiteColor];
        icon.frame = CGRectMake(10, 12, 20, 20);
        _callTimeLab.frame = CGRectMake(icon.right + 8.0f, 8.0f, bubbleSize.width, 29);
        self.bubbleView.frame = CGRectMake(self.portraitImg.originX -bubbleSize.width - 30.0f - 10.0f -icon.width, self.portraitImg.originY, bubbleSize.width + 30.0f + icon.width, 45);
    } else {
        if (message.messageBody.messageBodyType == MessageBodyType_Call){
            ECCallMessageBody *body = (ECCallMessageBody *)self.displayMessage.messageBody;
            if (body.calltype == VOICE) {
                icon.image = ThemeImage(@"message_icon_voicecall_left");
            }else if (body.calltype == VIDEO){
                icon.image =  ThemeImage(@"message_icon_videocall_left");
            }
        } else {
            if ([im_modeDic[@"callType"] integerValue] == 1) {
                icon.image = ThemeImage(@"message_icon_voicecall_left");
            }else {
                icon.image =  ThemeImage(@"message_icon_videocall_left");
            }
            if (status == 105 || status == 101) {
                _callTimeLab.textColor = [UIColor redColor];
            }else {
                _callTimeLab.textColor = [UIColor blackColor];
            }
        }
        _callTimeLab.frame = CGRectMake(icon.right + 8.0f, 8.0f, bubbleSize.width, 29);
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+self.portraitImg.frame.size.width+10.0f, self.portraitImg.frame.origin.y, bubbleSize.width+30.0f+icon.size.width, 45);
    }
    
}


@end
