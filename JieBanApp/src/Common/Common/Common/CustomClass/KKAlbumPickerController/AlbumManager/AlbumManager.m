//
//  AlbumManager.m
//  Artup
//
//  Created by beartech on 13-10-23.
//  Copyright (c) 2013年 Artup. All rights reserved.
//

#import "AlbumManager.h"

//NSString *const AlbumManager_ALAssetsLibraryChangedNotification = @"AlbumManager_ALAssetsLibraryChangedNotification";

@interface AlbumManager ()

//@property (nonatomic,retain)ALAssetsLibrary* defaultAssetsLibrary;

@end


@implementation AlbumManager
//@synthesize defaultAssetsLibrary;

+ (AlbumManager *)defaultManager{
    static AlbumManager *sharedKKShareSinaInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedKKShareSinaInstance =  [[AlbumManager alloc] init];
    });
    return sharedKKShareSinaInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
//        [self observeNotificaiton:ALAssetsLibraryChangedNotification selector:@selector(Notification_ALAssetsLibraryChanged:)];
//
//        [self observeNotificaiton:UIApplicationDidBecomeActiveNotification selector:@selector(applicationDidBecomeActive:)];
    }
    return self;
}

- (void)Notification_ALAssetsLibraryChanged:(NSNotification*)aNotification{
//    [allAlbumDirectory removeAllObjects];
//    [self loadAlbumDirectoryWithFinishedBlock:^(NSArray *Albums) {
//        [allAlbumDirectory addObject:Albums];
//    }];
}

/*
 切换到前台
 */
- (void)applicationDidBecomeActive:(NSNotification *)notification{
//    [allAlbumDirectory removeAllObjects];
//    [self loadAlbumDirectoryWithFinishedBlock:^(NSArray *Albums) {
//        [allAlbumDirectory addObject:Albums];
//    }];
}


#pragma mark ==================================================
#pragma mark == 遍历所有目录
#pragma mark ==================================================
- (void)loadAlbumDirectoryWithFinishedBlock:(AlbumManagerLoadAlbumFinishedBlock)finishedBlock{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        [self loadAlbumDirectory_WithFinishedBlock:finishedBlock];
    }
    else{
        [self loadAlbumDirectory_WithFinishedBlock:finishedBlock];
    }
}

/**
 * ios7以及以前的，就用此方法从ALAssetsLibrary里面读取
 */
- (void)loadAlbumDirectory_WithFinishedBlock:(AlbumManagerLoadAlbumFinishedBlock)finishedBlock{
    
    //    __block NSMutableArray *subDataSource = nil;
    __block NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    //检查是否授权Block
    ALAssetsLibraryAccessFailureBlock failureblock01 = ^(NSError *myerror){
        if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
            finishedBlock([NSMutableArray array]);
        }else{
            finishedBlock([NSMutableArray array]);
        }
    };
    
    //遍历目录里面的照片的Block
    ALAssetsLibraryGroupsEnumerationResultsBlock  libraryGroupsEnumeration01 = ^(ALAssetsGroup* group, BOOL* stop){
        
        if (group != nil){
            //过滤出所有的照片
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            [dataSource addObject:group];
            
            //            /*相册名字*/
            //            NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            //            /*
            //             NSString *groupPersistentID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
            //             NSString *groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
            //             */
            //
            //            /*内容数量*/
            //            NSString *numberOfAssets = [NSString stringWithInteger:[group numberOfAssets]];
            //
            //            /*封面图片*/
            //            UIImage* posterImage = [UIImage imageWithCGImage: group.posterImage];
            //            if (posterImage && [posterImage isKindOfClass:[UIImage class]]) {
            //                [dic setObject:image forKey:AlbumManagerKey_groupPosterImage];
            //            }
            //
            //            if (subDataSource) {
            //                [subDataSource removeAllObjects];
            //            }
            //            else{
            //                subDataSource = [[NSMutableArray alloc] init];
            //            }
            //
            //            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            //                                        subDataSource,AlbumManagerKey_groupImages,
            //                                        groupName,AlbumManagerKey_groupName,
            //                                        groupType,AlbumManagerKey_groupImagesCount,
            //                                        nil];
            //            UIImage* image = [UIImage imageWithCGImage: group.posterImage];
            //            if (image && [image isKindOfClass:[UIImage class]]) {
            //                [dic setObject:image forKey:AlbumManagerKey_groupPosterImage];
            //            }
            //            [dataSource addObject:dic];
            //
            //            [subDataSource release];
            //            subDataSource = nil;
        }
        else{
            finishedBlock([[dataSource reverseObjectEnumerator] allObjects]);
            dataSource = nil;
        }
    };
    
    //开始解析
    ALAssetsLibrary* defaultAssetsLibrary = [[ALAssetsLibrary alloc] init];
    [defaultAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                        usingBlock:libraryGroupsEnumeration01
                                      failureBlock:failureblock01];
    
    //ALAssetsGroupLibrary 照片图库
    //ALAssetsGroupAlbum 美颜相机、出差北京
    //ALAssetsGroupEvent
    //ALAssetsGroupFaces
    //ALAssetsGroupSavedPhotos 相机胶卷
    //ALAssetsGroupPhotoStream
    //ALAssetsGroupAll 美颜相机、出差北京、相机胶卷
}

