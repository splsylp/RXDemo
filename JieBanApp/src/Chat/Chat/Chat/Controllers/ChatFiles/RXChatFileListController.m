//
//  RXChatFileListController.m
//  Chat
//
//  Created by 高源 on 2019/5/5.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "RXChatFileListController.h"
#import "RXChatFileManager.h"

// 状态
typedef enum : NSUInteger {
    RXChatFileStatusNone,
    RXChatFileStatusDowloading,
    RXChatFileStatusPause,
    RXChatFileStatusFail,
    RXChatFileStatusSuccess,
} RXChatFileStatus;

@interface RXChatFileModel : NSObject

/** message */
@property(nonatomic,strong)ECMessage *message;

/** progress */
@property(nonatomic,assign)CGFloat progress;

/** status */
@property(nonatomic,assign)RXChatFileStatus status;

@end


@implementation RXChatFileModel


@end




@interface RXChatFileStatusButton : UIControl

/** progress */
@property(nonatomic,assign)CGFloat progress;

/** iconImgView */
@property(nonatomic,strong)UIImageView *iconImgView;

/** status */
@property(nonatomic,assign)RXChatFileStatus status;

/** progressLayer */
@property(nonatomic,strong)CAShapeLayer *progressLayer;

/** tapBlock type:0暂停 1下载 */
@property(nonatomic,copy)void (^tapBlock)(int type,RXChatFileStatusButton *button);

@end

static  CGFloat const kLineWidth = 2.f;

@implementation RXChatFileStatusButton

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUpViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.width/2.f;
}

- (void)setUpViews {
    self.backgroundColor = [UIColor colorWithHexString:@"F0F0F0"];
    _iconImgView = [UIImageView new];
    _iconImgView.image = ThemeImage(@"btn_download");
    [self addSubview:_iconImgView];
    [_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_offset(0);
    }];
    
    self.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.iconImgView.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.status = RXChatFileStatusNone;
}

- (void)setStatus:(RXChatFileStatus)status {
    _status = status;
    self.hidden = status == RXChatFileStatusSuccess;
    if (status == RXChatFileStatusDowloading) {
        _iconImgView.image = ThemeImage(@"btn_downloading");
        _progressLayer.hidden = NO;
    }else if (status == RXChatFileStatusFail){
        _iconImgView.image = ThemeImage(@"btn_failure");
        _progressLayer.hidden = YES;
    }else {
        _iconImgView.image = ThemeImage(@"btn_download");
        _progressLayer.hidden = YES;
    }
    
    if (status == RXChatFileStatusFail) {
        self.backgroundColor = [UIColor redColor];
    }else {
        self.backgroundColor = [UIColor colorWithHexString:@"F0F0F0"];
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self drawCircle:progress];
}

- (void)drawCircle:(CGFloat)progress {
    if (progress>1.f) {progress=1.f;}
    CGRect rect = {kLineWidth / 2, kLineWidth / 2, self.width - kLineWidth, self.height - kLineWidth};
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    if (!self.progressLayer) {
        self.progressLayer = [CAShapeLayer layer];
        [self.layer addSublayer:self.progressLayer];
    }
    self.progressLayer.magnificationFilter = kCAFilterNearest;
    self.progressLayer.contentsScale = [UIScreen mainScreen].scale;
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressLayer.strokeColor = ThemeColor.CGColor;
    self.progressLayer.lineWidth = kLineWidth;
    self.progressLayer.lineCap = kCALineCapSquare;
    self.progressLayer.lineJoin = kCALineCapSquare;
    self.progressLayer.path = path.CGPath;
    self.progressLayer.strokeStart = 0;
    self.progressLayer.strokeEnd = progress;
}

- (void)tapAction {
    //type:0暂停 1下载
    int type = self.status == RXChatFileStatusDowloading ? 0 : 1;
    !self.tapBlock?:self.tapBlock(type,self);
}

@end



@interface RXChatFileListCell : UITableViewCell

/** iconImgView */
@property(nonatomic,strong)UIImageView *iconImgView;

/** titleLabel */
@property(nonatomic,strong)UILabel *titleLabel;

/** timeLabel */
@property(nonatomic,strong)UILabel *timeLabel;

/** nickNameLabel */
@property(nonatomic,strong)UILabel *nickNameLabel;

