//
//  RX_TZPhotoPreviewCell.m
//  RX_TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "RX_TZPhotoPreviewCell.h"
#import "RX_TZAssetModel.h"
#import "UIView+RX_Layout.h"
#import "RX_TZImageManager.h"
#import "RX_TZProgressView.h"
#import "RX_TZImageCropManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "RX_TZImagePickerController.h"

@implementation RX_TZAssetPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self configSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoPreviewCollectionViewDidScroll) name:@"photoPreviewCollectionViewDidScroll" object:nil];
    }
    return self;
}

- (void)configSubviews {
    
}

#pragma mark - Notification

- (void)photoPreviewCollectionViewDidScroll {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@implementation RX_TZPhotoPreviewCell

- (void)configSubviews {
    self.rxpreviewView = [[RX_TZPhotoPreviewView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    [self.rxpreviewView setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.singleTapGestureBlock) {
            strongSelf.singleTapGestureBlock();
        }
    }];
    [self.rxpreviewView setImageProgressUpdateBlock:^(double progress) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.imageProgressUpdateBlock) {
            strongSelf.imageProgressUpdateBlock(progress);
        }
    }];
    [self addSubview:self.rxpreviewView];
}

- (void)setModel:(RX_TZAssetModel *)model {
    [super setModel:model];
    _rxpreviewView.asset = model.asset;
}

- (void)recoverSubviews {
    [_rxpreviewView recoverSubviews];
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = allowCrop;
    _rxpreviewView.allowCrop = allowCrop;
}

- (void)setCropRect:(CGRect)cropRect {
    _cropRect = cropRect;
    _rxpreviewView.cropRect = cropRect;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.rxpreviewView.frame = self.bounds;
}

@end


@interface RX_TZPhotoPreviewView ()<UIScrollViewDelegate>
@property (assign, nonatomic) BOOL isRequestingGIF;
@end

@implementation RX_TZPhotoPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        if (@available(iOS 11, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:_scrollView];
        
        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
        _imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
        [_scrollView addSubview:_imageContainerView];
        
        _imageView = [[FLAnimatedImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [_imageContainerView addSubview:_imageView];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
        
        [self configProgressView];
    }
    return self;
}

- (void)configProgressView {
    _progressView = [[RX_TZProgressView alloc] init];
    _progressView.hidden = YES;
    [self addSubview:_progressView];
}

- (void)setModel:(RX_TZAssetModel *)model {
    _model = model;
    self.isRequestingGIF = NO;
    [_scrollView setZoomScale:1.0 animated:NO];
    if (model.type == TZAssetModelMediaTypePhotoGif) {
        // 先显示缩略图
        [[RX_TZImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            self.imageView.image = photo;
            [self resizeSubviews];
            if (self.isRequestingGIF) {
                return;
            }
            // 再显示gif动图
            self.isRequestingGIF = YES;
            [[RX_TZImageManager manager] getOriginalPhotoDataWithAsset:model.asset progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                progress = progress > 0.02 ? progress : 0.02;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.progressView.progress = progress;
                    if (progress >= 1) {
                        self.progressView.hidden = YES;
                    } else {
                        self.progressView.hidden = NO;
                    }
                });
#ifdef DEBUG
                NSLog(@"[RX_TZImagePickerController] getOriginalPhotoDataWithAsset:%f error:%@", progress, error);
#endif
            } completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                if (!isDegraded) {
                    self.isRequestingGIF = NO;
                    self.progressView.hidden = YES;
                    self.imageView.image = [UIImage sd_tz_animatedGIFWithData:data];
                    FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
                    self.imageView.animatedImage = animatedImage;
                    [self resizeSubviews];
                    [self resizeSubviews];
                }
            }];
        } progressHandler:nil networkAccessAllowed:NO];
    } else {
        self.asset = model.asset;
    }
}

