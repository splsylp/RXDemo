//
//  YxpidVerificationAlert.h
//  Common
//
//  Created by yuxuanpeng on 2017/7/18.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YxpidVerificationAlertDelegate <NSObject>

- (void) verifyRequestSuccess;

@end

@interface YxpidVerificationAlert : UIView<UITextFieldDelegate>

@property(nonatomic,assign)id<YxpidVerificationAlertDelegate>verifyDelegate;
- (instancetype)initWithAlert:(BOOL)isNavigator withPrompt:(NSString *)prompt;
@end
