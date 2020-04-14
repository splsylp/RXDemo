//
//  HXMergeMessageDetailController.m
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/3/31.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXMergeMessageDetailController.h"
#import "HXMergeMessageFatherCell.h"
#import "DocumentDownLoadView.h"
#import "HXMessageMergeManager.h"
#import "HXMergeMessageModel.h"
#import "HXMergerMessageBubbleFatherView.h"
#import "HXMergerImageBubbleView.h"
#import "HXMPMovieController.h"
#import "zlib.h"
#import "NSData+Ext.h"
#import "RXCollectData.h"
#import "HXFileCacheManager.h"
#import "MSSBrowseViewController.h"
#import "MSSBrowseModel.h"
#import <AVKit/AVPlayerViewController.h>
#import "RestApi.h"
#import "ShowLocationViewController.h"
#import "ECLocationPoint.h"

@interface HXMergeMessageDetailController ()<UITableViewDelegate,UITableViewDataSource,DocumentDownloadViewDelegate>

@property (nonatomic,strong) ECMessage *mMessage;//当前消息

@property (nonatomic,strong) RXCollectData *collectData;//当前消息

@property (nonatomic,strong) UITableView *mTableView;

@property (nonatomic,strong) NSMutableArray     *mDataArray;

@end

@implementation HXMergeMessageDetailController

- (NSMutableArray *)mDataArray {
    if(!_mDataArray){
        _mDataArray = [[NSMutableArray alloc]init];
    }
    return _mDataArray;
}

/**
 @brief 提取上个页面传递的信息
 @discussion
 */
- (void)getDataForLastVC {
    if (self.data && [self.data isKindOfClass:[NSDictionary class]]) {
        if ([self.data objectForKey:@"message"]) {
            self.mMessage = [self.data objectForKey:@"message"];
        }
        if ([self.data objectForKey:@"collectData"]) {
            self.collectData = [self.data objectForKey:@"collectData"];
             [self setBarButtonWithNormalImg:ThemeImage(@"barbuttonicon_more") highlightedImg:ThemeImage(@"barbuttonicon_more") target:self action:@selector(moreBtnClick) type:NavigationBarItemTypeRight];
        }
        [self getFileData];
//    }else if ([self.data isKindOfClass:[NSArray class]]) {
//        self.title = languageStringWithKey(@"详情");
//        for (NSDictionary *dict in self.data) {
//            HXMergeMessageModel *model = [[HXMergeMessageModel alloc]init];
//            [model setValuesForKeysWithDictionary:dict];
//            model.faterMessage = self.mMessage;
//            [self.mDataArray addObject:model];
//        }
        [self.mTableView reloadData];
    }
}

- (UITableView *)mTableView {
    if(!_mTableView){
        _mTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight -kTotalBarHeight) style:UITableViewStyleGrouped];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.showsHorizontalScrollIndicator = NO;
        _mTableView.showsVerticalScrollIndicator = NO;
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mTableView.backgroundColor = [UIColor whiteColor];
    }
    return _mTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = languageStringWithKey(@"聊天记录");
    [self getDataForLastVC];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageViewLoadFinsh:) name:REFRESH_CELL_IMAGE_LOADFINISH object:nil];
    [self.view addSubview:self.mTableView];
    [self.mTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0);
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)imageViewLoadFinsh:(NSNotification *)notification {
    __weak HXMergeMessageDetailController *blockSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [blockSelf.mTableView reloadData];
    });
}

