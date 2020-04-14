//
//  YXPPlayerItemCacheFile.m
//  Common
//
//  Created by yuxuanpeng on 2017/9/30.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "YXPPlayerItemCacheFile.h"
#import "AVPlayerItem+YXPPlayerCache.h"

const NSString *MCAVPlayerCacheFileZoneKey = @"zone";
const NSString *MCAVPlayerCacheFileSizeKey = @"size";
const NSString *MCAVPlayerCacheFileResponseHeadersKey = @"responseHeaders";

/// 接受数据达到上限之后强制保存进度.
const NSUInteger kForceSynchronousMaxCount = 20;

@interface YXPPlayerItemCacheFile ()
{
@private
    NSMutableArray *_ranges;
    NSFileHandle *_writeFileHandle;
    NSFileHandle *_readFileHandle;
    BOOL _compelete;
    /// 接受数据达到上限之后强制保存进度.default is 10
    NSUInteger _recieveMaxCount;
}
@end

@implementation YXPPlayerItemCacheFile

+ (instancetype)cacheFileWithFilePath:(NSString *)filePath
{
    return [[self alloc] initWithFilePath:filePath];
}

- (instancetype)initWithFilePath:(NSString *)filePath
{
    if (!filePath)
    {
        return nil;
    }
    NSLog(@"caching path: %@",filePath);
    //再拼接一次
    filePath = [YXPCacheTemporaryDirectory() stringByAppendingPathComponent:[filePath lastPathComponent]];
    //    NSLog(@"caching path: %@",filePath);
    
    self = [super init];
    if (self)
    {
        NSString *cacheFilePath = [filePath copy];
        NSString *indexFilePath = [NSString stringWithFormat:@"%@%@",filePath,[[self class] indexFileExtension]];
        
        
        NSString *directory = [cacheFilePath stringByDeletingLastPathComponent];
        BOOL createDirector = NO;
        NSFileManager * manager = [NSFileManager defaultManager];

        if (![manager fileExistsAtPath:directory])
        {
           createDirector = [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        
        _cacheFilePath = cacheFilePath;
        _indexFilePath = indexFilePath;
        _ranges = [[NSMutableArray alloc] init];
        NSString * temPath = [NSString stringWithFormat:@"%@/YXPLoadVoice.%@",[self tempFilePath],[cacheFilePath pathExtension]];
        if ([manager fileExistsAtPath:temPath]) {
            [manager removeItemAtPath:temPath error:nil];
        }
        if (![manager fileExistsAtPath:[self tempFilePath]])
        {
            createDirector = [[NSFileManager defaultManager] createDirectoryAtPath:[self tempFilePath] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        createDirector =  [manager createFileAtPath:temPath contents:nil attributes:nil];

       
        
        _tmpFilePath = temPath;
        _readFileHandle = [NSFileHandle fileHandleForReadingAtPath:temPath];
        _writeFileHandle = [NSFileHandle fileHandleForWritingAtPath:temPath];
        _recieveMaxCount = 0;
        
        NSString *indexStr = [NSString stringWithContentsOfFile:_indexFilePath encoding:NSUTF8StringEncoding error:nil];
        if(indexStr)
        {
            NSData *data = [indexStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *indexDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments error:nil];
            if (![self serializeIndex:indexDic])
            {
                [self truncateFileWithFileLength:0];
            }
        }
       
        [self checkCompelete];
    }
    return self;
}

-(NSString *)tempFilePath {
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"GHPublicVoice"];
}

- (NSRange)firstNotCachedRangeFromPosition:(NSUInteger)pos
{
    NSRange range = {NSNotFound,0};
    if (pos >= _fileLength)
    {
        return range;
    }
    
    NSUInteger start = pos;
    for (int i = 0; i < _ranges.count; ++i)
    {
        NSRange range = [_ranges[i] rangeValue];
        if (NSLocationInRange(start, range))
        {
            start = NSMaxRange(range);
        }
        else
        {
            if (start >= NSMaxRange(range))
            {
                continue;
            }
            else
            {
                return NSMakeRange(start, range.location - start);
            }
        }
    }
    
    if (start < _fileLength)
    {
        return NSMakeRange(start, _fileLength - start);
    }
    NSRange irange = {NSNotFound,0};

    return irange;
}

#pragma mark setting

- (BOOL)setResponse:(NSHTTPURLResponse *)response
{
    BOOL success = YES;
    if (![self isFileLengthValid])
    {
        success = [self truncateFileWithFileLength:(NSUInteger)response.mc_fileLength];
    }
    _responseHeaders = [[response allHeaderFields] copy];
    success = success && [self synchronize];
    return success;
}
#pragma mark custom

- (BOOL)isFileLengthValid
{
    return _fileLength != 0;
}

- (BOOL)saveData:(NSData *)data atOffset:(NSUInteger)offset synchronize:(BOOL)synchronize;
{
    _recieveMaxCount++;
    
    if (!_writeFileHandle)
    {
        return NO;
    }
    
    @try
    {
        [_writeFileHandle seekToFileOffset:offset];
        [_writeFileHandle mc_safeWriteData:data];
    }
    @catch (NSException * e)
    {
        NSLog(@"[cache]%@",e);
        return NO;
    }
    
    @synchronized (self) {
        [self addRange:NSMakeRange(offset, [data length])];
        if (synchronize || _recieveMaxCount>kForceSynchronousMaxCount)
        {
            [self synchronize];
        }
    }
    
    return YES;
}

- (void)addRange:(NSRange)range
{
    if (range.length == 0 || range.location >= _fileLength)
    {
        return;
    }
    
    BOOL inserted = NO;
    for (int i = 0; i < _ranges.count; ++i)
    {
        NSRange currentRange = [_ranges[i] rangeValue];
        if (currentRange.location >= range.location)
        {
            [_ranges insertObject:[NSValue valueWithRange:range] atIndex:i];
            inserted = YES;
            break;
        }
    }
    if (!inserted)
    {
        [_ranges addObject:[NSValue valueWithRange:range]];
    }
    
    [self mergeRanges];
    [self checkCompelete];
}

- (void)mergeRanges
{
    for (int i = 0; i < _ranges.count; ++i)
    {
        if ((i + 1) < _ranges.count)
        {
            NSRange currentRange = [_ranges[i] rangeValue];
            NSRange nextRange = [_ranges[i + 1] rangeValue];
            if (YXPRangeCanMerge(currentRange, nextRange))
            {
                [_ranges removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i, 2)]];
                [_ranges insertObject:[NSValue valueWithRange:NSUnionRange(currentRange, nextRange)] atIndex:i];
                i -= 1;
            }
        }
    }
}

#pragma mark - serialize
- (BOOL)serializeIndex:(NSDictionary *)indexDic
{
    if (![indexDic isKindOfClass:[NSDictionary class]])
    {
        return NO;
    }
    
    NSNumber *fileSize = indexDic[MCAVPlayerCacheFileSizeKey];
    if (fileSize && [fileSize isKindOfClass:[NSNumber class]])
    {
        _fileLength = [fileSize unsignedIntegerValue];
    }
    
    if (_fileLength == 0)
    {
        return NO;
    }
    
    [_ranges removeAllObjects];
    NSMutableArray *rangeArray = indexDic[MCAVPlayerCacheFileZoneKey];
    for (NSString *rangeStr in rangeArray)
    {
        NSRange range = NSRangeFromString(rangeStr);
        [_ranges addObject:[NSValue valueWithRange:range]];
    }
    
    _responseHeaders = indexDic[MCAVPlayerCacheFileResponseHeadersKey];
    
    return YES;
}

#pragma mark - file
- (BOOL)truncateFileWithFileLength:(NSUInteger)fileLength;
{
    if (!_writeFileHandle)
    {
        return NO;
    }
    
    _fileLength = fileLength;
    @try
    {
        [_writeFileHandle truncateFileAtOffset:_fileLength * sizeof(Byte)];
        unsigned long long end = [_writeFileHandle seekToEndOfFile];
        if (end != _fileLength)
        {
            return NO;
        }
    }
    @catch (NSException * e)
    {
        return NO;
    }
    
    return YES;
}

- (void)removeCache
{
    [[NSFileManager defaultManager] removeItemAtPath:_cacheFilePath error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:_indexFilePath error:NULL];
}


+ (NSString *)indexFileExtension
{
    return @".idx!";
}

- (void)checkCompelete
{
    if (_ranges && _ranges.count == 1)
    {
        NSRange range = [_ranges[0] rangeValue];
        if (range.location == 0 && (range.length == _fileLength))
        {
            _compelete = YES;
            return;
        }
    }
    _compelete = NO;
}


#pragma mark - seek
- (void)seekToPosition:(NSUInteger)pos
{
    [_readFileHandle seekToFileOffset:pos];
    _readOffset = (NSUInteger)_readFileHandle.offsetInFile;
}

- (void)seekToEnd
{
    [_readFileHandle seekToEndOfFile];
    _readOffset = (NSUInteger)_readFileHandle.offsetInFile;
}

#pragma mark - property
- (NSUInteger)cachedDataBound
{
    if (_ranges.count > 0)
    {
        NSRange range = [[_ranges lastObject] rangeValue];
        return NSMaxRange(range);
    }
    return 0;
}

- (BOOL)synchronize
{
    @synchronized (self) {
        _recieveMaxCount = 0;
        NSString *indexStr = [self unserializeIndex];
        return [indexStr writeToFile:_indexFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
}

- (NSString *)unserializeIndex
{
    NSMutableArray *rangeArray = [[NSMutableArray alloc] init];
    for (NSValue *range in _ranges)
    {
        [rangeArray addObject:NSStringFromRange([range rangeValue])];
    }
    NSMutableDictionary *dict = [@{
                                   MCAVPlayerCacheFileSizeKey: @(_fileLength),
                                   MCAVPlayerCacheFileZoneKey: rangeArray
                                   } mutableCopy];
    if (_responseHeaders)
    {
        dict[MCAVPlayerCacheFileResponseHeadersKey] = _responseHeaders;
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    if (data)
    {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

@end
