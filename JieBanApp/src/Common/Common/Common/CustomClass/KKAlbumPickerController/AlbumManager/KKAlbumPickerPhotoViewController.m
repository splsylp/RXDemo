//
//  KKAlbumPickerPhotoViewController.m
//  Demo
//
//  Created by beartech on 14-9-10.
//  Copyright (c) 2014年 liubo. All rights reserved.
//

#import "KKAlbumPickerPhotoViewController.h"
#import "AlbumManager.h"
#import "KKAlbumPickerController.h"
#import "KIImageCropperViewController.h"
#import "KKAlertView.h"
#import "YXPExtension.h"

@interface KKAlbumPickerPhotoViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,assign)NSInteger numberOfPhotosNeedSelected;
@property (nonatomic,assign)BOOL editEnable;//是否可以编辑 (当numberOfPhotosNeedSelected=1时 有效)
@property (nonatomic,assign)CGSize cropSize;//裁剪大小（当editEnable为YES的时候有效）
@property (nonatomic,assign)BOOL pushToGroupSavedPhotos;//是否默认进入相机胶卷;

@end

@implementation KKAlbumPickerPhotoViewController
@synthesize table = _table;
@synthesize dataSource = _dataSource;
@synthesize toolBarView = _toolBarView;
@synthesize infoBoxView = _infoBoxView;
@synthesize infoLabel =  _infoLabel;
@synthesize okButton = _okButton;

@synthesize selectedInformation = _selectedInformation;
@synthesize selectedImages = _selectedImages;
@synthesize selectImageArray = _selectImageArray;

@synthesize numberOfPhotosNeedSelected;
@synthesize editEnable;
@synthesize cropSize;
@synthesize pushToGroupSavedPhotos;



- (void)dealloc{
    [_table release];
    [_dataSource release];
    [_toolBarView release];
    [_infoBoxView release];
    [_infoLabel release];
    [_okButton release];

    [_selectedInformation release];
    [_selectedImages release];
    [_selectImageArray release];
    [super dealloc];
}

/**
 * 1、group 相册目录
 * 2、aNumberNeedSelected 需要选择的照片数量
 * 3、aEditEnable 是否需要编辑功能（仅在aNumberNeedSelected为1的时候有效）
 * 4、aCropSize 编辑的尺寸（仅在aEditEnable为YES的时候有效）
 * 5、aPushToDefaultDirectory 是否需要默认进入“相机胶卷”
 */
- (id)initWithAssetsGroup:(id)aGroup
       numberNeedSelected:(NSInteger)aNumberNeedSelected
               editEnable:(BOOL)aEditEnable
                 cropSize:(CGSize)aCropSize
   pushToDefaultDirectory:(BOOL)aPushToDefaultDirectory{
    self = [super init];
    if (self) {
        _selectedInformation = [[NSMutableDictionary alloc] init];
        _selectedImages = [[NSMutableDictionary alloc] init];
        _selectImageArray =  [[NSMutableArray alloc] init];
        
        numberOfPhotosNeedSelected = aNumberNeedSelected;
        editEnable = aEditEnable;
        if (CGSizeEqualToSize(aCropSize, CGSizeZero)) {
            cropSize = CGSizeMake(200, 200);
        }
        else{
            cropSize = aCropSize;
        }
        pushToGroupSavedPhotos = aPushToDefaultDirectory;
        _dataSource = [[NSMutableArray alloc] init];

        if ([aGroup isKindOfClass:[ALAssetsGroup class]]) {
            self.title = [aGroup valueForProperty:ALAssetsGroupPropertyName];
            [[AlbumManager defaultManager] loadAlbumPhotosWithALAssetsGroupGroup:aGroup finishedBlock:^(NSArray *Albums) {
                [_dataSource addObjectsFromArray:Albums];
                [_table reloadData];
            }];
        }
        else if ([aGroup isKindOfClass:[PHAssetCollection class]]){
            PHAssetCollection *group = (PHAssetCollection*)aGroup;
            NSString *groupName = group.localizedTitle;
            self.title = groupName;

            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:group options:nil];
//            NSString *numberOfAssets = [NSString stringWithInteger:[result count]];
            
            for (NSInteger i=0; i<[result count]; i++) {
                PHAsset *asset = [result objectAtIndex:i];
                if ([asset mediaType]==PHAssetMediaTypeImage) {
                    [_dataSource addObject:asset];
                }
            }
            [_table reloadData];
        }
        else{
        
        }
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
//    [self showNavigationDefaultBackButton_ForNavPopBack];
//    
//    [self setNavRightButtonTitle:@"取消" selector:@selector(navigationControllerDismiss)];
    
    [self initUI];
}

