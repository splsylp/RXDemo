//
//  RX_TZAssetModel.h
//  RX_TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TZAssetModelMediaTypePhoto = 0,
    TZAssetModelMediaTypeLivePhoto,
    TZAssetModelMediaTypePhotoGif,
    TZAssetModelMediaTypeVideo,
    TZAssetModelMediaTypeAudio
} TZAssetModelMediaType;

@class PHAsset;
@interface RX_TZAssetModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL isSelected;      ///< The select status of a photo, default is No
@property (nonatomic, assign) TZAssetModelMediaType type;
@property (assign, nonatomic) BOOL needOscillatoryAnimation;
@property (nonatomic, copy) NSString *timeLength;
@property (strong, nonatomic) UIImage *cachedImage;

/// Init a photo dataModel With a PHAsset
/// 用一个PHAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(TZAssetModelMediaType)type;
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(TZAssetModelMediaType)type timeLength:(NSString *)timeLength;

@end


@class PHFetchResult;
@interface RX_TZAlbumModel : NSObject

@property (nonatomic, strong) NSString *rxname;        ///< The album name
@property (nonatomic, assign) NSInteger rxcount;       ///< Count of photos the album contain
@property (nonatomic, strong) PHFetchResult *rxresult;

@property (nonatomic, strong) NSArray *rxmodels;
@property (nonatomic, strong) NSArray *rxselectedModels;
@property (nonatomic, assign) NSUInteger rxselectedCount;

@property (nonatomic, assign) BOOL rxisCameraRoll;

- (void)rxsetResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets;

@end
