//
//  ChatViewRedpacketCell.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/22.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewRedpacketCell.h"
//#import "RedpacketOpenConst.h"

#define Redpacket_SubMessage_Text languageStringWithKey(@"查看红包")
#define Redpacket_Label_Padding 2

#define REDPACKET_BUNDLE(name) @"RedpacketCellResource.bundle/" name
//#define REDPACKET_BUNDLE(name) [NSString stringWithFormat:@"RedpacketCellResource.bundle/" name

static const CGFloat kXHAvatorPaddingX = 8.0;

@interface ChatViewRedpacketCell ()  {
    BOOL isRed;
    BOOL isTrans;
    BOOL isRedPacketTip;
    
    NSDictionary *dictData;
}
@property(strong, nonatomic) UILabel *greetingLabel;
@property(strong, nonatomic) UILabel *subLabel; // 显示 "查看红包"
@property(strong, nonatomic) UILabel *orgLabel;
@property(strong, nonatomic) UIImageView *iconView;
@property(strong, nonatomic) UILabel *orgTypeLabel;

@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

@end

@implementation ChatViewRedpacketCell

-(instancetype) initWithIsSender:(BOOL)aIsSender reuseIdentifier:(NSString *)reuseIdentifier{
   if (self = [super initWithIsSender:aIsSender reuseIdentifier:reuseIdentifier]){
       
       dictData = [[NSDictionary alloc] init];
       
        [self.bubleimg removeFromSuperview];
   
        self.bubbleView.backgroundColor = self.backgroundColor;
       
       [self.receipteBtn removeFromSuperview];
       
        // 设置背景
        self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,198, 84)];
        self.bubbleBackgroundView.autoresizingMask = UIViewAutoresizingNone;
        [self.bubbleView addSubview:self.bubbleBackgroundView];

        [self prepareRedpacketUI];

        if (self.isSender) {
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-198, self.portraitImg.frame.origin.y, 198, 84.0);
            UIImage *image = ThemeImage(REDPACKET_BUNDLE(@"redpacket_sender_bg"));
            self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 15, 20)];
            
        } else {
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 198, 84.0f);
            UIImage *image = ThemeImage(REDPACKET_BUNDLE(@"redpacket_receiver_bg"));
            self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 15, 20)];
            
        }
    }
      return self;
}

- (void)prepareRedpacketUI {
    
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.bubbleBackgroundView addGestureRecognizer:tap];

    // 设置红包图标
    UIImage *icon = ThemeImage(REDPACKET_BUNDLE(@"redPacket_redPacktIcon"));

    self.iconView = [[UIImageView alloc] initWithImage:icon];
    self.iconView.frame = CGRectMake(13, 19, 26, 34);
    [self.bubbleBackgroundView addSubview:self.iconView];
    
    // 设置红包文字
    self.greetingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.greetingLabel.frame = CGRectMake(48, 19, 137, 15);
    self.greetingLabel.font = ThemeFontMiddle;
    self.greetingLabel.textColor = [UIColor whiteColor];
    self.greetingLabel.numberOfLines = 0;
    [self.greetingLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.greetingLabel setTextAlignment:NSTextAlignmentLeft];
    [self.bubbleBackgroundView addSubview:self.greetingLabel];
    
    // 设置次级文字
    self.subLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    CGRect frame = self.greetingLabel.frame;
    frame.origin.y = 41;
    self.subLabel.frame = frame;
    self.subLabel.text = Redpacket_SubMessage_Text;
    self.subLabel.font =ThemeFontSmall;
    self.subLabel.numberOfLines = 1;
    self.subLabel.textColor = [UIColor whiteColor];
    self.subLabel.numberOfLines = 1;
    [self.subLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.subLabel setTextAlignment:NSTextAlignmentLeft];
    [self.bubbleBackgroundView addSubview:self.subLabel];
    
    // 设置次级文字
    self.orgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    frame = CGRectMake(13, 66, 150, 12);
    self.orgLabel.frame = frame;
    self.orgLabel.text = Redpacket_SubMessage_Text;
    self.orgLabel.font =ThemeFontSmall;
    self.orgLabel.numberOfLines = 1;
    self.orgLabel.textColor = [UIColor lightGrayColor];
    self.orgLabel.numberOfLines = 1;
    [self.orgLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.orgLabel setTextAlignment:NSTextAlignmentLeft];
    [self.bubbleBackgroundView addSubview:self.orgLabel];
    
    // 设置红包类型
    self.orgTypeLabel = [[UILabel alloc] init];
    self.orgTypeLabel.textColor = [self hexColor:0xD83C1E];
    self.orgTypeLabel.font =ThemeFontSmall;
    [self.bubbleBackgroundView addSubview:self.orgTypeLabel];
    
    
    CGRect rt = self.orgTypeLabel.frame;
    rt.origin = CGPointMake(145, 66);
    if (self.isSender) {
        rt.origin = CGPointMake(141, 66);
    }
    rt.size = CGSizeMake(51, 12);
    self.orgTypeLabel.frame = rt;
}

