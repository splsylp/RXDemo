//
//  HXFileCacheManager.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/3.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

/*单个类型的文件目录*/

//整个应用文件缓存的目录
#define  YXP_FileCacheManager_CacheDirectoryOfDocument  @"YXPFileCache_DirectoryOfFile"

//聊天记录－本地图片缓存

#define YXP_ChatCacheManager_CacheDirectoryOfLocalImage @"YXPRonglian_ChatImageCache"

//来自相册的图片 做缓存

#define YXP_ChatCacheManager_CacheDirectoryOfAlbumImage @"YXPRonglian_ChatAlbumImageCache"


/*所有缓存目录的根目录*/
#define KKFileCacheManager_CacheDirectoryOfRoot       [NSString stringWithFormat:@"%@%@",@"RLIM_File_AllCacheDocument",[[Common sharedInstance] getAccount]]

//临时缓存目录

#define  YXP_ChatFileCacheManager_CacheDirectoryOfTmp  @"YXPRonglian_ChatFileTmpCache"


@interface HXFileCacheManager : NSObject

+(HXFileCacheManager *)defaultManager;


@property (retain, nonatomic) NSCache *memoryCacheImage;
@property (retain, nonatomic) NSCache *memoryCacheData;



//----------------清空缓存
- (void)clearMemory;

#pragma mark ==================================================
#pragma mark == 沙盒路径
#pragma mark ==================================================
/**
 @brief 【Documents（Documents）目录】
 @discussion 如果KKLibraryTempFile目录不存在，就会自动创建
 @return 完整目录路径
 */
+ (NSString*)documentsDirectory;

/**
 @brief 【Library（Library）目录】
 @return 完整目录路径
 */
+ (NSString*)libraryDirectory;

/**
 @brief 【Caches（Library/Caches）目录】
 @return 完整目录路径
 */
+ (NSString*)cachesDirectory;

/**
 @brief 【Temporary（tmp）目录】
 @return 完整目录路径
 */
+ (NSString*)temporaryDirectory;

/**
 *获取文件上级目录缓存路径
 */
+(NSString *)getFileCachePath:(NSString *)directory;

/**
 @brief 【文件夹里面：所有文件列表】
 @return
 */
+ (NSArray*)fileListAtDirectory:(NSString*)path;

/**
 @brief 【文件夹里面文件夹：所有文件列表】
 @return
 */
+ (NSArray*)moreFileListAtDirectory:(NSString*)path;

#pragma mark ==================================================
#pragma mark == 缓存操作
#pragma mark ==================================================
/**
 @brief 创建一个临时文件路径
 @discussion
 @param aCacheDirectory 存储于哪个目录（
 YXPFileCache_DirectoryOfFile、，
 也可自定义）
 @param imPushTime 时间唯一表示 自动生成的 防止文件重名
 @parm  sessionId IM聊天标识
 @return 函数调用成功返回 文件完整路径
 */
+ (NSString*)createFilePathInCacheDirectory:(NSString*)aCacheDirectory dataExtension:(NSString*)imPushTime sessionId:(NSString *)sessionId fileName:(NSString*)aFileName;


/**
 @brief 获取缓存文件路径
 @discussion 判断缓存文件是否存在
 @param aCacheDirectory 上一级目录
 @param imPushTime 文件唯一标示符 自动生成的
 @param dispathName 文件名
 @parm  sessionId  聊天的标识
 @return 函数调用成功返回 文件路径
 */
+ (NSString*)DocumentAppDataPath:(NSString*)imPushTime CacheDirectory:(NSString*)aCacheDirectory dispathName:(NSString *)dispathName sessionId:(NSString *)sessionId;

/**
 @brief 判断缓存文件是否存在
 @discussion 判断缓存文件是否存在
 @param aIdentifier 文件标示符 (一般是文件的远程URL字符串)
 @return 函数调用成功返回 结果
 */

+(BOOL)IsExistCacheData:(NSString *)filePath;



#pragma mark ==================================================
#pragma mark == 文件与文件夹操作
#pragma mark ==================================================
/**
 @brief 创建一个随机的文件名【例如：YYYYMMdd_HHmmss_SSS????】
 @discussion 其中YYYYMMdd是"年月日",HHmmss是"时分秒",SSS是毫秒,????是一个0-1000的四位随机数整数)
 @return 函数调用成功返回创建的文件名
 */
