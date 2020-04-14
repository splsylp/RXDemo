//
//  RXDisplayViewController.m
//  Chat
//
//  Created by 高源 on 2019/5/6.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "RXDisplayViewController.h"

// 导航条高度
#define RXNavBarH  ([[UIApplication sharedApplication] statusBarFrame].size.height + 44.f)

// 标题滚动视图的高度
static CGFloat const RXTitleScrollViewH = 44;

// 标题缩放比例
static CGFloat const RXTitleTransformScale = 1.3;

// 下划线默认高度
static CGFloat const RXUnderLineH = 2;

#define RXScreenW [UIScreen mainScreen].bounds.size.width
#define RXScreenH [UIScreen mainScreen].bounds.size.height

// 默认标题字体
#define RXTitleFont [UIFont systemFontOfSize:15]

// 默认标题间距
static CGFloat const margin = 20;

static NSString * const ID = @"cell";

// 标题被点击或者内容滚动完成，会发出这个通知，监听这个通知，可以做自己想要做的事情，比如加载数据
static NSString * const RXDisplayViewClickOrScrollDidFinshNote = @"RXDisplayViewClickOrScrollDidFinshNote";

// 重复点击通知
static NSString * const RXDisplayViewRepeatClickTitleNote = @"RXDisplayViewRepeatClickTitleNote";





/************************************************/

@interface UIView (RXFrame)

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end

@implementation UIView (RXFrame)

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

@end




/************************************************/

@interface RXDisplayTitleLabel : UILabel

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) UIColor *fillColor;

@end


@implementation RXDisplayTitleLabel

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    
    [_fillColor set];
    
    rect.size.width = rect.size.width * _progress;
    
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}


- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

@end



/************************************************/




@interface RXFlowLayout : UICollectionViewFlowLayout

@end

@implementation RXFlowLayout

- (void)prepareLayout
{
    [super prepareLayout];
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    if (self.collectionView.bounds.size.height) {
        self.itemSize = self.collectionView.bounds.size;
    }
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
}

@end



/************************************************/






@interface RXDisplayViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

/** 整体内容View 包含标题好内容滚动视图 */
@property (nonatomic, weak) UIView *contentView;

/** 标题滚动视图 */
@property (nonatomic, weak) UIScrollView *titleScrollView;

/** 内容滚动视图 */
@property (nonatomic, weak) UICollectionView *contentScrollView;

/** 所以标题数组 */
@property (nonatomic, strong) NSMutableArray *titleLabels;

/** 所以标题宽度数组 */
@property (nonatomic, strong) NSMutableArray *titleWidths;

/** 下标视图 */
@property (nonatomic, weak) UIView *underLine;

/** 标题遮盖视图 */
@property (nonatomic, weak) UIView *coverView;

/** 记录上一次内容滚动视图偏移量 */
@property (nonatomic, assign) CGFloat lastOffsetX;

/** 记录是否点击 */
@property (nonatomic, assign) BOOL isClickTitle;

/** 记录是否在动画 */
@property (nonatomic, assign) BOOL isAniming;

/* 是否初始化 */
@property (nonatomic, assign) BOOL isInitial;

/** 标题间距 */
@property (nonatomic, assign) CGFloat titleMargin;

/** 计算上一次选中角标 */
@property (nonatomic, assign) NSInteger selIndex;

@end

@implementation RXDisplayViewController

#pragma mark - 初始化方法

- (instancetype)init
{
    if (self = [super init]) {
        [self initial];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initial];
}

