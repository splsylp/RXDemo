//
//  MSSBrowseViewController.m
//  MSSBrowse
//
//  Created by yuxuanpeng on 15/12/23.
//  Copyright © 2015年 yuxuanpeng. All rights reserved.
//

#import "MSSBrowseViewController.h"
#import "MSSBrowseCollectionViewCell.h"
#import "RXThirdPart.h"
#import "UIImage+MSSScale.h"
#import "MSSBrowseDefine.h"
#import "MSSBrowseRemindView.h"
#import "YXPExtension.h"
#import "RestApi.h"
#import "RXCollectData.h"
#import "UIImage+deal.h"

#ifndef YY_CLAMP // return the clamped value
#define YY_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

@interface MSSBrowseViewController ()

@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)NSArray *browseItemArray;
@property (nonatomic,assign)BOOL isFirstOpen;
@property (nonatomic,assign)BOOL haveUpdate;//是否有更新 表示加载图片成功
@property (nonatomic,assign)NSInteger currentIndex;
@property (nonatomic,assign)BOOL isRotate;// 判断是否正在切换横竖屏
@property (nonatomic,strong)UILabel *countLabel;// 当前图片位置
@property (nonatomic,assign)CGFloat screenWidth;
@property (nonatomic,assign)CGFloat screenHeight;
@property (nonatomic,strong)UIView *snapshotView;
@property (nonatomic,strong)NSMutableArray *verticalBigRectArray;//home健在上
@property (nonatomic,strong)NSMutableArray *horizontalBigRectArray;
@property (nonatomic,strong)UIView *bgView;
@property (nonatomic,assign)UIDeviceOrientation currentOrientation;
@property (nonatomic,strong)MSSBrowseRemindView *browseRemindView;

@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, assign) CGPoint panGestureBeginPoint;
@property (nonatomic, assign) BOOL isPressed;
/** UIImageView */
@property(nonatomic,strong)UIImageView *snapshotImgView;

@property (nonatomic, assign) BOOL isEndScroll;
@end

@implementation MSSBrowseViewController

- (instancetype)initWithBrowseItemArray:(NSArray *)browseItemArray currentIndex:(NSInteger)currentIndex
{
    self = [super init];
    if(self)
    {
        _browseItemArray = browseItemArray;
        _currentIndex = currentIndex;
    }
    return self;
}

- (void)showBrowseViewController {
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    } else {
        _snapshotView = [rootViewController.view snapshotViewAfterScreenUpdates:NO];
    }
    [rootViewController presentViewController:self animated:NO completion:^{
        if (iOS13) {
            if (@available(iOS 13.0, *)) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent animated:NO];
            } else {
                // Fallback on earlier versions
            }
        }else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        }
    }];
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//- (void)viewWillAppear:(BOOL)animated{
//
//    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//
//    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self initData];
    [self createBrowseView];
    [self createGesture];
}

- (void)createGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];
    _pan = pan;
}

- (void)initData
{
    _isFirstOpen = YES;
    _screenWidth = MSS_SCREEN_WIDTH;
    _screenHeight = MSS_SCREEN_HEIGHT;
    _currentOrientation = UIDeviceOrientationPortrait;
    _verticalBigRectArray = [[NSMutableArray alloc]init];
    _horizontalBigRectArray = [[NSMutableArray alloc]init];
    for (MSSBrowseModel *browseItem in _browseItemArray)
    {
        CGRect verticalRect = [browseItem.smallImageView.image mss_getBigImageRectSizeWithScreenWidth:MSS_SCREEN_WIDTH ScreenHeight:MSS_SCREEN_HEIGHT];
        NSValue *verticalValue = [NSValue valueWithCGRect:verticalRect];
        [_verticalBigRectArray addObject:verticalValue];
        
        CGRect horizontalRect = [browseItem.smallImageView.image mss_getBigImageRectSizeWithScreenWidth:MSS_SCREEN_HEIGHT ScreenHeight:MSS_SCREEN_WIDTH];
        NSValue *horizontalValue = [NSValue valueWithCGRect:horizontalRect];
        [_horizontalBigRectArray addObject:horizontalValue];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(burnPicturnDeleteClick:) name:@"burnModeDeleteMsg" object:nil];
    
}

- (void)burnPicturnDeleteClick:(NSNotification *)noti{
    ECMessage * message = (ECMessage *)noti.object;
    if (message.messageBody.messageBodyType == MessageBodyType_Image) {
        //            ECImageMessageBody * imageBody = (ECImageMessageBody *)message.messageBody;
        for (int i = 0;i< _browseItemArray.count;i++) {
            MSSBrowseModel *model = [_browseItemArray objectAtIndex:i];
            if([model.messageId isEqualToString:message.messageId]){
                NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
                MSSBrowseCollectionViewCell *cell = (MSSBrowseCollectionViewCell *) [_collectionView cellForItemAtIndexPath:path];
                if(cell){
                    [self tap:cell];
                }
            }
        }
    }
}