#pragma mark ------------------------------- 关于TableView协议方法----------------------------------
/**
 secton 组数
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.mDataArray.count;
}
/**
 row 行数
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

/**
 cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak HXMergeMessageDetailController *blockSelf = self;
    NSString *cellID = [HXMergeMessageFatherCell cellIdentifierForMessageModel:[self.mDataArray objectAtIndex:indexPath.section]];
    HXMergeMessageFatherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[HXMergeMessageFatherCell alloc] initWithEachMergeMessageModel:[self.mDataArray objectAtIndex:indexPath.section] reuseIdentifier:cellID];
    }
    cell.bubbleViewClickBlock = ^(HXMergeMessageModel *model,XSMergeMessageBublleEvent EventType){
        
        [blockSelf clickBubbleModel:model andEventType:EventType];
    };
    HXMergeMessageModel *lastModel = nil;
    if (self.mDataArray.count > 1 && indexPath.section > 0) {
        lastModel = [self.mDataArray objectAtIndex:indexPath.section - 1];
    }
    
    cell.model = [self.mDataArray objectAtIndex:indexPath.section];
    if ([cell.model.merge_account isEqualToString:lastModel.merge_account]) {
        cell.mHeaderImageView.hidden = NO;//如果需要隐藏就YES
    }
    else {
        cell.mHeaderImageView.hidden = NO;
    }
    
    return cell;
}
/**
 row height --行高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [HXMergeMessageFatherCell returnHeightWithModel:[self.mDataArray objectAtIndex:indexPath.section]];
    NSLog(@"-->%f",height);
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return FooterHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [HXMergeMessageFatherCell returnSecontionFooterView];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
}

#pragma mark ------------------------------- 关于父消息的文件的下载----------------------------------
- (void)getFileData{
    //判断文件本地是否存在
    ECFileMessageBody *fileBody = (ECFileMessageBody *)self.mMessage.messageBody;
    //路径修改
    //    NSDictionary *fileDic =[[IMMsgDBAccess sharedInstance]getCacheFileData:[fileBody.localPath lastPathComponent]];
    NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:fileBody.remotePath];
    if(fileDic.count > 0){
        [self getArrayData];
    }else{
        if(KCNSSTRING_ISEMPTY(fileBody.remotePath)){
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件不存在")];
            return;
        }
        [self downloadFile:self.mMessage filePath:fileBody.remotePath];
    }
}

//下载文件
- (void)downloadFile:(ECMessage *)messAge filePath:(NSString *)filePath{
    NSString *fileExtention = [[filePath lastPathComponent] pathExtension];
    if ([NSObject isFileType_Doc:fileExtention] ||
        [NSObject isFileType_PPT:fileExtention] ||
        [NSObject isFileType_XLS:fileExtention] ||
        [NSObject isFileType_IMG:fileExtention] ||
        [NSObject isFileType_PDF:fileExtention] ||
        [NSObject isFileType_TXT:fileExtention] ||
        [NSObject isFileType_ZIP:fileExtention]
        ) {
        DocumentDownLoadView *subview = [[DocumentDownLoadView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight) filemessage:messAge];
        subview.delegate = self;
        [subview beginLoadFile:subview.startBtn];
        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:subview];
    }else{
        DocumentDownLoadView *subview = [[DocumentDownLoadView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight) filemessage:messAge];
        subview.delegate = self;
        [subview beginLoadFile:subview.startBtn];

        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:subview];
    }
}
- (void)DocumentDownloadView:(DocumentDownLoadView *)aView didFailWithError:(NSError *)error{
    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件下载失败")];
}

- (void)DocumentDownloadView_didFinished:(DocumentDownLoadView*)aView{
    //ECFileMessageBody *fileBody =(ECFileMessageBody*)self.mMessage.messageBody;
    [self getArrayData];
}

- (void)getArrayData{
    ECFileMessageBody *fileBody = (ECFileMessageBody *)self.mMessage.messageBody;
    NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:fileBody.remotePath];
    NSString *filePaht = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
    
//    NSString *filePaht = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:mediaBody.remotePath.lastPathComponent];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePaht];
    NSString *base64 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!base64) {//Android 发的需要先解压，才能读取到里面的内容
        NSData *dataUncompressed = [data uncompressZippedData];
        base64 = [[NSString alloc] initWithData:dataUncompressed encoding:NSUTF8StringEncoding];
    }
    if (!base64) {
        return;
    }
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    NSArray *tempDataArray = [NSData toArrayOrNSDictionary:decodedData];
    
    for (NSDictionary *dict in tempDataArray) {
        HXMergeMessageModel *model = [[HXMergeMessageModel alloc]init];
        [model setValuesForKeysWithDictionary:dict];
        model.faterMessage = self.mMessage;
        [self.mDataArray addObject:model];
    }
    [self.mTableView reloadData];
}

#pragma mark ------------------------------- 关于事件的处理------------------------------------
- (void)clickBubbleModel:(HXMergeMessageModel *)model andEventType:(XSMergeMessageBublleEvent)EventType{
    if(EventType == XSMergeMessageBublleEvent_Text){//文字无事件
        [self opentextUrl:model.textUrl];
    }else if(EventType == XSMergeMessageBublleEvent_Image){
        [self pushPicturePreView:model ];
    }else if(EventType == XSMergeMessageBublleEvent_Video){
        ECMessage *message = [self changeModeToVideoMesssageWithModel:model];
        [self videoPlayVideoTap:message andModel:model];
    }else if(EventType == XSMergeMessageBublleEvent_File){
        ECMessage * message =   [self changeModeToFileMesssageWithModel:model];
        [self showfileWithMessage:message];
    }else if(EventType == XSMergeMessageBublleEvent_Preview){
        [self showLink:model];
    }else if(EventType == XSMergeMessageBublleEvent_NameCard){
        [self cardShareCardTap:model];
    }else if(EventType == XSMergeMessageBublleEvent_Voice){
//        [self cardShareCardTap:model];
    }else if(EventType == XSMergeMessageBublleEvent_Location){
        NSDictionary *domain;
        if([model.merge_userData isKindOfClass:[NSDictionary class]]){
            domain = (NSDictionary *)model.merge_userData;
        }else{
            domain = model.merge_userData.coverToDictionary;
        }
         
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([domain[@"latitude"]floatValue], [domain[@"longitude"]floatValue]);
        ECLocationPoint *point = [[ECLocationPoint alloc] initWithCoordinate:coordinate andTitle:model.merge_content];
        ShowLocationViewController *locationVC = [[ShowLocationViewController alloc] initWithLocationPoint:point];
        RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:locationVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark ------------------------------- 关于文字展示的处理------------------------------------
- (void)opentextUrl:(NSString *)url {
    [self pushViewController:@"WebViewController" withData:@{@"URL":url} withNav:YES];
}
#pragma mark ------------------------------- 关于图片的展示的处理------------------------------------
- (void)pushPicturePreView:(HXMergeMessageModel *)model{
    NSArray *imageArray = [self getImageModelArray];
    //获取图片索引
    NSInteger indexRow = [self.mDataArray indexOfObject:model];
    NSMutableDictionary *showCellImageDic = [NSMutableDictionary dictionary];
    //查询当前显示的图片cell 用来获取显示图片的坐标
    if (self.mTableView.visibleCells && self.mTableView.visibleCells.count > 0) {
        for (id temp in [self.mTableView.visibleCells copy]) {
            @try {
                if(self.mDataArray.count > 0 && temp){
                    if([temp isKindOfClass:[HXMergeMessageFatherCell class]]){
                        HXMergeMessageFatherCell *imgCell = (HXMergeMessageFatherCell *)temp;
                        if (imgCell) {
                             [showCellImageDic setObject:imgCell forKey:imgCell.model.merge_messageId];
                        }
                    }
                }
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
    }
    
    if (indexRow != NSNotFound) {
        NSMutableArray *imgModelArray = [[NSMutableArray alloc] init];
        int index = 0;
        int i = 0;
        for(NSDictionary *imgDic in imageArray){
            MSSBrowseModel *yxpModel = [[MSSBrowseModel alloc] init];
            if([showCellImageDic.allKeys containsObject:imgDic[@"messageId"]]){
                HXMergeMessageFatherCell *showimgCell = showCellImageDic[imgDic[@"messageId"]];
                FLAnimatedImageView *imgView = ((HXMergerImageBubbleView *)showimgCell.mBubbleView).mImageView;
                CGRect imgRect = [imgView.superview convertRect:imgView.frame toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
                yxpModel.smallimageViewFrame = imgRect;
                yxpModel.smallImageView = imgView;
            }
            yxpModel.bigImageUrl = imgDic[@"remotePath"];
            yxpModel.locImgUrl  = imgDic[@"loaclPath"];
            yxpModel.authId     = imgDic[@"sender"];
            yxpModel.messageId  = imgDic[@"messageId"];
            if([yxpModel.messageId isEqualToString:model.merge_messageId]){
                index = i;
            }
            [imgModelArray addObject:yxpModel];
            i++;
        }
        MSSBrowseViewController *bvc = [[MSSBrowseViewController alloc] initWithBrowseItemArray:imgModelArray currentIndex:index];
        bvc.clickArr = @[MSSBrowseTypeString(MSSBrowseTypeForward),MSSBrowseTypeString(MSSBrowseTypeCollect),MSSBrowseTypeString(MSSBrowseTypeSave)];
        bvc.isLoadLoc = YES;
        [bvc showBrowseViewController];
    }else {
        [self showCustomToast:languageStringWithKey(@"消息不存在")];
    }
}

- (NSArray *)getImageModelArray{
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (HXMergeMessageModel *model in self.mDataArray) {
        if(model.merge_type.integerValue  ==  MessageBodyType_Image){
            NSDictionary *fileDic =[[SendFileData sharedInstance] getCacheFileData:model.merge_url];
            //老的存储路径，没有去掉是为了兼容之前的消息记录
            NSString *old_filePath = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
            NSString *localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[fileDic objectForKey:cachefileDisparhName]];
            
            NSData *imageData = [NSData dataWithContentsOfFile:localPath];
            if (imageData.length<=0) {
                localPath = old_filePath;
            }
            
            if (model) {
                NSDictionary *dict = @{@"sender":model.merge_account,@"loaclPath":localPath?:@"",@"remotePath":model.merge_url?model.merge_url:@"",@"messageId":model.merge_messageId};
                if (dict) {
                    [imageArray addObject:dict];
                }
            }
        }
    }
    return imageArray;
}

#pragma mark ------------------------------- 关于视频的处理------------------------------------
- (void)videoPlayVideoTap:(ECMessage *)message andModel:(HXMergeMessageModel *)model{
    __weak typeof(ECMessage *)weakMessage = message;
    ECVideoMessageBody *mediaBody = (ECVideoMessageBody *)message.messageBody;
    if (message.messageState != ECMessageState_Receive && mediaBody.localPath.length>0) {
        [self createMPPlayerController:mediaBody.localPath];
        return;
    }
    if (mediaBody.mediaDownloadStatus != ECMediaDownloadSuccessed || mediaBody.localPath.length == 0) {
        [[AppModel sharedInstance] readedMessage:message completion:^(ECError *error, ECMessage *amessage) {
            if (error.errorCode == ECErrorType_NoError) {
                weakMessage.isRead = YES;
                [[KitMsgData sharedInstance] updateMessageReadStateByMessageId:amessage.messageId isRead:amessage.isRead];
            }
        }];
        __weak typeof(self) weakSelf = self;
        [SVProgressHUD showWithStatus:languageStringWithKey(@"正在加载视频，请稍后")];
        
        void(^block)(ECError *error, ECMessage *message) = ^(ECError *error, ECMessage *message){
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [SVProgressHUD dismiss];
            if (error.errorCode == ECErrorType_NoError) {
                model.merge_messageState = ECMediaDownloadSuccessed;
                model.localPath = mediaBody.localPath;
                if(strongSelf && [strongSelf isKindOfClass:[HXMergeMessageDetailController class]]){
                    [strongSelf createMPPlayerController:mediaBody.localPath];
                }
                DDLogInfo(@"本地地址%@",[NSString stringWithFormat:@"file://localhost%@", mediaBody.localPath]);
            }else{
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"下载视频失败")];
            }
        };
        
        [[AppModel sharedInstance] runModuleFunc:@"ChatMessageManager" :@"downloadMediaMessage:andCompletion:" :@[message,block]];

//        [[ChatMessageManager sharedInstance] downloadMediaMessage:message andCompletion:^(ECError *error, ECMessage *message) {
//            __strong __typeof(weakSelf)strongSelf = weakSelf;
//            [SVProgressHUD dismiss];
//            if (error.errorCode == ECErrorType_NoError) {
//                model.merge_messageState = ECMediaDownloadSuccessed;
//                model.localPath = mediaBody.localPath;
//                if(strongSelf && [strongSelf isKindOfClass:[HXMergeMessageDetailController class]]){
//                    [strongSelf createMPPlayerController:mediaBody.localPath];
//                }
//                DDLogInfo(@"本地地址%@",[NSString stringWithFormat:@"file://localhost%@", mediaBody.localPath]);
//            }else{
//                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"下载视频失败")];
//            }
//
//        }];
    } else {
        [self createMPPlayerController:mediaBody.localPath];
    }
}
- (void)createMPPlayerController:(NSString *)fileNamePath {
    NSString *videoName = fileNamePath.lastPathComponent;
    NSString *cachePath = [NSCacheDirectory() stringByAppendingPathComponent:videoName];
    //视频播放的url
    NSURL *playerURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", cachePath]];
    //初始化
    AVPlayerViewController *playerView = [[AVPlayerViewController alloc]init];
    //        AVPlayerViewController *playerView2 = [[AVPlayerViewController alloc]init];
    playerView.player = [AVPlayer playerWithURL:playerURL];
    playerView.videoGravity = AVLayerVideoGravityResizeAspect;
    playerView.showsPlaybackControls = YES;
    // 设置拉伸模式
    playerView.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // 设置是否显示媒体播放组件
    playerView.showsPlaybackControls = YES;
    // 设置大力
    //    playerView.delegate = self;
    // 播放视频
    [playerView.player play];
    // 设置媒体播放器视图大小
    playerView.view.bounds = [UIScreen mainScreen].bounds;
    //    playerView2.view.center = CGPointMake(CGRectGetMidX(self.
    [playerView.view setBackgroundColor:[UIColor clearColor]];
    [playerView.view setFrame:[UIScreen mainScreen].bounds];

    [self presentViewController:playerView animated:NO completion:nil];
}
//- (void)createMPPlayerController:(NSString *)fileNamePath {
//
//    HXMPMovieController *playerView =[[HXMPMovieController alloc]initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", fileNamePath]]];
//
//
//    // MPMoviePlayerViewController* playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", fileNamePath]]];
//
//    playerView.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
//
//    [playerView.view setBackgroundColor:[UIColor clearColor]];
//    [playerView.view setFrame:self.view.bounds];
//
//
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:playerView.moviePlayer];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieStateChangeCallback:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:playerView.moviePlayer];
//
//    [self presentViewController:playerView animated:NO completion:nil];
//}
- (void)movieStateChangeCallback:(NSNotification *)notify{
    //点击播放器中的播放/ 暂停按钮响应的通知
    MPMoviePlayerController *playerView = notify.object;
    MPMoviePlaybackState state = playerView.playbackState;
    switch (state) {
        case MPMoviePlaybackStatePlaying:
            DDLogInfo(@"正在播放...");
            break;
        case MPMoviePlaybackStatePaused:
            DDLogInfo(@"暂停播放.");
            break;
        case MPMoviePlaybackStateSeekingForward:
            DDLogInfo(@"快进");
            break;
        case MPMoviePlaybackStateSeekingBackward:
            DDLogInfo(@"快退");
            break;
        case MPMoviePlaybackStateInterrupted:
            DDLogInfo(@"打断");
            break;
        case MPMoviePlaybackStateStopped:
            DDLogInfo(@"停止播放.");
            break;
        default:
            DDLogInfo(@"播放状态:%li",(long)state);
            break;
    }
}

- (void)movieFinishedCallback:(NSNotification *)notify{
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    MPMoviePlayerController* theMovie = [notify object];
    [theMovie stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
}

#pragma mark ------------------------------- 关于文件的处理------------------------------------
- (void)showfileWithMessage:(ECMessage *)message {
    ECFileMessageBody *fileBody = (ECFileMessageBody *)message.messageBody;
    //先判断是否下载成功 或者本地有缓存
    if(fileBody.mediaDownloadStatus != ECMediaDownloadSuccessed){
        if(KCNSSTRING_ISEMPTY(fileBody.remotePath)){
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件不存在")];
            return;
        }
        
    }
 //   [self pushViewController:@"CheckFileViewController" withData:message withNav:YES];
    [self pushViewController:@"HXShowFileViewController" withData:message withNav:YES];
}

#pragma mark ------------------------------- 关于名片的处理------------------------------------
#pragma mark 名片点击
- (void)cardShareCardTap:(HXMergeMessageModel *)model{

    NSDictionary * useDataDic = [HXMessageMergeManager jsonDicWithNOBase64UserData:model.merge_userData];
    if (useDataDic.allKeys.count == 0 && model.merge_userData.length > 0) { //可能是base64
        NSString *nobase64 = [HXMessageMergeManager getUserBase64DataString:model.merge_userData];
        useDataDic = [HXMessageMergeManager jsonDicWithNOBase64UserData:nobase64];
    }
    
    NSDictionary *cardData = [useDataDic hasValueForKey:SMSGTYPE] ? useDataDic:useDataDic [ShareCardMode];
    NSInteger type = [[cardData objectForKey:@"type"] integerValue];
    if (type == 1) {
        NSString *str = [cardData objectForKey:@"account"];
        UIViewController *contactorInfosVC = [[Common sharedInstance].componentDelegate getContactorInfosVCWithData:str];
        [self pushViewController:contactorInfosVC];
    }else if (type == 2) {
        UIViewController *contactorInfosVC = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"getHXPublicDetailViewControllerWithID:" :@[cardData[@"pn_id"]?:@""]];
        if (contactorInfosVC) {
            [self pushViewController:contactorInfosVC];
        }
    }
}


#pragma mark ------------------------------- 关于链接的处理------------------------------------
- (void)showLink:(HXMergeMessageModel *)model {
    [self pushViewController:@"WebViewController" withData:@{@"URL":model.merge_url,@"sender":model.merge_account} withNav:YES];
}


- (ECMessage *)changeModeToFileMesssageWithModel:(HXMergeMessageModel *)model{
    //文件名
    NSString *fileName;
    if(model.merge_type.integerValue == MessageBodyType_File){
        fileName = model.merge_title;
        if (KCNSSTRING_ISEMPTY(fileName)) {
            fileName = [model.merge_url lastPathComponent];
        }
    }else if(model.merge_type.integerValue == MessageBodyType_Image){
        fileName = [model.merge_url lastPathComponent];
    }
    //时间
    NSString *fileIdentiferTime = [HXFileCacheManager createRandomFileName];

    ECFileMessageBody *fileBody = [[ECFileMessageBody alloc] init];
    fileBody.remotePath = model.merge_url;
    fileBody.displayName = model.merge_title;
    fileBody.originFileLength = [model.merge_fileSize longLongValue];
    fileBody.localPath = [HXFileCacheManager createFilePathInCacheDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument dataExtension:fileIdentiferTime sessionId:model.merge_messageId fileName:fileName];
    ECMessage *fileMessage = [[ECMessage alloc]initWithReceiver:[Common sharedInstance].getAccount body:fileBody];
    fileMessage.messageId = model.merge_messageId;
    fileMessage.userData = model.merge_userData;
    return fileMessage;
}

- (ECMessage *)changeModeToVideoMesssageWithModel:(HXMergeMessageModel *)model{
    ECVideoMessageBody *body = [[ECVideoMessageBody alloc]init];
    body.remotePath = model.merge_url;
    body.localPath = model.localPath;
    
    ECMessage *message = [[ECMessage alloc] initWithReceiver:model.merge_sessonId body:body];
    message.messageId = model.merge_messageId;
    message.from = model.merge_account;
    return message;
}

#pragma mark 更多
- (void)moreBtnClick{
    
    [self showSheetWithItems:@[languageStringWithKey(@"分享"),languageStringWithKey(@"删除")] inView:self.view selectedIndex:^(NSInteger index) {
        if (index == MSSBrowseTypeForward) {
            if (_collectData) {
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_collectData,@"transmitedMsg", nil];
                BOOL isTransmit = YES;
                NSNumber *isTransmitNum = [NSNumber numberWithBool:isTransmit];
                NSDictionary *exceptData = @{@"msg":dict,@"isTransmitNum":isTransmitNum, @"collectionPage_IM_forwardMenu":@"collectionPage_IM_forwardMenu"};
                UIViewController *groupVC = [[Common sharedInstance].componentDelegate getChooseMembersVCWithExceptData:exceptData WithType:SelectObjectType_TransmitSelectMember];
                [self pushViewController:groupVC];
            }
        }
        else if (index == 1) {
            WS(weakSelf)
            [RestApi deleteCollectDataWithAccount:[[Common sharedInstance] getAccount] CollectIds:@[_collectData.collectId] didFinishLoaded:^(NSDictionary *dict, NSString *path) {
                NSDictionary *headDic = [dict objectForKey:@"head"];
                NSInteger statusCode = [[headDic objectForKey:@"statusCode"] integerValue];
                if (statusCode == 000000) {
                    [RXCollectData deleteCollectionData:weakSelf.collectData.collectId];
                    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(popViewController) userInfo:nil repeats:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"collectionFrom_CollectionPage_IM" object:nil];
                }
            } didFailLoaded:^(NSError *error, NSString *path) {
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"删除失败")];
            }];
        }
    }];
    return;
}

@end