- (void)initial
{
    // 初始化标题高度
    _titleHeight = RXTitleScrollViewH;
    
    //默认不在导航栏上面
    _titleLableOnNavigationBar =  NO;
    
    //标题栏背景默认透明
    _titleScrollViewColor = [UIColor clearColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setUp
{
    
    if (_isShowTitleGradient && _titleColorGradientStyle == RXTitleColorGradientStyleRGB) {
        
        // 初始化颜色渐变
        if (_endR == 0 && _endG == 0 && _endB == 0) {
            _endR = 1;
        }
    }
}

#pragma mark - 懒加载

- (UIFont *)titleFont
{
    if (_titleFont == nil) {
        _titleFont = RXTitleFont;
    }
    return _titleFont;
}


- (NSMutableArray *)titleWidths
{
    if (_titleWidths == nil) {
        _titleWidths = [NSMutableArray array];
    }
    return _titleWidths;
}

- (UIColor *)norColor
{
    if (_isShowTitleGradient && _titleColorGradientStyle == RXTitleColorGradientStyleRGB) {
        _norColor = [UIColor colorWithRed:_startR green:_startG blue:_startB alpha:1];
    }
    
    if (_norColor == nil){
        _norColor = [UIColor blackColor];
    }
    
    
    return _norColor;
}

- (UIColor *)selColor
{
    if (_isShowTitleGradient && _titleColorGradientStyle == RXTitleColorGradientStyleRGB) {
        _selColor = [UIColor colorWithRed:_endR green:_endG blue:_endB alpha:1];
    }
    
    if (_selColor == nil) _selColor = [UIColor redColor];
    
    return _selColor;
}

- (UIView *)coverView
{
    if (_coverView == nil) {
        UIView *coverView = [[UIView alloc] init];
        coverView.backgroundColor = _coverColor?_coverColor:[UIColor lightGrayColor];
        coverView.layer.cornerRadius = _coverCornerRadius;
        [self.titleScrollView insertSubview:coverView atIndex:0];
        
        _coverView = coverView;
    }
    return _isShowTitleCover?_coverView:nil;
}

- (UIView *)underLine
{
    if (_underLine == nil) {
        
        UIView *underLineView = [[UIView alloc] init];
        
        underLineView.backgroundColor = _underLineColor?_underLineColor:[UIColor redColor];
        
        [self.titleScrollView addSubview:underLineView];
        
        _underLine = underLineView;
        
    }
    return _isShowUnderLine?_underLine : nil;
}

- (NSMutableArray *)titleLabels
{
    if (_titleLabels == nil) {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}

// 懒加载标题滚动视图
- (UIScrollView *)titleScrollView
{
    if (_titleScrollView == nil) {
        
        UIScrollView *titleScrollView = [[UIScrollView alloc] init];
        titleScrollView.backgroundColor = _titleScrollViewColor;
        
        
        //        titleScrollView.backgroundColor = _titleScrollViewColor?_titleScrollViewColor:[UIColor colorWithWhite:1 alpha:0.7];
        
        
        if (_titleLableOnNavigationBar) {
            [self.navigationController.navigationBar addSubview:titleScrollView];
        }else {
            
            [self.contentView addSubview:titleScrollView];
        }
        
        _titleScrollView = titleScrollView;
        
    }
    return _titleScrollView;
}

// 懒加载内容滚动视图
- (UIScrollView *)contentScrollView
{
    if (_contentScrollView == nil) {
        
        // 创建布局
        RXFlowLayout *layout = [[RXFlowLayout alloc] init];
        
        UICollectionView *contentScrollView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _contentScrollView = contentScrollView;
        if (@available(iOS 11.0, *)) {
            _contentScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        // 设置内容滚动视图
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.bounces = NO;
        _contentScrollView.delegate = self;
        _contentScrollView.dataSource = self;
        [self.contentView insertSubview:contentScrollView belowSubview:self.titleScrollView];
        
    }
    
    return _contentScrollView;
}

// 懒加载整个内容view
- (UIView *)contentView
{
    if (_contentView == nil) {
        
        UIView *contentView = [[UIView alloc] init];
        _contentView = contentView;
        [self.view addSubview:contentView];
        
    }
    
    return _contentView;
}


#pragma mark - 属性setter方法
- (void)setIsShowTitleScale:(BOOL)isShowTitleScale
{
    if (_isShowUnderLine) {
        // 抛异常
        NSException *excp = [NSException exceptionWithName:@"RXDisplayViewControllerException" reason:@"字体放大效果和角标不能同时使用。" userInfo:nil];
        [excp raise];
    }
    
    _isShowTitleScale = isShowTitleScale;
}

- (void)setIsShowUnderLine:(BOOL)isShowUnderLine
{
    if (_isShowTitleScale) {
        // 抛异常
        NSException *excp = [NSException exceptionWithName:@"RXDisplayViewControllerException" reason:@"字体放大效果和角标不能同时使用。" userInfo:nil];
        [excp raise];
    }
    
    _isShowUnderLine = isShowUnderLine;
}

- (void)setTitleScrollViewColor:(UIColor *)titleScrollViewColor
{
    _titleScrollViewColor = titleScrollViewColor;
    
    self.titleScrollView.backgroundColor = titleScrollViewColor;
}

- (void)setIsfullScreen:(BOOL)isfullScreen
{
    _isfullScreen = isfullScreen;
    
    self.contentView.frame = CGRectMake(0, 0, RXScreenW, RXScreenH);
    
}


- (void)setContentCanScroll:(BOOL)contentCanScroll {
    _contentCanScroll = contentCanScroll;
    self.contentScrollView.scrollEnabled = contentCanScroll;
}

// 设置整体内容的尺寸
- (void)setUpContentViewFrame:(void (^)(UIView *))contentBlock
{
    if (contentBlock) {
        contentBlock(self.contentView);
    }
}

// 一次性设置所有颜色渐变属性
- (void)setUpTitleGradient:(void (^)(BOOL *, RXTitleColorGradientStyle *, CGFloat *, CGFloat *, CGFloat *, CGFloat *, CGFloat *, CGFloat *))titleGradientBlock
{
    if (titleGradientBlock) {
        titleGradientBlock(&_isShowTitleGradient,&_titleColorGradientStyle,&_startR,&_startG,&_startB,&_endR,&_endG,&_endB);
    }
}

// 一次性设置所有遮盖属性
- (void)setUpCoverEffect:(void (^)(BOOL *, UIColor **, CGFloat *))coverEffectBlock
{
    UIColor *color;
    
    if (coverEffectBlock) {
        
        coverEffectBlock(&_isShowTitleCover,&color,&_coverCornerRadius);
        
        if (color) {
            _coverColor = color;
        }
        
    }
}

// 一次性设置所有字体缩放属性
- (void)setUpTitleScale:(void(^)(BOOL *isShowTitleScale,CGFloat *titleScale))titleScaleBlock
{
    if (titleScaleBlock) {
        titleScaleBlock(&_isShowTitleScale,&_titleScale);
    }
}

// 一次性设置所有下标属性
- (void)setUpUnderLineEffect:(void(^)(BOOL *isShowUnderLine,BOOL *isDelayScroll,CGFloat *underLineH,UIColor **underLineColor))underLineBlock
{
    UIColor *underLineColor;
    
    if (underLineBlock) {
        underLineBlock(&_isShowUnderLine,&_isDelayScroll,&_underLineH,&underLineColor);
        
        _underLineColor = underLineColor;
    }
    
}

// 一次性设置所有标题属性
- (void)setUpTitleEffect:(void(^)(UIColor **titleScrollViewColor,UIColor **norColor,UIColor **selColor,UIFont **titleFont,CGFloat *titleHeight))titleEffectBlock{
    UIColor *titleScrollViewColor;
    UIColor *norColor;
    UIColor *selColor;
    UIFont *titleFont;
    if (titleEffectBlock) {
        titleEffectBlock(&titleScrollViewColor,&norColor,&selColor,&titleFont,&_titleHeight);
        _norColor = norColor;
        _selColor = selColor;
        _titleScrollViewColor = titleScrollViewColor;
        _titleFont = titleFont;
    }
}


#pragma mark - 控制器view生命周期方法

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat contentY = self.navigationController?RXNavBarH : [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat contentW = RXScreenW;
    CGFloat contentH = RXScreenH - contentY;
    // 设置整个内容的尺寸
    if (self.contentView.height == 0) {
        // 没有设置内容尺寸，才需要设置内容尺寸
        self.contentView.frame = CGRectMake(0, contentY, contentW, contentH);
    }
    
    // 设置标题滚动视图frame
    // 计算尺寸
    CGFloat titleH = _titleHeight?_titleHeight:RXTitleScrollViewH;
    CGFloat titleY = _isfullScreen?contentY:0;
    self.titleScrollView.frame = CGRectMake(0, titleY, contentW, titleH);
    
    // 设置内容滚动视图frame
    CGFloat contentScrollY = CGRectGetMaxY(self.titleScrollView.frame);
    self.contentScrollView.frame = _isfullScreen?CGRectMake(0, 0, contentW, RXScreenH) :CGRectMake(0, contentScrollY, contentW, self.contentView.height - contentScrollY);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isInitial == NO) {
        
        _isInitial = YES;
        
        // 注册cell
        [self.contentScrollView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ID];
        self.contentScrollView.backgroundColor = self.view.backgroundColor;
        
        // 初始化
        [self setUp];
        
        // 没有子控制器，不需要设置标题
        if (self.childViewControllers.count == 0) return;
        
        [self setUpTitleWidth];
        
        [self setUpAllTitle];
        
    }
    
    
}

#pragma mark - 添加标题方法
// 计算所有标题宽度
- (void)setUpTitleWidth
{
    // 判断是否能占据整个屏幕
    NSUInteger count = self.childViewControllers.count;
    
    NSArray *titles = [self.childViewControllers valueForKeyPath:@"title"];
    
    CGFloat totalWidth = 0;
    
    // 计算所有标题的宽度
    for (NSString *title in titles) {
        
        if ([title isKindOfClass:[NSNull class]]) {
            // 抛异常
            NSException *excp = [NSException exceptionWithName:@"RXDisplayViewControllerException" reason:@"没有设置Controller.title属性，应该把子标题保存到对应子控制器中" userInfo:nil];
            [excp raise];
            
        }
        
        CGRect titleBounds = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
        
        CGFloat width = titleBounds.size.width;
        
        [self.titleWidths addObject:@(width)];
        
        totalWidth += width;
    }
    
    if (totalWidth > RXScreenW) {
        
        _titleMargin = margin;
        
        self.titleScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, _titleMargin);
        return;
    }
    
    CGFloat titleMargin = (RXScreenW - totalWidth) / (count + 1);
    
    _titleMargin = titleMargin < margin? margin: titleMargin;
    
    self.titleScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, _titleMargin);
}


// 设置所有标题
- (void)setUpAllTitle
{
    
    // 遍历所有的子控制器
    NSUInteger count = self.childViewControllers.count;
    
    // 添加所有的标题
    CGFloat labelW = 0;
    CGFloat labelH = self.titleHeight;
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    
    for (int i = 0; i < count; i++) {
        
        UIViewController *vc = self.childViewControllers[i];
        
        UILabel *label = [[RXDisplayTitleLabel alloc] init];
        //        label.backgroundColor = [UIColor redColor];
        label.tag = i;
        
        // 设置按钮的文字颜色
        label.textColor = self.norColor;
        
        label.font = self.titleFont;
        
        // 设置按钮标题
        label.text = vc.title;
        
        labelW = [self.titleWidths[i] floatValue];
        
        // 设置按钮位置
        UILabel *lastLabel = [self.titleLabels lastObject];
        
        labelX = _titleMargin + CGRectGetMaxX(lastLabel.frame);
        
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        
        // 监听标题的点击
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick:)];
        [label addGestureRecognizer:tap];
        
        // 保存到数组
        [self.titleLabels addObject:label];
        
        [_titleScrollView addSubview:label];
        
        if (i == _selectIndex) {
            [self titleClick:tap];
        }
    }
    
    // 设置标题滚动视图的内容范围
    UILabel *lastLabel = self.titleLabels.lastObject;
    _titleScrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastLabel.frame), 0);
    _titleScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.contentSize = CGSizeMake(count * RXScreenW, 0);
    
}