// 获取指定视图在window中的位置
- (CGRect)getFrameInWindow:(UIView *)view
{
    // 改用[UIApplication sharedApplication].keyWindow.rootViewController.view，防止present新viewController坐标转换不准问题
    return [view.superview convertRect:view.frame toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
}

- (void)createBrowseView
{
    if(_snapshotView)
    {
        _snapshotView.hidden = YES;
        [self.view addSubview:_snapshotView];
    }
    
    _bgView = [[UIView alloc]initWithFrame:self.view.bounds];
//    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bgView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;
    // 布局方式改为从上至下，默认从左到右
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    // Section Inset就是某个section中cell的边界范围
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // 每行内部cell item的间距
    flowLayout.minimumInteritemSpacing = 0;
    // 每行的间距
    flowLayout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, _screenWidth + kBrowseSpace, _screenHeight) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    MSSBrowseModel *browseItem = [_browseItemArray objectAtIndex:_currentIndex];
    if (browseItem.isBurnMessage) {
        _collectionView.scrollEnabled = NO;
    } else {
        _collectionView.scrollEnabled = YES;
    }
    _collectionView.bounces = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
//    _collectionView.backgroundColor = [UIColor blackColor];
    [_collectionView registerClass:[MSSBrowseCollectionViewCell class] forCellWithReuseIdentifier:@"MSSBrowserCell"];
    _collectionView.contentOffset = CGPointMake(_currentIndex * (_screenWidth + kBrowseSpace), 0);
    [_bgView addSubview:_collectionView];
    
    _countLabel = [[UILabel alloc]init];
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.frame = CGRectMake(0, _screenHeight - 50, _screenWidth, 50);
    _countLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)_currentIndex + 1,(long)_browseItemArray.count];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    [_bgView addSubview:_countLabel];
    
    _browseRemindView = [[MSSBrowseRemindView alloc]initWithFrame:_bgView.bounds];
    [_bgView addSubview:_browseRemindView];
}


#pragma mark UIColectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSSBrowseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MSSBrowserCell" forIndexPath:indexPath];
    if(cell){
        
        MSSBrowseModel *browseItem = [_browseItemArray objectAtIndex:indexPath.row];
        
        // 还原初始缩放比例
        cell.zoomScrollView.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
        cell.zoomScrollView.zoomScale = 1.0f;
        cell.zoomScrollView.contentSize = CGSizeMake(_screenWidth, _screenHeight);
        cell.browseItem = browseItem;
        if (_isLoadLoc) {//加载本地
            UIImage *image = [UIImage imageWithContentsOfFile:browseItem.locImgUrl];
            if (!image) {//有点图片 imageWithContentsOfFile 获取不到
                image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:browseItem.bigImageUrl];
                [cell.zoomScrollView.zoomImageView sd_setImageWithURL:[NSURL URLWithString:browseItem.bigImageUrl] placeholderImage:ThemeImage(@"chat_placeholder_image")];
            }else {
                [cell.zoomScrollView.zoomImageView sd_setImageWithURL:[NSURL fileURLWithPath:browseItem.locImgUrl] placeholderImage:ThemeImage(@"chat_placeholder_image")];
            }
            
            cell.zoomScrollView.zoomImageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.zoomScrollView.zoomImageView.clipsToBounds = browseItem.smallImageView.clipsToBounds;
            cell.zoomScrollView.zoomImageView.frame = [self getFrameInWindow:browseItem.smallImageView];
            
            if(_isFirstOpen){
                _isFirstOpen = NO;
                [UIView animateWithDuration:0.2 animations:^{
                    // 长图的时候，按照宽高比例拉伸 eagle
                    if ((image.size.width < kScreenWidth || image.size.height > kScreenHeight)&& image.size.height>3*image.size.width) {
                        CGFloat theHeight = image.size.height*kScreenWidth/
                        image.size.width;
                        cell.zoomScrollView.zoomImageView.frame = CGRectMake(0, 0, _screenWidth, theHeight);
                        cell.zoomScrollView.contentSize = CGSizeMake(_screenWidth, theHeight);
                    }
                    else{
                        
                        cell.zoomScrollView.zoomImageView.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
                    }
                }];
            }else{//长图的时候，按照宽高比例拉伸 eagle
                if ((image.size.width < kScreenWidth || image.size.height > kScreenHeight)&& image.size.height>3*image.size.width) {
                    CGFloat theHeight = image.size.height*kScreenWidth/
                    image.size.width;
                    cell.zoomScrollView.zoomImageView.frame = CGRectMake(0, 0, _screenWidth, theHeight);
                    cell.zoomScrollView.contentSize = CGSizeMake(_screenWidth, theHeight);
                }else{
                    
                    cell.zoomScrollView.zoomImageView.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
                }
            }
            
        }else {
            // 停止加载
            [cell.loadingView stopAnimation];
            
            cell.zoomScrollView.zoomImageView.contentMode = browseItem.smallImageView.contentMode;
            cell.zoomScrollView.zoomImageView.clipsToBounds = browseItem.smallImageView.clipsToBounds;
            [cell.loadingView mss_setFrameInSuperViewCenterWithSize:CGSizeMake(30, 30)];
            CGRect bigImageRect = [_verticalBigRectArray[indexPath.row] CGRectValue];
            if(_currentOrientation != UIDeviceOrientationPortrait){
                bigImageRect = [_horizontalBigRectArray[indexPath.row] CGRectValue];
            }
            //            UIImage *theImage = cell.zoomScrollView.zoomImageView.image;
            // 长图的时候，按照宽高比例拉伸 eagle
            if ((bigImageRect.size.width < kScreenWidth || bigImageRect.size.height > kScreenHeight)&& bigImageRect.size.height>3*bigImageRect.size.width) {
                CGFloat theHeight = bigImageRect.size.height*kScreenWidth/
                bigImageRect.size.width;
                cell.zoomScrollView.contentSize = CGSizeMake(_screenWidth, theHeight);
                bigImageRect = CGRectMake(0, 0, kScreenWidth, theHeight);
                
            }
            
            if([browseItem.bigImageUrl hasSuffix:@"_thum"]){
                browseItem.bigImageUrl =[browseItem.bigImageUrl substringToIndex:(browseItem.bigImageUrl.length - 5)];
            }
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            NSString *imagePath = [NSString stringWithFormat:@"%@/%@/%@_2small",cachesDirectory,@"CircleOfFriends",browseItem.bigImageUrl.lastPathComponent];
            BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
//            if(isExist)
//            {
//                [self showBigLocalImagee:cell.zoomScrollView.zoomImageView browseItem:browseItem rect:bigImageRect withImagePath:imagePath];
//            } else if([[SDImageCache sharedImageCache]imageFromDiskCacheForKey:browseItem.bigImageUrl]){
//                // 显示大图
//                [self showBigImage:cell.zoomScrollView.zoomImageView browseItem:browseItem rect:bigImageRect];
//            }else{// 如果大图不存在
//                _isFirstOpen = NO;
//                // 加载大图
//                [self loadBigImageWithBrowseItem:browseItem cell:cell rect:bigImageRect];
//            }
            
            if([[SDImageCache sharedImageCache]imageFromDiskCacheForKey:browseItem.bigImageUrl])
            {
                // 显示大图
                [self showBigImage:cell.zoomScrollView.zoomImageView browseItem:browseItem rect:bigImageRect];
            } else if(isExist){
                [self showBigLocalImagee:cell.zoomScrollView.zoomImageView browseItem:browseItem rect:bigImageRect withImagePath:imagePath];
                
            }else{// 如果大图不存在
                _isFirstOpen = NO;
                // 加载大图
                [self loadBigImageWithBrowseItem:browseItem cell:cell rect:bigImageRect];
            }
            
        }
        
        __weak __typeof(self)weakSelf = self;
        [cell tapClick:^(MSSBrowseCollectionViewCell *browseCell) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf tap:browseCell];
        }];
        [cell longPress:^(MSSBrowseCollectionViewCell *browseCell) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf.isLoadLoc) {
                if(!KCNSSTRING_ISEMPTY(browseItem.locImgUrl)
                   &&[[NSFileManager defaultManager] fileExistsAtPath:browseItem.locImgUrl]) {
                    [strongSelf longPress:cell];
                }
            }else {
                //                if([[SDImageCache sharedImageCache]makeDiskCachePath:browseItem.bigImageUrl]) {
                if([[SDImageCache sharedImageCache]imageFromDiskCacheForKey:browseItem.bigImageUrl]) {
                    [strongSelf longPress:cell];
                }
            }
        }];
        
        cell.scrollBlock = ^(CGPoint offset) {
            [weakSelf scrollWithOffset:offset];
        };
        
        cell.endScrollBlock = ^(UIScrollView *scrollView) {
            [weakSelf endScroll:scrollView];
        };
        
        cell.willEndScrollBlock = ^(UIScrollView *scrollView, CGPoint velocity, CGPoint *targetContentOffset) {
            [weakSelf willEndScroll:scrollView velocity:velocity];
        };
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _browseItemArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_screenWidth + kBrowseSpace, _screenHeight);
}

