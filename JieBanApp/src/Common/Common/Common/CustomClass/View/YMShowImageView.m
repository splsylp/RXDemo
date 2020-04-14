//
//  YMShowImageView.m
//  WFCoretext
//
//  Created by 阿虎 on 14/11/3.
//  Copyright (c) 2014年 tigerwf. All rights reserved.
//

#import "YMShowImageView.h"
#import "RX_MLSelectPhotoPickerViewController.h"
#import "RX_MLSelectPhotoAssets.h"
#import "UIImage+MSSScale.h"
#import "YXPBrowseModel.h"
#import "YXPBrowserLoadingView.h"
#import "UIView+MSSLayout.h"
#import "RX_TZImagePickerController.h"
#import "MSSBrowseActionSheet.h"

@implementation YMShowImageView{

    UIView * navView;
    UIScrollView *_scrollView;
    UILabel * pagNum;
    
    CGRect self_Frame;
    NSInteger page;
    BOOL doubleClick;
    
    BOOL IsWatch;
    NSArray * _imgArr;
    NSMutableArray *_verticalBigRectArray;
    NSMutableArray *_horizontalBigRectArray;
   // YXPBrowserLoadingView *loadingView;
}

-(id)initWithFrame:(CGRect)frame byClick:(NSInteger)clickTag appendArray:(NSArray *)appendArray smallArray:(NSMutableArray *)smallArray isHiddenDeleBtn:(BOOL)isHidden isWatch:(BOOL)isWatch
{
    self =[super initWithFrame:frame];
    
    if(self)
    {
        self_Frame = frame;

        self.backgroundColor =[UIColor blackColor];
        self.alpha =1.0;
        doubleClick = YES;
        IsWatch = isWatch;//你我看点
        _imgArr = appendArray;
        [self configScrollViewWith:clickTag andAppendArray:appendArray withSmallImage:smallArray isHidden:isHidden isWatch:IsWatch];
        UITapGestureRecognizer *tapGser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disappear)];
        tapGser.numberOfTouchesRequired = 1;
        tapGser.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGser];
        
        UITapGestureRecognizer *doubleTapGser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeBig:)];
        doubleTapGser.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGser];
        
        [tapGser requireGestureRecognizerToFail:doubleTapGser];
        
        UILongPressGestureRecognizer * longPressTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveImageClick:)];
        longPressTap.minimumPressDuration = 1.0;
        [self addGestureRecognizer:longPressTap];
        
    }
    return self;
}

