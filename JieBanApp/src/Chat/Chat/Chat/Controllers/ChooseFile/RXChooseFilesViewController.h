//
//  RXChooseFilesViewController.h
//  ECSDKDemo_OC
//
//  Created by yuxuanpeng on 16/2/20.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "BaseViewController.h"

@protocol ChooseFileDelegate
@optional
- (void)chooseFile:(NSString *)fileUrl;
@end

@interface RXChooseFilesViewController : BaseViewController
@property(nonatomic,weak)id<ChooseFileDelegate> chooseDelegate;
@property(nonatomic,assign) int type;//0网盘，1本地文件浏览
@end
