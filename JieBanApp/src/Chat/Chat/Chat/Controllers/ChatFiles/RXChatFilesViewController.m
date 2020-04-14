//
//  RXChatFilesViewController.m
//  Chat
//
//  Created by 高源 on 2019/5/5.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "RXChatFilesViewController.h"
#import "RXChatFileListController.h"
#import "RXChatMediaListController.h"

@interface RXChatFilesViewController()

@end

@implementation RXChatFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"聊天文件";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpAllViewController];
    // Do any additional setup after loading the view.
}

// 添加所有子控制器
- (void)setUpAllViewController {
    
    [self setUpContentViewFrame:^(UIView *contentView) {
        contentView.frame = CGRectMake(0, kTotalBarHeight, kScreenWidth, kScreenHeight- kTotalBarHeight);
    }];
    
    // *推荐方式(设置标题渐变)
    [self setUpTitleGradient:^(BOOL *isShowTitleGradient, RXTitleColorGradientStyle *titleColorGradientStyle, CGFloat *startR, CGFloat *startG, CGFloat *startB, CGFloat *endR, CGFloat *endG, CGFloat *endB) {
        
        *startR = 153/255.0;
        *startG = 153/255.0;
        *startB = 153/255.0;
        // 不需要设置的属性，可以不管
        *isShowTitleGradient = YES;
        
        // 设置结束时，RGB通道各个值
        *endR = 34/255.0;
        *endG = 34/255.0;
        *endB = 34/255.0;
    }];
    
    self.underLineColor = ThemeColor;
    self.isShowUnderLine = YES;
    self.contentCanScroll = NO;
    
    RXChatFileListController *fileVC = [[RXChatFileListController alloc] init];
    fileVC.title = languageStringWithKey(@"文件");
    fileVC.sessionId = self.sessionId;
    [self addChildViewController:fileVC];
    
    RXChatMediaListController *mediaVC = [[RXChatMediaListController alloc] init];
    mediaVC.title = languageStringWithKey(@"图片视频");
    mediaVC.sessionId = self.sessionId;
    [self addChildViewController:mediaVC];
    
}


@end