- (void)configScrollViewWith:(NSInteger)clickTag andAppendArray:(NSArray *)appendArray withSmallImage:(NSMutableArray *)smallImgArray isHidden:(BOOL)isHidden isWatch:(BOOL)isWatch{

    _scrollView = [[UIScrollView alloc] initWithFrame:self_Frame];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.pagingEnabled = true;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(self.frame.size.width * appendArray.count, 0);
    [self addSubview:_scrollView];
    
    float W = self.frame.size.width;
    
    //获取到小图片 得到图像显示完整后的宽度和高度
    [self initImageData:smallImgArray];
    for(int i =0;i<smallImgArray.count;i++)
    {
        YXPBrowseModel *browseModel =smallImgArray[i];
        
        UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height)];
        imageScrollView.backgroundColor = [UIColor blackColor];
        imageScrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        imageScrollView.delegate = self;
        imageScrollView.maximumZoomScale = 4;
        imageScrollView.minimumZoomScale = 1;
        [_scrollView addSubview:imageScrollView];
        imageScrollView.zoomScale = 1.0f;
        imageScrollView.contentMode = browseModel.smallImageView.contentMode;

        UIImageView *showImageView =[[UIImageView alloc]init];
        showImageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageScrollView addSubview:showImageView];
        showImageView.backgroundColor =[UIColor redColor];
        showImageView.userInteractionEnabled=YES;
        
        YXPBrowserLoadingView *loadView = [[YXPBrowserLoadingView alloc] init];
        loadView.frame =CGRectMake((imageScrollView.width-30)/2, (imageScrollView.height-30)/2, 30, 30);
        [imageScrollView addSubview:loadView];
        imageScrollView.tag = 100 + i;
        showImageView.tag = 1000 + i;
        CGRect bigImageRect = [_verticalBigRectArray[i] CGRectValue];
        //[self showBigImage:showImageView browseModel:browseModel rect:bigImageRect];
        
        if([browseModel.bigImageUrl hasSuffix:@"_thum"]) {
            browseModel.bigImageUrl =[browseModel.bigImageUrl substringToIndex:(browseModel.bigImageUrl.length - 5)];
        }
        //判断大图是否存在
        if([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:browseModel.bigImageUrl]) {
            [self showBigImage:showImageView browseModel:browseModel rect:bigImageRect];
        } else {
           //加载大图
            [self loadBigImageWithBrowseItem:browseModel loadView:loadView withImageView:showImageView rect:bigImageRect];
        }

    }
    
    if (clickTag) {
        [_scrollView setContentOffset:CGPointMake(W * (clickTag - 9999), 0) animated:YES];
        page = clickTag - 9999;
    }

}
-(void)showBigImage:(UIImageView *)imageView browseModel:(YXPBrowseModel *)browseModel rect:(CGRect)rect
{
    [imageView sd_cancelCurrentImageLoad];
    imageView.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:browseModel.bigImageUrl];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.frame = rect;
    }];
}
-(void)loadBigImageWithBrowseItem:(YXPBrowseModel *)browseItem loadView:(YXPBrowserLoadingView *)loadingView withImageView:(UIImageView *)imageView rect:(CGRect)rect
{
    [loadingView startAnimation];
    imageView.frame = CGRectMake((self.width-browseItem.smallImageView.width)/2, (self.height-browseItem.smallImageView.height)/2, browseItem.smallImageView.mssWidth, browseItem.smallImageView.mssHeight);
     //__weak  UIImageView *selfImg =imageView;
    imageView.backgroundColor =[UIColor redColor];
   // [imageView setImageAddWaittingWith:[NSURL URLWithString:browseItem.bigImageUrl] placeholderImage:browseItem.smallImageView.image completed:nil];
    
    //[loadingView stopAnimation];
    [UIView animateWithDuration:0.5 animations:^{
            imageView.frame = rect;
        }];
    
//    [imageView sd_setImageWithURL:[NSURL URLWithString:browseItem.bigImageUrl] placeholderImage:browseItem.smallImageView.image options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//        DDLogInfo(@",,,,,,,,,,,,,,weisbuouya  w d tian ,,,,,,,,");
//    }];
//    
//    [selfImg mss_setFrameInSuperViewCenterWithSize:CGSizeMake(browseItem.smallImageView.mssWidth, browseItem.smallImageView.mssHeight)];
//    [selfImg sd_setImageWithURL:[NSURL URLWithString:browseItem.bigImageUrl] placeholderImage:browseItem.smallImageView.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//        // 停止加载
//        [loadingView stopAnimation];
//        if(error)
//        {
//           //失败
//        }
//        else
//        {
//            // 图片加载成功
//            [UIView animateWithDuration:0.5 animations:^{
//                selfImg.frame = rect;
//            }];
//        }
//    }];
}
-(void)initImageData:(NSMutableArray *)smallImgView
{
    _verticalBigRectArray = [[NSMutableArray alloc]init];
    _horizontalBigRectArray = [[NSMutableArray alloc]init];
    
    for(YXPBrowseModel *browseModel in smallImgView)
    {
        CGRect verticalRect = [browseModel.smallImageView.image mss_getBigImageRectSizeWithScreenWidth:kScreenWidth ScreenHeight:kScreenHeight];
        NSValue *verticalValue = [NSValue valueWithCGRect:verticalRect];
        [_verticalBigRectArray addObject:verticalValue];
        
        CGRect horizontalRect = [browseModel.smallImageView.image mss_getBigImageRectSizeWithScreenWidth:kScreenHeight ScreenHeight:kScreenWidth];
        NSValue *horizontalValue = [NSValue valueWithCGRect:horizontalRect];
        [_horizontalBigRectArray addObject:horizontalValue];
    }

}


