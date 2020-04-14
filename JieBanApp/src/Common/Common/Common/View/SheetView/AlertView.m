//
//  AlertView.m
//  Common
//
//  Created by 韩微 on 2017/8/15.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "AlertView.h"
#import "AlertSheetCell.h"
@interface AlertView ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic)  UITableView *cardView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UILabel *viserionLabel;

@property (nonatomic, strong) UIButton *bottomButton;

@end


@implementation AlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (instancetype)init {

    self = [super init];

    if (self) {

        [self internalInit];

    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self internalInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self internalInit];
    }
    
    return self;
}

- (void)internalInit {
    
    self.backgroundColor = [UIColor whiteColor];
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 91*fitScreenHeight)];
    _centerView = [[UIView alloc] initWithFrame:CGRectMake(0, _topView.origin.y+_topView.frame.size.height, self.frame.size.width, 285*fitScreenHeight-91*fitScreenHeight-82*fitScreenHeight)];
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,_centerView.origin.y+_centerView.frame.size.height, self.frame.size.width, 82*fitScreenHeight)];
    [self addSubview:_topView];
    [self addSubview:_centerView];
    [self addSubview:_bottomView];

    
        
}

- (void)loadViewIfNeed:(NSString *)cancel {
    [self loadTopView];
    [self loadTableView];
    [self loadBottonView:cancel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}
- (void)loadCardView {
    [self.cardView reloadData];
}
- (void)loadTopView {
    _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, _topView.frame.size.height)];
    [_topView addSubview:_topImageView];
    _topImageView.image = ThemeImage(@"versionBackI");
    
    _viserionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _topView.frame.size.height/2, _topView.frame.size.width, 12*fitScreenHeight)];
//    _viserionLabel.textColor = [self colorWithHex:0xEDEDEDff];
    _viserionLabel.textColor = [UIColor blackColor];
    _viserionLabel.font =ThemeFontSmall;
    _viserionLabel.text = [NSString stringWithFormat:@"%@ %@",languageStringWithKey(@"版本"), _dataVersion];
    _viserionLabel.textAlignment = NSTextAlignmentCenter;
    
    [_topView addSubview:_viserionLabel];
}