/**
 * ios8以及以后的，就用此方法从PhotoKit里面读取
 */
- (void)loadAlbumDirectoryPhotoKit_WithFinishedBlock:(AlbumManagerLoadAlbumFinishedBlock)finishedBlock{
    /* 暂时未实现 */
    
//    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];

    NSMutableArray *dataSource = [NSMutableArray array];

    
    NSArray *subTypeArray = [self assetCollectionSubtypes];
    for (NSNumber *subtypeNumber in subTypeArray)
    {
        PHAssetCollectionSubtype subtype = subtypeNumber.integerValue;
        PHAssetCollectionType type = (subtype >= PHAssetCollectionSubtypeSmartAlbumGeneric) ? PHAssetCollectionTypeSmartAlbum : PHAssetCollectionTypeAlbum;

        PHFetchResult *fetchResult =
        [PHAssetCollection fetchAssetCollectionsWithType:type
                                                 subtype:subtype
                                                 options:nil];

        for (NSInteger i=0; i<[fetchResult count]; i++) {
            PHAssetCollection *collection = fetchResult[i];
            PHFetchResult *fetchResult2 = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            NSInteger count =0;
            for (NSInteger i=0; i<[fetchResult2 count]; i++) {
                PHAsset *asset = [fetchResult2 objectAtIndex:i];
                //只筛选照片
                if ([asset mediaType]==PHAssetMediaTypeImage) {
                    count++;
                }
            }
            if (count>0) {
                [dataSource addObject:collection];
            }
        }
    }

    finishedBlock(dataSource);

    
//        NSString *count = [NSString stringWithFormat:@"%ld",(long)[fetchResult2  count]];
//        NSString *title = [self transformAblumTitle:collection.localizedTitle];
//        
//        PHAsset *asset = [fetchResult2 lastObject];
//        // Request an image for the asset from the PHCachingImageManager.
//        [imageManager requestImageForAsset:asset
//                                targetSize:CGSizeMake(10000, 10000)
//                               contentMode:PHImageContentModeAspectFill
//                                   options:nil
//                             resultHandler:^(UIImage *result, NSDictionary *info) {
//                                 // Set the cell's thumbnail image if it's still showing the same asset.
//                                 cell.imageView.image = result;
//                             }];

//    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
//    for (NSInteger i=0; i<[topLevelUserCollections count]; i++) {
//        PHAssetCollection *collection = topLevelUserCollections[i];
//        PHFetchResult *fetchResult2 = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
//        if ([fetchResult2 count]>0) {
//            [dataSource addObject:collection];
//        }
//    }
    
}

- (NSArray *)assetCollectionSubtypes{

    NSMutableArray *assetCollectionSubtypes = [NSMutableArray array];
    
    /* PHAssetCollectionTypeSmartAlbum subtypes */
    //209相机胶卷
    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumUserLibrary]];
    //203个人收藏
    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumFavorites]];
    //206最近添加
    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded]];
    //200
