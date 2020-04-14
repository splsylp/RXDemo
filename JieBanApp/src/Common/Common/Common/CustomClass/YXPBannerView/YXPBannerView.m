//
//  YXPBannerView.m
//  Common
//
//  Created by yuxuanpeng on 2017/7/27.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "YXPBannerView.h"
#import "RXThirdPart.h"

#define bannerBtnTag  80
#define bannerBtnOther 100
#define iconImgScrollViewHeight 250

@interface YXPBannerView ()<UIScrollViewDelegate>

@property(nonatomic ,strong) UIImageView *backImageView;

@property(nonatomic, strong) UIPageControl *myPageControl;
@property(nonatomic, strong) NSTimer *rotateTimer;//让视图自动切换 定时器
@property(nonatomic, assign) BOOL isScroll;//是否正在滑动
@property(nonatomic, retain) UIScrollView *iconImgScrollView;
@property(nonatomic, retain) NSMutableArray *failLoadArray;//下载失败的记录一下
@property(nonatomic, strong) NSArray<KitBannerData *> *bannerArray;

@end

@implementation YXPBannerView

- (instancetype)initWithFrame:(CGRect)frame withShowArray:(NSArray *)showArray{
    if(self = [super initWithFrame:frame]){
        self.failLoadArray = [NSMutableArray array];
        self.bannerArray = showArray;
        [self addSubview:self.backImageView];
        [self initUI:showArray];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.failLoadArray = [NSMutableArray array];
        self.iconImgScrollView.frame = self.frame;
        [self addSubview:self.backImageView];
//        [self initUI:nil];
    }
    return self;
}

- (void)initUI:(NSArray<KitBannerData *> *)bannerArray{
    [self addSubview:self.iconImgScrollView];
    self.iconImgScrollView.contentSize = CGSizeMake(self.frame.size.width *(bannerArray.count + 2), self.frame.size.height);
    for (int i = 0; i < bannerArray.count; i++) {
        KitBannerData *data = bannerArray[i];
        NSString *loadUrl = data.bannerImageUrl;
        NSString *title = data.bannerTitle;
        NSString *defalutPath = nil;

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.iconImgScrollView.frame.size.width * (i+1), 0, self.iconImgScrollView.frame.size.width, self.iconImgScrollView.frame.size.height);
        btn.tag = bannerBtnTag + i;
        [btn setImage:ThemeImage(defalutPath) forState:UIControlStateNormal];
        [btn setImage:ThemeImage(defalutPath) forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(onActionEvetn:) forControlEvents:UIControlEventTouchUpInside];

        if(!KCNSSTRING_ISEMPTY(loadUrl)) {
            [self loadBtnImage:loadUrl withCurView:btn];
        }
        [self.iconImgScrollView addSubview:btn];

        [self setTitleView:bannerBtnTag+10 withTitle:title withCurView:btn];
    }
    //为滚动视图的右边添加一个视图，使得它和第一个视图一模一样。
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    KitBannerData *firstData = [bannerArray firstObject];
    NSString *firstLoadUrl = firstData.bannerImageUrl;
    NSString *firstTitle = firstData.bannerTitle;
    NSString *firstDefalutPath = nil;
    btn.frame = CGRectMake(kScreenWidth*(bannerArray.count+1), 0, kScreenWidth, self.iconImgScrollView.frame.size.height);
    btn.tag = bannerBtnOther;
    [btn setImage:ThemeImage(firstDefalutPath) forState:UIControlStateNormal];
    [btn setImage:ThemeImage(firstDefalutPath) forState:UIControlStateHighlighted];
    if(!KCNSSTRING_ISEMPTY(firstLoadUrl)) {
        [self loadBtnImage:firstLoadUrl withCurView:btn];
    }
    [self setTitleView:0 withTitle:firstTitle withCurView:btn];

    [self.iconImgScrollView addSubview:btn];
    //为滚动视图的左边添加一个视图，使得它和最后一个视图一模一样。
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    KitBannerData *lastData = [bannerArray lastObject];
    btn1.tag = bannerBtnOther+1;
    NSString *lastLoadUrl = lastData.bannerImageUrl;
    NSString *lastTitle = lastData.bannerTitle;
    NSString *lastDefalutPath = nil;
    btn1.frame = CGRectMake(0, 0, kScreenWidth, self.iconImgScrollView.frame.size.height);
    [btn1 setImage:ThemeImage(lastDefalutPath) forState:UIControlStateNormal];
    [btn1 setImage:ThemeImage(lastDefalutPath) forState:UIControlStateHighlighted];

    if(!KCNSSTRING_ISEMPTY(lastLoadUrl)) {
        [self loadBtnImage:lastLoadUrl withCurView:btn1];
    }
    [self setTitleView:0 withTitle:lastTitle withCurView:btn1];

    [self.iconImgScrollView addSubview:btn1];

    _myPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 23,  self.frame.size.width, 15)];
    _myPageControl.numberOfPages = bannerArray.count;
    _myPageControl.backgroundColor = [UIColor clearColor];
    _myPageControl.currentPage = 0;
    _myPageControl.hidden = bannerArray.count == 0 ? YES:NO;
    [self addSubview:_myPageControl];

    //启动定时器
    _rotateTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(changeView) userInfo:nil repeats:YES];
}