- (void)loadTableView {
    
//    _dataArr = [NSMutableArray arrayWithObjects:@"1.恒信接入统一的认证平台，请使用统一认证的用户名和密码登录", @"2.恒信接入统一的认证平台，请使用统一认证的用户名和密码登录", @"3.恒信接入统一的认证平台，请使用统一认证的用户名和密码登录", nil];
    _dataArr = [NSMutableArray arrayWithObject:_descriptionStr];
    
    self.cardView = [[UITableView alloc] initWithFrame:CGRectMake(29*fitScreenWidth, 0, _centerView.frame.size.width-29*fitScreenWidth-15*fitScreenWidth, _centerView.frame.size.height) style:UITableViewStylePlain];
    self.cardView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.cardView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.cardView.showsHorizontalScrollIndicator = YES;
    self.cardView.delegate = self;
    self.cardView.dataSource = self;
    [_centerView addSubview:self.cardView];
    [self loadCardView];
    
}
- (void)loadBottonView:(NSString *)cancel {
    
    if (!KCNSSTRING_ISEMPTY(cancel)) {
        
        UIButton *buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(20.0*fitScreenWidth, (_bottomView.frame.size.height-28*fitScreenHeight)/2, (_bottomView.frame.size.width-40*fitScreenWidth-10*fitScreenWidth)/2, 28*fitScreenHeight)];
        [_bottomView addSubview:buttonCancel];
        buttonCancel.layer.masksToBounds = YES;
        buttonCancel.layer.cornerRadius = 14;
        buttonCancel.backgroundColor = [self colorWithHex:0x369BECff];
        [buttonCancel setTitle:cancel forState:UIControlStateNormal];
        [buttonCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        buttonCancel.titleLabel.font = ThemeFontLarge;
        [buttonCancel addTarget:self action:@selector(clickedActionCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        _bottomButton = [[UIButton alloc] initWithFrame:CGRectMake((_bottomView.frame.size.width)/2+10*fitScreenWidth, (_bottomView.frame.size.height-28*fitScreenHeight)/2, (_bottomView.frame.size.width-40*fitScreenWidth-10*fitScreenWidth)/2, 28*fitScreenHeight)];
            [_bottomView addSubview:_bottomButton];
        _bottomButton.layer.masksToBounds = YES;
        _bottomButton.layer.cornerRadius = 14;
        _bottomButton.backgroundColor = [self colorWithHex:0x369BECff];
        [_bottomButton setTitle:languageStringWithKey(@"立即升级") forState:UIControlStateNormal];
        [_bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _bottomButton.titleLabel.font = ThemeFontLarge;
        [_bottomButton addTarget:self action:@selector(clickedAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        
        _bottomButton = [[UIButton alloc] initWithFrame:CGRectMake((_bottomView.frame.size.width-137*fitScreenWidth)/2, (_bottomView.frame.size.height-31*fitScreenWidth)/2, 137*fitScreenWidth, 31*fitScreenHeight)];
        [_bottomView addSubview:_bottomButton];
        
        _bottomButton.layer.masksToBounds = YES;
        _bottomButton.layer.cornerRadius = 16;
        _bottomButton.backgroundColor = [self colorWithHex:0x369BECff];
        [_bottomButton setTitle:languageStringWithKey(@"立即升级") forState:UIControlStateNormal];
        [_bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _bottomButton.titleLabel.font = ThemeFontLarge;
        [_bottomButton addTarget:self action:@selector(clickedAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
//    _bottomButton = [[UIButton alloc] initWithFrame:CGRectMake((_bottomView.frame.size.width-137)/2, (_bottomView.frame.size.height-31)/2, 137, 31)];
//    _bottomButton = [[UIButton alloc] initWithFrame:CGRectMake((_bottomView.frame.size.width-137)/2, (_bottomView.frame.size.height-31)/2, 137, 31)];
//    [_bottomView addSubview:_bottomButton];
//    
//    _bottomButton.layer.masksToBounds = YES;
//    _bottomButton.layer.cornerRadius = 16;
//    _bottomButton.backgroundColor = [self colorWithHex:0x369BECff];
//    [_bottomButton setTitle:@"立即升级" forState:UIControlStateNormal];
//    [_bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    _bottomButton.titleLabel.font = ThemeFontLarge;
//    [_bottomButton addTarget:self action:@selector(clickedAction:) forControlEvents:UIControlEventTouchUpInside];
    

    
}
- (void)clickedAction:(UIButton *)btn {
    if (self.removeAlertViewDelegate && [self.removeAlertViewDelegate respondsToSelector:@selector(removeAlertView)]) {
        [self.removeAlertViewDelegate removeAlertView];
    }
    
}
- (void)clickedActionCancel:(UIButton *)btn {
    if (self.removeAlertViewDelegate && [self.removeAlertViewDelegate respondsToSelector:@selector(cancelView)]) {
        [self.removeAlertViewDelegate cancelView];
    }
}
#pragma tableviewDelegate -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        
        for (UIView* subview in [self.cardView subviews])
        {
            if([subview isKindOfClass:[UIImageView class]] && subview.frame.size.width == 2.5)
            {
                UIImageView *img=(UIImageView*)subview;
                img.backgroundColor = [self colorWithHex:0xc0dff6ff];
                break;
            }
        }
        
    });
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    CGSize bubbleSize = [[_dataArr objectAtIndex:indexPath.row] sizeWithFont:ThemeFontMiddle constrainedToSize:CGSizeMake(tableView.frame.size.width-12, 1000.0f) lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat height = [AlertSheetCell getSpaceLabelHeight:[_dataArr objectAtIndex:indexPath.row] withFont:ThemeFontMiddle withWidth:tableView.frame.size.width-12];
    return height;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifierT = @"cell";
    
    AlertSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierT];
    if (cell == nil) {
        cell = [[AlertSheetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierT];
    }
    [cell getTextWith:[_dataArr objectAtIndex:indexPath.row] withWidth:tableView.frame.size.width];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma privite methods -
- (UIColor *)colorWithHex:(int)color {
    
    float red = (color & 0xff000000) >> 24;
    float green = (color & 0x00ff0000) >> 16;
    float blue = (color & 0x0000ff00) >> 8;
    float alpha = (color & 0x000000ff);
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}
@end