//    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumGeneric]];
    //201全景照片
    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumPanoramas]];
    //202视频
//    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumVideos]];
    //204延时摄影
//    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumTimelapses]];
    //205隐藏
//    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumAllHidden]];
    //207
//    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumBursts]];
    //208慢动作
//    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumSlomoVideos]];
//    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=9.0) {
//        [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumSelfPortraits]];
//        [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumScreenshots]];
//    }
    
    /*PHAssetCollectionTypeAlbum regular subtypes */
    //2
    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumRegular]];
    //3
    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumSyncedEvent]];
    //4
    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumSyncedFaces]];
    //5
    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumSyncedAlbum]];
    //6
    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumImported]];
    
    /* PHAssetCollectionTypeAlbum shared subtypes */
    //100
    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumMyPhotoStream]];
    //101
    [assetCollectionSubtypes addObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumCloudShared]];

    return assetCollectionSubtypes;
    
    /**
     // PHAssetCollectionTypeAlbum regular subtypes
     PHAssetCollectionSubtypeAlbumRegular         = 2,
     PHAssetCollectionSubtypeAlbumSyncedEvent     = 3,
     PHAssetCollectionSubtypeAlbumSyncedFaces     = 4,
     PHAssetCollectionSubtypeAlbumSyncedAlbum     = 5,
     PHAssetCollectionSubtypeAlbumImported        = 6,
     
     // PHAssetCollectionTypeAlbum shared subtypes
     PHAssetCollectionSubtypeAlbumMyPhotoStream   = 100,
     PHAssetCollectionSubtypeAlbumCloudShared     = 101,
     
     // PHAssetCollectionTypeSmartAlbum subtypes
     PHAssetCollectionSubtypeSmartAlbumGeneric    = 200,
     PHAssetCollectionSubtypeSmartAlbumPanoramas  = 201,
     PHAssetCollectionSubtypeSmartAlbumVideos     = 202,
     PHAssetCollectionSubtypeSmartAlbumFavorites  = 203,
     PHAssetCollectionSubtypeSmartAlbumTimelapses = 204,
     PHAssetCollectionSubtypeSmartAlbumAllHidden  = 205,
     PHAssetCollectionSubtypeSmartAlbumRecentlyAdded = 206,
     PHAssetCollectionSubtypeSmartAlbumBursts     = 207,
     PHAssetCollectionSubtypeSmartAlbumSlomoVideos = 208,
     PHAssetCollectionSubtypeSmartAlbumUserLibrary = 209,
     PHAssetCollectionSubtypeSmartAlbumSelfPortraits NS_AVAILABLE_IOS(9_0) = 210,
     PHAssetCollectionSubtypeSmartAlbumScreenshots NS_AVAILABLE_IOS(9_0) = 211,
     */
}

- (NSString *)transformAblumTitle:(NSString *)title
{
    if ([title isEqualToString:@"Slo-mo"]) {
        return languageStringWithKey(@"慢动作");
    } else if ([title isEqualToString:@"Recently Added"]) {
        return languageStringWithKey(@"最近添加");
    } else if ([title isEqualToString:@"Favorites"]) {
        return languageStringWithKey(@"最爱");
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return languageStringWithKey(@"最近删除");
    } else if ([title isEqualToString:@"Videos"]) {
        return languageStringWithKey(@"视频");
    } else if ([title isEqualToString:@"All Photos"]) {
        return languageStringWithKey(@"所有照片");
    } else if ([title isEqualToString:@"Selfies"]) {
        return languageStringWithKey(@"自拍");
    } else if ([title isEqualToString:@"Screenshots"]) {
        return languageStringWithKey(@"屏幕快照");
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return languageStringWithKey(@"相机胶卷");
    } else if ([title isEqualToString:@"Panoramas"]) {
        return languageStringWithKey(@"全景照片");
    }
    else{
        return title;
    }
}


