//
//  ChatViewRedpacketTakenTipCell.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/22.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewRedpacketTakenTipCell.h"
//#import "ECMessage+RedpacketMessage.h"

#define REDPACKET_BUNDLE(name) @"RedpacketCellResource.bundle/" name
#define BACKGROUND_LEFT_RIGHT_PADDING 10
#define ICON_LEFT_RIGHT_PADDING 2

@interface ChatViewRedpacketTakenTipCell ()
@property(nonatomic, strong) UIView *bgView;

@property(strong, nonatomic) UILabel *tipMessageLabel;
@property(strong, nonatomic) UIImageView *iconView;
@property (nonatomic, strong, readwrite) ECMessage * message;

@end

@implementation ChatViewRedpacketTakenTipCell

- (instancetype) initWithIsSender:(BOOL)aIsSender reuseIdentifier:(NSString *)reuseIdentifier{
      if (self = [super initWithIsSender:aIsSender reuseIdentifier:reuseIdentifier]) {
          [self.portraitImg removeFromSuperview];
          [self.bubleimg removeFromSuperview];
          [self.receipteBtn removeFromSuperview];
          
          self.bgView = [[UIView alloc] initWithFrame:self.bounds];
          self.bgView.userInteractionEnabled = NO;
          self.bgView.backgroundColor = [UIColor colorWithRed:0xdd * 1.0f / 255.0f green:0xdd * 1.0f / 255.0f blue:0xdd * 1.0f / 255.0f alpha:1.0f];
        self.bgView.autoresizingMask = UIViewAutoresizingNone;
        self.bgView.layer.cornerRadius = 4.0f;
        [self.contentView addSubview:self.bgView];
        
        self.tipMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.tipMessageLabel.font =ThemeFontSmall;
        self.tipMessageLabel.textColor = [UIColor colorWithRed:0x9e * 1.0f / 255.0f green:0x9e * 1.0f / 255.0f blue:0x9e * 1.0f / 255.0f alpha:1.0f];
        self.tipMessageLabel.userInteractionEnabled = NO;
        self.tipMessageLabel.numberOfLines = 1;
        [self.bgView addSubview:self.tipMessageLabel];
        
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 15)];
        self.iconView.image = ThemeImage(REDPACKET_BUNDLE(@"redpacket_smallIcon"));
        self.iconView.userInteractionEnabled = NO;
        [self.bgView addSubview:self.iconView];
    }
    return self;
}


- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;

    [self.tipMessageLabel sizeToFit];
    CGRect frame = self.tipMessageLabel.frame;
    CGRect iconFrame = self.iconView.frame;
    CGRect bgFrame = CGRectMake(0, 0.0f,frame.size.width + iconFrame.size.width + 2 * BACKGROUND_LEFT_RIGHT_PADDING,22);

    frame.origin.y = (bgFrame.size.height - frame.size.height) * 0.5;
    iconFrame.origin.x = BACKGROUND_LEFT_RIGHT_PADDING - ICON_LEFT_RIGHT_PADDING;
    iconFrame.origin.y = frame.origin.y + (frame.size.height - iconFrame.size.height) * 0.5;
    self.iconView.frame = iconFrame;

    frame.origin.x = ICON_LEFT_RIGHT_PADDING + iconFrame.origin.x + iconFrame.size.width;
    self.tipMessageLabel.frame = frame;

    bgFrame.origin.y = (self.frame.size.height - bgFrame.size.height) * 0.5f;
    bgFrame.origin.x = (self.bounds.size.width - bgFrame.size.width) * 0.5;
    self.bgView.frame = bgFrame;


    self.message = message;
    NSData *data = [message.userData dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictt = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *tipText = nil;
    
    BOOL isRedpacket = [[Chat sharedInstance].componentDelegate isRedpacketWithData:message.userData];
//    BOOL isTranser = [[Chat sharedInstance].componentDelegate isTransferWithData:message.userData];
//    BOOL isRedTip = [[Chat sharedInstance].componentDelegate isRedpacketOpenMessageWithData:message.userData];
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:dictt];

    if (isRedpacket == YES) {//红包消息

        NSString *userId = [Common sharedInstance].getAccount;
        //发送者和接收者的账号
        NSString *redpacketSenderId = [dict objectForKey:@"money_sender_id"];
        NSString *redpacketReceiverId = [dict objectForKey:@"money_receiver_id"];

        //发送者和接收者的名字
        NSString *redpacketSenderName = [[Common sharedInstance] getOtherNameWithPhone:redpacketSenderId];
        NSString *redpacketReceiverName = [[Common sharedInstance] getOtherNameWithPhone:redpacketReceiverId];
        NSString *tepS1 = languageStringWithKey(@"领取了");
        NSString *tepS2 = languageStringWithKey(@"红包");
        NSString *tepS3 = languageStringWithKey(@"你");
        if (message.isGroup) {

            if([userId isEqualToString:redpacketSenderId] && [redpacketSenderId isEqualToString:redpacketReceiverId]) {
                tipText = languageStringWithKey(@"你领取了自己的红包");
            } else if ([userId isEqualToString:redpacketSenderId]) {
                NSString *tepStr = languageStringWithKey(@"领取了你的红包");
                tipText = [NSString stringWithFormat:@"%@%@",redpacketReceiverName,tepStr];
            } else if (![userId isEqualToString:redpacketReceiverId] && ![userId isEqualToString:redpacketSenderId]) {

                tipText = [NSString stringWithFormat:@"%@%@%@%@",redpacketReceiverName,tepS1,redpacketSenderName,tepS2];
            } else {
                tipText = [NSString stringWithFormat:@"%@%@%@%@",tepS3,tepS1,redpacketSenderName,tepS2];
            }

        } else {

            if ([userId isEqualToString:redpacketSenderId]) {
                NSString *tepS = languageStringWithKey(@"领取了你的红包");
                tipText = [NSString stringWithFormat:@"%@%@",redpacketReceiverName,tepS];
            } else {
                tipText = [NSString stringWithFormat:@"%@%@%@%@",tepS3,tepS1,redpacketSenderName,tepS2];
            }
        }

    }
    self.tipMessageLabel.text = tipText;
    [self setNeedsLayout];

    [super bubbleViewWithData:message];
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message {
    return 40;
}

@end