+ (NSString*)createRandomFileName;

/**
 @brief 删除文件
 @discussion 删除文件
 @param aFilePath 文件的完整路径【例如：/var/………………/KKLibraryTempFile/aa.png 】
 @return 函数调用成功返回结果
 */
+ (BOOL)deleteFileAtPath:(NSString*)aFilePath;


/**
 * 删除某个聊天中的文件缓存
 * sessionId 某个聊天标识
 * timeIdentifer 文件路径的唯一标识
 * aCacheDirectory 缓存目录
 **/
+(void)deleteAppointFileInSession:(NSString *)sessionId identifer:(NSString *)timeIdentifer withCacheDirectory:(NSString *)aCacheDirectory;

/**
 @brief 删除文件夹
 @discussion 删除文件夹
 @param aFilePath 文件的完整路径【例如：/var/………………/SESSIONID/xxxxx/aa.png 】
 @return 函数调用成功返回结果
 */
+ (BOOL)deleteDirectoryAtPath:(NSString*)aDirectoryPath;

/**
 * 删除某个聊天中的文件夹缓存 包含多个路径
 * sessionId 某个聊天标识
 *
 **/
+(void)deleteAllSessionFile:(NSString *)sessionId;

/**
 @brief 计算文件的大小
 @discussion 计算文件的大小
 @param aFilePath 文件的完整路径【例如：/var/………………/SESSIONID/xxxxx/aa.png 】
 @return 函数调用成功 返回文件有多少Byte
 */
+ (long long)fileSizeAtPath:(NSString*)filePath;


/**
 @brief 将Data保存到本地
 @discussion
 @param data 文件二进制数据
 @param aCacheDirectory 存储与哪个目录（YXP_FileCacheManager_CacheDirectoryOfDocument、YXP_ChatCacheManager_CacheDirectoryOfLocalImage、YXP_ChatCacheManager_CacheDirectoryOfAlbumImage，也可自定义）
 @param fileIdentifer 文件标识 生成的时间 防止重名
 @param aDisplayName 例如：考勤数据表.xls” ”
 @param sessionId IM聊天标识
 @param aExtension 扩展名
 @return 函数调用成功返回 aIdentifier 文件标示符
 */
+ (NSString*)saveData:(NSData*)data toCacheDirectory:(NSString*)aCacheDirectory fileIdentifer:(NSString*)timeIdentifer displayName:(NSString*)aDisplayName ImSessionId:(NSString*)sessionId aExtension:(NSString *)aExtension;

//恒丰新增wjy
/**
 @brief 将Data保存到本地
 @discussion
 @param data 文件二进制数据
 @param aCacheDirectory 存储与哪个目录（YXP_FileCacheManager_CacheDirectoryOfDocument、YXP_ChatCacheManager_CacheDirectoryOfLocalImage、YXP_ChatCacheManager_CacheDirectoryOfAlbumImage，也可自定义）
 @param fileIdentifer 文件标识 生成的时间 防止重名
 @param aDisplayName 例如：考勤数据表.xls” ”
 @param sessionId IM聊天标识
 @param aExtension 扩展名
 @return 函数调用成功返回 aIdentifier 文件标示符
 */
+ (NSString*)saveData:(NSData*)data toCacheDirectory:(NSString*)aCacheDirectory fileIdentifer:(NSString*)timeIdentifer displayName:(NSString*)aDisplayName ImSessionId:(NSString*)sessionId aExtension:(NSString *)aExtension fileKey:(NSString *)fileKey;

/*不带IM标示**/
+ (NSString*)saveData:(NSData*)data toCacheDirectory:(NSString*)aCacheDirectory fileIdentifer:(NSString*)timeIdentifer displayName:(NSString*)aDisplayName aExtension:(NSString *)aExtension;
+ (NSString *)decodeFile:(NSString *)fileKey dispathName:(NSString *)fileName filePath:(NSString *)filePath;

/**
 * 删除临时缓存
 * YXP_ChatFileCacheManager_CacheDirectoryOfTmp 目录下
 **/

+ (BOOL)deleteFileTmpCachePath;

/**
 * 创建临时缓存并保持数据
 * fileData 文件数据
 **/
+ (NSString *)createAndSavaTmpFilecache:(NSData *)fileData dispathName:(NSString *)dispathName;

@end
