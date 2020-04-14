//
//  AlertView.h
//  Common
//
//  Created by 韩微 on 2017/8/15.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define labelFont 13


@protocol RemoveAlertViewDelegate;

@interface AlertView : UIView
@property (nonatomic, assign) id<RemoveAlertViewDelegate>removeAlertViewDelegate;

- (void)loadViewIfNeed:(NSString *)cancel;

@property (nonatomic, strong) NSString *dataVersion;
@property (nonatomic, strong) NSString *descriptionStr;

@end

@protocol RemoveAlertViewDelegate <NSObject>

- (void)removeAlertView;
- (void)cancelView;

@end