- (UIColor *)hexColor:(uint)color
{
    float r = (color&0xFF0000) >> 16;
    float g = (color&0xFF00) >> 8;
    float b = (color&0xFF);
    
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;

    CGFloat bubbleX = 0.0f;
    if (self.isSender) {
        bubbleX = CGRectGetMinX(self.portraitImg.frame) - 198 - kXHAvatorPaddingX;
    } else {
        bubbleX = CGRectGetMaxX(self.portraitImg.frame) + kXHAvatorPaddingX;
    }
    CGFloat bubbleViewY = CGRectGetMinY(self.portraitImg.frame);
    CGRect frame = CGRectMake(bubbleX, bubbleViewY,198.0F,84.0f);
    self.bubbleView.frame = frame;

    ECTextMessageBody *body = (ECTextMessageBody *)message.messageBody;
    if (body.text == nil) {
        body.text = @"";
    }
    NSData *data = [message.userData dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 1) {
        return ;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    dictData = [NSDictionary dictionaryWithDictionary:dict];

    BOOL isRedpacket = [[Chat sharedInstance].componentDelegate isRedpacketWithData:message.userData];
    BOOL isTranser = [[Chat sharedInstance].componentDelegate isTransferWithData:message.userData];
    BOOL isRedTip = [[Chat sharedInstance].componentDelegate isRedpacketOpenMessageWithData:message.userData];
    isRed = isRedpacket;
    isTrans = isTranser;
    isRedPacketTip = isRedTip;

    if (isRedpacket == YES) {
        if (isRedTip == YES) {
            //zmf add
            NSString *preStr;
            if (IsHengFengTarget != 1) {

                preStr = languageStringWithKey(@"[容联云红包]");
                self.orgLabel.text = languageStringWithKey(@"容联云红包");//orgString;
            } else {
                preStr = languageStringWithKey(@"[恒信红包]");
                self.orgLabel.text = languageStringWithKey(@"恒信红包");//orgString;
            }
            if ([body.text containsString:preStr]) {
                body.text =[body.text substringFromIndex:preStr.length];
            }
            self.greetingLabel.text = body.text;

        } else {
            NSString *preStr;
            if (IsHengFengTarget != 1) {

                preStr = languageStringWithKey(@"[容联云红包]");
                self.orgLabel.text = languageStringWithKey(@"容联云红包");//orgString;
            } else {
                preStr = languageStringWithKey(@"[恒信红包]");
                self.orgLabel.text = languageStringWithKey(@"恒信红包");//orgString;
            }
            if ([body.text containsString:preStr]) {
                body.text =[body.text substringFromIndex:preStr.length];
            }
            self.greetingLabel.text = body.text;

            //zmf end
        }
    } else if (isTranser == YES) {

    }
    if ([[dict valueForKey:@"money_type_special"] isEqualToString:@"member"]) {
        self.orgTypeLabel.text = languageStringWithKey(@"专属红包");
    }else
    {
        self.orgTypeLabel.text = @"";
    }
    if (!self.isSender) {

        UIImage *image;
        if (isTranser == YES) {
            //收到转账
            //     NSDictionary *receiverPerson = [[Chat sharedInstance].componentDelegate getDicWithId:dict[@"money_sender_id"] withType:0];
            self.greetingLabel.text = [NSString stringWithFormat:languageStringWithKey(@"收到对方转账")/*, receiverPerson[@"member_name"]*/];
            self.orgLabel.text = languageStringWithKey(@"[转账]");
            image = ThemeImage(REDPACKET_BUNDLE(@"redpacket_receiver_bg"));
        }
        else {
            image = ThemeImage(REDPACKET_BUNDLE(@"redpacket_receiver_bg"));
        }
        self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 15, 20)];

    } else {

        UIImage *image;
        if (isTranser == YES) {

            //        NSDictionary *receiverPerson = [[Chat sharedInstance].componentDelegate getDicWithId:dict[@"money_receiver_id"] withType:0];
            self.greetingLabel.text = languageStringWithKey(@"对方已收到转账");/*, receiverPerson[@"member_name"]*/
            image = ThemeImage(REDPACKET_BUNDLE(@"redpacket_sender_bg"));
            self.orgLabel.text = languageStringWithKey(@"[转账]");
        }
        else {
            image = ThemeImage(REDPACKET_BUNDLE(@"redpacket_sender_bg"));

        }
        self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 15, 20)];

    }
    if (isTranser == YES) {
        UIImage *icon = ThemeImage(REDPACKET_BUNDLE(@"redPacket_transferIcon"));
        self.iconView.frame = CGRectMake(13, 19, 32, 32);
        [self.iconView setImage:icon];
        NSString *tepStr = languageStringWithKey(@"元");
        self.subLabel.text = [NSString stringWithFormat:@"%@%@", dict[@"money_transfer_amount"],tepStr];
    }
    [self setNeedsLayout];
    [super bubbleViewWithData:message];
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message {
    return 110.0f;
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(redpacketCell:didTap:)]) {
            [self.delegate redpacketCell:self didTap:self.displayMessage];
        }
    }
}

