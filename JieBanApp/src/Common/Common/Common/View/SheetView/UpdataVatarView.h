//
//  UpdataVatarView.h
//  Common
//
//  Created by 韩微 on 2017/8/18.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@protocol AlertViewAvatarDelegate;


@interface UpdataVatarView : UIView

@property (nonatomic, assign) id<AlertViewAvatarDelegate>alertViewAvatarDelegate;

- (void)loadViewIfNeed;


@end
@protocol AlertViewAvatarDelegate <NSObject>

- (void)removeAvatarView;
- (void)confimAlertView;

@end
