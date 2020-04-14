//
//  ChatWebUrlCell.h
//  Chat
//
//  Created by 胡伟 on 2019/8/9.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "ChatViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatWebUrlCell : ChatViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) FLAnimatedImageView *imgView;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *urlLabel;
@end

NS_ASSUME_NONNULL_END