- (void)loadBtnImage:(NSString *)loadUrl withCurView:(UIButton *)btn {
    [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:loadUrl] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if(!error) {
            [btn setImage:image forState:UIControlStateNormal];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
            btn.contentHorizontalAlignment= UIControlContentHorizontalAlignmentFill;//水平方向拉伸
            btn.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;//垂直方向拉伸
            btn.contentMode = UIViewContentModeScaleAspectFill;
            [self existLoadImageUrl:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
        }else{
            //请求失败 记录一下 做刷新用
            [self.failLoadArray addObject:@{@"btnTag":[NSString stringWithFormat:@"%ld",(long)btn.tag],@"bannerImageUrl":loadUrl}];
        }
    }];
}

- (void)setTitleView:(NSInteger)viewTag withTitle:(NSString *)title withCurView:(UIButton *)btn {
    UIView *titleView =[[UIView alloc]initWithFrame:CGRectMake(0, btn.bounds.size.height-35, self.iconImgScrollView.frame.size.width, 35)];
    titleView.backgroundColor=[UIColor clearColor];
    titleView.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5].CGColor;
    [btn addSubview:titleView];

    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 2.5, self.iconImgScrollView.frame.size.width, 20)];
    titleLbl.font = ThemeFontMiddle;
    titleLbl.tag = viewTag;
    titleLbl.lineBreakMode = NSLineBreakByCharWrapping;
    titleLbl.numberOfLines = 0;
    titleLbl.backgroundColor = [UIColor clearColor];
    titleLbl.textColor=[UIColor whiteColor];
    titleLbl.text = title;
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:titleLbl];
    if(KCNSSTRING_ISEMPTY(title))
    {
        titleView.hidden = YES;
    }
}

- (void)existLoadImageUrl:(NSString *)btnTag{
    if(self.failLoadArray.count > 0){
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"btnTag CONTAINS[cd] %@",btnTag];
        NSArray *myArray =[self.failLoadArray filteredArrayUsingPredicate:predicate];
        if(myArray.count>0) {
            [self.failLoadArray removeObjectsInArray:myArray];
        }
    }
}
#pragma mark update
- (void)updaloadImage{
    if(!self.iconImgScrollView || self.failLoadArray.count == 0){
        return;
    }
    NSArray *newArray = [self.failLoadArray copy];
    for (NSDictionary *loadDic in newArray) {
        NSInteger tag = [loadDic[@"btnTag"] integerValue];
        UIButton *failBtn = [self.iconImgScrollView viewWithTag:tag];
        if(failBtn){
            [self loadBtnImage:loadDic[@"bannerImageUrl"] withCurView:failBtn];
        }
    }
}

- (void)updateShowBanner:(NSArray *)bannerArray{
    if(!self.iconImgScrollView){
        return;
    }
    //先移除
    [self.iconImgScrollView removeFromSuperview];
    self.iconImgScrollView = nil;
    self.failLoadArray = [NSMutableArray array];
    if(self.rotateTimer){
        [self.rotateTimer invalidate];
        self.rotateTimer = nil;
    }

    self.bannerArray = bannerArray;
    [self initUI:bannerArray];
}

