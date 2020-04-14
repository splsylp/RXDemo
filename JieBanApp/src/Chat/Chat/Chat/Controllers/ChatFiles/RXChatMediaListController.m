//
//  RXChatMediaListController.m
//  Chat
//
//  Created by 高源 on 2019/5/5.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "RXChatMediaListController.h"

@interface RXChatMediaListCell : UICollectionViewCell

/** coverImgView */
@property(nonatomic,strong)UIImageView *coverImgView;

/** message */
@property(nonatomic,strong)ECMessage *message;

/** playBtn */
@property(nonatomic,strong)UIButton *playBtn;

@end

@implementation RXChatMediaListCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUpViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews {
    if (!_coverImgView) {
        _coverImgView = [UIImageView new];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImgView.clipsToBounds = YES;
    }
    [self.contentView addSubview:_coverImgView];
    [_coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0);
    }];
    
    if (!_playBtn) {
        _playBtn = [[UIButton alloc]init];
        _playBtn.userInteractionEnabled = NO;
        [self.contentView addSubview:_playBtn];
    }
    [_playBtn setImage:ThemeImage(@"video_button_play_normal") forState:UIControlStateNormal];
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       make.center.mas_offset(0);
    }];
}

- (void)setMessage:(ECMessage *)message {
    _message = message;
    _playBtn.hidden = YES;
    if (message.messageBody.messageBodyType == MessageBodyType_Video ) {
        _playBtn.hidden = NO;
        ECVideoMessageBody *mediaBody = (ECVideoMessageBody *)message.messageBody;
        if (mediaBody.remotePath.length > 8 && mediaBody.thumbnailRemotePath.length <= 0) {
            mediaBody.thumbnailRemotePath = [NSString stringWithFormat:@"%@_thum",mediaBody.remotePath];
        }
        
        if (mediaBody.localPath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath] && (mediaBody.mediaDownloadStatus == ECMediaDownloadSuccessed || message.messageState != ECMessageState_Receive)) {
            UIImage *image = [self getVideoImage:[mediaBody.localPath copy]];
            if (image) {
                _coverImgView.image = image;
            }
        } else if (mediaBody.thumbnailRemotePath.length > 0){
            __weak UIImageView *weakImgView = _coverImgView;
            [_coverImgView sd_setImageWithURL:[NSURL URLWithString:mediaBody.thumbnailRemotePath] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image) {
                    weakImgView.image = image;
                }
            }];
        }
    }else if (message.messageBody.messageBodyType == MessageBodyType_Image){
        ECImageMessageBody *mediaBody = (ECImageMessageBody *)message.messageBody;
        if (mediaBody.remotePath.length > 8 && mediaBody.thumbnailRemotePath.length <= 0) {
            mediaBody.thumbnailRemotePath = [NSString stringWithFormat:@"%@_thum",mediaBody.remotePath];
        }
        __weak UIImageView *weakImgView = _coverImgView;
        [_coverImgView sd_setImageWithURL:[NSURL URLWithString:mediaBody.thumbnailRemotePath] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image) {
                weakImgView.image = image;
            }
        }];
    }
}

-(UIImage *)getVideoImage:(NSString *)videoURL
{
    NSString* fileNoExtStr = [videoURL stringByDeletingPathExtension];
    NSString* imagePath = [NSString stringWithFormat:@"%@.jpg", fileNoExtStr];
    UIImage * returnImage = [[UIImage alloc] initWithContentsOfFile:imagePath] ;
    if (returnImage){
        return returnImage;
    }
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:opts] ;
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset] ;
    gen.appliesPreferredTrackTransform = YES;
    gen.maximumSize = CGSizeMake(360.0f, 480.0f);
    NSError *error = nil;
    CGImageRef image = [gen copyCGImageAtTime: CMTimeMake(1, 1) actualTime:NULL error:&error];
    returnImage = [[UIImage alloc] initWithCGImage:image] ;
    CGImageRelease(image);
    [UIImageJPEGRepresentation(returnImage, 0.6) writeToFile:imagePath atomically:YES];
    return returnImage;
}


@end



@interface RXChatMediaListController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

/** collectionView<##> */
@property(nonatomic,strong)UICollectionView *collectionView;

