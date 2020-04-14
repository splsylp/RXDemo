//
//  ChatViewCardCell.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 16/7/27.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewCell.h"
extern NSString *const KResponderCustomChatViewCardCellBubbleViewEvent;

@interface ChatViewCardCell : ChatViewCell

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImageView *photoImg;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *phoneLab;
@property (nonatomic, strong) UILabel *publicNameLab;

@end