- (void)showBigLocalImagee:(UIImageView *)imageView browseItem:(MSSBrowseModel *)browseItem rect:(CGRect)rect withImagePath:(NSString *)imagePath {
    // 取消当前请求防止复用问题
    [imageView sd_cancelCurrentImageLoad];
    // 如果存在直接显示图片
    imageView.image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    
    // 第一次打开浏览页需要加载动画
    if(_isFirstOpen) {
        _isFirstOpen = NO;
        imageView.frame = [self getFrameInWindow:browseItem.smallImageView];
        ;
        [UIView animateWithDuration:0.2 animations:^{
            imageView.frame = rect;
        }];
    }
    else {
        imageView.frame = rect;
    }
}

- (void)showBigImage:(UIImageView *)imageView browseItem:(MSSBrowseModel *)browseItem rect:(CGRect)rect
{
    // 取消当前请求防止复用问题
    [imageView sd_cancelCurrentImageLoad];
    NSURL *urlThumURL = [NSURL URLWithString:browseItem.bigImageUrl];
    NSString *localPath = [NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),urlThumURL.lastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        [imageView sd_setImageWithURL:[NSURL fileURLWithPath:localPath] placeholderImage:ThemeImage(@"chat_placeholder_image")];
        
    }else {
        // 如果存在直接显示图片
//        imageView.image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:browseItem.bigImageUrl];
        [imageView sd_setImageWithURL:[NSURL URLWithString:browseItem.bigImageUrl] placeholderImage:ThemeImage(@"chat_placeholder_image")];
    }
    
    // 第一次打开浏览页需要加载动画
    if(_isFirstOpen)
    {
        _isFirstOpen = NO;
        imageView.frame = [self getFrameInWindow:browseItem.smallImageView];
        [UIView animateWithDuration:0.5 animations:^{
            imageView.frame = rect;
        }];
    }
    else
    {
        imageView.frame = rect;
    }
    
    __weak typeof(self)weak_self = self;

    CGSize smallImageViewSize = browseItem.smallImageView.frame.size;
    //不能直接操作imageView.image 会导致UI卡顿
    UIImage *image = imageView.image.copy;
    DDLogInfo(@"%s---99999 %@",__func__,[NSThread currentThread]);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
         DDLogInfo(@"%s---3 %@",__func__,[NSThread currentThread]);
        [image compressAndSaveImageWithSize:rect.size withCompressionQuality:1 withFilePath:[NSString stringWithFormat:@"%@%@",browseItem.bigImageUrl.lastPathComponent,@"_2small"]];
         DDLogInfo(@"%s---4 %@",__func__,[NSThread currentThread]);
        BOOL isSave =  [image compressAndSaveImageWithSize:(_browseItemArray.count==1)?smallImageViewSize:CGSizeMake(180, 180) withCompressionQuality:1 withFilePath:[NSString stringWithFormat:@"%@%@",browseItem.bigImageUrl.lastPathComponent,@"_1small"]];
         DDLogInfo(@"%s---5 %@",__func__,[NSThread currentThread]);
        if(isSave)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weak_self.haveUpdate = YES;
            });
        }
    });
    
    
}