/** sizeLabel */
@property(nonatomic,strong)UILabel *sizeLabel;

/** downLoadBtn */
@property(nonatomic,strong)RXChatFileStatusButton *downLoadBtn;

/** model */
@property(nonatomic,strong)RXChatFileModel *model;

@end

@implementation RXChatFileListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews {
    
    _iconImgView = [UIImageView new];
    _iconImgView.layer.cornerRadius = 4.8;
    _iconImgView.clipsToBounds = YES;
    [self.contentView addSubview:_iconImgView];
    [_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15.f);
        make.size.mas_equalTo(CGSizeMake(48, 48));
        make.top.mas_offset(14.f);
    }];
    
    _titleLabel = [UILabel new];
    _titleLabel.textColor = [UIColor colorWithHexString:@"222222"];
    _titleLabel.font = ThemeFontLarge;
    _titleLabel.numberOfLines = 0;
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImgView.mas_right).mas_offset(12.f);
        make.top.mas_equalTo(self.iconImgView.mas_top).mas_offset(0);
        make.right.mas_offset(-76.f);
    }];
    
    _timeLabel = [UILabel new];
    _timeLabel.textColor = [UIColor colorWithHexString:@"999999"];
    _timeLabel.font = ThemeFontSmall;
    [self.contentView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImgView.mas_right).mas_offset(10.f);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(5);
    }];
    
    
    _downLoadBtn = [RXChatFileStatusButton new];
    [self.contentView addSubview:_downLoadBtn];
    [_downLoadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(26.f, 26.f));
        make.centerY.mas_offset(0);
        make.right.mas_offset(-13.f);
    }];
    [_downLoadBtn layoutIfNeeded];
    
    
    _sizeLabel = [UILabel new];
    _sizeLabel.textColor = [UIColor colorWithHexString:@"999999"];
    _sizeLabel.font = ThemeFontSmall;
    [self.contentView addSubview:_sizeLabel];
    [_sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_top);
        make.bottom.mas_lessThanOrEqualTo(-5);
        make.right.mas_equalTo(_downLoadBtn.mas_left).mas_offset(-10);
    }];
    
    _nickNameLabel = [UILabel new];
    _nickNameLabel.textColor = [UIColor colorWithHexString:@"777777"];
    _nickNameLabel.font = ThemeFontSmall;
    [self.contentView addSubview:_nickNameLabel];
    [_nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeLabel.mas_right).mas_offset(10.f);
        make.top.mas_equalTo(self.timeLabel.mas_top);
        make.right.mas_equalTo(_sizeLabel.mas_left).mas_offset(-10);
    }];
    
    
    
    
    
}

- (void)setModel:(RXChatFileModel *)model {
    _model = model;
    ECMessage *message = model.message;
    
    NSDictionary *info = [[Chat sharedInstance].componentDelegate getDicWithId:message.from withType:0];
    if (info.count>0) {
        _nickNameLabel.text = info[@"member_name"];
    }else {
        _nickNameLabel.text = message.from;
    }
    ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
    _titleLabel.text = body.displayName;
    _iconImgView.image = [self iconImage:body.displayName];
    _timeLabel.text = [ChatTools getSessionDateDisplayString:message.timestamp.longLongValue];
    float totalSize = [[NSString stringWithFormat:@"%lld", (body.originFileLength != 0)?body.originFileLength:body.fileLength] floatValue];
    NSString *totalSizeStr = [NSObject dataSizeFormat:[NSString stringWithFormat:@"%f",totalSize]];
    //文件大小
    _sizeLabel.text = totalSizeStr;
    
    _downLoadBtn.status = model.status;
    _downLoadBtn.progress = model.progress;
    _downLoadBtn.hidden = model.status == RXChatFileStatusSuccess;
}