#pragma mark - 标题效果渐变方法
// 设置标题颜色渐变
- (void)setUpTitleColorGradientWithOffset:(CGFloat)offsetX rightLabel:(RXDisplayTitleLabel *)rightLabel leftLabel:(RXDisplayTitleLabel *)leftLabel
{
    if (_isShowTitleGradient == NO) return;
    
    // 获取右边缩放
    CGFloat rightSacle = offsetX / RXScreenW - leftLabel.tag;
    
    // 获取左边缩放比例
    CGFloat leftScale = 1 - rightSacle;
    
    // RGB渐变
    if (_titleColorGradientStyle == RXTitleColorGradientStyleRGB) {
        
        CGFloat r = _endR - _startR;
        CGFloat g = _endG - _startG;
        CGFloat b = _endB - _startB;
        
        // rightColor
        // 1 0 0
        UIColor *rightColor = [UIColor colorWithRed:_startR + r * rightSacle green:_startG + g * rightSacle blue:_startB + b * rightSacle alpha:1];
        
        // 0.3 0 0
        // 1 -> 0.3
        // leftColor
        UIColor *leftColor = [UIColor colorWithRed:_startR +  r * leftScale  green:_startG +  g * leftScale  blue:_startB +  b * leftScale alpha:1];
        
        // 右边颜色
        rightLabel.textColor = rightColor;
        
        // 左边颜色
        leftLabel.textColor = leftColor;
        
        return;
    }
    
    // 填充渐变
    if (_titleColorGradientStyle == RXTitleColorGradientStyleFill) {
        
        // 获取移动距离
        CGFloat offsetDelta = offsetX - _lastOffsetX;
        
        if (offsetDelta > 0) { // 往右边
            
            
            rightLabel.fillColor = self.selColor;
            rightLabel.progress = rightSacle;
            
            leftLabel.fillColor = self.norColor;
            leftLabel.progress = rightSacle;
            
        } else if(offsetDelta < 0){ // 往左边
            
            rightLabel.textColor = self.norColor;
            rightLabel.fillColor = self.selColor;
            rightLabel.progress = rightSacle;
            
            leftLabel.textColor = self.selColor;
            leftLabel.fillColor = self.norColor;
            leftLabel.progress = rightSacle;
            
        }
    }
}