// 加载大图
- (void)loadBigImageWithBrowseItem:(MSSBrowseModel *)browseItem cell:(MSSBrowseCollectionViewCell *)cell rect:(CGRect)rect
{
    
    __weak  UIImageView *imageView = cell.zoomScrollView.zoomImageView;
    __weak typeof(self)weak_self = self;
    
    // 加载圆圈显示
    [cell.loadingView startAnimation];
    // 默认为屏幕中间
    [imageView mss_setFrameInSuperViewCenterWithSize:CGSizeMake(browseItem.smallImageView.mssWidth, browseItem.smallImageView.mssHeight)];
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:browseItem.bigImageUrl] placeholderImage:browseItem.smallImageView.image completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        // 关闭图片浏览view的时候，不需要继续执行小图加载大图动画
        __strong typeof(weak_self)strong_self = weak_self;
        if(_collectionView.userInteractionEnabled)
        {
            if(error)
            {
                // 停止加载
                [cell.loadingView stopAnimation];
                // hanwei
                if (![browseItem.bigImageUrl isEqualToString:@""]) {
                    [self showBrowseRemindViewWithText:languageStringWithKey(@"图片加载失败")];
                } else {
                    imageView.frame = CGRectMake(0, (kScreenHeight-kScreenWidth)/2, kScreenWidth, kScreenWidth);
                }
                
            }
            else
            {
                //存放当前比例的
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    BOOL isSave =  [image compressAndSaveImageWithSize:rect.size withCompressionQuality:1 withFilePath:[NSString stringWithFormat:@"%@%@",browseItem.bigImageUrl.lastPathComponent,@"_2small"]];
                    
                    if(isSave)
                    {
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                        NSString *cachesDirectory = [paths objectAtIndex:0];
                        NSString *imagePath = [NSString stringWithFormat:@"%@/%@/%@_2small",cachesDirectory,@"CircleOfFriends",browseItem.bigImageUrl.lastPathComponent];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imageView.image = [[UIImage alloc] initWithContentsOfFile:imagePath];
                        });
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 停止加载
                        [cell.loadingView stopAnimation];
                        // 图片加载成功
                        [UIView animateWithDuration:0.2 animations:^{
                            imageView.frame = rect;
                        }];
                        if (browseItem.isBurnMessage) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"burnMediaMessageHasDownLoad" object:browseItem.messageId];
                        }
                        BOOL isSaveSmall = [imageView.image compressAndSaveImageWithSize:(_browseItemArray.count==1)?browseItem.smallImageView.frame.size:CGSizeMake(180, 180) withCompressionQuality:1 withFilePath:[NSString stringWithFormat:@"%@%@",browseItem.bigImageUrl.lastPathComponent,@"_1small"]];
                        if(isSaveSmall) {
                            strong_self.haveUpdate = YES;
                        }
                    });
                });
            }
        }
    }];
}

#pragma mark UIScrollViewDeletate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!_isRotate)
    {
        _currentIndex = scrollView.contentOffset.x / (_screenWidth + kBrowseSpace);
        _countLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)_currentIndex + 1,(long)_browseItemArray.count];
    }
    _isRotate = NO;
}

#pragma mark Tap Method
- (void)tap:(MSSBrowseCollectionViewCell *)browseCell
{
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // 显示状态栏
    [self setNeedsStatusBarAppearanceUpdate];
    // 停止加载
    NSArray *cellArray = _collectionView.visibleCells;
    for (MSSBrowseCollectionViewCell *cell in cellArray)
    {
        [cell.loadingView stopAnimation];
    }
    [_countLabel removeFromSuperview];
    _countLabel = nil;
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    
    NSIndexPath *indexPath = [_collectionView indexPathForCell:browseCell];
    browseCell.zoomScrollView.zoomScale = 1.0f;
    MSSBrowseModel *browseItem = _browseItemArray[indexPath.row];
    
    CGRect rect =[self getFrameInWindow:browseItem.smallImageView];
    
    if(_isLoadLoc )
    {
        if(browseItem.smallimageViewFrame.size.width==0)
        {
            [self disminssView];
            return;
        }else
        {
            rect=browseItem.smallimageViewFrame;
        }
    }
    
    
    //[self getFrameInWindow:browseItem.smallImageView];
    CGAffineTransform transform = CGAffineTransformMakeRotation(0);
    if(_currentOrientation == UIDeviceOrientationLandscapeLeft)
    {
        transform = CGAffineTransformMakeRotation(- M_PI / 2);
        rect = CGRectMake(rect.origin.y, MSS_SCREEN_WIDTH - rect.size.width - rect.origin.x, rect.size.height, rect.size.width);
    }
    else if(_currentOrientation == UIDeviceOrientationLandscapeRight)
    {
        transform = CGAffineTransformMakeRotation(M_PI / 2);
        rect = CGRectMake(MSS_SCREEN_HEIGHT - rect.size.height - rect.origin.y, rect.origin.x, rect.size.height, rect.size.width);
    }
    
    
    
    [UIView animateWithDuration:0.3 animations:^{
        browseCell.zoomScrollView.zoomImageView.transform = transform;
        browseCell.zoomScrollView.zoomImageView.frame = rect;
        
        self.view.backgroundColor = [UIColor clearColor];
        _bgView.backgroundColor = [UIColor clearColor];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.userInteractionEnabled = NO;
    } completion:^(BOOL finished) {
        [self disminssView];
    }];
}