/** dataSource */
@property(nonatomic,strong)NSMutableDictionary *dataSource;

/** titleArray 分组的标题数组 */
@property(nonatomic,strong)NSMutableArray *titleArray;

/** allImageMsg */
@property(nonatomic,strong)NSArray *allImageMsg;

@end

static CGFloat const gap = 8.f;

@implementation RXChatMediaListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self getDataSource];
    // Do any additional setup after loading the view.
}

- (void)getDataSource {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *allMessage = [[KitMsgData sharedInstance] getAllMediaMessageOfSessionId:self.sessionId];
    allMessage = [[allMessage reverseObjectEnumerator] allObjects];
    NSString *thisWeek = languageStringWithKey(@"本周");
    for (ECMessage *msg in allMessage) {
        if ([self isSameWeek:msg.timestamp]) {
            NSString *key = thisWeek;
            NSMutableArray *arr = [NSMutableArray array];
            if ([dic hasValueForKey:key]) {
                arr = dic[key];
            }
            [arr addObject:msg];
            [dic setObject:arr forKey:key];
        }else {
            NSString *key = [self formateDate:msg.timestamp];
            NSMutableArray *arr = [NSMutableArray array];
            if ([dic hasValueForKey:key]) {
                arr = dic[key];
            }
            [arr addObject:msg];
            [dic setObject:arr forKey:key];
        }
    }
    self.dataSource = dic;
    
    NSMutableArray *allKeys = self.dataSource.allKeys.mutableCopy;
    if (allKeys.count > 0) {
        [allKeys removeObject:thisWeek];
        NSArray *result = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj2 compare:obj1]; //降序
        }];
        self.titleArray = result.mutableCopy;
        if ([self.dataSource.allKeys containsObject:thisWeek]) {        
            [self.titleArray insertObject:thisWeek atIndex:0];
        }
    }
    [self.collectionView reloadData];
    
    self.allImageMsg = [[KitMsgData sharedInstance] getAllImageMessageOfSessionId:self.sessionId];
    self.allImageMsg = [[self.allImageMsg reverseObjectEnumerator] allObjects];
}

//格式化时间戳 年 月
- (NSString *)formateDate:(NSString *)timestamp {
    if (KCNSSTRING_ISEMPTY(timestamp)) {
        return @"";
    }
    NSTimeInterval seconds = timestamp.longLongValue;
    if (timestamp.length == 13) {
        seconds = seconds/1000;
    }
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    dateFmt.dateFormat = @"yyyy/MM";
    return [dateFmt stringFromDate:myDate];
}

//判断是否在本周
- (BOOL)isSameWeek:(NSString *)timestamp {
    if (KCNSSTRING_ISEMPTY(timestamp)) {
        return NO;
    }
    NSTimeInterval seconds = timestamp.longLongValue;
    if (timestamp.length == 13) {
        seconds = seconds/1000;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp1 = [calendar components:NSCalendarUnitWeekday fromDate:now];
    NSDateComponents *comp2 = [calendar components:NSCalendarUnitWeekday fromDate:date];
    
    NSUInteger week1 = [self currentWeekdayFormSystem:comp1.weekday];
    NSUInteger week2 = [self currentWeekdayFormSystem:comp2.weekday];
    
    NSTimeInterval differ = date.timeIntervalSince1970 - now.timeIntervalSince1970;
    
    int offsetOneDay = 24*60*60;
    
    if (differ == 0) {
        return YES;
    }else if (differ > 0){
        return differ < offsetOneDay * week2 ? YES : NO;
    }else {
        return -differ < offsetOneDay * week1 ? YES : NO;
    }
}

- (NSUInteger)currentWeekdayFormSystem:(NSUInteger)weekday {
    switch (weekday) {
        case 1:
            return 7;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 2;
            break;
        case 4:
            return 3;
            break;
        case 5:
            return 4;
            break;
        case 6:
            return 5;
            break;
        case 7:
            return 6;
            break;
        default:
            return 0;
            break;
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = gap;
        layout.minimumInteritemSpacing = gap;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor colorWithHexString:@"F4F4F4"];
        [self.view addSubview:_collectionView];
        [_collectionView registerClass:RXChatMediaListCell.class forCellWithReuseIdentifier:NSStringFromClass(RXChatMediaListCell.class)];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"oneHeader"];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(0);
        }];
    }
    return _collectionView;
}

