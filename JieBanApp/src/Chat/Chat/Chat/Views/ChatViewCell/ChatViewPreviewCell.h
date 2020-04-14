//
//  ChatViewPreviewCell.h
//  ECSDKDemo_OC
//
//  Created by admin on 16/3/22.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewCell.h"

@interface ChatViewPreviewCell : ChatViewCell
extern NSString *const KResponderCustomChatViewPreviewCellBubbleViewEvent;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *urlLabel;

@end
