//
//  RX_TZPhotoPreviewCell.h
//  RX_TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RX_TZAssetModel;
@interface RX_TZAssetPreviewCell : UICollectionViewCell
@property (nonatomic, strong) RX_TZAssetModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
- (void)configSubviews;
- (void)photoPreviewCollectionViewDidScroll;
@end


@class RX_TZAssetModel,RX_TZProgressView,RX_TZPhotoPreviewView;
@interface RX_TZPhotoPreviewCell : RX_TZAssetPreviewCell

@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);

@property (nonatomic, strong) RX_TZPhotoPreviewView *rxpreviewView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

- (void)recoverSubviews;

@end


@interface RX_TZPhotoPreviewView : UIView
@property (nonatomic, strong) FLAnimatedImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) RX_TZProgressView *progressView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, strong) RX_TZAssetModel *model;
@property (nonatomic, strong) id asset;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);

@property (nonatomic, assign) int32_t imageRequestID;

- (void)recoverSubviews;
@end


@class AVPlayer, AVPlayerLayer;
@interface RX_TZVideoPreviewCell : RX_TZAssetPreviewCell
@property (strong, nonatomic) AVPlayer *rxPlayer;
@property (strong, nonatomic) AVPlayerLayer *rxPlayerLayer;
@property (strong, nonatomic) UIButton *rxPlayButton;
@property (strong, nonatomic) UIImage *rxCover;
- (void)pausePlayerAndShowNaviBar;
@end


@interface RX_TZGifPreviewCell : RX_TZAssetPreviewCell
@property (strong, nonatomic) RX_TZPhotoPreviewView *rxpreviewView;
@end