#pragma mark  - delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (kScreenWidth-gap*5)/4;
    return CGSizeMake(width, width);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(kScreenWidth, 30.f-gap);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.titleArray.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(gap, gap, 0, gap);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *arr = self.dataSource[self.titleArray[section]];
    return arr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RXChatMediaListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(RXChatMediaListCell.class) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    NSArray *arr = self.dataSource[self.titleArray[indexPath.section]];
    ECMessage *message = arr[indexPath.item];
    cell.message = message;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"oneHeader" forIndexPath:indexPath];
    headerView.backgroundColor = collectionView.backgroundColor;
    
    UILabel *titleLabel = [headerView viewWithTag:1000];
    if (!titleLabel) {
        titleLabel = [UILabel new];
        titleLabel.tag = 1000;
        titleLabel.font = ThemeFontSmall;
        titleLabel.textColor = [UIColor colorWithHexString:@"3D3D3D"];
        [headerView addSubview:titleLabel];
    }
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(gap);
        make.bottom.mas_offset(2);
    }];
    NSString *key = self.titleArray[indexPath.section];
    titleLabel.text = key;
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = self.dataSource[self.titleArray[indexPath.section]];
    ECMessage *message = arr[indexPath.item];
    if (message.messageBody.messageBodyType == MessageBodyType_Video ) {
        [self videoCellPlayVideo:message];
    }else if (message.messageBody.messageBodyType == MessageBodyType_Image){
        RXChatMediaListCell *cell = (RXChatMediaListCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [self showImagesWith:message imageView:cell.coverImgView];
    }
}

#pragma mark - 播放小视频
-(void)videoCellPlayVideo:(ECMessage *)message{
    __weak typeof(ECMessage *)weakMessage = message;
    [[AppModel sharedInstance] readedMessage:message completion:^(ECError *error, ECMessage *amessage) {
        if (error.errorCode == ECErrorType_NoError) {
            weakMessage.isRead = YES;
            [[KitMsgData sharedInstance] updateMessageReadStateByMessageId:amessage.messageId isRead:amessage.isRead];
        }
    }];
    
    ECVideoMessageBody *mediaBody = (ECVideoMessageBody*)message.messageBody;
    if (message.messageState != ECMessageState_Receive && mediaBody.localPath.length>0&&[[NSFileManager defaultManager]fileExistsAtPath:mediaBody.localPath] ) {
        [self createMPPlayerController:mediaBody.localPath];
        return;
    }
    if (mediaBody.mediaDownloadStatus != ECMediaDownloadSuccessed || mediaBody.localPath.length == 0) {
        [SVProgressHUD showWithStatus:languageStringWithKey(@"正在加载视频，请稍后")];
        __weak typeof(self) weakSelf = self;
        [[ChatMessageManager sharedInstance] downloadMediaMessage:message andCompletion:^(ECError *error, ECMessage *message) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [SVProgressHUD dismiss];
            if (error.errorCode == ECErrorType_NoError) {
                [strongSelf createMPPlayerController:mediaBody.localPath];
            }
        }];
    } else {
        [self createMPPlayerController:mediaBody.localPath];
    }
}

- (void)createMPPlayerController:(NSString *)fileNamePath {
    NSString *videoName = fileNamePath.lastPathComponent;
    NSString *cachePath = [NSCacheDirectory() stringByAppendingPathComponent:videoName];
    //    //视频播放的url
    NSURL *playerURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", cachePath]];
    //初始化
    AVPlayerViewController *playerView2 = [[AVPlayerViewController alloc]init];
    //        AVPlayerViewController *playerView2 = [[AVPlayerViewController alloc]init];
    playerView2.player = [AVPlayer playerWithURL:playerURL];
    playerView2.videoGravity = AVLayerVideoGravityResizeAspect;
    playerView2.showsPlaybackControls = YES;
    // 设置拉伸模式
    playerView2.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // 设置是否显示媒体播放组件
    playerView2.showsPlaybackControls = YES;
    // 设置大力
    //    playerView2.delegate = self;
    // 播放视频
    [playerView2.player play];
    // 设置媒体播放器视图大小
    playerView2.view.bounds = [UIScreen mainScreen].bounds;
    //    playerView2.view.center = CGPointMake(CGRectGetMidX(self.
    
    [playerView2.view setBackgroundColor:[UIColor clearColor]];
    [playerView2.view setFrame:[UIScreen mainScreen].bounds];
    
    [self presentViewController:playerView2 animated:NO completion:nil];
}

