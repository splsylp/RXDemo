//
//  ChatHomeView.m
//  Chat
//
//  Created by mac on 2017/3/19.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ChatHomeView.h"

#define BubbleMaxSizeChat CGSizeMake(280.0f*fitScreenWidth, 100000.0f)

@implementation ChatHomeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (void)getText:(NSString *)text {
    CGSize bubbleSize = [[Common sharedInstance] widthForContent:text withSize:BubbleMaxSizeChat withLableFont:25];
    
    //兼容iphoneX
    if (bubbleSize.height >= self.frame.size.height-20-iPhoneStatusBarHeight) {
        self.chatHomeLabel.hidden = YES;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:scrollView];
        UILabel *scrolllabel = [[UILabel alloc] initWithFrame:CGRectMake(20, iPhoneStatusBarHeight, self.frame.size.width - 40, bubbleSize.height)];
        [scrollView addSubview:scrolllabel];
        scrolllabel.text = text;
        [scrollView setContentSize:CGSizeMake(self.frame.size.width, bubbleSize.height + 20)];
        
        scrolllabel.font = [UIFont systemFontOfSize:25];
        scrolllabel.numberOfLines = 0;
        [scrolllabel sizeToFit];
        
    } else {
        if (bubbleSize.height < 30) {
            //如果只有一行字，则字体居中  其他居左
            self.chatHomeLabel.textAlignment = NSTextAlignmentCenter;
        }
        else {
            self.chatHomeLabel.textAlignment = NSTextAlignmentLeft;
        }
        self.chatHomeLabel.hidden = NO;
        self.chatHomeLabel.text = text;
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeSelfView:)];
    [tap setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tap];
    
}
- (void)removeSelfView:(UITapGestureRecognizer *)tap {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
         [self removeFromSuperview];
    }];
}


@end
