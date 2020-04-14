//
//  ChatGroupVotingCell.h
//  ECSDKDemo_OC
//
//  Created by 王文龙 on 16/7/15.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewCell.h"

@interface ChatGroupVotingCell : ChatViewCell
extern NSString *const KResponderCustomChatGroupVotingCellBubbleViewEvent;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *detailLabel1;
@property (nonatomic, strong) UILabel *detailLabel2;
@end
