//
//  RXPicturePreviewViewController.h
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/7/7.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "BaseViewController.h"

@interface RXPicturePreviewViewController : BaseViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
@property (retain,nonatomic)NSString *imagePath;
@property (copy,nonatomic)NSString *remotePath;
@property (retain,nonatomic)NSMutableArray *imagePathArray;
@property (nonatomic,assign)NSInteger indexRow;

@end
