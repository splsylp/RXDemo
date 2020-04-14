//
//  MSSBrowseZoomScrollView.m
//  MSSBrowse
//
//  Created by yuxuanpeng on 15/12/5.
//  Copyright © 2015年 yuxuanpeng. All rights reserved.
//

#import "MSSBrowseZoomScrollView.h"
#import "MSSBrowseDefine.h"

@interface MSSBrowseZoomScrollView ()

@property (nonatomic,copy)MSSBrowseZoomScrollViewTapBlock tapBlock;


@end

@implementation MSSBrowseZoomScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createZoomScrollView];
    }
    return self;
}

- (void)createZoomScrollView
{
    self.delegate = self;
    _isSingleTap = NO;
    self.minimumZoomScale = 1.0f;
    self.maximumZoomScale = 3.0f;

    _zoomImageView = [[FLAnimatedImageView alloc]init];
//    _zoomImageView.userInteractionEnabled = YES;
    [self addSubview:_zoomImageView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // 延中心点缩放
    CGRect rect = _zoomImageView.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    /// eagle 当宽图时候，上下无边界，根据图片大小来缩放
    if (_zoomImageView.image.size.width > _zoomImageView.image.size.height) {
        rect.size.height = (CGFloat )_zoomImageView.frame.size.width / (CGFloat )_zoomImageView.image.size.width * (CGFloat )_zoomImageView.image.size.height;
    }
    if (rect.size.width < self.mssWidth) {
        rect.origin.x = floorf((self.mssWidth - rect.size.width) / 2.0);
    }
    
    if (rect.size.height < self.mssHeight) {
        rect.origin.y = floorf((self.mssHeight - rect.size.height) / 2.0);
    }
    _zoomImageView.frame = rect;
    self.contentSize = CGSizeMake(rect.size.width, rect.size.height);
}

- (void)tapClick:(MSSBrowseZoomScrollViewTapBlock)tapBlock
{
    _tapBlock = tapBlock;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    if(touch.tapCount == 1)
    {
        [self performSelector:@selector(singleTapClick) withObject:nil afterDelay:0.17];
    }
    else
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        // 防止先执行单击手势后还执行下面双击手势动画异常问题
        if(!_isSingleTap)
        {
            CGPoint touchPoint = [touch locationInView:_zoomImageView];
            [self zoomDoubleTapWithPoint:touchPoint];
        }
    }
}

- (void)singleTapClick
{
    _isSingleTap = YES;
    if(_tapBlock)
    {
        _tapBlock();
    }
}

- (void)zoomDoubleTapWithPoint:(CGPoint)touchPoint
{
    if(self.zoomScale > self.minimumZoomScale)
    {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
    else
    {
        CGFloat scale = self.maximumZoomScale;
        CGRect newRect = [self getRectWithScale:scale andCenter:touchPoint];
        [self zoomToRect:newRect animated:YES];
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    !self.scrollBlock?:self.scrollBlock(scrollView.contentOffset);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    !self.endScrollBlock?:self.endScrollBlock(scrollView);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    !self.willEndScrollBlock?:self.willEndScrollBlock(scrollView,velocity,targetContentOffset);
}

/** 计算点击点所在区域frame */
- (CGRect)getRectWithScale:(CGFloat)scale andCenter:(CGPoint)center{
    CGRect newRect = CGRectZero;
    newRect.size.width =  self.frame.size.width/scale;
    newRect.size.height = self.frame.size.height/scale;
    newRect.origin.x = center.x - newRect.size.width * 0.5;
    newRect.origin.y = center.y - newRect.size.height * 0.5;
    
    return newRect;
}

//完成缩放
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    NSLog(@"%s,zooming:%d",__func__,scrollView.zooming);
}
@end
