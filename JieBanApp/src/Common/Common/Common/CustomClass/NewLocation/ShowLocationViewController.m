//
//  ShowLocationViewController.m
//  Chat
//
//  Created by zhangmingfei on 2017/6/23.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ShowLocationViewController.h"
#import "QMapKit.h"
#import "UIImage+deal.h"
#import <MapKit/MapKit.h>
#import "RXCollectData.h"
#import "RestApi.h"
#define KNOTIFICATION_onReceivedGroupNotice    @"KNOTIFICATION_onReceivedGroupNotice"
@interface ShowLocationViewController ()<QMapViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) QMapView *mapView;

@property (nonatomic, strong) ECLocationPoint *locationPoint;//传进来的数据

@property (nonatomic, strong) NSMutableArray<id <QAnnotation> > *annotations;

@property (nonatomic,strong) RXCollectData *collectData;//当前消息

@end

@implementation ShowLocationViewController

- (NSMutableArray<id<QAnnotation>> *)annotations {
    if (_annotations == nil) {
        _annotations = [NSMutableArray arrayWithCapacity:1];
    }
    return _annotations;
}

//聊天界面 点击发送的位置进来 没有定位 中心图标不动 只能导航
- (instancetype)initWithLocationPoint:(ECLocationPoint*)locationPoint {
    self = [super init];
    if (self) {
        _locationPoint = locationPoint;
    }
    return self;
}
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return   UIInterfaceOrientationPortrait ;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"位置信息";
    
    [self setNavUI];
    
    //如果您的系统版本高于iOS7.0，地图会根据按所在界面的status bar，navigationbar，与tabbar的高度，自动调整inset,可以在QmapView初始化之前添加如下设置
    if (iOS7)
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //地图
    self.mapView = [[QMapView alloc] initWithFrame:CGRectMake(0, kTotalBarHeight, kScreenWidth,  kScreenHeight-90*iPhone6FitScreenHeight-kTotalBarHeight)];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    //如果您感觉初始化后显示的地图锯齿太过明显可以按如下代码设置一下缩放级别
    //这里的zoomlevel并没有使用整数，是因为地图SDK中的zoomlevel调整是左开右闭的。
    //这里加了0.01，实际使用的底图是12级的
    [self.mapView setZoomLevel:17.01];
    
    //用户可以通过对QMapView对象设置地图的拖动、缩放及比例尺的显示和隐藏。示例代码如下
    
    //地图平移，默认YES
    _mapView.scrollEnabled = YES;
    //地图缩放，默认YES
    _mapView.zoomEnabled = YES;
    //比例尺是否显示，ƒF默认YES
    _mapView.showsScale = YES;
    

    //开启定位功能
    [_mapView setShowsUserLocation:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView setCenterCoordinate:self.locationPoint.coordinate
                                zoomLevel:self.mapView.zoomLevel animated:YES];
    });
    
    //定义pointAnnotation
    QPointAnnotation *yinke = [[QPointAnnotation alloc] init];
    yinke.coordinate = self.locationPoint.coordinate;
    
    [self.annotations addObject:yinke];
    //向mapview添加annotation
    [_mapView addAnnotations:self.annotations];
    
    //创建底部的视图
    [self createBottomView];
    
    
    
}

- (void)mapView:(QMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //保存截图
    NSString *fileName =[NSString stringWithFormat:@"%@.jpg", self.locationPoint.title];
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if (!image) {
        //这里为什么要加异步的呢 系统提示视图主线程警告了
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self saveViewImage];
//        });
    }
}


- (void)saveViewImage {
    UIImage *newImage = [_mapView takeSnapshotInRect:CGRectMake(0, _mapView.center.y - 100 -64, kScreenWidth, 200)];
    
    [self saveToDocment:newImage];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onReceivedGroupNotice object:nil];
}


- (NSString *)saveToDocment:(UIImage *)image {
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", self.locationPoint.title];
    return [image saveToDocumentAndThumWithFileName:fileName];
}



#pragma mark - 底部视图
- (void)createBottomView {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.mapView.bottom, kScreenWidth, 90*iPhone6FitScreenHeight)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    //位置标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20*iPhone6FitScreenWidth, 20, 50*iPhone6FitScreenWidth*FitThemeFont, 22*iPhone6FitScreenHeight)];
    titleLabel.font = ThemeFontLarge;
    titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    titleLabel.text = @"[位置]";
    titleLabel.numberOfLines = 1;
    [titleLabel sizeToFit];
    [bottomView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(20*iPhone6FitScreenWidth);
        make.top.mas_equalTo(20);
    }];
    
    //地址
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20*iPhone6FitScreenWidth, 55, kScreenWidth-90, 17*iPhone6FitScreenHeight)];
    addressLabel.font =ThemeFontSmall;
    addressLabel.textColor = [UIColor colorWithHexString:@"#A1A7B4"];
    addressLabel.text = self.locationPoint.title;
