//
//  RXChatMemberView.h
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/10/27.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RXChatMemberView;

@protocol RXChatMemberViewDelegate <NSObject>

- (void)RXChatMemberView:(RXChatMemberView*)memberView index:(NSInteger)index;

@end
@interface RXChatMemberView : UIView
@property (weak,nonatomic) id<RXChatMemberViewDelegate>delegate;
@property(nonatomic,strong)UIImageView *headerIconView;
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UIButton *deleteBtn;

@end
