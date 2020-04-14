//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  ZLPhotoPickerAssetsViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-12.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "RX_MLSelectPhotoPickerGroup.h"
#import "RX_MLSelectPhotoPickerDatas.h"
#import "RX_MLSelectPhotoPickerAssetsViewController.h"
#import "RX_MLSelectPhotoPickerCollectionView.h"
#import "RX_MLSelectPhotoPickerCollectionViewCell.h"
#import "RX_MLSelectPhotoPickerFooterCollectionReusableView.h"
#import "RX_MLSelectPhotoBrowserViewController.h"

static CGFloat CELL_ROW = 4;
static CGFloat CELL_MARGIN = 2;
static CGFloat CELL_LINE_MARGIN = 2;
static CGFloat TOOLBAR_HEIGHT = 44;

static NSString *const _cellIdentifier = @"cell";
static NSString *const _footerIdentifier = @"FooterView";
static NSString *const _identifier = @"toolBarThumbCollectionViewCell";

#define APPMainUIColorHexString @"#48cb83"

@interface RX_MLSelectPhotoPickerAssetsViewController () <ZLPhotoPickerCollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

// View
@property (nonatomic , strong) RX_MLSelectPhotoPickerCollectionView *collectionView;

// 标记View
@property (strong,nonatomic) UILabel *makeView;
@property (strong,nonatomic) UIButton *previewBtn;
@property (strong,nonatomic) UIButton *doneBtn;
@property (strong,nonatomic) UIToolbar *toolBar;

// Datas
@property (assign,nonatomic) NSUInteger privateTempMinCount;
// 数据源
@property (strong,nonatomic) NSMutableArray *assets;
// 记录选中的assets
@property (strong,nonatomic) NSMutableArray *selectAssets;
@end

@implementation RX_MLSelectPhotoPickerAssetsViewController

#pragma mark - getter
#pragma mark Get Data
- (NSMutableArray *)selectAssets{
    if (!_selectAssets) {
        _selectAssets = [NSMutableArray array];
    }
    return _selectAssets;
}


- (void)setDoneString:(NSString *)doneString{
    if (_doneString != doneString) {
        _doneString = doneString;
    }
    [_doneBtn setTitle:(_doneString && ![_doneString isEqualToString:@""]) ? _doneString : languageStringWithKey(@"发送") forState:UIControlStateNormal];
}
#pragma mark Get View
- (UIButton *)doneBtn{
    if (!_doneBtn) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        rightBtn.enabled = YES;
        rightBtn.titleLabel.font = ThemeFontLarge;

      
        rightBtn.frame = CGRectMake(0, 0, 45, 45);
        [rightBtn setTitle:(_doneString && ![_doneString isEqualToString:@""]) ? _doneString : languageStringWithKey(@"发送") forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn addSubview:self.makeView];
        self.doneBtn = rightBtn;
    }
    return _doneBtn;
}

