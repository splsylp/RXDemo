//
//  NSData+Ext.h
//  Lafaso
//
//  Created by yuxuanpeng MINA on 14-7-16.
//  Copyright (c) 2014年 Lafaso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface NSData (MD5)

/**
 *  MD5加密
 *
 *  @return 加密后字符串
 */
- (NSString *)MD5EncodingString;

@end

@interface NSData (base64)

/**
 *  Base64加密
 *
 *  @return 加密后字符串
 */
- (NSString *)base64EncodingString;

@end

@interface NSData (SHA1)

/**
 *  SHA1加密
 *
 *  @param key 密钥
 *
 *  @return 
 */
- (NSData *)HMACSHA1EncodeDataWithKey:(NSString *)key;

@end

@interface NSData (gzip)

/**
 *  gzip解压
 *
 *  @param
 *
 *  @return
 */
- (NSData *)gzipInflate;

//解压
- (NSData *)uncompressZippedData;
@end

@interface NSData (fixImage)

/**
 *  gzip解压
 *
 *  @param
 *
 *  @return
 */
+ (NSData *)getSelectImageData:(ALAsset*)asset;
@end


@interface NSData (string)

+ (id)toArrayOrNSDictionary:(NSData *)jsonData;

@end