// 标题缩放
- (void)setUpTitleScaleWithOffset:(CGFloat)offsetX rightLabel:(UILabel *)rightLabel leftLabel:(UILabel *)leftLabel
{
    if (_isShowTitleScale == NO) return;
    
    // 获取右边缩放
    CGFloat rightSacle = offsetX / RXScreenW - leftLabel.tag;
    
    CGFloat leftScale = 1 - rightSacle;
    
    CGFloat scaleTransform = _titleScale?_titleScale:RXTitleTransformScale;
    
    scaleTransform -= 1;
    
    // 缩放按钮
    leftLabel.transform = CGAffineTransformMakeScale(leftScale * scaleTransform + 1, leftScale * scaleTransform + 1);
    
    // 1 ~ 1.3
    rightLabel.transform = CGAffineTransformMakeScale(rightSacle * scaleTransform + 1, rightSacle * scaleTransform + 1);
}

// 获取两个标题按钮宽度差值
- (CGFloat)widthDeltaWithRightLabel:(UILabel *)rightLabel leftLabel:(UILabel *)leftLabel
{
    CGRect titleBoundsR = [rightLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    
    CGRect titleBoundsL = [leftLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    
    return titleBoundsR.size.width - titleBoundsL.size.width;
}

// 设置下标偏移
- (void)setUpUnderLineOffset:(CGFloat)offsetX rightLabel:(UILabel *)rightLabel leftLabel:(UILabel *)leftLabel
{
    if (_isClickTitle) return;
    
    // 获取两个标题中心点距离
    CGFloat centerDelta = rightLabel.x - leftLabel.x;
    
    // 标题宽度差值
    CGFloat widthDelta = [self widthDeltaWithRightLabel:rightLabel leftLabel:leftLabel];
    
    // 获取移动距离
    CGFloat offsetDelta = offsetX - _lastOffsetX;
    
    // 计算当前下划线偏移量
    CGFloat underLineTransformX = offsetDelta * centerDelta / RXScreenW;
    
    // 宽度递增偏移量
    CGFloat underLineWidth = offsetDelta * widthDelta / RXScreenW;
    
    self.underLine.width += underLineWidth;
    self.underLine.x += underLineTransformX;
    
}

// 设置遮盖偏移
- (void)setUpCoverOffset:(CGFloat)offsetX rightLabel:(UILabel *)rightLabel leftLabel:(UILabel *)leftLabel
{
    if (_isClickTitle) return;
    
    // 获取两个标题中心点距离
    CGFloat centerDelta = rightLabel.x - leftLabel.x;
    
    // 标题宽度差值
    CGFloat widthDelta = [self widthDeltaWithRightLabel:rightLabel leftLabel:leftLabel];
    
    // 获取移动距离
    CGFloat offsetDelta = offsetX - _lastOffsetX;
    
    // 计算当前下划线偏移量
    CGFloat coverTransformX = offsetDelta * centerDelta / RXScreenW;
    
    // 宽度递增偏移量
    CGFloat coverWidth = offsetDelta * widthDelta / RXScreenW;
    
    self.coverView.width += coverWidth;
    self.coverView.x += coverTransformX;
    
}

#pragma mark - 标题点击处理
- (void)setSelectIndex:(BOOL)selectIndex
{
    _selectIndex = selectIndex;
    if (self.titleLabels.count) {
        
        UILabel *label = self.titleLabels[selectIndex];
        
        [self titleClick:[label.gestureRecognizers lastObject]];
    }
}

// 标题按钮点击
- (void)titleClick:(UITapGestureRecognizer *)tap
{
    // 记录是否点击标题
    _isClickTitle = YES;
    
    // 获取对应标题label
    UILabel *label = (UILabel *)tap.view;
    
    // 获取当前角标
    NSInteger i = label.tag;
    
    // 选中label
    [self selectLabel:label];
    
    // 内容滚动视图滚动到对应位置
    CGFloat offsetX = i * RXScreenW;
    
    self.contentScrollView.contentOffset = CGPointMake(offsetX, 0);
    
    // 记录上一次偏移量,因为点击的时候不会调用scrollView代理记录，因此需要主动记录
    _lastOffsetX = offsetX;
    
    // 添加控制器
    UIViewController *vc = self.childViewControllers[i];
    
    // 判断控制器的view有没有加载，没有就加载，加载完在发送通知
    if (vc.view) {
        // 发出通知点击标题通知
        [[NSNotificationCenter defaultCenter] postNotificationName:RXDisplayViewClickOrScrollDidFinshNote  object:vc];
        if (self.selectBlock) {
            self.selectBlock(i);
        }
        
        // 发出重复点击标题通知
        if (_selIndex == i) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RXDisplayViewRepeatClickTitleNote object:vc];
            _selIndex = i;
        }
    }
    
    // 点击事件处理完成
    _isClickTitle = NO;
}

