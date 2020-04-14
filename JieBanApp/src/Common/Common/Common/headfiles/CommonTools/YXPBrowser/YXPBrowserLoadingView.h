//
//  YXPBrowserLoadingView.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/4/18.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXPBrowserLoadingView : UIView

- (void)startAnimation;
- (void)stopAnimation;
@property (nonatomic,assign)CGFloat angle;
@end