- (UIButton *)previewBtn{
    if (!_previewBtn) {
        UIButton *previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [previewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [previewBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        previewBtn.enabled = YES;

        previewBtn.titleLabel.font = ThemeFontLarge;

        previewBtn.frame = CGRectMake(0, 0, 60, 45);
        [previewBtn setTitle:languageStringWithKey(@"预览") forState:UIControlStateNormal];
        [previewBtn addTarget:self action:@selector(preview) forControlEvents:UIControlEventTouchUpInside];
        [previewBtn addSubview:self.makeView];
        self.previewBtn = previewBtn;
    }
    return _previewBtn;
}

- (void)setSelectPickerAssets:(NSArray *)selectPickerAssets{
    NSSet *set = [NSSet setWithArray:selectPickerAssets];
    _selectPickerAssets = [set allObjects];
    
    if (!self.assets) {
        self.assets = [NSMutableArray arrayWithArray:selectPickerAssets];
    }else{
        [self.assets addObjectsFromArray:selectPickerAssets];
    }
    
    for (RX_MLSelectPhotoAssets *assets in selectPickerAssets) {
        if ([assets isKindOfClass:[RX_MLSelectPhotoAssets class]]) {
            [self.selectAssets addObject:assets];
        }
    }

    self.collectionView.lastDataArray = nil;
    self.collectionView.isRecoderSelectPicker = YES;
    self.collectionView.selectAsstes = self.selectAssets;
    NSInteger count = self.selectAssets.count;
    self.makeView.hidden = !count;
    self.makeView.text = [NSString stringWithFormat:@"%ld",(long)count];
    self.doneBtn.enabled = (count > 0);
    self.previewBtn.enabled = (count > 0);
}

#pragma mark collectionView
- (RX_MLSelectPhotoPickerCollectionView *)collectionView{
    if (!_collectionView) {
        
        CGFloat cellW = (self.view.frame.size.width - CELL_MARGIN * CELL_ROW + 1) / CELL_ROW;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(cellW, cellW);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = CELL_LINE_MARGIN;
        layout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, TOOLBAR_HEIGHT * 2);
        
        RX_MLSelectPhotoPickerCollectionView *collectionView = [[RX_MLSelectPhotoPickerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        // 时间置顶
        collectionView.status = ZLPickerCollectionViewShowOrderStatusTimeDesc;
        collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [collectionView registerClass:[RX_MLSelectPhotoPickerCollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
        // 底部的View
        [collectionView registerClass:[RX_MLSelectPhotoPickerFooterCollectionReusableView class]  forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier];
        
        collectionView.contentInset = UIEdgeInsetsMake(5, 0,TOOLBAR_HEIGHT, 0);
        collectionView.collectionViewDelegate = self;
        [self.view insertSubview:collectionView belowSubview:self.toolBar];
        self.collectionView = collectionView;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(collectionView);
        
        NSString *widthVfl = @"H:|-0-[collectionView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:nil views:views]];
        
        NSString *heightVfl = @"V:|-0-[collectionView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:nil views:views]];
        
    }
    return _collectionView;
}

#pragma mark makeView 红点标记View
- (UILabel *)makeView{
    if (!_makeView) {
        UILabel *makeView = [[UILabel alloc] init];
        makeView.textColor = [UIColor whiteColor];
        makeView.textAlignment = NSTextAlignmentCenter;
        makeView.font = ThemeFontMiddle;
        makeView.frame = CGRectMake(-5, -5, 20, 20);
        makeView.hidden = YES;
        makeView.layer.cornerRadius = makeView.frame.size.height / 2.0;
        makeView.clipsToBounds = YES;
        makeView.backgroundColor = [UIColor redColor];
        [self.view addSubview:makeView];
        self.makeView = makeView;
        
    }
    return _makeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.bounds = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 初始化按钮
    [self setupButtons];
    
    // 初始化底部ToorBar
    [self setupToorBar];
}


#pragma mark - setter
#pragma mark 初始化按钮
- (void) setupButtons{

    self.navigationItem.rightBarButtonItem = [self setBarItemTitle:languageStringWithKey(@"取消") titleColor:APPMainUIColorHexString target:self action:@selector(back)];

    self.navigationItem.leftBarButtonItem = [self setBarItemTitle:languageStringWithKey(@"返回") titleColor:APPMainUIColorHexString target:self action:@selector(popClicked)];
}

- (UIBarButtonItem *)setBarItemTitle:(NSString *)title titleColor:(NSString *)color target:(id)target action:(SEL)action  {
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:SystemFontLarge}];
    CGRect btnFrame = CGRectMake(0, 0, size.width + 20, 30);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:btnFrame];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [[button titleLabel] setFont:SystemFontLarge];
    
    [button setTitleColor:[UIColor colorWithHexString:color] forState:UIControlStateNormal];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return buttonItem;//APPMainUIColorHexString
}

#pragma mark 初始化所有的组
- (void) setupAssets{
    if (!self.assets) {
        self.assets = [NSMutableArray array];
    }
    
    __block NSMutableArray *assetsM = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    
    [[RX_MLSelectPhotoPickerDatas defaultPicker] getGroupPhotosWithGroup:self.assetsGroup finished:^(NSArray *assets) {
        [assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop) {
            RX_MLSelectPhotoAssets *zlAsset = [[RX_MLSelectPhotoAssets alloc] init];
            zlAsset.asset = asset;
            [assetsM addObject:zlAsset];
        }];

        weakSelf.collectionView.dataArray = assetsM;
    }];
    
}

#pragma mark -初始化底部ToorBar
- (void) setupToorBar{
    UIToolbar *toorBar = [[UIToolbar alloc] init];
    toorBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toorBar];
    self.toolBar = toorBar;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(toorBar);
    NSString *widthVfl =  @"H:|-0-[toorBar]-0-|";
    NSString *heightVfl;
    if (isIPhoneX) {
         heightVfl = @"V:[toorBar(78)]-34-|";
    }else{
        
        heightVfl = @"V:[toorBar(44)]-0-|";
    }
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:0 views:views]];
    
    // 左视图 中间距 右视图
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.previewBtn];
    UIBarButtonItem *fiexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneBtn];
    
    toorBar.items = @[leftItem,fiexItem,rightItem];
    
}

