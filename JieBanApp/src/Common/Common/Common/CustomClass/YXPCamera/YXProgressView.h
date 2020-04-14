//
//  YXProgressView.h
//  Common
//
//  Created by yuxuanpeng on 2017/6/27.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXProgressView : UIView

//最大时间
@property (assign, nonatomic) NSInteger timeMax;

//清除
- (void)clearProgress;

@end