//    CGSize addressLabelSize = [self.locationPoint.title sizeForFont:ThemeFontSmall constrainedToSize:CGSizeMake((kScreenWidth-90.0f), 1000.0f) lineBreakMode:NSLineBreakByCharWrapping];
//    addressLabel.frame = CGRectMake(20*iPhone6FitScreenWidth, 55, kScreenWidth-90, addressLabelSize.height);
    addressLabel.numberOfLines = 0;
    [bottomView addSubview:addressLabel];
    [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(20*iPhone6FitScreenWidth);
        make.top.mas_equalTo(55);
        make.right.mas_offset(-15-44*iPhone6FitScreenWidth);
    }];
    
    
    //导航按钮
    UIButton *guideButton = [[UIButton alloc] initWithFrame:CGRectMake(311*iPhone6FitScreenWidth, 28*iPhone6FitScreenHeight, 44*iPhone6FitScreenWidth, 44*iPhone6FitScreenWidth)];
    [guideButton setBackgroundImage:ThemeImage(@"collection_icon_position_routebig") forState:UIControlStateNormal];
    [guideButton addTarget:self action:@selector(startGuide) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:guideButton];
    [guideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-15);
        make.top.mas_equalTo(28*iPhone6FitScreenHeight);
        make.size.mas_equalTo(CGSizeMake(44*iPhone6FitScreenWidth, 44*iPhone6FitScreenWidth));
    }];
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_offset(0);
        make.bottom.mas_offset(-90);
    }];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_offset(0);
        make.top.mas_equalTo(self.mapView.mas_bottom);
    }];
    
    if ([self.data[@"from"] isEqualToString:@"alert"]) {
        [guideButton setBackgroundImage:ThemeImage(@"collection_icon_position_routesmall") forState:UIControlStateNormal];
        guideButton.userInteractionEnabled = NO;
    }else if ([self.data[@"from"] isEqualToString:@"collection"]){
        self.collectData = self.data[@"collectData"];
        [self setBarButtonWithNormalImg:ThemeImage(@"barbuttonicon_more") highlightedImg:ThemeImage(@"barbuttonicon_more") target:self action:@selector(moreBtnClick) type:NavigationBarItemTypeRight];
    }
}

- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation {
    static NSString *pointReuseIndentifier = @"pointReuseIdentifier";
    if ([annotation isKindOfClass:[QPointAnnotation class]]) {
        QAnnotationView *annotationView = (QAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil) {
            annotationView = [[QPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:pointReuseIndentifier];
        }
        UIImage *image = ThemeImage(@"redPin_lift");
        annotationView.image = image;
        annotationView.draggable = NO;
        return annotationView;
    }
    return nil;
}

#pragma mark - 导航栏按钮
- (void)setNavUI {
    [self setBarButtonWithNormalImg:ThemeImage(@"title_bar_back") highlightedImg:ThemeImage(@"title_bar_back") target:self action:@selector(popToBackClicked) type:NavigationBarItemTypeLeft];
//    CGRect btnFrame = CGRectMake(0, 0, 40, 40);
//    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setFrame:btnFrame];
//    [button setImage:ThemeImage(@"title_bar_back") forState:UIControlStateNormal];
//    [button setTitleColor:ThemeColor forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(popToBackClicked) forControlEvents:UIControlEventTouchUpInside];
//    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//
//    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.leftBarButtonItem = buttonItem;
}

- (void)popToBackClicked {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - 导航
- (void)startGuide {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"开始导航" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *guideAction = [UIAlertAction actionWithTitle:@"苹果地图导航" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.locationPoint.coordinate addressDictionary:@{@"title":self.locationPoint.title}];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
        toLocation.name = self.locationPoint.title;
        
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:guideAction];
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
}

/*!
 *  @brief  位置或者设备方向更新后，会调用此函数
 *
 *  @param mapView          地图view
 *  @param userLocation     用户定位信息(包括位置与设备方向等数据)
 *  @param updatingLocation 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
 */
- (void)mapView:(QMapView *)mapView didUpdateUserLocation:(QUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    [mapView setCenterCoordinate:self.locationPoint.coordinate
                            zoomLevel:self.mapView.zoomLevel animated:YES];
}

/*!
 *  @brief  定位失败后，会调用此函数
 *
 *  @param mapView 地图view
 *  @param error   错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(QMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    
}

#pragma mark 更多
- (void)moreBtnClick{
    
    WS(weakSelf)
    [self showSheetWithItems:@[languageStringWithKey(@"分享"),languageStringWithKey(@"删除")] inView:self.view selectedIndex:^(NSInteger index) {
        if (index ==0) {
            if (weakSelf.collectData) {
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:weakSelf.collectData,@"transmitedMsg", nil];
                BOOL isTransmit = YES;
                NSNumber *isTransmitNum = [NSNumber numberWithBool:isTransmit];
                NSDictionary *exceptData = @{@"msg":dict,@"isTransmitNum":isTransmitNum, @"collectionPage_IM_forwardMenu":@"collectionPage_IM_forwardMenu"};
                UIViewController *groupVC = [[Common sharedInstance].componentDelegate getChooseMembersVCWithExceptData:exceptData WithType:SelectObjectType_TransmitSelectMember];
                [weakSelf pushViewController:groupVC];
            }
        }else if (index == 1){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *quitAction = [UIAlertAction actionWithTitle:languageStringWithKey(@"取消") style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:quitAction];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:languageStringWithKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [RestApi deleteCollectDataWithAccount:[[Common sharedInstance] getAccount] CollectIds:@[weakSelf.collectData.collectId] didFinishLoaded:^(NSDictionary *dict, NSString *path) {
                    NSDictionary *headDic = [dict objectForKey:@"head"];
                    NSInteger statusCode = [[headDic objectForKey:@"statusCode"] integerValue];
                    if (statusCode == 000000) {
                        [RXCollectData deleteCollectionData:weakSelf.collectData.collectId];
                        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(popViewController) userInfo:nil repeats:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"collectionFrom_CollectionPage_IM" object:nil];
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }
                } didFailLoaded:^(NSError *error, NSString *path) {
                    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"删除失败")];
                }];
            }];
            [alert addAction:sureAction];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
