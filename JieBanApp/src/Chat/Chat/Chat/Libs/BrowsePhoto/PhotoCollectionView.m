//
//  PhotoCollectionView.m
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/10/19.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "PhotoCollectionView.h"
#import "PhotoCollectionViewCell.h"
static NSString *identify=@"PhotoCell";
@implementation PhotoCollectionView

//- (id)initWithFrame:(CGRect)frame
//{
//    //为当前UICollectionView对象创建布局对象
//    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    //设置滑动方向:UICollectionViewScrollDirectionHorizontal水平方向
//    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    flowLayout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight);
//    flowLayout.minimumLineSpacing = 0;
//    
//    //调用父类的初始化方法
//    self = [super initWithFrame:frame collectionViewLayout:flowLayout];
//    if (self) {
//        // Initialization code
//        self.delegate = self;
//        self.dataSource = self;
//        self.pagingEnabled = YES;
//       
//        [self registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:identify];
//        
//    }
//    return self;
//}


@end