- (NSDictionary *)getShareCard:(NSString *)message
{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 1) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    return dict;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (self.selectionStyle != UITableViewCellSelectionStyleNone) {
        
    }
    else {
        [super setSelected:selected animated:animated];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    //    [super setHighlighted:highlighted animated:animated];
    
    if (self.selectionStyle != UITableViewCellSelectionStyleNone) {
        if (highlighted) {
//            self.card.backgroundColor = [UIColor cardHighlightBackground];
            self.iconView.image = ThemeImage(REDPACKET_BUNDLE(@"redPacket_redPacktIconSelect"));
            if (self.isSender) {
                self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-198, self.portraitImg.frame.origin.y, 198, 84.0);
                UIImage *image = ThemeImage(REDPACKET_BUNDLE(@"redpacket_sender_bg_Select"));
                self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 15, 20)];
                
                UIImage *imagee;
                if (isTrans == YES) {
                    
                    //    NSDictionary *receiverPerson = [[Chat sharedInstance].componentDelegate getDicWithId:dictData[@"money_receiver_id"] withType:0];
                    self.greetingLabel.text = [NSString stringWithFormat:languageStringWithKey(@"对方已收到转账")/*, receiverPerson[@"member_name"]*/];
                    imagee = ThemeImage(REDPACKET_BUNDLE(@"redpacket_sender_bg_Select"));
                    self.orgLabel.text = languageStringWithKey(@"[转账]");
                }
                else {
                    imagee = ThemeImage(REDPACKET_BUNDLE(@"redpacket_sender_bg_Select"));
                    
                }
                self.bubbleBackgroundView.image = [imagee resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 15, 20)];
                
            } else {
                self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 198, 84.0f);
                UIImage *image = ThemeImage(REDPACKET_BUNDLE(@"redpacket_receiver_bg_Select"));
                self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 15, 20)];
                
                UIImage *imagee;
                if (isTrans == YES) {
                    //收到转账
                    //        NSDictionary *receiverPerson = [[Chat sharedInstance].componentDelegate getDicWithId:dictData[@"money_sender_id"] withType:0];
                    self.greetingLabel.text = [NSString stringWithFormat:languageStringWithKey(@"收到对方转账")/*, receiverPerson[@"member_name"]*/];
                    self.orgLabel.text = languageStringWithKey(@"[转账]");
                    imagee = ThemeImage(REDPACKET_BUNDLE(@"redpacket_receiver_bg_Select"));
                }
                else {
                    imagee = ThemeImage(REDPACKET_BUNDLE(@"redpacket_receiver_bg_Select"));
                }

                
            }
            
            if (isTrans == YES) {
                UIImage *icon = ThemeImage(REDPACKET_BUNDLE(@"redPacket_transferIconSelect"));
                self.iconView.frame = CGRectMake(13, 19, 32, 32);
                [self.iconView setImage:icon];
                NSString *tepStr = languageStringWithKey(@"元");
                self.subLabel.text = [NSString stringWithFormat:@"%@%@", dictData[@"money_transfer_amount"],tepStr];
            }
            
        }
        else {
            self.iconView.image = ThemeImage(REDPACKET_BUNDLE(@"redPacket_redPacktIcon"));

            if (self.isSender) {
                self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-198, self.portraitImg.frame.origin.y, 198, 84.0);
                UIImage *image = ThemeImage(REDPACKET_BUNDLE(@"redpacket_sender_bg"));
                self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 15, 20)];
                
                UIImage *imagee;
                if (isTrans == YES) {
                    
                //    NSDictionary *receiverPerson = [[Chat sharedInstance].componentDelegate getDicWithId:dictData[@"money_receiver_id"] withType:0];
                    self.greetingLabel.text = languageStringWithKey(@"对方已收到转账");/*, receiverPerson[@"member_name"]*/
                    imagee = ThemeImage(REDPACKET_BUNDLE(@"redpacket_sender_bg"));
                    self.orgLabel.text = languageStringWithKey(@"[转账]");
                }
                else {
                    imagee = ThemeImage(REDPACKET_BUNDLE(@"redpacket_sender_bg"));
                    
                }
                self.bubbleBackgroundView.image = [imagee resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 15, 20)];

                
                
            } else {
                self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 198, 84.0f);
                UIImage *image = ThemeImage(REDPACKET_BUNDLE(@"redpacket_receiver_bg"));
                self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 15, 20)];
                
                UIImage *imagee;
                if (isTrans == YES) {
                    //收到转账
            //        NSDictionary *receiverPerson = [[Chat sharedInstance].componentDelegate getDicWithId:dictData[@"money_sender_id"] withType:0];
                    self.greetingLabel.text =languageStringWithKey(@"收到对方转账");/*, receiverPerson[@"member_name"]*/
                    self.orgLabel.text = languageStringWithKey(@"[转账]");
                    imagee = ThemeImage(REDPACKET_BUNDLE(@"redpacket_receiver_bg"));
                }
                else {
                    imagee = ThemeImage(REDPACKET_BUNDLE(@"redpacket_receiver_bg"));
                }
                self.bubbleBackgroundView.image = [imagee resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 15, 20)];
                
            }
            
            if (isTrans == YES) {
                UIImage *icon = ThemeImage(REDPACKET_BUNDLE(@"redPacket_transferIcon"));
                self.iconView.frame = CGRectMake(13, 19, 32, 32);
                [self.iconView setImage:icon];
                NSString *tempStr =languageStringWithKey(@"元");
                self.subLabel.text = [NSString stringWithFormat:@"%@%@", dictData[@"money_transfer_amount"],tempStr];
            }

            
            
        }
    }
    else {
        [super setHighlighted:highlighted animated:animated];
    }
}


@end
