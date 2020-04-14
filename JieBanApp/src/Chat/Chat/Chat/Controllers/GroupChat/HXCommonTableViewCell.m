//
//  HXCommonTableViewCell.m
//  Chat
//
//  Created by apple on 2019/11/14.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "HXCommonTableViewCell.h"

@implementation HXCommonTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.font = ThemeFontLarge;
    self.contentLabel.font = ThemeFontMiddle;
}

@end
