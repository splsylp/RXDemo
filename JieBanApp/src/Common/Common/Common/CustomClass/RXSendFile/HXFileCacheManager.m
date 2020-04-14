//
//  HXFileCacheManager.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/3.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "HXFileCacheManager.h"
#import "NSString+AES.h"

@implementation HXFileCacheManager

+(HXFileCacheManager *)defaultManager
{
    static HXFileCacheManager *hxfileCache =nil;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        hxfileCache =[[HXFileCacheManager alloc]init];
    });
    
    return hxfileCache;
}
-(instancetype)init
{
    self =[super init];
    
    if(self)
    {
        NSString *nameData = [NSString stringWithFormat:@"%@.MemoryCacheData",[[NSBundle mainBundle] bundleIdentifier]];
        _memoryCacheData = [[NSCache alloc] init];
        _memoryCacheData.name = nameData;
    }
    
    return self;

}

- (void)clearMemory{
    [_memoryCacheData removeAllObjects];
    [_memoryCacheImage removeAllObjects];
}

#pragma mark ==================================================
#pragma mark == 沙盒路径
#pragma mark ==================================================

/**
 @brief 【Documents（Documents）目录】
 @return 完整目录路径
 */
+ (NSString*)documentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

/**
 @brief 【Library（Library）目录】
 @return 完整目录路径
 */
+ (NSString*)libraryDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}
/**
 @brief 【Caches（Library/Caches）目录】
 @return 完整目录路径
 */