-(id)initWithOtherFrame:(CGRect)frame byClick:(NSInteger)clickTag appendArray:(NSArray *)appendArray isHiddenDeleBtn:(BOOL)isHidden isWatch:(BOOL)isWatch{

    self = [super initWithFrame:frame];
    if (self) {
        
        self_Frame = frame;
        
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.0f;
        page = 0;
        doubleClick = YES;
        IsWatch = isWatch;//你我看点
        _imgArr = appendArray;
        
        
        navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTotalBarHeight)];
        navView.backgroundColor = [UIColor blackColor];
        navView.alpha = 0.7;
        [self addSubview:navView];
        
        
        UIButton * returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        returnBtn.frame = CGRectMake(5, kMainStatusBarHeight, 40, 40);
        [returnBtn setImage:ThemeColorImage(ThemeImage(@"title_bar_back"), [UIColor whiteColor]) forState:UIControlStateNormal];
        [returnBtn addTarget:self action:@selector(disappear) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:returnBtn];

        if (isHidden) {
            navView.hidden = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
        }else{
            UIButton * deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteBtn.frame = CGRectMake(kScreenWidth - 45, kMainStatusBarHeight, 40, 40);
            deleteBtn.userInteractionEnabled = YES;
            [deleteBtn setImage:ThemeImage(@"title_bar_delete") forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteImageClick:) forControlEvents:UIControlEventTouchUpInside];
            [navView addSubview:deleteBtn];
        }
        if (clickTag) {
            pagNum = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 40)/2, kMainStatusBarHeight, 40, 44)];
            pagNum.font = ThemeFontLarge;
            pagNum.textColor = [UIColor whiteColor];
            [navView addSubview:pagNum];
        }
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self_Frame];
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.pagingEnabled = true;
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(self.frame.size.width * appendArray.count, 0);
        [self addSubview:_scrollView];
        
        [self bringSubviewToFront:navView];
        
        [self configOtherScrollViewWith:clickTag andAppendArray:appendArray isWatch:isWatch];
        
        UITapGestureRecognizer *tapGser = nil;
        if (isHidden) {
            tapGser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disappear)];
        }else{
            tapGser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickHiddenNavView)];
        }
        tapGser.numberOfTouchesRequired = 1;
        tapGser.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGser];
        
        
        UITapGestureRecognizer *doubleTapGser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeBig:)];
        doubleTapGser.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGser];
        
        [tapGser requireGestureRecognizerToFail:doubleTapGser];
        
        if (_isNeedLongPressToSave) {
            //产品说不需要长按保存的功能  暂时屏蔽掉  如果需要该功能，设置该属性即可
            UILongPressGestureRecognizer * longPressTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveImageClick:)];
            longPressTap.minimumPressDuration = 1.0;
            [self addGestureRecognizer:longPressTap];
        }
        
    }
    return self;
}