#pragma mark - setter
-(void)setMinCount:(NSInteger)minCount{
    _minCount = minCount;
    
    if (!_privateTempMinCount) {
        _privateTempMinCount = minCount;
    }

    if (self.selectAssets.count == minCount){
        minCount = 0;
    }else if (self.selectPickerAssets.count - self.selectAssets.count > 0) {
        minCount = _privateTempMinCount;
    }
    
    self.collectionView.minCount = minCount;
}

- (void)setAssetsGroup:(RX_MLSelectPhotoPickerGroup *)assetsGroup{
    if (!assetsGroup.groupName.length) return ;
    
    _assetsGroup = assetsGroup;
    
    self.title = assetsGroup.groupName;
    
    // 获取Assets
    [self setupAssets];
}

- (void)pickerCollectionViewDidCameraSelect:(RX_MLSelectPhotoPickerCollectionView *)pickerCollectionView{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
        ctrl.delegate = self;
        if(iOS8)
        {
            ctrl.modalPresentationStyle=UIModalPresentationCurrentContext;
        }
        ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:ctrl animated:YES completion:nil];
    }else{
        DDLogInfo(@"请在真机使用!");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 处理
        UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
        
        [self.assets addObject:image];
        [self.selectAssets addObject:image];
        
        NSInteger count = self.selectAssets.count;
        self.makeView.hidden = !count;
        self.makeView.text = [NSString stringWithFormat:@"%ld",(long)count];
        self.doneBtn.enabled = (count > 0);
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }else{
        DDLogInfo(@"请在真机使用!");
    }
}

- (void)preview{
    RX_MLSelectPhotoBrowserViewController *browserVc = [[RX_MLSelectPhotoBrowserViewController alloc] init];
    [browserVc setValue:@(YES) forKeyPath:@"isEditing"];
    browserVc.photos = self.selectAssets;
    browserVc.shouldChange = YES;
    WS(weakSelf);
    browserVc.callBack = ^(NSArray *selectArr) {
        [weakSelf.selectAssets removeAllObjects];
        [weakSelf.selectAssets addObjectsFromArray:selectArr];
        weakSelf.collectionView.selectAsstes = weakSelf.selectAssets;
        NSInteger count = selectArr.count;
        weakSelf.makeView.hidden = !count;
        weakSelf.makeView.text = [NSString stringWithFormat:@"%ld",(long)count];
        weakSelf.doneBtn.enabled = (count > 0);
        weakSelf.previewBtn.enabled = (count > 0);
    };
    [self.navigationController pushViewController:browserVc animated:YES];
}

