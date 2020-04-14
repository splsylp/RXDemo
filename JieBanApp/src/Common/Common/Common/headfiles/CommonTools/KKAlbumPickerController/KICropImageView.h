//
//  KICropImageView.h
//  Kitalker
//
//  Created by 刘 波 on 12-8-9.
//
//

#import <UIKit/UIKit.h>

@class KICropImageMaskView;
@interface KICropImageView : UIView <UIScrollViewDelegate> {
    @private
    UIScrollView        *_scrollView;
    UIImageView         *_imageView;
    KICropImageMaskView *_maskView;
    UIImage             *_image;
    UIEdgeInsets        _imageInset;
    CGSize              _cropSize;
}

- (void)setImage:(UIImage *)image;
- (void)setCropSize:(CGSize)size;

- (UIImage *)cropImage;

@end