- (void)showImagesWith:(ECMessage *)message imageView:(UIImageView *)imageView {
    NSMutableArray *imgModelArray =[[NSMutableArray alloc] init];
    int index = 0;
    for (int i = 0;i < self.allImageMsg.count;i++) {
        ECMessage *msg = self.allImageMsg[i];
        if ([message.messageId isEqualToString:msg.messageId]) {
            index = i;
        }
    }
    imgModelArray = [self getImageMessage];
    MSSBrowseViewController *bvc = [[MSSBrowseViewController alloc] initWithBrowseItemArray:imgModelArray currentIndex:index];
    bvc.clickArr = @[MSSBrowseTypeString(MSSBrowseTypeForward),MSSBrowseTypeString(MSSBrowseTypeCollect),MSSBrowseTypeString(MSSBrowseTypeSave)];
    [bvc showBrowseViewController];
}

//获取会话消息里面为图片消息的路径数组
- (NSMutableArray *)getImageMessage{
    
    NSMutableDictionary *showCellImageDic = [NSMutableDictionary dictionary];
    //查询当前显示的图片cell 用来获取显示图片的坐标
    if (self.collectionView.visibleCells && self.collectionView.visibleCells.count > 0 ) {
        for (id temp in [self.collectionView.visibleCells copy]) {
            if([temp isKindOfClass:[RXChatMediaListCell class]]){
                RXChatMediaListCell *imgCell = (RXChatMediaListCell *)temp;
                [showCellImageDic setObject:imgCell forKey:imgCell.message.messageId];
            }
        }
    }
    
    NSArray *imageMessage = self.allImageMsg;
    NSMutableArray *imageMessageArray = [NSMutableArray array];
    for (ECMessage *message in imageMessage) {
        NSDictionary *im_modeDic =  [MessageTypeManager getCusDicWithUserData:message.userData];
        NSString *localPath = nil;
        BOOL isBurnMsg = NO;
        if ([[im_modeDic objectForKey:kRonxinBURN_MODE] isEqualToString:kRONGXINBURN_ON] ){
            isBurnMsg = YES;
        }
        if ([[im_modeDic objectForKey:kRonxinBURN_MODE] isEqualToString:kRONGXINBURN_OFF] ||
            ![im_modeDic hasValueForKey:kRonxinBURN_MODE] ||
            [im_modeDic hasValueForKey:@"isRead"] ||
            [message.from isEqualToString:[[Chat sharedInstance] getAccount]] ||
            message.isRead){
            ECImageMessageBody *imageBody = (ECImageMessageBody *)message.messageBody;
            localPath = imageBody.localPath;
            if (localPath) {//图片路径
                localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:localPath.lastPathComponent];
                
                MSSBrowseModel *yxpModel =[[MSSBrowseModel alloc] init];
                yxpModel.bigImageUrl = imageBody.remotePath?imageBody.remotePath:@"";
                yxpModel.locImgUrl = localPath;
                yxpModel.authId = message.from;
                yxpModel.messageId = message.messageId;
                yxpModel.isBurnMessage = isBurnMsg;
                if([showCellImageDic.allKeys containsObject:message.messageId]){
                    RXChatMediaListCell *showimgCell = showCellImageDic[message.messageId];
                    CGRect imgRect = [showimgCell.coverImgView.superview convertRect:showimgCell.coverImgView.frame toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
                    yxpModel.smallimageViewFrame = imgRect;
                    yxpModel.smallImageView = showimgCell.coverImgView;
                }
                [imageMessageArray addObject:yxpModel];
            }
        }
    }
    return imageMessageArray;
}

@end