- (UIImage*)iconImage:(NSString *)displayName{
    NSString *fileExtention = [[displayName lastPathComponent] pathExtension];
    if ([NSObject isFileType_Doc:fileExtention]) {
        return KKThemeImage(@"icon_file_word_small");
    }
    else if ([NSObject isFileType_PPT:fileExtention]) {
        return KKThemeImage(@"icon_file_ppt_small");
    }
    else if ([NSObject isFileType_XLS:fileExtention]) {
        return KKThemeImage(@"icon_file_xls_small");
    }
    else if ([NSObject isFileType_IMG:fileExtention]) {
        return KKThemeImage(@"FileTypeS_IMG");
    }else if ([NSObject isFileType_PDF:fileExtention]) {
        return KKThemeImage(@"icon_file_pdf_small");
    }
    else if ([NSObject isFileType_TXT:fileExtention]) {
        return KKThemeImage(@"icon_file_txt_small");
    }
    else if ([NSObject isFileType_ZIP:fileExtention]) {
        return KKThemeImage(@"icon_file_zip_small");
    }
    else{
        return KKThemeImage(@"FileTypeS_XXX");
    }
}


@end





@interface RXChatFileListController ()<UITableViewDelegate,UITableViewDataSource>

/** tableView */
@property(nonatomic,strong)UITableView *tableView;

/** dataSource */
@property(nonatomic,strong)NSMutableArray *dataSource;

@end

@implementation RXChatFileListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getDataSource];
}

- (void)getDataSource {
    
    NSArray *msgArray = [[KitMsgData sharedInstance] getAllFileMessageOfSessionId:self.sessionId];
    NSArray *tmpArr = [[msgArray reverseObjectEnumerator] allObjects];
    NSMutableArray *arr = [NSMutableArray array];
    for (ECMessage *message in tmpArr) {
        RXChatFileModel *model = [RXChatFileModel new];
        model.message = message;
        ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
        //判断文件本地是否存在
        NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:body.remotePath];
        if (fileDic.count>0) {
            model.status = RXChatFileStatusSuccess;
            model.progress = 1.0;
        }else {
            model.status = RXChatFileStatusNone;
            model.progress = 0.0;
        }
        [arr addObject:model];
    }
    self.dataSource = arr;
    [self.tableView reloadData];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[RXChatFileListCell class] forCellReuseIdentifier:NSStringFromClass(RXChatFileListCell.class)];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(0);
        }];
    }
    return _tableView;
}

#pragma mark  - tableView deleage
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass(RXChatFileListCell.class) configuration:^(RXChatFileListCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
    height = height < 76.f ? 76.f:height;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RXChatFileListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(RXChatFileListCell.class) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 75, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 75, 0, 0)];
    }
}

- (void)configureCell:(RXChatFileListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RXChatFileModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    WS(weakSelf)
    cell.downLoadBtn.tapBlock = ^(int type, RXChatFileStatusButton *button) {
        if (type == 0) {//暂停
            
        }else {//下载
            [weakSelf downloadFileWithModel:model downLoadBtn:button indexPath:indexPath];
        }
    };
}