- (void)initUI{
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ApplicationWidth, ApplicationHeight) style:UITableViewStylePlain];
    _table.backgroundColor = [UIColor whiteColor];
    _table.backgroundView.backgroundColor = [UIColor whiteColor];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    
    _toolBarView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    _toolBarView.userInteractionEnabled = YES;
    _toolBarView.backgroundColor = [UIColor clearColor];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"KKAlbumPickerController.bundle" ofType:nil];
    NSString *imagePath = [bundlePath stringByAppendingString:@"/KKImagePickerPhoto_BottomBar_Background.png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    _toolBarView.image = [image stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    [self.view addSubview:_toolBarView];
    
    _infoBoxView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7, CGRectGetWidth(self.view.bounds), 30)];
    _infoBoxView.backgroundColor = [UIColor clearColor];
    NSString *imagePath01 = [bundlePath stringByAppendingString:@"/KKImagePickerPhoto_BottomBar_RoundRectBox.png"];
    UIImage *image01 = [UIImage imageWithContentsOfFile:imagePath01];
    _infoBoxView.image = [image01 stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    [_toolBarView addSubview:_infoBoxView];
    
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_infoBoxView.frame)+15, 7, CGRectGetWidth(self.view.bounds), 30)];
    _infoLabel.backgroundColor = [UIColor clearColor];
    _infoLabel.textColor = [UIColor lightGrayColor];
    _infoLabel.font =ThemeFontSmall;
    [_toolBarView addSubview:_infoLabel];
    
    _okButton = [[UIButton alloc] initWithFrame:CGRectMake(_toolBarView.frame.size.width-10-60, (_toolBarView.frame.size.height-30)/2.0, 60, 30)];
    [_okButton setTitle:languageStringWithKey(@"确定") forState:UIControlStateNormal];
    [_okButton setCornerRadius:5.0];
    _okButton.exclusiveTouch = YES;
    [_okButton setBorderColor:[UIColor colorWithRed:0.78f green:0.78f blue:0.78f alpha:1.00f] width:1.0];
    [_okButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_okButton setBackgroundColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    _okButton.titleLabel.font =ThemeFontSmall;
    [_okButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_okButton addTarget:self action:@selector(pickeImageFinished) forControlEvents:UIControlEventTouchUpInside];
    [_toolBarView addSubview:_okButton];
}

- (void)pickeImageFinished{
    [self selectedFinished];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)selectedFinished{
    KKAlbumPickerController *rootNav = (KKAlbumPickerController*)self.navigationController;
    if (rootNav && rootNav.delegate && [rootNav.delegate respondsToSelector:@selector(KKAlbumPickerController_DidFinishedPickImage:imageInformation:)]) {
        //[rootNav.delegate KKAlbumPickerController_DidFinishedPickImage:[_selectedImages allValues] imageInformation:[_selectedInformation allValues]];
        [rootNav.delegate KKAlbumPickerController_DidFinishedPickImage:_selectImageArray  imageInformation:[_selectedInformation allValues]];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadToolBar];
    [_table reloadData];
    [_table scrollToBottomWithAnimated:NO];
}

- (void)reloadToolBar{
    if (numberOfPhotosNeedSelected<=1) {
        _table.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _toolBarView.hidden = YES;
    }else{
        _toolBarView.hidden = NO;
        _table.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _toolBarView.frame = CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
        NSString *infoString = [NSString stringWithFormat:@"%@ %ld/%ld %@",languageStringWithKey(@"已选"),(long)[_selectedInformation count],(long)numberOfPhotosNeedSelected, languageStringWithKey(@"张")];
       
        
        CGSize size = [infoString sizeWithFont:ThemeFontSmall maxSize:CGSizeMake(1000, 30) lineBreakMode:NSLineBreakByCharWrapping];
        
        _infoBoxView.frame = CGRectMake(20, 7, size.width+40, 30);
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"KKAlbumPickerController.bundle" ofType:nil];
        NSString *imagePath01 = [bundlePath stringByAppendingString:@"/KKImagePickerPhoto_BottomBar_RoundRectBox.png"];
        UIImage *image01 = [UIImage imageWithContentsOfFile:imagePath01];
        _infoBoxView.image = [image01 stretchableImageWithLeftCapWidth:20 topCapHeight:20];

        _infoLabel.frame = CGRectMake(CGRectGetMinX(_infoBoxView.frame)+25, 7, CGRectGetWidth(self.view.bounds), 30);
        _infoLabel.text = infoString;
    }
}