- (void)onClickHiddenNavView{
    
    [UIView animateWithDuration:0.5 animations:^{
        if (self->navView.hidden) {
            [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
        }else{
            [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
        }
        self->navView.hidden = !self->navView.hidden;
    }];
}

- (void)configOtherScrollViewWith:(NSInteger)clickTag andAppendArray:(NSArray *)appendArray isWatch:(BOOL)isWatch{
    
    float W = self.frame.size.width;
    
    
    for (int i = 0; i < appendArray.count; i ++) {
        
        UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kScreenWidth * i, 0, kScreenWidth, _scrollView.height)];
        imageScrollView.backgroundColor = [UIColor blackColor];
        imageScrollView.contentSize = CGSizeMake(self.frame.size.width, _scrollView.height);
        imageScrollView.delegate = self;
        imageScrollView.maximumZoomScale = 4;
        imageScrollView.minimumZoomScale = 1;
        
        //ShowImage_H
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _scrollView.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        
        if([[appendArray objectAtIndex:i] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *infoData = [appendArray objectAtIndex:i];
            //转化图片显示
            imageView.image = [infoData objectForKey:UIImagePickerControllerOriginalImage];
            
        }else if ([[appendArray objectAtIndex:i] isKindOfClass:[RX_MLSelectPhotoAssets class]]) {
            
            RX_MLSelectPhotoAssets * assets = [appendArray objectAtIndex:i];
            imageView.image = [RX_MLSelectPhotoPickerViewController getImageWithImageObj:assets];
            
            
        }else if ([[appendArray objectAtIndex:i] isKindOfClass:[UIImage class]]) {
            
            UIImage * shouImg = [appendArray objectAtIndex:i];
            imageView.image = shouImg;
            
        }else if ([[appendArray objectAtIndex:i] isKindOfClass:[PHAsset class]]){
            PHAsset *assets = [appendArray objectAtIndex:i];
            [[RX_TZImageManager manager] getPhotoWithAsset:assets completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (!isDegraded) {
                    imageView.image = photo;
                }
            }];
//            [[RX_TZImageManager manager] getOriginalPhotoWithAsset:assets completion:^(UIImage *photo, NSDictionary *info) {
//                imageView.image = photo;
//            }];
        }else{
//            NSString * imgUrl = [appendArray objectAtIndex:i];
//
//            if ([imgUrl hasSuffix:@"_thum"]) { //查看原图
//                imgUrl = [imgUrl substringToIndex:(imgUrl.length - 5)];
//            }
            
//            [imageView setImageAddWaittingWith:[NSURL URLWithString:imgUrl] placeholderImage:ThemeImage(@"") completed:nil];
//            首先判断有没有大图片的缓存
            
        }
        
        
        imageView.userInteractionEnabled = YES;
        [imageScrollView addSubview:imageView];
        [_scrollView addSubview:imageScrollView];
        
        imageScrollView.tag = 100 + i;
        imageView.tag = 1000 + i;
        
        if (isWatch) {
            UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            backBtn.frame = CGRectMake(10, 30, 40, 40);
            backBtn.tag = i + 20;
            backBtn.userInteractionEnabled = YES;
            [backBtn setImage:ThemeColorImage(ThemeImage(@"title_bar_back"), [UIColor whiteColor]) forState:UIControlStateNormal];
            [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:backBtn];
            
            UILabel * contentLab = [[UILabel alloc] initWithFrame:CGRectMake(5, kScreenHeight - 100, kScreenWidth - 10, 90)];
            contentLab.text = languageStringWithKey(@"图片简介");
            contentLab.textColor = [UIColor whiteColor];
            contentLab.numberOfLines = 5;
            contentLab.tag = i + 30;
            contentLab.userInteractionEnabled = YES;
            contentLab.backgroundColor = [UIColor clearColor];
            [imageView addSubview:contentLab];
            
            UIButton * tapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tapBtn.frame = CGRectMake(0, 0, contentLab.width, contentLab.height);
            tapBtn.tag = i + 40;
            tapBtn.userInteractionEnabled = YES;
            tapBtn.backgroundColor = [UIColor clearColor];
            [tapBtn addTarget:self action:@selector(tapBtn:) forControlEvents:UIControlEventTouchUpInside];
            [contentLab addSubview:tapBtn];
        }
    }
    if (clickTag) {
        [_scrollView setContentOffset:CGPointMake(W * (clickTag - 9999), 0) animated:YES];
        page = clickTag - 9999;
        pagNum.text = [NSString stringWithFormat:@"%d/%lu",(int)page + 1,(unsigned long)appendArray.count];
    }
}

- (void)deleteImageClick:(UIButton *)sender{
    [self.delegate deleteImgWith:page];
}

- (void)tapBtn:(UIButton *)sender{
    UILabel * lab = (UILabel *)[_scrollView viewWithTag:sender.tag - 10];
    [UIView animateWithDuration:0.5 animations:^{
        lab.frame = CGRectMake(5, kScreenHeight - 100, kScreenWidth - 10, 90);
    }];
}

- (void)backClick{
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    _removeImg();
}

- (void)disappear{
    if (IsWatch) {
        
        UILabel * lab = (UILabel *)[_scrollView viewWithTag:page + 30];
        [UIView animateWithDuration:0.5 animations:^{
            lab.frame = CGRectMake(5, kScreenHeight - 35, kScreenWidth - 10, 90);
        }];
        
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
        _removeImg();
    }
}