#pragma mark  - scroll
- (void)scrollWithOffset:(CGPoint)offset {
    return;
    NSLog(@"--> %@",NSStringFromCGPoint(offset));
    if (self.isEndScroll) {
        return;
    }
    CGFloat offsetY = offset.y;
    if (offsetY>0) {return;}
    UIView *zoomImageView;
    CGRect rect;
    MSSBrowseCollectionViewCell *cell;
    if (_collectionView.visibleCells.count == 1) {
        cell = _collectionView.visibleCells.firstObject;
        zoomImageView = cell.zoomScrollView.zoomImageView;
        UIImage *img = cell.zoomScrollView.zoomImageView.image;
        if (!img) {
            return;
        }
        if (!cell.loadingView.hidden && !CGSizeEqualToSize(cell.loadingView.size, CGSizeZero)) {
            return;
        }
        if (!_snapshotImgView) {
            _snapshotImgView = [UIImageView new];
            _snapshotImgView.contentMode = UIViewContentModeScaleAspectFit;
        }
        _snapshotImgView.image = cell.zoomScrollView.zoomImageView.image;
        _snapshotImgView.frame = cell.zoomScrollView.zoomImageView.frame;// cell.zoomScrollView.zoomImageView.bounds;
        [self.view addSubview:_snapshotImgView];
        zoomImageView.hidden = YES;
    }else {
        return;
    }
    
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    cell.zoomScrollView.zoomScale = 1.0f;
    MSSBrowseModel *browseItem = _browseItemArray[indexPath.row];
    rect =[self getFrameInWindow:browseItem.smallImageView];
    
    CGFloat deltaY = offsetY;
    CGFloat deltaX = 0;
    CGPoint point = _snapshotImgView.center;
    _snapshotImgView.height -= fabs(deltaY);
    _snapshotImgView.width -= fabs(deltaY)*kScreenWidth/kScreenHeight;
    _snapshotImgView.center = CGPointMake(point.x+deltaX, point.y-deltaY);
    
    CGFloat alphaDelta = 160;
    CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
    alpha = YY_CLAMP(alpha, 0, 1);
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
        self.collectionView.alpha = alpha;
    } completion:nil];
    
}

- (void)endScroll:(UIScrollView *)scrollView {
    if (_collectionView.visibleCells.count == 1) {
        MSSBrowseCollectionViewCell *cell = _collectionView.visibleCells.firstObject;
        UIView *zoomImageView = cell.zoomScrollView.zoomImageView;
        zoomImageView.hidden = NO;
    }
    _collectionView.alpha = 1;
    [_snapshotImgView removeFromSuperview];
}

- (void)willEndScroll:(UIScrollView *)scrollView velocity:(CGPoint)velocity {
    if (!_snapshotImgView) {
        return;
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY>0) {return;}
    self.isEndScroll = YES;
    UIView *zoomImageView;
    CGRect rect;
    MSSBrowseCollectionViewCell *cell;
    if (_collectionView.visibleCells.count == 1) {
        cell = _collectionView.visibleCells.firstObject;
        zoomImageView = cell.zoomScrollView.zoomImageView;
        UIImage *img = cell.zoomScrollView.zoomImageView.image;
        if (!img) {
            return;
        }
        if (!cell.loadingView.hidden && !CGSizeEqualToSize(cell.loadingView.size, CGSizeZero)) {
            return;
        }
    }else {
        return;
    }
    
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    cell.zoomScrollView.zoomScale = 1.0f;
    MSSBrowseModel *browseItem = _browseItemArray[indexPath.row];
    rect =[self getFrameInWindow:browseItem.smallImageView];
    CGFloat deltaY = offsetY;
    CGFloat deltaX = 0;
    CGPoint point = _snapshotImgView.center;
    _snapshotImgView.height -= fabs(deltaY);
    _snapshotImgView.width -= fabs(deltaY)*kScreenWidth/kScreenHeight;
    _snapshotImgView.center = CGPointMake(point.x+deltaX, point.y-deltaY);
    if (fabs(velocity.y) > 1000 || fabs(deltaY) > 60) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        BOOL moveToTop = (velocity.y < - 50 || (velocity.y < 50 && deltaY < 0));
        CGFloat vy = fabs(velocity.y);
        if (vy < 1) vy = 1;
        CGFloat duration = (moveToTop ? _snapshotImgView.bottom : self.view.height - _snapshotImgView.top) / vy;
        duration *= 0.8;
        duration = YY_CLAMP(duration, 0.05, 0.3);
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
            _collectionView.alpha = 0;
            _snapshotImgView.frame = rect;
        } completion:^(BOOL finished) {
            [_snapshotImgView removeFromSuperview];
            [cell.loadingView stopAnimation];
            [self disminssView];
            self.isEndScroll = NO;
        }];
    } else {
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:velocity.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
            _snapshotImgView.frame = zoomImageView.frame;
            _collectionView.alpha = 1;
        } completion:^(BOOL finished) {
            zoomImageView.hidden = NO;
            [_snapshotImgView removeFromSuperview];
            self.isEndScroll = NO;
        }];
    }
}