#pragma mark ==================================================
#pragma mark == UITableViewDataSource
#pragma mark ==================================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([_dataSource count]%4==0) {
        return [_dataSource count]/4;
    }
    else{
        return [_dataSource count]/4+1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        CGFloat space = 5;
        CGFloat width = ([[UIScreen mainScreen] bounds].size.width - space*5)/4;
        
        UIButton *button01 = [[UIButton alloc] initWithFrame:CGRectMake(space + (space+width)*0, space, width, width)];
        button01.backgroundColor = [UIColor clearColor];
        button01.tag = 1101;
        button01.exclusiveTouch = YES;
        [button01 addTarget:self action:@selector(ButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button01];
        
        UIImageView *selectedImageView01 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button01.frame)-23-2, CGRectGetMinY(button01.frame)+2, 23, 23)];
        selectedImageView01.backgroundColor = [UIColor clearColor];
        selectedImageView01.tag = 2201;
        selectedImageView01.userInteractionEnabled = NO;
        [cell.contentView addSubview:selectedImageView01];
        [selectedImageView01 release];
        [button01 release];
        
        UIButton *button02 = [[UIButton alloc] initWithFrame:CGRectMake(space + (space+width)*1, space, width, width)];
        button02.backgroundColor = [UIColor clearColor];
        button02.tag = 1102;
        button02.exclusiveTouch = YES;
        [button02 addTarget:self action:@selector(ButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button02];
        
        UIImageView *selectedImageView02 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button02.frame)-23-2, CGRectGetMinY(button02.frame)+2, 23, 23)];
        selectedImageView02.backgroundColor = [UIColor clearColor];
        selectedImageView02.tag = 2202;
        selectedImageView02.userInteractionEnabled = NO;
        [cell.contentView addSubview:selectedImageView02];
        [selectedImageView02 release];
        [button02 release];
        
        UIButton *button03 = [[UIButton alloc] initWithFrame:CGRectMake(space + (space+width)*2, space, width, width)];
        button03.backgroundColor = [UIColor clearColor];
        button03.tag = 1103;
        button03.exclusiveTouch = YES;
        [button03 addTarget:self action:@selector(ButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button03];
        
        UIImageView *selectedImageView03 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button03.frame)-23-2, CGRectGetMinY(button03.frame)+2, 23, 23)];
        selectedImageView03.backgroundColor = [UIColor clearColor];
        selectedImageView03.tag = 2203;
        selectedImageView03.userInteractionEnabled = NO;
        [cell.contentView addSubview:selectedImageView03];
        [selectedImageView03 release];
        [button03 release];
        
        
        UIButton *button04 = [[UIButton alloc] initWithFrame:CGRectMake(space + (space+width)*3, space, width, width)];
        button04.backgroundColor = [UIColor clearColor];
        button04.tag = 1104;
        button04.exclusiveTouch = YES;
        [button04 addTarget:self action:@selector(ButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button04];
        UIImageView *selectedImageView04 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button04.frame)-23-2, CGRectGetMinY(button04.frame)+2, 23, 23)];
        selectedImageView04.backgroundColor = [UIColor clearColor];
        selectedImageView04.tag = 2204;
        selectedImageView04.userInteractionEnabled = NO;
        [cell.contentView addSubview:selectedImageView04];
        [selectedImageView04 release];
        [button04 release];
    }
    
    for (NSInteger i=0; i<4; i++) {
        NSInteger index = indexPath.row*4+i;
        UIButton *button = (UIButton*)[cell.contentView viewWithTag:1101+i];
        UIImageView *selectedImageView = (UIImageView*)[cell.contentView viewWithTag:2201+i];
        
        if (index<[_dataSource count]) {
            button.hidden = NO;
            
            NSObject *object = [_dataSource objectAtIndex:index];
            if ([object isKindOfClass:[ALAsset class]]) {
                ALAsset *asset = [_dataSource objectAtIndex:index];
                UIImage* posterImage = [UIImage imageWithCGImage: asset.thumbnail];
                [button setBackgroundImage:posterImage forState:UIControlStateNormal];
                /*检查是否选中*/
                [self checkIsSelectedImageView:selectedImageView URL:asset.defaultRepresentation.url];
            }
            else if ([object isKindOfClass:[PHAsset class]]){
                /* 暂未实现 */
                
                PHAsset *asset = [_dataSource objectAtIndex:index];
                
                PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
                [imageManager requestImageForAsset:asset
                                        targetSize:CGSizeMake(button.bounds.size.width, button.bounds.size.height)
                                       contentMode:PHImageContentModeAspectFill
                                           options:nil
                                     resultHandler:^(UIImage *result, NSDictionary *info) {
                                         [button setBackgroundImage:result forState:UIControlStateNormal];
                                     }];
                [imageManager release];

//                PHContentEditingInputRequestOptions *editOptions = [[PHContentEditingInputRequestOptions alloc] init];
//                [editOptions setCanHandleAdjustmentData:^BOOL(PHAdjustmentData *adjustmentData) {
//                    return [adjustmentData.formatIdentifier isEqualToString:[NSBundle bundleIdentifier]] && [adjustmentData.formatVersion isEqualToString:[NSBundle bundleVersion]];
//                }];
                [asset requestContentEditingInputWithOptions:nil
                                           completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
                                               NSURL *imageURL = contentEditingInput.fullSizeImageURL;
                                               
                                               /*检查是否选中*/
                                               [self checkIsSelectedImageView:selectedImageView URL:imageURL];
                                           }];
//                [editOptions release];
            }
            else{
            
            }
        }
        else{
            button.hidden = YES;
            [self setCellPhotoImage:selectedImageView selectedStatus:2];
        }
    }
    return cell;
}


