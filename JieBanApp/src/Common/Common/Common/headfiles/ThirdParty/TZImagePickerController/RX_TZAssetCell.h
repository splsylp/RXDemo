//
//  RX_TZAssetCell.h
//  RX_TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    TZAssetCellTypePhoto = 0,
    TZAssetCellTypeLivePhoto,
    TZAssetCellTypePhotoGif,
    TZAssetCellTypeVideo,
    TZAssetCellTypeAudio,
} TZAssetCellType;

@class RX_TZAssetModel;
@interface RX_TZAssetCell : UICollectionViewCell
@property (weak, nonatomic) UIButton *selectPhotoButton;
@property (weak, nonatomic) UIButton *cannotSelectLayerButton;
@property (nonatomic, strong) RX_TZAssetModel *model;
@property (assign, nonatomic) NSInteger index;
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);
@property (nonatomic, assign) TZAssetCellType type;
@property (nonatomic, assign) BOOL allowPickingGif;
@property (nonatomic, assign) BOOL allowPickingMultipleVideo;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) int32_t imageRequestID;

@property (nonatomic, strong) UIImage *photoSelImage;
@property (nonatomic, strong) UIImage *photoDefImage;

@property (nonatomic, assign) BOOL showSelectBtn;
@property (assign, nonatomic) BOOL allowPreview;
@property (assign, nonatomic) BOOL useCachedImage;

@property (nonatomic, copy) void (^rxassetCellDidSetModelBlock)(RX_TZAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView);
@property (nonatomic, copy) void (^assetCellDidLayoutSubviewsBlock)(RX_TZAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView);
@end


@class RX_TZAlbumModel;
@interface RX_TZAlbumCell : UITableViewCell
@property (nonatomic, strong) RX_TZAlbumModel *rxmodel;
@property (weak, nonatomic) UIButton *rxselectedCountButton;

@property (nonatomic, copy) void (^rxalbumCellDidSetModelBlock)(RX_TZAlbumCell *cell, UIImageView *posterImageView, UILabel *titleLabel);
@property (nonatomic, copy) void (^albumCellDidLayoutSubviewsBlock)(RX_TZAlbumCell *cell, UIImageView *posterImageView, UILabel *titleLabel);
@end


@interface RX_TZAssetCameraCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *rximageView;
@end
