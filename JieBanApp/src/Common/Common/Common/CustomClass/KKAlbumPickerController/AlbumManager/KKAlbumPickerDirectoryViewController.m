//
//  KKAlbumPickerDirectoryViewController.m
//  Demo
//
//  Created by beartech on 14-9-10.
//  Copyright (c) 2014年 liubo. All rights reserved.
//

#import "KKAlbumPickerDirectoryViewController.h"
#import "AlbumManager.h"
#import "KKAlbumPickerPhotoViewController.h"

@interface KKAlbumPickerDirectoryViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain)UITableView *table;
@property(nonatomic,retain)NSMutableArray *dataSource;

@property (nonatomic,assign)NSInteger numberOfPhotosNeedSelected;
@property (nonatomic,assign)BOOL editEnable;//是否可以编辑 (当numberOfPhotosNeedSelected=1时 有效)
@property (nonatomic,assign)CGSize cropSize;//裁剪大小（当editEnable为YES的时候有效）
@property (nonatomic,assign)BOOL pushToGroupSavedPhotos;//是否默认进入相机胶卷;
@end

@implementation KKAlbumPickerDirectoryViewController
@synthesize table;
@synthesize dataSource;

@synthesize numberOfPhotosNeedSelected;
@synthesize editEnable;
@synthesize cropSize;
@synthesize pushToGroupSavedPhotos;


- (void)dealloc{
    [table release];
    [dataSource release];
    [super dealloc];
}

/**
 * 1、aNumberNeedSelected 需要选择的照片数量
 * 2、aEditEnable 是否需要编辑功能（仅在aNumberNeedSelected为1的时候有效）
 * 3、aCropSize 编辑的尺寸（仅在aEditEnable为YES的时候有效）
 * 4、aPushToDefaultDirectory 是否需要默认进入“相机胶卷”
 */
- (id)initWithNumberNeedSelected:(NSInteger)aNumberNeedSelected
                      editEnable:(BOOL)aEditEnable
                        cropSize:(CGSize)aCropSize
          pushToDefaultDirectory:(BOOL)aPushToDefaultDirectory{
    
    self = [super init];
    if (self) {
        numberOfPhotosNeedSelected = aNumberNeedSelected;
        editEnable = aEditEnable;
        if (CGSizeEqualToSize(aCropSize, CGSizeZero)) {
            cropSize = CGSizeMake(200, 200);
        }
        else{
            cropSize = aCropSize;
        }
        pushToGroupSavedPhotos = aPushToDefaultDirectory;
    }
    else{
    }
    return self;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = languageStringWithKey(@"照片");
    dataSource = [[NSMutableArray alloc] init];

//    [self setNavRightButtonTitle:@"取消" selector:@selector(navigationControllerDismiss)];    
    
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-44) style:UITableViewStylePlain];
    table.backgroundColor = [UIColor whiteColor];
    table.backgroundView.backgroundColor = [UIColor whiteColor];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    
    [[AlbumManager defaultManager] loadAlbumDirectoryWithFinishedBlock:^(NSArray *Albums) {
        [dataSource removeAllObjects];
        [dataSource addObjectsFromArray:Albums];
        [table reloadData];
        if (pushToGroupSavedPhotos && [dataSource count]>0) {
            KKAlbumPickerPhotoViewController *photoViewController = [[KKAlbumPickerPhotoViewController alloc] initWithAssetsGroup:[dataSource firstObject] numberNeedSelected:MAX(numberOfPhotosNeedSelected, 1) editEnable:editEnable cropSize:cropSize pushToDefaultDirectory:pushToGroupSavedPhotos];
            [self.navigationController pushViewController:photoViewController animated:NO];
            [photoViewController release];
        }
    }];
    
}

- (void)navgationControllerDissMiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark ==================================================
#pragma mark == UITableViewDataSource
#pragma mark ==================================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 70, 70)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.tag = 1101;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:imageView];
        [imageView release];
        
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, [[UIScreen mainScreen] bounds].size.width-90-25, 40)];
        mainLabel.font = ThemeFontLarge;
        mainLabel.tag = 1102;
        mainLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:mainLabel];
        [mainLabel release];
        
        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 50, [[UIScreen mainScreen] bounds].size.width-90-25, 30)];
        subLabel.font = ThemeFontLarge;
        subLabel.tag = 1103;
        subLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:subLabel];
        [subLabel release];
    }
    
    UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:1101];
    UILabel *mainLabel = (UILabel*)[cell.contentView viewWithTag:1102];
    UILabel *subLabel = (UILabel*)[cell.contentView viewWithTag:1103];
    
    NSObject *object = [dataSource objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = (ALAssetsGroup*)object;
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        NSString *numberOfAssets = [NSString stringWithInteger:[group numberOfAssets]];
        
        mainLabel.text = groupName;
        subLabel.text = numberOfAssets;
        
        if ([numberOfAssets integerValue]==0) {
            imageView.image = nil;
        }
        else{
            UIImage* posterImage = [UIImage imageWithCGImage: group.posterImage];
            imageView.image = posterImage;
        }
    }
    else if ([object isKindOfClass:[PHAssetCollection class]]){
        PHAssetCollection *group = (PHAssetCollection*)object;
        NSString *groupName = group.localizedTitle;
        
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:group options:nil];
        NSString *numberOfAssets = [NSString stringWithInteger:[result count]];

        mainLabel.text = groupName;
        subLabel.text = numberOfAssets;
        
        if ([numberOfAssets integerValue]==0) {
            imageView.image = nil;
        }
        else{
            if ([result count]>0) {
                PHAsset *asset = [result lastObject];
                PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
                [imageManager requestImageForAsset:asset
                                        targetSize:CGSizeMake(imageView.bounds.size.width*3, imageView.bounds.size.height*3)
                                       contentMode:PHImageContentModeAspectFill
                                           options:nil
                                     resultHandler:^(UIImage *result, NSDictionary *info) {
                                         imageView.contentMode = UIViewContentModeScaleAspectFill;
                                         imageView.image = result;
                                     }];
                [imageManager release];
            }
            else{
                imageView.image = nil;
            }
        }
    }
    else{
        imageView.image = nil;
        mainLabel.text = @"";
        subLabel.text = @"";
    }
    
    return cell;
}

#pragma mark ==================================================
#pragma mark == UITableViewDelegate
#pragma mark ==================================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KKAlbumPickerPhotoViewController *photoViewController = [[KKAlbumPickerPhotoViewController alloc] initWithAssetsGroup:[dataSource objectAtIndex:indexPath.row] numberNeedSelected:numberOfPhotosNeedSelected editEnable:editEnable cropSize:cropSize pushToDefaultDirectory:pushToGroupSavedPhotos];
    [self.navigationController pushViewController:photoViewController animated:YES];
    [photoViewController release];
}


@end