#pragma mark  - pan
//滑动消失手势
- (void)pan:(UIPanGestureRecognizer *)g {
    UIView *zoomImageView;
    CGRect rect;
    MSSBrowseCollectionViewCell *cell;
    if (_collectionView.visibleCells.count == 1) {
        cell = _collectionView.visibleCells.firstObject;
        zoomImageView = cell.zoomScrollView.zoomImageView;
        UIImage *img = cell.zoomScrollView.zoomImageView.image;
        if (!img) {
            return;
        }
        if (!cell.loadingView.hidden && !CGSizeEqualToSize(cell.loadingView.size, CGSizeZero)) {
            return;
        }
        if (!_snapshotImgView) {
            _snapshotImgView = [UIImageView new];
            _snapshotImgView.contentMode = UIViewContentModeScaleAspectFit;
        }
        _snapshotImgView.image = cell.zoomScrollView.zoomImageView.image;
        _snapshotImgView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);// cell.zoomScrollView.zoomImageView.bounds;
        [self.view addSubview:_snapshotImgView];
        zoomImageView.hidden = YES;
    }else {
        return;
    }
    
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    cell.zoomScrollView.zoomScale = 1.0f;
    MSSBrowseModel *browseItem = _browseItemArray[indexPath.row];
    rect =[self getFrameInWindow:browseItem.smallImageView];
    switch (g.state) {
        case UIGestureRecognizerStateBegan: {
            if (!_isPressed) {
                _panGestureBeginPoint = [g locationInView:self.view];
            } else {
                _panGestureBeginPoint = CGPointZero;
            }
        } break;
        case UIGestureRecognizerStateChanged: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint p = [g locationInView:self.view];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            CGFloat deltaX = p.x - _panGestureBeginPoint.x;
            
            CGPoint point = _snapshotImgView.center;
            _snapshotImgView.height -= fabs(deltaY);
            _snapshotImgView.width -= fabs(deltaY)*kScreenWidth/kScreenHeight;
            _snapshotImgView.center = CGPointMake(point.x+deltaX, point.y+deltaY);
            
            CGFloat alphaDelta = 160;
            CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
            alpha = YY_CLAMP(alpha, 0, 1);
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
                self.collectionView.alpha = alpha;
            } completion:nil];
        } break;
        case UIGestureRecognizerStateEnded: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint v = [g velocityInView:self.view];
            CGPoint p = [g locationInView:self.view];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            CGFloat deltaX = p.x - _panGestureBeginPoint.x;
            
            CGPoint point = _snapshotImgView.center;
            _snapshotImgView.height -= fabs(deltaY);
            _snapshotImgView.width -= fabs(deltaY)*kScreenWidth/kScreenHeight;
            _snapshotImgView.center = CGPointMake(point.x+deltaX, point.y+deltaY);
            
            if (fabs(v.y) > 1000 || fabs(deltaY) > 120) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
                BOOL moveToTop = (v.y < - 50 || (v.y < 50 && deltaY < 0));
                CGFloat vy = fabs(v.y);
                if (vy < 1) vy = 1;
                CGFloat duration = (moveToTop ? _snapshotImgView.bottom : self.view.height - _snapshotImgView.top) / vy;
                duration *= 0.8;
                duration = YY_CLAMP(duration, 0.05, 0.3);
                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    _collectionView.alpha = 0;
                    _snapshotImgView.frame = rect;
                } completion:^(BOOL finished) {
                    [_snapshotImgView removeFromSuperview];
                    [cell.loadingView stopAnimation];
                    [self disminssView];
                }];
            } else {
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:v.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    _snapshotImgView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
                    _collectionView.alpha = 1;
                } completion:^(BOOL finished) {
                    zoomImageView.hidden = NO;
                    [_snapshotImgView removeFromSuperview];
                }];
            }
        } break;
        case UIGestureRecognizerStateCancelled : {
            _snapshotImgView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            _collectionView.alpha = 1;
        }
        default:break;
    }
}

#pragma mark -dismiess
-(void)disminssView
{
    if(_snapshotView)
    {
        _snapshotView.hidden = NO;
    }
    else
    {
        self.view.backgroundColor = [UIColor clearColor];
    }
    // 集合视图背景色设置为透明
    _collectionView.backgroundColor = [UIColor clearColor];
    // 动画结束前不可点击透明背景后的内容
    _collectionView.userInteractionEnabled = NO;
    if(self.haveUpdate) {
        self.haveUpdate = NO;
        //朋友圈更新了
        //[[NSNotificationCenter defaultCenter]postNotificationName:@"CircleOfFriendsUpdateImage" object:nil];
    }
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (void)longPress:(MSSBrowseCollectionViewCell *)browseCell
{
    __weak __typeof(self)weakSelf = self;
    
    NSMutableArray * clickArray = [NSMutableArray arrayWithCapacity:0];
    [clickArray addObjectsFromArray:self.clickArr];
    MSSBrowseModel *browseItem = browseCell.browseItem;
    
    if(browseItem.isBurnMessage){
        [clickArray removeAllObjects];//阅后jifen
        return;
    }
    //历史记录中不做二维码识别
    if (!browseItem.isHistoryMsg && !isHCQ) {
        //判断图片中是否有二维码
        NSNumber * number1 = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"isHaveQrCodeWithImage:" :@[browseCell.zoomScrollView.zoomImageView.image]];
        UIImage * image2 = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"screenView:" :@[browseCell.zoomScrollView.zoomImageView]];
        if (image2) {
            NSNumber * number2 = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"isHaveQrCodeWithImage:" :@[image2]];
            DDLogInfo(@"zzzzzzzzzz");
            if ([number1 boolValue] || [number2 boolValue]) {
                [clickArray addObject:MSSBrowseTypeString(MSSBrowseTypeSweepYard)];
            }
        }
    }
    
    _isPressed = YES;
    [self showSheetWithItems:clickArray inView:_bgView selectedIndex:^(NSInteger index) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf browseActionSheetDidSelectedAtIndex:index currentCell:browseCell];
    } dismissCompletion:^{
        weakSelf.isPressed = NO;
    }];
    
}

#pragma mark StatusBar Method
- (BOOL)prefersStatusBarHidden
{
    if(!_collectionView.userInteractionEnabled)
    {
        return NO;
    }
    return YES;
}

#pragma mark Orientation Method
- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if(orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
    {
        _isRotate = YES;
        _currentOrientation = orientation;
        if(_currentOrientation == UIDeviceOrientationPortrait)
        {
            _screenWidth = MSS_SCREEN_WIDTH;
            _screenHeight = MSS_SCREEN_HEIGHT;
            [UIView animateWithDuration:0.2 animations:^{
                self->_bgView.transform = CGAffineTransformMakeRotation(0);
            }];
        }
        else
        {
            _screenWidth = MSS_SCREEN_HEIGHT;
            _screenHeight = MSS_SCREEN_WIDTH;
            if(_currentOrientation == UIDeviceOrientationLandscapeLeft)
            {
                [UIView animateWithDuration:0.2 animations:^{
                    self->_bgView.transform = CGAffineTransformMakeRotation(M_PI / 2);
                }];
            }
            else
            {
                [UIView animateWithDuration:0.2 animations:^{
                    self->_bgView.transform = CGAffineTransformMakeRotation(- M_PI / 2);
                }];
            }
        }
        _bgView.frame = CGRectMake(0, 0, MSS_SCREEN_WIDTH, MSS_SCREEN_HEIGHT);
        _browseRemindView.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);

        [self updateSheetStyle];
        _countLabel.frame = CGRectMake(0, _screenHeight - 50, _screenWidth, 50);
        [_collectionView.collectionViewLayout invalidateLayout];
        _collectionView.frame = CGRectMake(0, 0, _screenWidth + kBrowseSpace, _screenHeight);
        _collectionView.contentOffset = CGPointMake((_screenWidth + kBrowseSpace) * _currentIndex, 0);
        [_collectionView reloadData];
    }
}