- (void)selectLabel:(UILabel *)label
{
    
    for (RXDisplayTitleLabel *labelView in self.titleLabels) {
        
        if (label == labelView) continue;
        
        if (_isShowTitleGradient && _titleColorGradientStyle == RXTitleColorGradientStyleRGB) {
            
            labelView.transform = CGAffineTransformIdentity;
        }
        
        labelView.textColor = self.norColor;
        
        if (_isShowTitleGradient && _titleColorGradientStyle == RXTitleColorGradientStyleFill) {
            
            labelView.fillColor = self.norColor;
            
            labelView.progress = 1;
        }
        
    }
    
    // 标题缩放
    if (_isShowTitleScale && _titleColorGradientStyle == RXTitleColorGradientStyleRGB) {
        
        CGFloat scaleTransform = _titleScale?_titleScale:RXTitleTransformScale;
        
        label.transform = CGAffineTransformMakeScale(scaleTransform, scaleTransform);
    }
    
    // 修改标题选中颜色
    label.textColor = self.selColor;
    
    // 设置标题居中
    [self setLabelTitleCenter:label];
    
    // 设置下标的位置
    [self setUpUnderLine:label];
    
    // 设置cover
    [self setUpCoverView:label];
    
}

// 设置蒙版
- (void)setUpCoverView:(UILabel *)label
{
    // 获取文字尺寸
    CGRect titleBounds = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    
    CGFloat border = 5;
    CGFloat coverH = titleBounds.size.height + 2 * border;
    CGFloat coverW = titleBounds.size.width + 2 * border;
    
    self.coverView.y = (label.height - coverH) * 0.5;
    self.coverView.height = coverH;
    
    
    // 最开始不需要动画
    if (self.coverView.x == 0) {
        self.coverView.width = coverW;
        
        self.coverView.x = label.x - border;
        return;
    }
    
    // 点击时候需要动画
    [UIView animateWithDuration:0.25 animations:^{
        self.coverView.width = coverW;
        
        self.coverView.x = label.x - border;
    }];
    
    
    
}