#pragma mark ==================================================
#pragma mark == 遍历某个目录的所有照片
#pragma mark ==================================================
- (void)loadAlbumPhotosWithALAssetsGroupGroup:(ALAssetsGroup*)group finishedBlock:(AlbumManagerLoadAlbumAssetsFinishedBlock)finishedBlock{
    
    __block NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    //遍历照片的Block
    ALAssetsGroupEnumerationResultsBlock groupEnumerAtion01 = ^(ALAsset *result, NSUInteger index, BOOL *stop){
        if (result!=NULL) {
            /*
             DDLogInfo(@"ALAssetPropertyType:  %@",[result valueForProperty:ALAssetPropertyType]);
             DDLogInfo(@"ALAssetPropertyLocation:  %@",[result valueForProperty:ALAssetPropertyLocation]);
             DDLogInfo(@"ALAssetPropertyDuration:  %@",[result valueForProperty:ALAssetPropertyDuration]);
             DDLogInfo(@"ALAssetPropertyOrientation:  %@",[result valueForProperty:ALAssetPropertyOrientation]);
             DDLogInfo(@"ALAssetPropertyDate:  %@",[result valueForProperty:ALAssetPropertyDate]);
             DDLogInfo(@"ALAssetPropertyRepresentations:  %@",[result valueForProperty:ALAssetPropertyRepresentations]);
             DDLogInfo(@"ALAssetPropertyURLs:  %@",[result valueForProperty:ALAssetPropertyURLs]);
             DDLogInfo(@"ALAssetPropertyAssetURL:  %@",[result valueForProperty:ALAssetPropertyAssetURL]);
             DDLogInfo(@"URL:  %@",result.defaultRepresentation.url);
             DDLogInfo(@"Name:  %@",result.defaultRepresentation.filename);
             */
            
            //图片
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                [dataSource addObject:result];
            }
            //视频
            else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
                
            }
            //未知
            else{
                
            }
        }
        else{
            finishedBlock(dataSource);
        }
    };
    
    [group enumerateAssetsUsingBlock:groupEnumerAtion01];
}



#pragma mark ==================================================
#pragma mark == 根据地址读取图片
#pragma mark ==================================================
+ (void)loadAlbumThumbnailImageWithURL:(NSURL*)url resultBlock:(AlbumManagerLoadAlbumImageFinishedBlock)finishedBlock failureBlock:(AlbumManagerLoadAlbumImageFailureBlock)failureBlock{
    
    // 为了防止界面卡住，可以异步执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        //------------------------根据图片的url反取图片－－－－－
        __block ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
            
            UIImage *image=[UIImage imageWithCGImage:asset.thumbnail];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (finishedBlock) {
                    finishedBlock(image);
                }
            });
            
            [assetLibrary release];
            assetLibrary = nil;
            
        }failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock) {
                    failureBlock(error);
                }
            });
            [assetLibrary release];
            assetLibrary = nil;
        }];
        //－－－－－－－－－－－－－－－－－－－－－

    });
}

+ (void)loadAlbumFullScreenImageWithURL:(NSURL*)url resultBlock:(AlbumManagerLoadAlbumImageFinishedBlock)finishedBlock failureBlock:(AlbumManagerLoadAlbumImageFailureBlock)failureBlock{
    
    // 为了防止界面卡住，可以异步执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //------------------------根据图片的url反取图片－－－－－
        __block ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
            UIImage *image=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (finishedBlock) {
                    finishedBlock(image);
                }
            });
            
            [assetLibrary release];
            assetLibrary = nil;
            
        }failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock) {
                    failureBlock(error);
                }
            });
            [assetLibrary release];
            assetLibrary = nil;
        }];
    });

}

+ (void)loadAlbumFullResolutionImageWithURL:(NSURL*)url resultBlock:(AlbumManagerLoadAlbumImageFinishedBlock)finishedBlock failureBlock:(AlbumManagerLoadAlbumImageFailureBlock)failureBlock{
    
    // 为了防止界面卡住，可以异步执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //------------------------根据图片的url反取图片－－－－－
        __block ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
            
            UIImage *image=[UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (finishedBlock) {
                    finishedBlock(image);
                }
            });
            
            [assetLibrary release];
            assetLibrary = nil;
        }failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock) {
                    failureBlock(error);
                }
            });
            [assetLibrary release];
            assetLibrary = nil;
        }];
        //－－－－－－－－－－－－－－－－－－－－－
    });

    
}



@end