#pragma mark btnEvent
- (void)onActionEvetn:(UIButton *)btn{
    DDLogInfo(@".....是否响应了...");
    NSInteger viewTag = (btn.tag-bannerBtnTag);
    if(viewTag < self.bannerArray.count){
        KitBannerData *data = self.bannerArray[viewTag];
        if(self.delegate && [self.delegate respondsToSelector:@selector(onActionEvent:userData:)]){
            [self.delegate onActionEvent:data.bannerUrl userData:nil];
        }
    }
}
#pragma mark -- 滚动视图的代理方法
//开始拖拽的代理方法，在此方法中暂停定时器。
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(scrollView == self.iconImgScrollView){
        DDLogInfo(@"正在拖拽视图，所以需要将自动播放暂停掉");
        [_rotateTimer setFireDate:[NSDate distantFuture]];
        _isScroll = YES;
    }
}

//视图静止时（没有人在拖拽），开启定时器，让自动轮播
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(scrollView == self.iconImgScrollView){
        DDLogInfo(@"开启定时器");
        [_rotateTimer setFireDate:[NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]]];
        _isScroll = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == self.iconImgScrollView){
        if (scrollView.contentOffset.x /self.iconImgScrollView.frame.size.width == (_myPageControl.numberOfPages+1)) {
            if (_isScroll) {
                _myPageControl.currentPage = 0;
            }
            self.iconImgScrollView.contentOffset = CGPointMake(kScreenWidth, 0);
        }else if (scrollView.contentOffset.x/self.iconImgScrollView.frame.size.width==0){
            if (_isScroll) {
                _myPageControl.currentPage = _myPageControl.numberOfPages;
            }
            self.iconImgScrollView.contentOffset = CGPointMake(kScreenWidth*_myPageControl.numberOfPages, 0);
        }else{
            if (_isScroll) {
                _myPageControl.currentPage = scrollView.contentOffset.x/self.iconImgScrollView.frame.size.width-1;
            }
        }
    }
}

//定时器的回调方法   切换界面
- (void)changeView{
    //得到scrollView
    UIScrollView *scrollView = self.iconImgScrollView;
    //通过改变contentOffset来切换滚动视图的子界面
    float offset_X = scrollView.contentOffset.x;
    //每次切换一个屏幕
    offset_X += CGRectGetWidth(self.iconImgScrollView.frame);

    //说明要从最右边的多余视图开始滚动了，最右边的多余视图实际上就是第一个视图。所以偏移量需要更改为第一个视图的偏移量。
    if (offset_X > CGRectGetWidth(self.iconImgScrollView.frame)*(_myPageControl.numberOfPages+1)) {
        scrollView.contentOffset = CGPointMake( CGRectGetWidth(self.iconImgScrollView.frame), 0);

    }
    //说明正在显示的就是最右边的多余视图，最右边的多余视图实际上就是第一个视图。所以pageControl的小白点需要在第一个视图的位置。
    if (offset_X == CGRectGetWidth(self.iconImgScrollView.frame)*(_myPageControl.numberOfPages+1)) {
        _myPageControl.currentPage = 0;
    }else{
        _myPageControl.currentPage = offset_X/CGRectGetWidth(self.iconImgScrollView.frame)-1;
    }
    //得到最终的偏移量
    CGPoint resultPoint = CGPointMake(offset_X, 0);
    //切换视图时带动画效果
    //最右边的多余视图实际上就是第一个视图，现在是要从第一个视图向第二个视图偏移，所以偏移量为一个屏幕宽度
    if (offset_X >CGRectGetWidth(self.iconImgScrollView.frame)*(_myPageControl.numberOfPages+1)) {
        _myPageControl.currentPage = 1;
        [scrollView setContentOffset:CGPointMake(2*CGRectGetWidth(self.iconImgScrollView.frame), 0) animated:YES];
    }else{
        [scrollView setContentOffset:resultPoint animated:YES];
    }
}

#pragma mark - get
- (UIScrollView *)iconImgScrollView{
    if (!_iconImgScrollView) {
        self.iconImgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.iconImgScrollView.pagingEnabled = YES;
        self.iconImgScrollView.bounces = NO;
        self.iconImgScrollView.delegate = self;
        self.iconImgScrollView.showsVerticalScrollIndicator = NO;
        self.iconImgScrollView.showsHorizontalScrollIndicator = NO;
        self.iconImgScrollView.userInteractionEnabled = YES;
        self.iconImgScrollView.contentOffset = CGPointMake(self.frame.size.width,0);
    }
    return _iconImgScrollView;
}
- (UIImageView *)backImageView{
    if (_backImageView == nil) {
        _backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _backImageView.image = ThemeImage(@"work_placeholder");
    }
    return _backImageView;
}
@end



