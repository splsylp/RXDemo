//
//  ChatViewImageCell.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/16.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ChatViewCell.h"

@protocol ChatViewImageCellDelegate <NSObject>

//阅后即焚相关
- (void)addReceviceDataWithBurnMessage:(ECMessage *)message;

@end

@interface ChatViewImageCell : ChatViewCell

@property (nonatomic, strong) FLAnimatedImageView *displayImage;
//@property (nonatomic, strong) UIImageView *displayImage;

@property (nonatomic, strong) UIImageView *gifFlagImage;
@property (nonatomic,strong)  UIImageView *maskImageView;//蒙版
@property (nonatomic,strong) UILabel *maskLabel;
extern NSString *const KResponderCustomChatViewImageCellBubbleViewEvent;

@property (nonatomic, weak) id<ChatViewImageCellDelegate> delegate;


@end
