//
//  TakeMovieViewController.h
//  ZZYWeiXinShortMovie
//
//  Created by zhangziyi on 16/3/23.
//  Copyright © 2016年 GLaDOS. All rights reserved.
//
#import "Camera.h"
#import <UIKit/UIKit.h>

@class TakeMovieViewController;

@protocol TakeMovieViewControllerDelegate <NSObject>

-(void)onSendUserVideoUrl:(NSURL *)videoURL;
@end

@interface TakeMovieViewController : UIViewController
@property (nonatomic,assign) CGFloat cameraTime;
@property (nonatomic,assign) NSInteger frameNum;

@property (nonatomic, weak) id<TakeMovieViewControllerDelegate> delegate;


@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
