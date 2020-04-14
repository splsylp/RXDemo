//
//  ChatHomeView.h
//  Chat
//
//  Created by mac on 2017/3/19.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoChatHomeLabel.h"

@interface ChatHomeView : UIView

- (void)getText:(NSString *)text;

@property (weak, nonatomic) IBOutlet AutoChatHomeLabel *chatHomeLabel;

@end