- (void)changeBig:(UITapGestureRecognizer *)tapGes{

    CGFloat newscale = 1.9;
    UIScrollView *currentScrollView = (UIScrollView *)[self viewWithTag:page + 100];
    CGRect zoomRect = [self zoomRectForScale:newscale withCenter:[tapGes locationInView:tapGes.view] andScrollView:currentScrollView];
    
    if (doubleClick == YES)  {
        
        [currentScrollView zoomToRect:zoomRect animated:YES];
        
    }else {
      
        [currentScrollView zoomToRect:currentScrollView.frame animated:YES];
    }
    
    doubleClick = !doubleClick;

}

- (void)saveImageClick:(UIGestureRecognizer *)sender{
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (sender.state == UIGestureRecognizerStateBegan) {
        
        NSArray *items = @[languageStringWithKey(@"保存图片")];
        MSSBrowseActionSheet *sheet = [[MSSBrowseActionSheet alloc] initWithTitleArray:items cancelButtonTitle:languageStringWithKey(@"取消") didSelectedBlock:^(NSInteger index) {
            if (index == MSSBrowseTypeSave) {
                __block UIImage *image;
                id imgType = [_imgArr objectAtIndex:page];
                if([imgType isKindOfClass:[UIImage class]]) {
                    image =imgType;
                } else if([imgType isKindOfClass:[NSString class]]) {
                    NSString * imgURL = [_imgArr objectAtIndex:page];
                    if ([imgURL hasSuffix:@"_thum"]) { //原图
                        imgURL = [imgURL substringToIndex:(imgURL.length - 5)];
                    }
                    DDLogInfo(@"imgurl = %@", imgURL);
                    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
                    image = [UIImage imageWithData:data];
                } else if ([imgType isKindOfClass:[RX_MLSelectPhotoAssets class]
                       ]) {
                    image = [RX_MLSelectPhotoPickerViewController getImageWithImageObj:imgType];
                } else if ([imgType isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *infoData = imgType;
                    image = [infoData objectForKey:UIImagePickerControllerOriginalImage];
                }
                else if ([imgType isKindOfClass:[PHAsset class]]){
                    PHAsset *asset = imgType;
                    [[RX_TZImageManager manager] getPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                        if (isDegraded) {
                             image = photo;
                        }
                    }];
                }
                if (image) {
                    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                }
            }
        }];
        [sheet showInView:self];
    }
}
                                                      
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo{
    if (!error && image){
        DDLogInfo(@"OK");
        [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"保存成功")];
    } else {
        DDLogInfo(@"Error");
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"保存失败")];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    UIImageView *imageView = (UIImageView *)[self viewWithTag:scrollView.tag + 900];
    return imageView;
}

- (CGRect)zoomRectForScale:(CGFloat)newscale withCenter:(CGPoint)center andScrollView:(UIScrollView *)scrollV{
   
    CGRect zoomRect = CGRectZero;
    
    zoomRect.size.height = scrollV.frame.size.height / newscale;
    zoomRect.size.width = scrollV.frame.size.width  / newscale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;

}

- (void)show:(UIView *)bgView didFinish:(didRemoveImage)tempBlock{
     [bgView addSubview:self];
     _removeImg = tempBlock;
    
     [UIView animateWithDuration:.4f animations:^(){
         self.alpha = 1.0f;
    
     } completion:^(BOOL finished) {
        
     }];
}


#pragma mark - ScorllViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
  
    CGPoint offset = _scrollView.contentOffset;
    page = offset.x / self.frame.size.width ;
   
    pagNum.text = [NSString stringWithFormat:@"%d/%lu",(int)page + 1,(unsigned long)_imgArr.count];
    UIScrollView *scrollV_next = (UIScrollView *)[self viewWithTag:page+100+1]; //前一页
    
    if (scrollV_next.zoomScale != 1.0){
        scrollV_next.zoomScale = 1.0;
    }
    
    UIScrollView *scollV_pre = (UIScrollView *)[self viewWithTag:page+100-1]; //后一页
    if (scollV_pre.zoomScale != 1.0){
        scollV_pre.zoomScale = 1.0;
    }
    
   // DDLogInfo(@"page == %d",page);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
  

}

@end
