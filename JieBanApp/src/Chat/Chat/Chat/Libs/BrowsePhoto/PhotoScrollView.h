//
//  PhotoScrollView.h
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/10/19.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoScrollView : UIScrollView<UIScrollViewDelegate,UIActionSheetDelegate>
@property(nonatomic,copy)NSString *imagePath;
@property (nonatomic,copy)NSString *remotePath;
@end