// 设置下标的位置
- (void)setUpUnderLine:(UILabel *)label
{
    // 获取文字尺寸
    CGRect titleBounds = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    
    CGFloat underLineH = _underLineH?_underLineH:RXUnderLineH;
    
    self.underLine.y = label.height - underLineH;
    self.underLine.height = underLineH;
    
    
    // 最开始不需要动画
    if (self.underLine.x == 0) {
        self.underLine.width = titleBounds.size.width+30;
        
        self.underLine.x = label.x-15;
        return;
    }
    
    // 点击时候需要动画
    [UIView animateWithDuration:0.25 animations:^{
        self.underLine.width = titleBounds.size.width+30;
        self.underLine.x = label.x-15;
    }];
    
}

// 让选中的按钮居中显示
- (void)setLabelTitleCenter:(UILabel *)label
{
    
    // 设置标题滚动区域的偏移量
    CGFloat offsetX = label.center.x - RXScreenW * 0.5;
    
    if (offsetX < 0) {
        offsetX = 0;
    }
    
    // 计算下最大的标题视图滚动区域
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - RXScreenW + _titleMargin;
    
    if (maxOffsetX < 0) {
        maxOffsetX = 0;
    }
    
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    
    // 滚动区域
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
}

#pragma mark - 刷新界面方法
// 更新界面
- (void)refreshDisplay
{
    // 清空之前所有标题
    [self.titleLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.titleLabels removeAllObjects];
    
    // 刷新表格
    [self.contentScrollView reloadData];
    
    // 重新设置标题
    [self setUpTitleWidth];
    
    [self setUpAllTitle];
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.childViewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    // 移除之前的子控件
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 添加控制器
    UIViewController *vc = self.childViewControllers[indexPath.row];
    
    vc.view.frame = CGRectMake(0, 0, self.contentScrollView.width, self.contentScrollView.height);
    
    [cell.contentView addSubview:vc.view];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

// 减速完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger offsetXInt = offsetX;
    NSInteger screenWInt = RXScreenW;
    
    NSInteger extre = offsetXInt % screenWInt;
    if (extre > RXScreenW * 0.5) {
        // 往右边移动
        offsetX = offsetX + (RXScreenW - extre);
        _isAniming = YES;
        [self.contentScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }else if (extre < RXScreenW * 0.5 && extre > 0){
        _isAniming = YES;
        // 往左边移动
        offsetX =  offsetX - extre;
        [self.contentScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
    
    // 获取角标
    NSInteger i = offsetX / RXScreenW;
    
    // 选中标题
    [self selectLabel:self.titleLabels[i]];
    
    // 取出对应控制器发出通知
    UIViewController *vc = self.childViewControllers[i];
    
    // 发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:RXDisplayViewClickOrScrollDidFinshNote object:vc];
    
    if (self.selectBlock) {
        self.selectBlock(i);
    }
}


// 监听滚动动画是否完成
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _isAniming = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 点击和动画的时候不需要设置
    if (_isAniming || self.titleLabels.count == 0) return;
    
    // 获取偏移量
    CGFloat offsetX = scrollView.contentOffset.x;
    
    // 获取左边角标
    NSInteger leftIndex = offsetX / RXScreenW;
    
    // 左边按钮
    RXDisplayTitleLabel *leftLabel = self.titleLabels[leftIndex];
    
    // 右边角标
    NSInteger rightIndex = leftIndex + 1;
    
    // 右边按钮
    RXDisplayTitleLabel *rightLabel = nil;
    
    if (rightIndex < self.titleLabels.count) {
        rightLabel = self.titleLabels[rightIndex];
    }
    
    // 字体放大
    [self setUpTitleScaleWithOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    
    // 设置下标偏移
    if (_isDelayScroll == NO) { // 延迟滚动，不需要移动下标
        
        [self setUpUnderLineOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    }
    
    // 设置遮盖偏移
    [self setUpCoverOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    
    // 设置标题渐变
    [self setUpTitleColorGradientWithOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    
    // 记录上一次的偏移量
    _lastOffsetX = offsetX;
}

@end