#pragma mark 编辑按钮
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//侧滑删除置顶功能
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < 0){return nil;}
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:languageStringWithKey(@"删除") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        RXChatFileModel *model = self.dataSource[indexPath.row];
        [self deleteChatMessageWithIndexPath:indexPath model:model];
    }];
    deleteRowAction.backgroundColor = [UIColor colorWithHexString:@"F22F26"];
    return @[deleteRowAction];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete && !iOS8){
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

- (void)deleteChatMessageWithIndexPath:(NSIndexPath *)indexPath model:(RXChatFileModel *)model {
    
    ECMessage *message = model.message;
    
    //如果删除的也是唯一一个消息，删除session
    [[KitMsgData sharedInstance] deleteMessage:message.messageId andSession:message.sessionId];
    [self.dataSource removeObject:model];
    
    //可放后台操作
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        //是否是文件
        if([message.messageBody isKindOfClass:[ECFileMessageBody class]]){
            NSDictionary *fileCacheDic = [[SendFileData sharedInstance]getCacheFileData:((ECFileMessageBody *)message.messageBody).remotePath];
            if(fileCacheDic.count>0){
                //标识有缓存 清空
                if([[fileCacheDic objectForKey:cacheimSissionId] isEqualToString:self.sessionId]) {
                    //修改路径
                    [[SendFileData sharedInstance]deleteAllFileUrl:((ECFileMessageBody *)message.messageBody).remotePath];
                    [HXFileCacheManager deleteAppointFileInSession:[fileCacheDic objectForKey:cacheimSissionId] identifer:[fileCacheDic objectForKey:cachefileIdentifer] withCacheDirectory:[fileCacheDic objectForKey:cachefileDirectory]];
                }
            }
        }
//        self.backgroundIdentifier=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void){
//            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundIdentifier];
//            self.backgroundIdentifier = UIBackgroundTaskInvalid;
//        }];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_ReceiveMessageDelete object:nil userInfo:@{@"msgid":message.messageId, @"sessionid":message.sessionId}];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RXChatFileModel *model = self.dataSource[indexPath.row];
    [self fileCellBubbleViewTap:model.message];
}

-(void)fileCellBubbleViewTap:(ECMessage*)message {
    ECFileMessageBody *fileBody =(ECFileMessageBody *)message.messageBody;
    //先判断是否下载成功 或者本地有缓存
    if(fileBody.mediaDownloadStatus!=ECMediaDownloadSuccessed) {
        if(KCNSSTRING_ISEMPTY(fileBody.remotePath)) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件不存在")];
            return;
        }
    }
    
    if (fileBody.fileLength<=0.f && fileBody.localPath.length<10) {//判断空文件不让点 2018.5.16 by gy
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件不存在")];
        return;
    }
    
    BaseViewController *controller = [NSClassFromString(@"HXShowFileViewController") new];
    controller.data = message;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)downloadFileWithModel:(RXChatFileModel *)model downLoadBtn:(RXChatFileStatusButton *)downLoadBtn indexPath:(NSIndexPath *)indexPath {
    ECMessage *message = model.message;
    ECFileMessageBody *fileBody =(ECFileMessageBody *)message.messageBody;
    NSString *fileName;
    NSDictionary *userData = [MessageTypeManager getCusDicWithUserData:message.userData];
    if ([userData hasValueForKey:@"fileName"]) {
        fileName = [userData valueForKey:@"fileName"];
    }
    if (KCNSSTRING_ISEMPTY(fileName)){
        fileName = fileBody.displayName;
        if (KCNSSTRING_ISEMPTY(fileName)) {
            fileName = [fileBody.remotePath lastPathComponent];
        }
    }
    
    NSString *fileIdentiferTime =[HXFileCacheManager createRandomFileName];
    fileBody.localPath = [HXFileCacheManager createFilePathInCacheDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument dataExtension:fileIdentiferTime sessionId:message.sessionId fileName:fileName];
    
    [[RXChatFileManager sharedInstance] downloadMediaMessage:message progress:^(CGFloat progress) {
        model.progress = progress;
        if (progress>=1.0) {
            model.status = RXChatFileStatusSuccess;
        }else {
            model.status = RXChatFileStatusDowloading;
        }
        
        //实时更新进度变化
        for (RXChatFileListCell *cell in self.tableView.visibleCells) {
            if ([cell.model.message.messageId isEqualToString:model.message.messageId]) {
                cell.downLoadBtn.progress = progress;
                cell.downLoadBtn.status = model.status;
            }
        }
        
    } completion:^(ECError * _Nonnull error, ECMessage * _Nonnull message) {
        if (error.errorCode == ECErrorType_NoError) {
            //恒丰新增wjy
            NSString *fileUUid = [NSString fileMessageUUid:message.userData];
            long long llSize = fileBody.originFileLength;
            if (llSize<=0) {
                llSize = fileBody.fileLength;
            }
            NSDictionary *fileDic =@{cachefileUrl:fileBody.remotePath,cacheimSissionId:message.sessionId,  cachefileDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument,cachefileIdentifer:fileIdentiferTime,cachefileDisparhName:fileName,cachefileExtension:[fileName pathExtension]?[fileName pathExtension]:@"",cachefileSize:[NSString stringWithFormat:@"%lld",llSize],cachefileUuid:!KCNSSTRING_ISEMPTY(fileUUid)?fileUUid:@""};
            [[SendFileData sharedInstance] insertFileinfoData:fileDic];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DownloadMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:message}];
        } else {
            model.status = RXChatFileStatusFail;
            //实时更新进度变化
            for (RXChatFileListCell *cell in self.tableView.visibleCells) {
                if ([cell.model.message.messageId isEqualToString:model.message.messageId]) {
                    cell.downLoadBtn.status = model.status;
                }
            }
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            fileBody.localPath = nil;
            [[KitMsgData sharedInstance] updateMessageLocalPath:message.messageId withPath:@"" withDownloadState:((ECFileMessageBody*)message.messageBody).mediaDownloadStatus];
        }
    }];
}



@end
