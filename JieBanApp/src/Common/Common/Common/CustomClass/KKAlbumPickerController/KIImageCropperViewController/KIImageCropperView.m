//
//  KIImageCropView.m
//  Kitalker
//
//  Created by 刘 波 on 13-7-11.
//  
//

#import "KIImageCropperView.h"

#define kMaskViewBorderWidth 2.0f

@interface KIImageCropperMaskView : UIView {
@private
    CGRect  _maskRect;
}
- (void)setMaskSize:(CGSize)size;
- (CGSize)maskSize;
@end

@interface KIImageCropperView() {
    KIImageCropperMaskView  *_maskView;
    UIEdgeInsets            _imageViewInsets;
    CGFloat                 _maskViewZoomScale;
    CGSize                  _maskViewSize;
}

@end

@implementation KIImageCropperView

@synthesize cropRatio   = _cropRatio;
@synthesize cropSize    = _cropSize;
@synthesize image       = _image;
@synthesize padding     = _padding;


- (void)dealloc {
    [_maskView release];
    _maskView = nil;
    [_imageView release];
    _imageView = nil;
    [_scrollView release];
    _scrollView = nil;
    [_image release];
    _image = nil;
    [super dealloc];
}

- (KIImageCropperMaskView *)maskView {
    if (_maskView == nil) {
        _maskView = [[KIImageCropperMaskView alloc] initWithFrame:self.bounds];
        [_maskView setBackgroundColor:[UIColor clearColor]];
        [_maskView setUserInteractionEnabled:NO];
        [self addSubview:_maskView];
        
        [self setBackgroundColor:[UIColor lightGrayColor]];
    }
    [self bringSubviewToFront:_maskView];
    return _maskView;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        [[self scrollView] addSubview:_imageView];
    }
    return _imageView;
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView setBackgroundColor:[UIColor clearColor]];
        [_scrollView setDelegate:self];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self imageView];
}

- (CGFloat)width {
    return CGRectGetWidth(self.bounds);
}

- (CGFloat)height {
    return CGRectGetHeight(self.bounds);
}

- (void)setCropRatio:(KIImageCropRatio)cropRatio {
    if (cropRatio != _cropRatio) {
        _cropRatio = cropRatio;
        [self updateCropSizeWithRatio:_cropRatio];
    }
}

#pragma mark ****************************************
#pragma mark 【根据比例换算出尺寸】
#pragma mark ****************************************

- (void)updateCropSizeWithRatio:(KIImageCropRatio)ratio {
    CGSize size = CGSizeZero;
    /*将宽度和高度分别减去maskView的边框*/
    CGFloat width = [self width];
    CGFloat height = [self height];
    
    switch (ratio) {
        case KIImageCropRatio1_1: {
            height = width;
        }
            break;
        case KIImageCropRatio1_2: {
            width = height / 2.0f;
        }
            break;
        case KIImageCropRatio2_1: {
            height = width / 2.0f;
        }
            break;
        case KIImageCropRatio16_9: {
            height = width / (16.0f / 9.0f);
        }
            break;
        case KIImageCropRatio16_10: {
            height = width / (16.0f / 10.0f);
        }
            break;
        default:
            height = width;
            break;
    }
    
    size = CGSizeMake(width, height);
    _cropSize = size;
    [self setNeedsLayout];
}

#pragma mark ****************************************
#pragma mark 【算出实际的尺寸，除去边距】
#pragma mark ****************************************

- (void)setCropSize:(CGSize)cropSize {
    if (!CGSizeEqualToSize(cropSize, _cropSize)) {
        _cropSize = cropSize;
        _cropRatio = 0;
        [self setNeedsLayout];
    }
}

- (CGSize)cropSize {
    if (CGSizeEqualToSize(_cropSize, CGSizeZero)) {
        _cropSize = CGSizeMake(100, 100);
    }
    return _cropSize;
}

#pragma mark ****************************************
#pragma mark 【计算出maskView的尺寸】
#pragma mark ****************************************

- (CGSize)maskViewSize {
    /*先算出view除去边框和边距剩下的大小*/
    CGFloat viewWidth = [self width]-kMaskViewBorderWidth*2-self.padding.left-self.padding.right;;
    CGFloat viewHeight = [self height]-kMaskViewBorderWidth*2-self.padding.top-self.padding.bottom;
    
    /*取得实际的裁剪尺寸*/
    CGFloat cropWidth = self.cropSize.width;
    CGFloat cropHeight = self.cropSize.height;
    
    CGFloat scaleWidth = viewWidth / cropWidth;
    CGFloat scaleHeight = viewHeight / cropHeight;
    
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    if (scaleWidth < 1 && scaleHeight < 1) {
        minScale = MAX(scaleWidth, scaleHeight);
    }
    minScale = minScale > 1?1:minScale;
    
    _maskViewZoomScale = minScale;
    
    /*取出view和crop两者间最小的尺寸*/
    CGFloat minWidth = MIN(viewWidth, cropWidth)+0.5;
    CGFloat minHeight = MIN(viewHeight, cropHeight)+0.5;
    
    if (scaleWidth < scaleHeight) {
        minHeight *= minScale;
    } else {
        minWidth *= minScale;
    }

    _maskViewSize = CGSizeMake((int)minWidth, (int)minHeight);
    if (self.cropSize.width == self.cropSize.height) {
        /*如果实际裁剪尺寸的长宽相等，则取出最小的一个*/
        _maskViewSize = CGSizeMake((int)MIN(minWidth, minHeight), (int)MIN(minWidth, minHeight));
    }
    
    CGFloat left = (CGRectGetWidth(self.bounds) - _maskViewSize.width) / 2;
    CGFloat top = (CGRectGetHeight(self.bounds) - _maskViewSize.height) / 2;
    CGFloat bottom = CGRectGetHeight(self.bounds) - _maskViewSize.height - top;
    CGFloat right = CGRectGetWidth(self.bounds) - _maskViewSize.width - left;
    
    _imageViewInsets = UIEdgeInsetsMake(top, left, bottom, right);
    
    return _maskViewSize;
}

