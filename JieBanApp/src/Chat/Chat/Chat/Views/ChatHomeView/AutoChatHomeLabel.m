//
//  AutoChatHomeLabel.m
//  Chat
//
//  Created by mac on 2017/3/19.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "AutoChatHomeLabel.h"

@implementation AutoChatHomeLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    // If this is a multiline label, need to make sure
    // preferredMaxLayoutWidth always matches the frame width
    // (i.e. orientation change can mess this up)
    
    if (/*self.numberOfLines == 0 && */bounds.size.width != self.preferredMaxLayoutWidth) {
        self.preferredMaxLayoutWidth = self.bounds.size.width;
        [self setNeedsUpdateConstraints];
    }
}
@end