- (void)ButtonClicked:(UIButton*)button{

    UITableViewCell *cell = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0 &&[[[UIDevice currentDevice] systemVersion] floatValue]<8.0) {
        cell = (UITableViewCell*)[[button.superview superview] superview];
    }
    else{
        cell = (UITableViewCell*)[button.superview superview];
    }
    
    NSIndexPath *indexPath = [_table indexPathForCell:cell];
    NSInteger index = indexPath.row*4+(button.tag - 1101);
    id object = [_dataSource objectAtIndex:index];
    if ([object isKindOfClass:[ALAsset class]]) {
        ALAsset *result = [_dataSource objectAtIndex:index];
        NSURL *URL = result.defaultRepresentation.url;
        UIImageView *selectedImageView = (UIImageView*)[cell.contentView viewWithTag:2201+(button.tag - 1101)];
        
        
        if (numberOfPhotosNeedSelected<=1) {
            [_selectedInformation removeAllObjects];
            [_selectImageArray removeAllObjects];
            [_selectedImages removeAllObjects];
            
            NSMutableDictionary *selectInfo = [NSMutableDictionary dictionary];
            if (URL) {
                [selectInfo setObject:URL forKey:AlbumManagerKey_url];
            }
            NSString *kName = result.defaultRepresentation.filename;
            if ([NSString isStringNotEmpty:kName]) {
                [selectInfo setObject:kName forKey:AlbumManagerKey_name];
            }
            NSDate *kDate = [result valueForProperty:ALAssetPropertyDate];
            if (kDate && [kDate isKindOfClass:[NSDate class]]) {
                [selectInfo setObject:kDate forKey:AlbumManagerKey_date];
            }
            
            NSString *urlString = [URL absoluteString];
            if ([NSString isStringEmpty:urlString]) {
                return;
            }
            [_selectedInformation setObject:selectInfo forKey:urlString];
            
            UIImage* image = [UIImage imageWithCGImage:[result.defaultRepresentation fullScreenImage]];
            if (editEnable) {
                KIImageCropperViewController *cropImageViewController = [[KIImageCropperViewController alloc] initWithImage:image
                                                                                                                   cropSize:self.cropSize];
                [self.navigationController pushViewController:cropImageViewController animated:YES];
                [cropImageViewController setCroppedImage:^(UIImage *image) {
                    [_selectImageArray addObject:image];
                    [_selectedImages setObject:image forKey:[URL absoluteString]];
                    [self selectedFinished];
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                }];
                [cropImageViewController release];
            }
            else{
                [_selectImageArray addObject:image];
                [_selectedImages setObject:image forKey:[URL absoluteString]];
                [self selectedFinished];
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
        }
        else{
            if ([_selectedImages objectForKey:[URL absoluteString]]) {
                [_selectImageArray removeObject:[_selectedImages objectForKey:[URL absoluteString]]];
                [_selectedImages removeObjectForKey:[URL absoluteString]];
                [_selectedInformation removeObjectForKey:[URL absoluteString]];
            }
            else{
                if (numberOfPhotosNeedSelected==[_selectedImages count]) {
                    KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:nil subTitle:nil message:languageStringWithKey(@"可选照片数量已达上限") delegate:self buttonTitles: languageStringWithKey(@"确定"),nil];
                   
                    [alertView show];
                    [alertView release];
                    
                    UIButton *button = [alertView buttonAtIndex:0];
                    [button setTitleColor:MainTheme_GreenColor forState:UIControlStateNormal];
                    return;
                }
                else{
                    NSMutableDictionary *selectInfo = [NSMutableDictionary dictionary];
                    if (URL) {
                        [selectInfo setObject:URL forKey:AlbumManagerKey_url];
                    }
                    NSString *kName = result.defaultRepresentation.filename;
                    if ([NSString isStringNotEmpty:kName]) {
                        [selectInfo setObject:kName forKey:AlbumManagerKey_name];
                    }
                    NSDate *kDate = [result valueForProperty:ALAssetPropertyDate];
                    if (kDate && [kDate isKindOfClass:[NSDate class]]) {
                        [selectInfo setObject:kDate forKey:AlbumManagerKey_date];
                    }
                    
                    [_selectedInformation setObject:selectInfo forKey:[URL absoluteString]];
                    [AlbumManager loadAlbumFullScreenImageWithURL:URL resultBlock:^(UIImage *image) {
                        [_selectImageArray addObject:image];
                        [_selectedImages setObject:image forKey:[URL absoluteString]];
                        
                    } failureBlock:^(NSError *error) {
                        
                    }];
                }
            }
            
            /*检查是否选中*/
            [self checkIsSelectedImageView:selectedImageView URL:URL];
            [self reloadToolBar];
        }
    }
    else if ([object isKindOfClass:[PHAsset class]]){
        PHAsset *asset = [_dataSource objectAtIndex:index];

        PHContentEditingInputRequestOptions *editOptions = [[PHContentEditingInputRequestOptions alloc] init];
        editOptions.networkAccessAllowed = YES;
        [editOptions setCanHandleAdjustmentData:^BOOL(PHAdjustmentData *adjustmeta) {
            return YES;
        }];
        [asset requestContentEditingInputWithOptions:editOptions
                                   completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
                                       NSURL *URL = contentEditingInput.fullSizeImageURL;

                                       UIImageView *selectedImageView = (UIImageView*)[cell.contentView viewWithTag:2201+(button.tag - 1101)];
                                       
                                       if (numberOfPhotosNeedSelected<=1) {
                                           [_selectedInformation removeAllObjects];
                                           [_selectImageArray removeAllObjects];
                                           [_selectedImages removeAllObjects];
                                           
                                           NSMutableDictionary *selectInfo = [NSMutableDictionary dictionary];
                                           if (URL) {
                                               [selectInfo setObject:URL forKey:AlbumManagerKey_url];
                                           }
                                           NSString *kName = [URL lastPathComponent];
                                           if ([NSString isStringNotEmpty:kName]) {
                                               [selectInfo setObject:kName forKey:AlbumManagerKey_name];
                                           }
                                           NSDate *kDate = asset.creationDate;
                                           if (kDate && [kDate isKindOfClass:[NSDate class]]) {
                                               [selectInfo setObject:kDate forKey:AlbumManagerKey_date];
                                           }
                                           
                                           NSString *urlString = [URL absoluteString];
                                           if ([NSString isStringEmpty:urlString]) {
                                               return;
                                           }
                                           [_selectedInformation setObject:selectInfo forKey:urlString];
                                           
                                           UIImage *image = [UIImage imageWithContentsOfFile:[URL path]];
                                           if (editEnable) {
                                               KIImageCropperViewController *cropImageViewController = [[KIImageCropperViewController alloc] initWithImage:image
                                                                                                                                                  cropSize:self.cropSize];
                                               [self.navigationController pushViewController:cropImageViewController animated:YES];
                                               [cropImageViewController setCroppedImage:^(UIImage *image) {
                                                   [_selectImageArray addObject:image];
                                                   [_selectedImages setObject:image forKey:[URL absoluteString]];
                                                   [self selectedFinished];
                                                   [self.navigationController dismissViewControllerAnimated:YES completion:^{
                                                       
                                                   }];
                                               }];
                                               [cropImageViewController release];
                                           }
                                           else{
                                               [_selectImageArray addObject:image];
                                               [_selectedImages setObject:image forKey:[URL absoluteString]];
                                               [self selectedFinished];
                                               [self.navigationController dismissViewControllerAnimated:YES completion:^{
                                                   
                                               }];
                                           }
                                       }
                                       else{
                                           if ([_selectedImages objectForKey:[URL absoluteString]]) {
                                               [_selectImageArray removeObject:[_selectedImages objectForKey:[URL absoluteString]]];
                                               [_selectedImages removeObjectForKey:[URL absoluteString]];
                                               [_selectedInformation removeObjectForKey:[URL absoluteString]];
                                           }
                                           else{
                                               if (numberOfPhotosNeedSelected==[_selectedImages count]) {
                                                   KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:nil subTitle:nil message:languageStringWithKey(@"可选照片数量已达上限") delegate:self buttonTitles:languageStringWithKey(@"确定"),nil];
                                                   
                                                   [alertView show];
                                                   [alertView release];
                                                   
                                                   UIButton *button = [alertView buttonAtIndex:0];
                                                   [button setTitleColor:MainTheme_GreenColor forState:UIControlStateNormal];
                                                   return;
                                               }
                                               else{
                                                   NSMutableDictionary *selectInfo = [NSMutableDictionary dictionary];
                                                   if (URL) {
                                                       [selectInfo setObject:URL forKey:AlbumManagerKey_url];
                                                   }
                                                   NSString *kName = [URL lastPathComponent];
                                                   if ([NSString isStringNotEmpty:kName]) {
                                                       [selectInfo setObject:kName forKey:AlbumManagerKey_name];
                                                   }
                                                   NSDate *kDate = asset.creationDate;
                                                   if (kDate && [kDate isKindOfClass:[NSDate class]]) {
                                                       [selectInfo setObject:kDate forKey:AlbumManagerKey_date];
                                                   }
                                                   
                                                   [_selectedInformation setObject:selectInfo forKey:[URL absoluteString]];
                                                   UIImage *image = [UIImage imageWithContentsOfFile:[URL path]];
                                                   [_selectImageArray addObject:image];
                                                   [_selectedImages setObject:image forKey:[URL absoluteString]];
                                               }
                                           }
                                           
                                           /*检查是否选中*/
                                           [self checkIsSelectedImageView:selectedImageView URL:URL];
                                           [self reloadToolBar];
                                       }
                                   }];
        [editOptions release];

    }
    else{
    
    }
    
    if ([_selectedInformation count]==0) {
        _okButton.userInteractionEnabled = NO;
        [_okButton setBorderColor:[UIColor colorWithRed:0.78f green:0.78f blue:0.78f alpha:1.00f] width:1.0];
        [_okButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_okButton setBackgroundColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_okButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
    else{
        _okButton.userInteractionEnabled = YES;
        [_okButton setBorderColor:[UIColor clearColor] width:1.0];
        [_okButton setBackgroundColor:MainTheme_GreenColor forState:UIControlStateNormal];
        [_okButton setBackgroundColor:nil forState:UIControlStateHighlighted];
        [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }

}

- (void)checkIsSelectedImageView:(UIImageView*)imageView URL:(NSURL*)URL {
    /*检查是否选中*/
    if ([_selectedInformation objectForKey:[URL absoluteString]]) {
        [self setCellPhotoImage:imageView selectedStatus:1];
    }
    else{
        if (numberOfPhotosNeedSelected<=1) {
            [self setCellPhotoImage:imageView selectedStatus:2];
        }
        else{
            [self setCellPhotoImage:imageView selectedStatus:0];
        }
    }
}

/**
    设置Cell里面图片选中的状态
    0、未选中状态
    1、选中状态
    2、无状态
 */
- (void)setCellPhotoImage:(UIImageView*)imageView selectedStatus:(NSInteger)status{
    if (status==0) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"KKAlbumPickerController.bundle" ofType:nil];
        NSString *imagePath = [bundlePath stringByAppendingString:@"/KKImagePickerPhoto_UnSelected.png"];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        imageView.image = image;
    }
    else if (status==1){
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"KKAlbumPickerController.bundle" ofType:nil];
        NSString *imagePath = [bundlePath stringByAppendingString:@"/KKImagePickerPhoto_SelectedH.png"];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        imageView.image = image;
    }
    else if (status==2){
        imageView.image = nil;
    }
    else{
        
    }
}


#pragma mark ==================================================
#pragma mark == UITableViewDelegate
#pragma mark ==================================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat space = 5;
    CGFloat width = ([[UIScreen mainScreen] bounds].size.width - space*5)/4;
    return space + width;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (numberOfPhotosNeedSelected<=1) {
        return 10;
    }
    else{
        return 54;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return [view autorelease];
}

@end