- (void)setTopShowPhotoPicker:(BOOL)topShowPhotoPicker{
    _topShowPhotoPicker = topShowPhotoPicker;
    
    if (self.topShowPhotoPicker == YES) {
        NSMutableArray *reSortArray= [[NSMutableArray alloc] init];
        for (id obj in [self.collectionView.dataArray reverseObjectEnumerator]) {
            [reSortArray addObject:obj];
        }
        
        RX_MLSelectPhotoAssets *mlAsset = [[RX_MLSelectPhotoAssets alloc] init];
        [reSortArray insertObject:mlAsset atIndex:0];
        
        self.collectionView.status = ZLPickerCollectionViewShowOrderStatusTimeAsc;
        self.collectionView.topShowPhotoPicker = topShowPhotoPicker;
        self.collectionView.dataArray = reSortArray;
        [self.collectionView reloadData];
    }
}


- (void) pickerCollectionViewDidSelected:(RX_MLSelectPhotoPickerCollectionView *) pickerCollectionView deleteAsset:(RX_MLSelectPhotoAssets *)deleteAssets{
    
    [self.makeView.layer removeAllAnimations];
    CAKeyframeAnimation *scaoleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaoleAnimation.duration = 0.25;
    scaoleAnimation.autoreverses = YES;
    scaoleAnimation.values = @[[NSNumber numberWithFloat:1.0],[NSNumber numberWithFloat:1.2],[NSNumber numberWithFloat:1.0]];
    scaoleAnimation.fillMode = kCAFillModeForwards;
    [self.makeView.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
    
    if (self.selectPickerAssets.count == 0){
        self.selectAssets = [NSMutableArray arrayWithArray:pickerCollectionView.selectAsstes];
    }else if (deleteAssets == nil){
        [self.selectAssets addObject:[pickerCollectionView.selectAsstes lastObject]];
    }
    
    NSInteger count = self.selectAssets.count;
    self.makeView.hidden = !count;
    self.makeView.text = [NSString stringWithFormat:@"%ld",(long)count];
    self.doneBtn.enabled = (count > 0);
    self.previewBtn.enabled = (count > 0);
    
    
    if (self.selectPickerAssets.count || deleteAssets) {
        RX_MLSelectPhotoAssets *asset = [pickerCollectionView.lastDataArray lastObject];
        if (deleteAssets){
            asset = deleteAssets;
        }
        
        NSInteger selectAssetsCurrentPage = -1;
        for (NSInteger i = 0; i < self.selectAssets.count; i++) {
            RX_MLSelectPhotoAssets *photoAsset = self.selectAssets[i];
            if([[[[asset.asset defaultRepresentation] url] absoluteString] isEqualToString:[[[photoAsset.asset defaultRepresentation] url] absoluteString]]){
                selectAssetsCurrentPage = i;
                break;
            }
        }
        
        if (
            (self.selectAssets.count > selectAssetsCurrentPage)
            &&
            (selectAssetsCurrentPage >= 0)
            ){
            if (deleteAssets){
                [self.selectAssets removeObjectAtIndex:selectAssetsCurrentPage];
            }
            [self.collectionView.selectsIndexPath removeObject:@(selectAssetsCurrentPage)];
            self.makeView.text = [NSString stringWithFormat:@"%d",(int)self.selectAssets.count];
        }
        // 刷新下最小的页数
        self.minCount = self.selectAssets.count + (_privateTempMinCount - self.selectAssets.count);
    }
}

#pragma mark -
#pragma mark - UICollectionViewDataSource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.selectAssets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    
    if (self.selectAssets.count > indexPath.item) {
        UIImageView *imageView = [[cell.contentView subviews] lastObject];
        // 判断真实类型
        if (![imageView isKindOfClass:[UIImageView class]]) {
            imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.clipsToBounds = YES;
            [cell.contentView addSubview:imageView];
        }
        
        imageView.tag = indexPath.item;
        imageView.image = [self.selectAssets[indexPath.item] thumbImage];
    }
    
    return cell;
}

#pragma mark -<Navigation Actions>
#pragma mark -开启异步通知
- (void) back{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)popClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) done{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_TAKE_DONE object:nil userInfo:@{@"selectAssets":self.selectAssets}];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)dealloc{
    // 赋值给上一个控制器
    self.groupVc.selectAsstes = self.selectAssets;
}

@end
