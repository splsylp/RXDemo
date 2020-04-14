

#import "RXAlbumManager.h"
#import "SandBoxHelper.h"


dispatch_queue_t album_queue() {
    static dispatch_queue_t as_album_queue;
    static dispatch_once_t onceToken_album_queue;
    dispatch_once(&onceToken_album_queue, ^{
        as_album_queue = dispatch_queue_create("getAlbumVideo.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return as_album_queue;
}

@interface RXAlbumManager () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHFetchResult *assetsFetchResults;

@end

@implementation RXAlbumManager

static RXAlbumManager *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (RXAlbumManager *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)startManager { //注册相册的监听
    
    dispatch_async(album_queue(), ^{
        self.dataSource = [[NSMutableArray alloc] init];
        self.assetsFetchResults = [[PHFetchResult alloc] init];
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        [self getAlbumVideoWithBehaviorType:ALBUMIMAGEBEHAVIOR_GETALL PHObjectsArr:nil];
    });
}

- (void)stopManager { //注销相册的监听
    
    dispatch_async(dispatch_queue_create(0, 0), ^{
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    });
}

#pragma mark - 实现相册监听方法
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 监听相册图片发生变化
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
        if (collectionChanges) {
            if ([collectionChanges hasIncrementalChanges]) {
                //监听相册图片的增删
                //增加了
                if (collectionChanges.insertedObjects.count > 0) {
                    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:collectionChanges.insertedObjects];
                    [self getAlbumVideoWithBehaviorType:ALBUMIMAGEBEHAVIOR_INSTER PHObjectsArr:mArr];
                }
                //删除了
                if (collectionChanges.removedObjects.count > 0) {
                    
                    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:collectionChanges.removedObjects];
                    [self getAlbumVideoWithBehaviorType:ALBUMIMAGEBEHAVIOR_REMOVE PHObjectsArr:mArr];
                }
                /**监听完一次更新一下监听对象*/
                self.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:[self getFetchPhotosOptions]];
            }
        }
    });
}
#pragma mark - 相机授权
- (BOOL)getCameraRight {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - 相册授权
- (BOOL)getAlbumRight{
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied) {
        return NO;
    }else{
        return YES;
    }
}

//筛选的规则和范围
- (PHFetchOptions *)getFetchPhotosOptions{
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc]init];
    //排序的方式为：按时间排序
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    return allPhotosOptions;
}

- (void)getAlbumVideoWithBehaviorType:(AlbumImageBehaviorType)type PHObjectsArr:(NSArray *)phobjectsArr;{
    
    @synchronized(self) {
        if (type == ALBUMIMAGEBEHAVIOR_GETALL) {
            
            self.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:[self getFetchPhotosOptions]];
            
            if (!self.assetsFetchResults.count) {
                [self.dataSource removeAllObjects];
                return;
            }
            [self.dataSource removeAllObjects];
        }
        
        for (PHAsset *videoAsset in type == ALBUMIMAGEBEHAVIOR_GETALL ? self.assetsFetchResults : phobjectsArr) {
            if (type == ALBUMIMAGEBEHAVIOR_REMOVE) {
                if (self.dataSource.count > 0) {
                    /**数组的安全遍历*/
                    NSArray *arr = [NSArray arrayWithArray:self.dataSource];
                    for (PHAsset *model in arr) {
                        if ([model.localIdentifier isEqualToString:videoAsset.localIdentifier]) {
                            [self.dataSource removeObject:model];
                        }
                    }
                }
            } else {
                [self.dataSource addObject:videoAsset];
            }
//            DDLogInfo(@"相册图片数量为 = %lu", (unsigned long)self.dataSource.count);
//            [[PHImageManager defaultManager] requestImageDataForAsset:videoAsset options:<#(nullable PHImageRequestOptions *)#> resultHandler:<#^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info)resultHandler#>];
        }
    }
}

//删除相册图片
#pragma mark 删除相册图片

- (void)deleteAlbumVideo:(NSMutableArray<PHAsset *> *)assetArr {
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        [PHAssetChangeRequest deleteAssets:assetArr];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            DDLogInfo(@"相册图片删除完毕");
        }
    }];
}
@end
