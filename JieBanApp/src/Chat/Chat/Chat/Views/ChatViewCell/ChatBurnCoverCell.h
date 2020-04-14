//
//  ChatBurnCoverCell.h
//  ECSDKDemo_OC
//
//  Created by 王文龙 on 16/7/11.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewCell.h"

extern NSString *const KResponderCustomChatViewBurnTextCellBubbleViewEvent;
@interface ChatBurnCoverCell : ChatViewCell
@property (nonatomic, strong) UIButton *showButton;

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)messageBody;

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier;
@end
