

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, AlbumImageBehaviorType) {
    
    /**
     *  获取相册全部图片
     */
    ALBUMIMAGEBEHAVIOR_GETALL = 0,
    
    /**
     *  相册添加图片
     */
    ALBUMIMAGEBEHAVIOR_INSTER = 1,
    
    /**
     *  相册删除图片
     */
    ALBUMIMAGEBEHAVIOR_REMOVE = 2
    
};



@interface RXAlbumManager : NSObject


@property (nonatomic, strong) NSMutableArray *dataSource;

+ (RXAlbumManager *)shared;

/**
 注册相册的监听
 */
- (void)startManager;

/**
  注销相册的监听
 */
- (void)stopManager;

/**
 *  获取相机的授权
 *  @return YES/NO
 */
- (BOOL)getCameraRight;

/**
 *  获取相册的授权
 *  @return YES/NO
 */
- (BOOL)getAlbumRight;

/**
 *  获取所需要的Video属性
 *
 *  @param type TFVideoAssetType
 *
 *  @return 资源数组
 */

- (void)getAlbumVideoWithBehaviorType:(AlbumImageBehaviorType)type PHObjectsArr:(NSArray *)phobjectsArr;

//删除相册视频
- (void)deleteAlbumVideo:(NSArray *)assetArr;

@end
