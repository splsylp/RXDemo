//
//  ChatViewBigEmojiCell.m
//  ECSDKDemo_OC
//
//  Created by 王文龙 on 16/6/22.
//  Copyright © 2016年 ronglian. All rights reserved.
//
//表情云
#import "ChatViewBigEmojiCell.h"
#pragma mark - zmf 表情云相关 先屏蔽
//#import <BQMM/BQMM.h>

//获取控制器  做跳转用
#import "UIView+CurrentController.h"
#import "ChatViewController.h"

#define BubbleMaxSize CGSizeMake(180.0f*fitScreenWidth, 1000.0f)
NSString *const KResponderCustomChatViewBigEmojiCellBubbleViewEvent = @"KResponderCustomChatViewBigEmojiCellBubbleViewEvent";

@implementation ChatViewBigEmojiCell
-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        _displayImage = [[UIImageView alloc] init];
        _displayImage.contentMode = UIViewContentModeScaleAspectFill;
        _displayImage.clipsToBounds = YES;
        
        _displayImage.layer.cornerRadius =_displayImage.frame.size.width/2;
        _displayImage.layer.masksToBounds=YES;
        
        
        if (self.isSender) {
            
            _displayImage.frame = CGRectMake(5, 5, 110.0f, 120.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-140.0f, self.portraitImg.frame.origin.y, 130.0f, 130.0f);
            
        } else {
            
            _displayImage.frame = CGRectMake(15, 5, 110.0f, 120.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 130.0f, 130.0f);
        }
        
        [self.bubbleView addSubview:_displayImage];
        self.bubleimg.image = nil;
    }
    return self;
}

-(void)bubbleViewTapGesture:(UITapGestureRecognizer *)tap{
    
    [self dispatchCustomEventWithName:KResponderCustomChatViewBigEmojiCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:tap];
    
#pragma mark - zmf 表情云相关 先屏蔽
//    NSString* str = nil;
//    NSRange ran = [self.displayMessage.userData rangeOfString:@"UserData="];
//    if (ran.location == NSNotFound) {
//        str = self.displayMessage.userData;
//    }else{
//        NSInteger index = ran.location + ran.length;
//        str = [self.displayMessage.userData substringFromIndex:index];
//    }
//    NSDictionary* userData =[str coverDictionary];
//    if ([userData hasValueForKey:@"SmileyEmoji"]) {
//        NSString *emojiCodeStr = [userData valueForKey:@"SmileyEmoji"];
//        UIViewController *emojiController = [[MMEmotionCentre defaultCentre] controllerForEmotionCode:emojiCodeStr];//表情云
//        ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
//        [chatVC.navigationController pushViewController:emojiController animated:YES];
//    }
    
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    
    return 150.0f*fitScreenWidth;
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;
    self.displayImage.image = ThemeImage(@"mm_emoji_loading");
#pragma mark - zmf 表情云相关 先屏蔽
//    ECMessage *message = self.displayMessage;
//    
//    NSString* str = nil;
//    NSRange ran = [message.userData rangeOfString:@"UserData="];
//    if (ran.location == NSNotFound) {
//        str = message.userData;
//    }else{
//        NSInteger index = ran.location + ran.length;
//        str = [message.userData substringFromIndex:index];
//    }
//    //表情云
//    NSDictionary* userData =[str coverDictionary];
//    if ([userData hasValueForKey:@"SmileyEmoji"]) {
//        NSString *emojiCodeStr = [userData valueForKey:@"SmileyEmoji"];
//        __weak typeof(self) weakself = self;
//        [[MMEmotionCentre defaultCentre] fetchEmojisByType:MMFetchTypeBig codes:@[emojiCodeStr] completionHandler:^(NSArray *emojis) {
//            if (emojis.count > 0) {
//                MMEmoji *emoji = emojis[0];
//                if ([emojiCodeStr isEqualToString:emoji.emojiCode]) {
//                    weakself.displayImage.image = emoji.emojiImage;
//                }
//            }
//            else {
//                weakself.displayImage.image = ThemeImage(@"mm_emoji_error");
//            }
//        }];
//    }
    [super bubbleViewWithData:message];
}

@end