- (void)setAsset:(PHAsset *)asset {
    if (_asset && self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    
    _asset = asset;
    self.imageRequestID = [[RX_TZImageManager manager] getPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (![asset isEqual:self->_asset]) return;
        self.imageView.image = photo;
        [self resizeSubviews];
        self->_progressView.hidden = YES;
        if (self.imageProgressUpdateBlock) {
            self.imageProgressUpdateBlock(1);
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        if (![asset isEqual:self->_asset]) return;
        self->_progressView.hidden = NO;
        [self bringSubviewToFront:self->_progressView];
        progress = progress > 0.02 ? progress : 0.02;
        self->_progressView.progress = progress;
        if (self.imageProgressUpdateBlock && progress < 1) {
            self.imageProgressUpdateBlock(progress);
        }
        
        if (progress >= 1) {
            self->_progressView.hidden = YES;
            self.imageRequestID = 0;
        }
    } networkAccessAllowed:YES];
}

- (void)recoverSubviews {
    [_scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    _imageContainerView.tz_origin = CGPointZero;
    _imageContainerView.tz_width = self.scrollView.tz_width;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.tz_height / self.scrollView.tz_width) {
        _imageContainerView.tz_height = floor(image.size.height / (image.size.width / self.scrollView.tz_width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.scrollView.tz_width;
        if (height < 1 || isnan(height)) height = self.tz_height;
        height = floor(height);
        _imageContainerView.tz_height = height;
        _imageContainerView.tz_centerY = self.tz_height / 2;
    }
    if (_imageContainerView.tz_height > self.tz_height && _imageContainerView.tz_height - self.tz_height <= 1) {
        _imageContainerView.tz_height = self.tz_height;
    }
    CGFloat contentSizeH = MAX(_imageContainerView.tz_height, self.tz_height);
    _scrollView.contentSize = CGSizeMake(self.scrollView.tz_width, contentSizeH);
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageContainerView.tz_height <= self.tz_height ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
    
    [self refreshScrollViewContentSize];
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = allowCrop;
    _scrollView.maximumZoomScale = allowCrop ? 4.0 : 2.5;
    
    if ([self.asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)self.asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        // 优化超宽图片的显示
        if (aspectRatio > 1.5) {
            self.scrollView.maximumZoomScale *= aspectRatio / 1.5;
        }
    }
}

- (void)refreshScrollViewContentSize {
    if (_allowCrop) {
        // 1.7.2 如果允许裁剪,需要让图片的任意部分都能在裁剪框内，于是对_scrollView做了如下处理：
        // 1.让contentSize增大(裁剪框右下角的图片部分)
        CGFloat contentWidthAdd = self.scrollView.tz_width - CGRectGetMaxX(_cropRect);
        CGFloat contentHeightAdd = (MIN(_imageContainerView.tz_height, self.tz_height) - self.cropRect.size.height) / 2;
        CGFloat newSizeW = self.scrollView.contentSize.width + contentWidthAdd;
        CGFloat newSizeH = MAX(self.scrollView.contentSize.height, self.tz_height) + contentHeightAdd;
        _scrollView.contentSize = CGSizeMake(newSizeW, newSizeH);
        _scrollView.alwaysBounceVertical = YES;
        // 2.让scrollView新增滑动区域（裁剪框左上角的图片部分）
        if (contentHeightAdd > 0 || contentWidthAdd > 0) {
            _scrollView.contentInset = UIEdgeInsetsMake(contentHeightAdd, _cropRect.origin.x, 0, 0);
        } else {
            _scrollView.contentInset = UIEdgeInsetsZero;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = CGRectMake(10, 0, self.tz_width - 20, self.tz_height);
    static CGFloat progressWH = 40;
    CGFloat progressX = (self.tz_width - progressWH) / 2;
    CGFloat progressY = (self.tz_height - progressWH) / 2;
    _progressView.frame = CGRectMake(progressX, progressY, progressWH, progressWH);
    
    [self recoverSubviews];
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self refreshScrollViewContentSize];
}

#pragma mark - Private

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.tz_width > _scrollView.contentSize.width) ? ((_scrollView.tz_width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.tz_height > _scrollView.contentSize.height) ? ((_scrollView.tz_height - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageContainerView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}

@end


@implementation RX_TZVideoPreviewCell

- (void)configSubviews {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)configPlayButton {
    if (_rxPlayButton) {
        [_rxPlayButton removeFromSuperview];
    }
    _rxPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rxPlayButton setImage:[UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
    [_rxPlayButton setImage:[UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlayHL"] forState:UIControlStateHighlighted];
    [_rxPlayButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rxPlayButton];
}

- (void)setModel:(RX_TZAssetModel *)model {
    [super setModel:model];
    [self configMoviePlayer];
}

- (void)configMoviePlayer {
    if (_rxPlayer) {
        [_rxPlayerLayer removeFromSuperlayer];
        _rxPlayerLayer = nil;
        [_rxPlayer pause];
        _rxPlayer = nil;
    }
    
    [[RX_TZImageManager manager] getPhotoWithAsset:self.model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        self->_rxCover = photo;
    }];
    [[RX_TZImageManager manager] getVideoWithAsset:self.model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_rxPlayer = [AVPlayer playerWithPlayerItem:playerItem];
            self->_rxPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self->_rxPlayer];
            self->_rxPlayerLayer.backgroundColor = [UIColor blackColor].CGColor;
            self->_rxPlayerLayer.frame = self.bounds;
            [self.layer addSublayer:self->_rxPlayerLayer];
            [self configPlayButton];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self->_rxPlayer.currentItem];
        });
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _rxPlayerLayer.frame = self.bounds;
    _rxPlayButton.frame = CGRectMake(0, 64, self.tz_width, self.tz_height - 64 - 44);
}

- (void)photoPreviewCollectionViewDidScroll {
    [self pausePlayerAndShowNaviBar];
}

#pragma mark - Click Event

- (void)playButtonClick {
    CMTime currentTime = _rxPlayer.currentItem.currentTime;
    CMTime durationTime = _rxPlayer.currentItem.duration;
    if (_rxPlayer.rate == 0.0f) {
        if (currentTime.value == durationTime.value) [_rxPlayer.currentItem seekToTime:CMTimeMake(0, 1)];
        [_rxPlayer play];
        [_rxPlayButton setImage:nil forState:UIControlStateNormal];
        [UIApplication sharedApplication].statusBarHidden = YES;
        if (self.singleTapGestureBlock) {
            self.singleTapGestureBlock();
        }
    } else {
        [self pausePlayerAndShowNaviBar];
    }
}

- (void)pausePlayerAndShowNaviBar {
    if (_rxPlayer.rate != 0.0) {
        [_rxPlayer pause];
        [_rxPlayButton setImage:[UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
        if (self.singleTapGestureBlock) {
            self.singleTapGestureBlock();
        }
    }
}

@end


@implementation RX_TZGifPreviewCell

- (void)configSubviews {
    [self configPreviewView];
}

- (void)configPreviewView {
    _rxpreviewView = [[RX_TZPhotoPreviewView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    [_rxpreviewView setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf signleTapAction];
    }];
    [self addSubview:_rxpreviewView];
}

- (void)setModel:(RX_TZAssetModel *)model {
    [super setModel:model];
    _rxpreviewView.model = self.model;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _rxpreviewView.frame = self.bounds;
}

#pragma mark - Click Event

- (void)signleTapAction {    
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

@end