- (void)showCustomToast:(NSString *)msg{
    [SVProgressHUD showErrorWithStatus:msg];
}

#pragma mark MSSActionSheetClick
- (void)browseActionSheetDidSelectedAtIndex:(NSInteger)index currentCell:(MSSBrowseCollectionViewCell *)currentCell {
    _isPressed = NO;
    MSSBrowseModel *currentBwowseItem = _browseItemArray[_currentIndex];
    NSString * imgUrl = [NSString stringWithFormat:@"%@",currentBwowseItem.bigImageUrl];
    if([imgUrl hasSuffix:@"_thum"]){
        imgUrl =[imgUrl substringToIndex:(imgUrl.length - 5)];
    }
    if (index == MSSBrowseTypeCollect) {//收藏
        
        NSDictionary * dic = @{@"url":imgUrl};
        NSString * content = [dic translateToJSONString];
        
        RXCollectData *tempCollectData = [[RXCollectData alloc] init];
        tempCollectData.txtContent = content;
        tempCollectData.type = @"2";
        tempCollectData.sessionId = currentBwowseItem.authId.length >0 ?currentBwowseItem.authId :[Common sharedInstance].getAccount;
        tempCollectData.url = @"";
        tempCollectData.favoriteMsgId = [imgUrl MD5EncodingString].lowercaseString;
        
        [RestApi addMultiCollectDataWithAccount:[Common sharedInstance].getAccount collectContents:@[tempCollectData] didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            NSDictionary *headDic = [dict objectForKey:@"head"];
            NSInteger statusCode = [[headDic objectForKey:@"statusCode"] integerValue];
            if (statusCode == 000000) {
                [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"收藏成功")];
                NSDictionary *body = [dict objectForKey:@"body"];
                RXCollectData *collectData = [[RXCollectData alloc] init];
                collectData.collectId = [body objectForKey:@"collectId"];
                if ([[body objectForKey:@"collectIds"] count] > 0) {
                    collectData.collectId = [[body objectForKey:@"collectIds"] firstObject];
                }
                
                collectData.time = [body objectForKey:@"createTime"];
                collectData.txtContent = content;
                collectData.type = @"2";
                collectData.sessionId = [Common sharedInstance].getAccount;
                collectData.url = @"";
                
                [RXCollectData insertCollectionInfoData:collectData];
                
            } else {
                
                [SVProgressHUD showErrorWithStatus:statusCode == 901551 ? languageStringWithKey(@"请不要重复收藏"): languageStringWithKey(@"收藏失败")];
            }
        } didFailLoaded:^(NSError *error, NSString *path) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"收藏失败")];
        }];
        
//        [RestApi addCollectDataWithAccount:[Common sharedInstance].getOneAccount fromAccount:currentBwowseItem.authId TxtContent:content Url:nil DataType:@"2" didFinishLoaded:^(NSDictionary *dict, NSString *path) {
//
//            NSDictionary* head = [dict objectForKey:@"head"];
//            NSInteger statusCode = [[head objectForKey:@"statusCode"] integerValue];
//            if(statusCode == 0){
//                [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"收藏成功")];
//                NSDictionary *body = [dict objectForKey:@"body"];
//                RXCollectData *collectData = [[RXCollectData alloc] init];
//                collectData.collectId = [body objectForKey:@"collectId"];
//                collectData.time = [body objectForKey:@"createTime"];
//                collectData.txtContent = content;
//                collectData.type = @"2";
//                collectData.sessionId = currentBwowseItem.authId;
//                collectData.url = @"";
//                [RXCollectData insertCollectionInfoData:collectData];
//            }else{
//                [self showCustomToast:languageStringWithKey(@"收藏失败")];
//            }
//
//        } didFailLoaded:^(NSError *error, NSString *path) {
//            [self showCustomToast:languageStringWithKey(@"收藏失败")];
//            DDLogInfo(@"收藏失败:%@",error);
//        }];
    }else if(index == MSSBrowseTypeSave){// 保存图片
        [self savePhoto:currentCell.zoomScrollView.zoomImageView callBack:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"保存图片成功")];
            }else{
                [self showCustomToast:languageStringWithKey(@"保存图片失败")];
            }
        }];
    }else if (index == MSSBrowseTypeForward){//转发
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_REGISTERFIRSETRESPONDER" object:nil];
        if (_isLoadLoc) {
            if(!KCNSSTRING_ISEMPTY(currentBwowseItem.locImgUrl)
               &&[[NSFileManager defaultManager] fileExistsAtPath:currentBwowseItem.locImgUrl]) {
                //                objc_setAssociatedObject(@"YXPMessageRealy", @"YXPMessageRealy", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                //                NSDictionary *allDic =@{@"RelayType":[NSNumber numberWithInt:RelayMessage_image],@"data":@{@"msg_remoteUrl":currentBwowseItem.bigImageUrl?currentBwowseItem.bigImageUrl:@""}};
                //                objc_setAssociatedObject(@"YXPMessageRealy", @"YXPMessageRealy", allDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                NSString *imagePath = currentBwowseItem.locImgUrl;
                ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
                mediaBody.remotePath = imagePath;
                ECMessage *message = [[ECMessage alloc] initWithReceiver:@"" body:mediaBody];
                [self getRealyMessage:message];
            }else
            {
                [self showCustomToast:languageStringWithKey(@"图片未下载")];
                return;
            }
            
        }else {
            //            if([[SDImageCache sharedImageCache] makeDiskCachePath:imgUrl])
            UIImage *image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:imgUrl];
            
            if(image)
            {
                NSString *imagePath = [image saveToDocument];
                ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
                mediaBody.remotePath = imagePath;
                ECMessage *message = [[ECMessage alloc] initWithReceiver:@"" body:mediaBody];
                
                if ([[Common sharedInstance].componentDelegate respondsToSelector:@selector(getChooseMembersVCWithExceptData:WithType:)]) {
                    UIViewController *groupVC = [[Common sharedInstance].componentDelegate getChooseMembersVCWithExceptData:@{@"msg":message,@"from":@"friendcicle"} WithType:SelectObjectType_TransmitSelectMember];
                    
                    RXBaseNavgationController * nav = [[RXBaseNavgationController alloc] initWithRootViewController:groupVC];
                    nav.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:nav animated:YES completion:nil];
                }
                
            }else
            {
                [self showCustomToast:languageStringWithKey(@"图片未下载")];
                return;
            }
        }
    }else if(index == MSSBrowseTypeCopy){// 复制图片地址
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = imgUrl;
        [self showBrowseRemindViewWithText:languageStringWithKey(@"复制图片地址成功")];
    }else if (index == MSSBrowseTypeSweepYard) { //识别图中二维码
        NSNumber * number = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"isHaveQrCodeWithImage:" :@[currentCell.zoomScrollView.zoomImageView.image]];
        if ([number boolValue]) {
            
            [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"checkImageQrCodeWithImage:rootVC:" :@[currentCell.zoomScrollView.zoomImageView.image,self]];
        }else {
            UIImage * image = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"screenView:" :@[currentCell.zoomScrollView.zoomImageView]];
            if (image) {
                [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"checkImageQrCodeWithImage:rootVC:" :@[image,self]];
            }
        }
    }
}