+ (NSString*)cachesDirectory{
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

/**
 @brief 【Temporary（tmp）目录】
 @return 完整目录路径
 */
+ (NSString*)temporaryDirectory{
    NSString *documentsDirectory = NSTemporaryDirectory();
    return documentsDirectory;
}


/**
 @brief 【文件夹里面：所有文件列表】
 @return
 */
+ (NSArray*)fileListAtDirectory:(NSString*)path{
    NSMutableArray *fileArrary = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    //fileArrary便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:path error:&error];
    
    
    BOOL isDirectory = NO;
    //在上面那段程序中获得的fileList中列出文件夹名
    for (NSString *file in fileList) {
        NSString *filePath = [path stringByAppendingPathComponent:file];
        [fileManager fileExistsAtPath:filePath isDirectory:(&isDirectory)];
        if (isDirectory) {
        }
        else{
            [fileArrary addObject:file];
        }
        isDirectory = NO;
    }
    return fileArrary;
}

/**
 *获取文件上级目录缓存路径
 */
+(NSString *)getFileCachePath:(NSString *)directory
{
    //缓存目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    //文件完整目录 去掉文件分类 [aExtension uppercaseString]
    NSString *fileFullDirectoryPath = [NSString stringWithFormat:@"%@/%@/%@",cachesDirectory,KKFileCacheManager_CacheDirectoryOfRoot,directory];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if(![fileManager contentsOfDirectoryAtPath:fileFullDirectoryPath error:&error]){
        return nil;
    }
    
    return fileFullDirectoryPath;
}
/**
 @brief 【文件夹里面文件夹：所有文件列表】文件列表 文件缓存 有三级目录 一级用户标识 二级 IM标识 三级 创建时间 来自remoteUrl的前缀
 @return
 */
+ (NSArray*)moreFileListAtDirectory:(NSString*)path{
        
    NSMutableArray *fileArrary = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    //fileArrary便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    
    //上一级目录
    NSArray *directoryList = [fileManager contentsOfDirectoryAtPath:path error:&error];
    
    //在上面那段程序中获得的fileList中列出文件夹名
    for (NSString *directoryFile in directoryList) {
        //文件目录
        NSArray *fileList =[fileManager contentsOfDirectoryAtPath:[path stringByAppendingPathComponent:directoryFile] error:&error];
        BOOL isDirectory = NO;
        
        for(NSString *timeFile in fileList)
        {
            NSString *timePath = [[path stringByAppendingPathComponent:directoryFile] stringByAppendingPathComponent:timeFile];
            NSArray *fileArray =[fileManager contentsOfDirectoryAtPath:timePath error:&error];
            
            if(fileArray.count>0)
            {
                for(NSString *file in fileArray)
                {
                    NSString *filePath = [[[path stringByAppendingPathComponent:directoryFile] stringByAppendingPathComponent:timeFile] stringByAppendingPathComponent:file];
                   if( [fileManager fileExistsAtPath:filePath isDirectory:(&isDirectory)])
                   {
                      [fileArrary addObject:filePath];
                   }
                }
            }else
            {
                if( [fileManager fileExistsAtPath:timePath isDirectory:(&isDirectory)])
                {
                    [fileArrary addObject:timePath];
                }
               
            }
            
        }
        
        
    }
    return fileArrary;
}


#pragma mark ==================================================
#pragma mark == 缓存操作
#pragma mark ==================================================
/**
 @brief 创建一个临时文件路径
 @discussion
 @param aCacheDirectory 存储于哪个目录（
 YXPFileCache_DirectoryOfFile、，
 也可自定义）
 @param imPushTime 时间唯一表示 自动生成的
 @parm  sessionId IM聊天标识
 @param [self createRandomFileName] 创建一个时间  防止文件重名”
 @param aExtension 扩展名
 @return 函数调用成功返回 文件完整路径
 */
+ (NSString*)createFilePathInCacheDirectory:(NSString*)aCacheDirectory dataExtension:(NSString*)imPushTime sessionId:(NSString *)sessionId fileName:(NSString*)aFileName{
    if (!aCacheDirectory || [aCacheDirectory isKindOfClass:[NSNull class]] || [aCacheDirectory length]<1) {
        DDLogInfo(@"创建文件失败：aCacheDirectory：%@",aCacheDirectory);
        
        return nil;
    }
    
    if (!aFileName || [aFileName isKindOfClass:[NSNull class]] || [aFileName length]<1) {
        DDLogInfo(@"创建文件失败：aFileName：%@",aFileName);
        
        return nil;
    }
    
    if (!imPushTime || [imPushTime isKindOfClass:[NSNull class]] || [imPushTime length]<1) {
        DDLogInfo(@"缓存文件失败：imPushTime：%@",imPushTime);
        
        return nil;
    }
    //拆分的目的 后缀字母类型相同
    //后缀
    NSString *aExtension =[aFileName pathExtension];
    NSString *namePath =[aFileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",aExtension] withString:@""];
    
    
    NSString *realDisplayName =[NSString stringWithFormat:@"%@",namePath] ;
    
    
    //缓存目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    //文件完整目录 去掉文件分类 %@[aExtension uppercaseString]
    NSString *fileFullDirectoryPath = [NSString stringWithFormat:@"%@/%@/%@/%@/%@",cachesDirectory,KKFileCacheManager_CacheDirectoryOfRoot,aCacheDirectory,sessionId,imPushTime];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if(![fileManager contentsOfDirectoryAtPath:fileFullDirectoryPath error:&error]){
        BOOL result = [fileManager createDirectoryAtPath:fileFullDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!result) {
            DDLogInfo(@"%@",[error localizedDescription]);
            
            return nil;
        }
    }
    
    //文件完整目录
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@.%@",fileFullDirectoryPath,realDisplayName,[aExtension lowercaseString]];
    
    return fileFullPath;
}


/**
 @brief 获取缓存文件路径
 @discussion 判断缓存文件是否存在
 @param aCacheDirectory 上一级目录
 @param imPushTime 文件唯一标示符 自动生成的
 @param dispathName 文件名
 @parm  sessionId  聊天的标识
 @return 函数调用成功返回 文件路径
 */
+ (NSString*)DocumentAppDataPath:(NSString*)imPushTime CacheDirectory:(NSString*)aCacheDirectory dispathName:(NSString *)dispathName sessionId:(NSString *)sessionId{
    if ( !KCNSSTRING_ISEMPTY(imPushTime) && !KCNSSTRING_ISEMPTY(sessionId) && !KCNSSTRING_ISEMPTY(dispathName)) {
        
        //加个时间路径
        //后缀
        NSString *aExtension =[dispathName pathExtension];
        //拆分的目的 后缀字母类型相同
        NSString *namePath =[dispathName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",aExtension] withString:@""];
        
        NSString *realDisplayName =[NSString stringWithFormat:@"%@",namePath] ;
        
        
        //缓存目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths objectAtIndex:0];
        //文件完整目录 去掉文件分类 [aExtension uppercaseString]
        NSString *fileFullDirectoryPath = [NSString stringWithFormat:@"%@/%@/%@/%@/%@",cachesDirectory,KKFileCacheManager_CacheDirectoryOfRoot,aCacheDirectory,sessionId,imPushTime];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        if(![fileManager contentsOfDirectoryAtPath:fileFullDirectoryPath error:&error]){
            BOOL result = [fileManager createDirectoryAtPath:fileFullDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (!result) {
                DDLogInfo(@"%@",[error localizedDescription]);
                return nil;
            }
        }
        
        //文件完整目录
        NSString *fileFullPath =  [NSString stringWithFormat:@"%@/%@.%@",fileFullDirectoryPath,realDisplayName,[aExtension lowercaseString]];
        
        if (fileFullPath && [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath]) {
            return fileFullPath;
        }
        else{
            
            return nil;
        }
 
    }
    else{
        return nil;
    }
}

/**
 @brief 判断缓存文件是否存在
 @discussion 判断缓存文件是否存在
 @param filePath 文件路径
 @return 函数调用成功返回 结果
 */

+(BOOL)IsExistCacheData:(NSString *)filePath;
{
    if (filePath && ![filePath isKindOfClass:[NSNull class]]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            return YES;
        }
        else{
            return NO;
        }
    }
    else{
        return NO;
    }
}


#pragma mark ==================================================
#pragma mark == 文件与文件夹操作
#pragma mark ==================================================
/**
 @brief 创建一个随机的文件名【例如：YYYYMMdd_HHmmss_SSS????】
 @discussion 其中YYYYMMdd是"年月日",HHmmss是"时分秒",SSS是毫秒,????是一个0-1000的四位随机数整数)
 @return 函数调用成功返回创建的文件名
 */
+ (NSString*)createRandomFileName{
    //当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmssSSS"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
//    //随机码
//    int value = (arc4random() % 1000) + 1;
//    NSString *randomCode = [NSString stringWithFormat:@"%04d",value];
//    
//    NSString *savePathName = [NSString stringWithFormat:@"%@%@",dateStr,randomCode];
    
    return dateStr;
}

/**
 @brief 删除文件
 @discussion 删除文件
 @param aFilePath 文件的完整路径【例如：/var/………………/SESSIONID/xxxxx/aa.png 】
 @return 函数调用成功返回结果
 */



+ (BOOL)deleteFileAtPath:(NSString*)aFilePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if([fileManager fileExistsAtPath:aFilePath]){
        BOOL result = [fileManager removeItemAtPath:aFilePath error:&error];
        if (result) {
            return YES;
        }
        else{
            
            return NO;
        }
    }
    else{
        return YES;
    }
}

/**
 * 删除某个聊天中的文件缓存
 * sessionId 某个聊天标识
 * timeIdentifer 文件路径的唯一标识
 * aCacheDirectory 缓存目录
 **/
+(void)deleteAppointFileInSession:(NSString *)sessionId identifer:(NSString *)timeIdentifer withCacheDirectory:(NSString *)aCacheDirectory
{
   NSString *fileFullDirectoryPath = [NSString stringWithFormat:@"%@/%@/%@/%@/%@",[self cachesDirectory],KKFileCacheManager_CacheDirectoryOfRoot,aCacheDirectory,sessionId,timeIdentifer];
    [self deleteFileAtPath:fileFullDirectoryPath];
}

/**
 * 删除某个聊天中的文件夹缓存
 * sessionId 某个聊天标识
 *
 **/
+(void)deleteAllSessionFile:(NSString *)sessionId
{
    //系统相册图片缓存 文件夹缓存
    
    [self deleteDirectoryAtPath:[[[self cachesDirectory] stringByAppendingString:YXP_FileCacheManager_CacheDirectoryOfDocument] stringByAppendingString:sessionId]];
    
    [self deleteDirectoryAtPath:[[[self cachesDirectory] stringByAppendingString:YXP_ChatCacheManager_CacheDirectoryOfAlbumImage] stringByAppendingString:sessionId]];
    
}

/**
 @brief 删除文件夹
 @discussion 删除文件夹
 @param aDirectoryPath 文件夹的完整路径【例如：/var/………………/KKLibraryTempFile/PNG 】
 @return 函数调用成功返回结果
 */
+ (BOOL)deleteDirectoryAtPath:(NSString*)aDirectoryPath{
    
    BOOL isDirectory = YES;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if([fileManager fileExistsAtPath:aDirectoryPath isDirectory:&isDirectory]){
        BOOL result = [fileManager removeItemAtPath:aDirectoryPath error:&error];
        if (result) {
            return YES;
        }
        else{

            return NO;
        }
    }
    else{
        return YES;
    }
}
/**
 @brief 计算文件的大小
 @discussion 计算文件的大小
 @param filePath 文件的完整路径【例如：/var/………………/xxx/PNG/aa.png 】
 @return 函数调用成功 返回文件有多少Byte
 */
+ (long long)fileSizeAtPath:(NSString*)filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        NSError *error = nil;
        NSDictionary *dic = [manager attributesOfItemAtPath:filePath error:&error];
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            return [dic fileSize];
        }
        else{
            DDLogInfo(@"%@",[error localizedDescription]);
            return 0;
        }
    }
    return 0;
}



