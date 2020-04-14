//
//  PhotoCollectionViewCell.h
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/10/19.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoScrollView.h"
@interface PhotoCollectionViewCell : UICollectionViewCell
@property(nonatomic,copy)NSString *imagePath;
@property (nonatomic,copy)NSString *remotePath;
@property (nonatomic, retain)PhotoScrollView *scrolView;
@end