- (void)forwardObjectWithSessionId:(NSString *)sessionId {
    
    MSSBrowseModel *currentBwowseItem = _browseItemArray[_currentIndex];
    NSString * imgUrl = [NSString stringWithFormat:@"%@",currentBwowseItem.bigImageUrl];
    if([imgUrl hasSuffix:@"_thum"]){
        imgUrl =[imgUrl substringToIndex:(imgUrl.length - 5)];
    }
    NSURL * ImageURL = [NSURL URLWithString:imgUrl];
    NSString * localPath = [NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),ImageURL.lastPathComponent];
    ECImageMessageBody * imageBody;
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        imageBody = [[ECImageMessageBody alloc] initWithFile:localPath displayName:ImageURL.lastPathComponent];
        [self sendMediaMessage:imageBody sessionId:sessionId];
    }else{
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:ImageURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                BOOL success = [data writeToFile:localPath  atomically:YES];
                DDLogInfo(@"下载图片%d",success);
                ECImageMessageBody * imageBody = [[ECImageMessageBody alloc] initWithFile:localPath displayName:ImageURL.lastPathComponent];
                [self sendMediaMessage:imageBody sessionId:sessionId];
            }else{
                [self showCustomToast:languageStringWithKey(@"转发失败")];
            }
        }];
    }
}

/**
 *@brief 发送媒体类型消息
 */
-(void)sendMediaMessage:(ECFileMessageBody*)mediaBody sessionId:(NSString *)sessionId{
    
    //   ECMessage *sendMess =  [[DeviceChatHelper sharedInstance] sendMediaMessage:mediaBody to:sessionId isMcm:NO AnonMode:NO  BurnMode:NO];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:sendMess];
    //
    //    [self showCustomToast:@"已转发"];
}


#pragma mark RemindView Method
- (void)showBrowseRemindViewWithText:(NSString *)text
{
    [_browseRemindView showRemindViewWithText:text];
    _bgView.userInteractionEnabled = NO;
    [self performSelector:@selector(hideRemindView) withObject:nil afterDelay:0.7];
}

- (void)hideRemindView
{
    [_browseRemindView hideRemindView];
    _bgView.userInteractionEnabled = YES;
}

- (void)getRealyMessage:(ECMessage *)message
{
    if ([[Common sharedInstance].componentDelegate respondsToSelector:@selector(getChooseMembersVCWithExceptData:WithType:)]) {
        UIViewController *groupVC = [[Common sharedInstance].componentDelegate getChooseMembersVCWithExceptData:@{@"msg":message,@"from":@"friendcicle"} WithType:SelectObjectType_TransmitSelectMember];
        
        RXBaseNavgationController * nav = [[RXBaseNavgationController alloc] initWithRootViewController:groupVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - 李晓杰 保存图片
- (void)savePhoto:(FLAnimatedImageView *)imageView callBack:(void(^)(BOOL success, NSError * _Nullable error))callBack{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [self saveImage:imageView callBack:callBack];
    }else if (status == PHAuthorizationStatusRestricted ||
              status == PHAuthorizationStatusNotDetermined) {//无权限
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {//有权限了
                [self saveImage:imageView callBack:callBack];
            }
        }];
    }else{
        [self showBrowseRemindViewWithText:languageStringWithKey(@"用户拒绝相册权限，请打开")];
    }
}
- (void)saveImage:(FLAnimatedImageView *)imageView callBack:(void(^)(BOOL success, NSError * _Nullable error))callBack{
    if (imageView.animatedImage) {
        
         ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:imageView.animatedImage.data metadata:nil completionBlock:^(NSURL *assetURL,NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                callBack(error ? NO : YES,error);
            });
        }];
    } else {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //写入图片到相册 PHAssetChangeRequest *req =
            [PHAssetChangeRequest creationRequestForAssetFromImage:imageView.image];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                callBack(error ? NO : YES,error);
            });
        }];
    }
}
@end