/**
 @brief 将Data保存到本地
 @discussion
 @param data 文件二进制数据
 @param aCacheDirectory 存储与哪个目录（YXP_FileCacheManager_CacheDirectoryOfDocument、YXP_ChatCacheManager_CacheDirectoryOfLocalImage、YXP_ChatCacheManager_CacheDirectoryOfAlbumImage，也可自定义）
 @param fileIdentifer 文件标识 生成的时间 防止重名
 @param aDisplayName 例如：考勤数据表.xls” ”
 @param sessionId IM聊天标识
 @param aExtension 扩展名
 @return 函数调用成功返回 文件全路径
 */
+ (NSString*)saveData:(NSData*)data toCacheDirectory:(NSString*)aCacheDirectory fileIdentifer:(NSString*)timeIdentifer displayName:(NSString*)aDisplayName ImSessionId:(NSString*)sessionId aExtension:(NSString *)aExtension{
    
    
    if (!data || [data isKindOfClass:[NSNull class]]) {
#ifdef DEBUG
        DDLogInfo(@"缓存文件失败：data：%@",data);
#endif
        return nil;
    }
    
    if (!aCacheDirectory || [aCacheDirectory isKindOfClass:[NSNull class]] || [aCacheDirectory length]<1) {
        
        return nil;
    }
   if(KCNSSTRING_ISEMPTY(sessionId) && KCNSSTRING_ISEMPTY(timeIdentifer))
   {
       return nil;
   }
    
    
    NSString *realDisplayName = @"";
    if (!KCNSSTRING_ISEMPTY(aDisplayName)) {
        realDisplayName = [aDisplayName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",[aDisplayName pathExtension]] withString:@""];
    }
    else{
        realDisplayName = timeIdentifer;
    }
    
    //缓存目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    //文件完整目录
    NSString *fileFullDirectoryPath = [NSString stringWithFormat:@"%@/%@/%@/%@/%@",cachesDirectory,KKFileCacheManager_CacheDirectoryOfRoot,aCacheDirectory,sessionId,timeIdentifer];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if(![fileManager contentsOfDirectoryAtPath:fileFullDirectoryPath error:&error]){
        BOOL result = [fileManager createDirectoryAtPath:fileFullDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!result) {
#ifdef DEBUG
            DDLogInfo(@"%@",[error localizedDescription]);
#endif
            
            return nil;
        }
    }
    
    //文件完整目录
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@.%@",fileFullDirectoryPath,realDisplayName,[aExtension lowercaseString]];
    
    
    if([data writeToFile:fileFullPath atomically:YES]){
        return fileFullPath;
    }
    else{

        return nil;
    }
}
//恒丰新增 wjy
/**
 @brief 将Data保存到本地
 @discussion
 @param data 文件二进制数据
 @param aCacheDirectory 存储与哪个目录（YXP_FileCacheManager_CacheDirectoryOfDocument、YXP_ChatCacheManager_CacheDirectoryOfLocalImage、YXP_ChatCacheManager_CacheDirectoryOfAlbumImage，也可自定义）
 @param fileIdentifer 文件标识 生成的时间 防止重名
 @param aDisplayName 例如：考勤数据表.xls” ”
 @param sessionId IM聊天标识
 @param aExtension 扩展名
 @return 函数调用成功返回 文件全路径
 */
+ (NSString*)saveData:(NSData*)data toCacheDirectory:(NSString*)aCacheDirectory fileIdentifer:(NSString*)timeIdentifer displayName:(NSString*)aDisplayName ImSessionId:(NSString*)sessionId aExtension:(NSString *)aExtension fileKey:(NSString *)fileKey{
    
    
    if (!data || [data isKindOfClass:[NSNull class]]) {
#ifdef DEBUG
        DDLogInfo(@"缓存文件失败：data：%@",data);
#endif
        return nil;
    }
    
    if (!aCacheDirectory || [aCacheDirectory isKindOfClass:[NSNull class]] || [aCacheDirectory length]<1) {
        
        return nil;
    }
    if(KCNSSTRING_ISEMPTY(sessionId) && KCNSSTRING_ISEMPTY(timeIdentifer))
    {
        return nil;
    }
    
    
    NSString *realDisplayName = @"";
    if (!KCNSSTRING_ISEMPTY(aDisplayName)) {
        realDisplayName = [aDisplayName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",[aDisplayName pathExtension]] withString:@""];
    }
    else{
        realDisplayName = timeIdentifer;
    }
    
    //缓存目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    //文件完整目录
    NSString *fileFullDirectoryPath = [NSString stringWithFormat:@"%@/%@/%@/%@/%@",cachesDirectory,KKFileCacheManager_CacheDirectoryOfRoot,aCacheDirectory,sessionId,timeIdentifer];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if(![fileManager contentsOfDirectoryAtPath:fileFullDirectoryPath error:&error]){
        BOOL result = [fileManager createDirectoryAtPath:fileFullDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!result) {
#ifdef DEBUG
            DDLogInfo(@"%@",[error localizedDescription]);
#endif
            
            return nil;
        }
    }
    
    //文件完整目录
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@.%@",fileFullDirectoryPath,realDisplayName,[aExtension lowercaseString]];
    
    if(HX_fileEncodedSwitch && !KCNSSTRING_ISEMPTY(fileKey))
    {
        //NSString *base64 = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //     NSString *base64 = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        //     NSString *encodedStr = [NSString encoded_ase:base64 withkey:fileKey];
        
        data = [NSString encoded_aseData:data withkey:fileKey];
        
        // data = [encodedStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    if([data writeToFile:fileFullPath atomically:YES]){
        return fileFullPath;
    }
    else{
        
        return nil;
    }
}

//不带IM标示的
+ (NSString*)saveData:(NSData*)data toCacheDirectory:(NSString*)aCacheDirectory fileIdentifer:(NSString*)timeIdentifer displayName:(NSString*)aDisplayName aExtension:(NSString *)aExtension{
    if (!data || [data isKindOfClass:[NSNull class]]) {
#ifdef DEBUG
        DDLogInfo(@"缓存文件失败：data：%@",data);
#endif
        return nil;
    }
    
    if (!aCacheDirectory || [aCacheDirectory isKindOfClass:[NSNull class]] || [aCacheDirectory length]<1) {
        
        return nil;
    }
    if(KCNSSTRING_ISEMPTY(timeIdentifer))
    {
        return nil;
    }
    
    
    NSString *realDisplayName = @"";
    if (!KCNSSTRING_ISEMPTY(aDisplayName)) {
        realDisplayName = [aDisplayName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",[aDisplayName pathExtension]] withString:@""];
    }
    else{
        realDisplayName = timeIdentifer;
    }
    
    //缓存目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    //文件完整目录
    NSString *fileFullDirectoryPath = [NSString stringWithFormat:@"%@/%@/%@/%@",cachesDirectory,KKFileCacheManager_CacheDirectoryOfRoot,aCacheDirectory,timeIdentifer];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if(![fileManager contentsOfDirectoryAtPath:fileFullDirectoryPath error:&error]){
        BOOL result = [fileManager createDirectoryAtPath:fileFullDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!result) {
#ifdef DEBUG
            DDLogInfo(@"%@",[error localizedDescription]);
#endif
            
            return nil;
        }
    }
    
    //文件完整目录
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@.%@",fileFullDirectoryPath,realDisplayName,[aExtension lowercaseString]];
    
    
    if([data writeToFile:fileFullPath atomically:YES]){
        return fileFullPath;
    }
    else{
        
        return nil;
    }
}
#pragma mark 对文件进行解密  返回解密后的路径

+ (NSString *)decodeFile:(NSString *)fileKey dispathName:(NSString *)fileName filePath:(NSString *)filePath
{
    
    NSData *fileData  = [NSData dataWithContentsOfFile:filePath];
    
    NSData *decofileData  = [NSString decoded_aseData:fileData withKey:fileKey];
    
    //    NSString *base64 = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    //    NSString *decodeStr = [NSString decoded_ase:base64 withKey:fileKey];
    //
    //    NSData *decodeData = [decodeStr dataUsingEncoding:NSUTF8StringEncoding];
    //
    //    NSData *base64Data = [decodeData initWithBase64EncodedData:decodeData options:0];
    
    return  [self createAndSavaTmpFilecache:decofileData dispathName:fileName];
    
}

//创建一个临时文件目录
+ (NSString *)createAndSavaTmpFilecache:(NSData *)fileData dispathName:(NSString *)dispathName

{
    if(KCNSSTRING_ISEMPTY(dispathName))
    {
        return nil;
    }
    
    //后缀
    NSString *aExtension =[dispathName pathExtension];
    //拆分的目的 后缀字母类型相同
    NSString *namePath =[dispathName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",aExtension] withString:@""];
    
    NSString *realDisplayName =[NSString stringWithFormat:@"%@",namePath] ;
    
    NSString *fileFullDirectoryPath = [NSString stringWithFormat:@"%@%@/%@",[self temporaryDirectory],YXP_ChatFileCacheManager_CacheDirectoryOfTmp,[self createRandomFileName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if(![fileManager contentsOfDirectoryAtPath:fileFullDirectoryPath error:&error]){
        BOOL result = [fileManager createDirectoryAtPath:fileFullDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!result) {
            DDLogInfo(@"%@",[error localizedDescription]);
            return nil;
        }
    }
    
    //文件完整目录
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@.%@",fileFullDirectoryPath,realDisplayName,[aExtension lowercaseString]];
    
    
    if([fileData writeToFile:fileFullPath atomically:YES]){
        return fileFullPath;
    }
    else{
        
        return nil;
    }
}

/**
 * 删除临时缓存
 * YXP_ChatFileCacheManager_CacheDirectoryOfTmp 目录下
 **/

+ (BOOL)deleteFileTmpCachePath
{
    NSString *tmpFilePath = [NSString stringWithFormat:@"%@%@",[self temporaryDirectory],YXP_ChatFileCacheManager_CacheDirectoryOfTmp];
    return  [self deleteFileAtPath:tmpFilePath];
}
@end