- (UIEdgeInsets)padding {
    if (UIEdgeInsetsEqualToEdgeInsets(_padding, UIEdgeInsetsZero)) {
        _padding = UIEdgeInsetsMake(5, 5, 5, 5);
    }
    return _padding;
}

- (void)setPadding:(UIEdgeInsets)padding {
    if (!UIEdgeInsetsEqualToEdgeInsets(_padding, padding)) {
        _padding = padding;
        
        [self setNeedsLayout];
    }
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        [_image release];
        _image = [image retain];
        
        [[self imageView] setImage:_image];
        
        [[self imageView] setFrame:CGRectMake(0, 0, _image.size.width, _image.size.height)];
        
        [self setNeedsLayout];
    }
}

- (void)updateZoomScale {
    CGFloat width = _image.size.width;
    CGFloat height = _image.size.height;
    
    CGFloat xScale = _maskViewSize.width / width;
    CGFloat yScale = _maskViewSize.height / height;
    
    CGFloat min = MAX(xScale, yScale);
    CGFloat max = 1.0;
    if (min > max) {
        min = max;
    }
    
    [[self scrollView] setMinimumZoomScale:min];
    [[self scrollView] setMaximumZoomScale:max+5.0f];

    [[self scrollView] setZoomScale:min animated:YES];
    
    [[self scrollView] setContentInset:_imageViewInsets];
    [[self scrollView] setContentOffset:CGPointMake(-_imageViewInsets.left, -_imageViewInsets.top) animated:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [[self maskView] setFrame:self.bounds];
    [(KIImageCropperMaskView *)[self maskView] setMaskSize:[self maskViewSize]];
    [[self scrollView] setFrame:self.bounds];
    [self updateZoomScale];
}

- (UIImage *)croppedImage {
    CGFloat zoomScale = [self scrollView].zoomScale;
    
    CGFloat offsetX = [self scrollView].contentOffset.x;
    CGFloat offsetY = [self scrollView].contentOffset.y;
    CGFloat aX = offsetX>=0 ? offsetX + _imageViewInsets.left : (_imageViewInsets.left - ABS(offsetX));
    CGFloat aY = offsetY>=0 ? offsetY + _imageViewInsets.top : (_imageViewInsets.top - ABS(offsetY));
    
    aX = aX / zoomScale;
    aY = aY / zoomScale;
    
    CGFloat aWidth =  MIN(_cropSize.width / zoomScale, _cropSize.width);
    CGFloat aHeight = MIN(_cropSize.height / zoomScale, _cropSize.height);
    if (zoomScale < 1) {
        aWidth =  MAX(_cropSize.width / zoomScale, _cropSize.width);
        aHeight = MAX(_cropSize.height / zoomScale, _cropSize.height);
    }
    
    aWidth *= _maskViewZoomScale;
    aHeight *= _maskViewZoomScale;
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    
#ifdef DEBUG
    DDLogInfo(@"%f--%f", _image.size.width, _image.size.height);
    DDLogInfo(@"%f--%f--%f--%f", aX, aY, aWidth, aHeight);
#endif
    
    UIImage *image = [_image cropImageWithX:aX y:aY width:aWidth height:aHeight];
    
    if (_cropRatio == 0) {
        image = [image resizeToWidth:_cropSize.width/screenScale height:_cropSize.height/screenScale];
    } else {
        image = [image resizeToWidth:image.size.width/screenScale height:image.size.height/screenScale];
    }
    
    return image;
}

@end


#pragma mark ****************************************
#pragma mark 【KIImageCropMaskView】
#pragma mark ****************************************

@implementation KIImageCropperMaskView

- (void)setMaskSize:(CGSize)size {
    CGFloat x = (CGRectGetWidth(self.bounds) - size.width) / 2;
    CGFloat y = (CGRectGetHeight(self.bounds) - size.height) / 2;
    _maskRect = CGRectMake(x, y, size.width, size.height);
    
    [self setNeedsDisplay];
}

- (CGSize)maskSize {
    return _maskRect.size;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 0, 0, 0, .6);
    CGContextFillRect(ctx, self.bounds);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextStrokeRectWithWidth(ctx, _maskRect, kMaskViewBorderWidth);
    
    CGContextClearRect(ctx, _maskRect);
}
@end
