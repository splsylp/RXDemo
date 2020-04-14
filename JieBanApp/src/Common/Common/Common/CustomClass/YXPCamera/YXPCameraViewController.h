//
//  YXPCameraViewController.h
//  Common
//
//  Created by yuxuanpeng on 2017/6/27.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "BaseViewController.h"

//selectItem 为NSURL的就是视频 否则就是图片
typedef void(^TakeMoveOperationBlock)(id selectItem);

@interface YXPCameraViewController : BaseViewController

@property(nonatomic,assign)NSInteger recordTime;//录制的时间

@property (nonatomic,strong)NSString *promptTitle;//提示语

@property (copy, nonatomic) TakeMoveOperationBlock takeBlock;


@end
