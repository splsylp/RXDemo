//
//  YXPPlayer.h
//  Common
//
//  Created by yuxuanpeng on 2017/6/27.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXPPlayer : UIView

/**
 * frame 坐标
 * bgView 背景view
 * videoUrl 视频url
 */

- (instancetype)initWithFrame:(CGRect)frame withShowInView:(UIView *)bgView url:(NSURL *)videoUrl;

@property (copy, nonatomic) NSURL *videoUrl;//视频的地址

- (void)stopPlayer;
- (void)removeAvPlayerNtf;
@end
