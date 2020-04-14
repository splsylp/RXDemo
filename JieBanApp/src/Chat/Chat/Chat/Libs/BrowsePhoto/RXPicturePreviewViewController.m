//
//  RXPicturePreviewViewController.m
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/7/7.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "RXPicturePreviewViewController.h"
#import "PhotoCollectionView.h"
#import "PhotoCollectionViewCell.h"
static NSString *identify=@"PhotoCell";

@interface RXPicturePreviewViewController ()
@property(retain,nonatomic)PhotoCollectionView *collectionView;
@property(copy,nonatomic)UILabel *curIndexLabel;
@end

@implementation RXPicturePreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
    
    //为当前UICollectionView对象创建布局对象
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    //设置滑动方向:UICollectionViewScrollDirectionHorizontal水平方向
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight);
    flowLayout.minimumLineSpacing = 0;
    
    _collectionView =[[PhotoCollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:flowLayout];
    [self.view addSubview:_collectionView];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    
    [_collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:identify];
    //将数据传给UICollectionView对象
    //_collectionView.imagePathArray=self.imagePathArray;
    
    
    //滚动到指定的单元格
    if (_indexRow) {
         [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_indexRow inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
 
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backView) name:@"photoBrowseBackView" object:nil];
    _curIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-100*fitScreenWidth)/2, kScreenHeight-20*fitScreenWidth-20, 100*fitScreenWidth, 21)];
    _curIndexLabel.textColor = [UIColor whiteColor];
    _curIndexLabel.text = [NSString stringWithFormat:@"%d/%ld",_indexRow+1,(unsigned long)[self.imagePathArray count]];
    _curIndexLabel.textAlignment = NSTextAlignmentCenter;
    _curIndexLabel.font = ThemeFontLarge;
    _curIndexLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_curIndexLabel];
}

#pragma mark -UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagePathArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    cell.imagePath = self.imagePathArray[indexPath.row];
    cell.remotePath = self.remotePath;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}

//当单元格从视图上移除后调用的协议方法
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *pCell = (PhotoCollectionViewCell *)cell;
    //缩回原来的比例
    [pCell.scrolView setZoomScale:1 animated:NO];
    
   // DDLogInfo(@"indexPath-------%d",indexPath.row);
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (iOS7) {
        [self setNeedsStatusBarAppearanceUpdate];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    self.indexRow = 0;
    [self.imagePathArray removeAllObjects];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //进来隐藏导航栏
    if (iOS7) {
        [self setNeedsStatusBarAppearanceUpdate];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
//
- (BOOL)prefersStatusBarHidden//for iOS7.0
{
    return YES;
}

- (void)backView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  //手指将要离开屏幕时调用
 *
 *  @param scrollView          scrollView滑动对象
 *  @param velocity            手指离开屏幕时scrollView的滑动速度
 *  @param targetContentOffset  scrollView停止后的偏移量
 */
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    int index = (targetContentOffset->x + (kScreenWidth)/2)/(kScreenWidth);
    //设置停止后的偏移量
    targetContentOffset->x = index*(kScreenWidth);
    DDLogInfo(@"indexPath-------%d",index);
    _curIndexLabel.text=[NSString stringWithFormat:@"%d/%d",index+1,(int)self.imagePathArray.count];
    
}

@end
