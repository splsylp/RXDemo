//
//  NSData+Ext.m
//  Lafaso
//
//  Created by yuxuanpeng MINA on 14-7-16.
//  Copyright (c) 2014年 Lafaso. All rights reserved.
//

#import "NSData+Ext.h"
#import "RXThirdPart.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <zlib.h>
@implementation NSData (MD5)

- (NSString *)MD5EncodingString
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([self bytes], (CC_LONG)[self length], result);
    
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

@end

@implementation NSData (base64)

- (NSString *)base64EncodingString
{
    return [GTMBase64 stringByEncodingData:self];
}

@end

@implementation NSData (SHA1)

- (NSData *)HMACSHA1EncodeDataWithKey:(NSString *)key
{
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    void *buffer = malloc(CC_SHA1_DIGEST_LENGTH);
    CCHmac(kCCHmacAlgSHA1, [keyData bytes], [keyData length], [self bytes], [self length], buffer);
    
    NSData *encodeData = [NSData dataWithBytesNoCopy:buffer length:CC_SHA1_DIGEST_LENGTH freeWhenDone:YES];
    return encodeData;
}

@end

@implementation NSData (gzip)

- (NSData *) gzipInflate
{
    z_stream strm;
    
    // Initialize input
    strm.next_in = (Bytef *)[self bytes];
    NSUInteger left = [self length];        // input left to decompress
    if (left == 0)
        return nil;                         // incomplete gzip stream
    
    // Create starting space for output (guess double the input size, will grow
    // if needed -- in an extreme case, could end up needing more than 1000
    // times the input size)
    NSUInteger space = left << 1;
    if (space < left)
        space = NSUIntegerMax;
    NSMutableData *decompressed = [NSMutableData dataWithLength: space];
    space = [decompressed length];
    
    // Initialize output
    strm.next_out = (Bytef *)[decompressed mutableBytes];
    NSUInteger have = 0;                    // output generated so far
    
    // Set up for gzip decoding
    strm.avail_in = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    int status = inflateInit2(&strm, (15+16));
    if (status != Z_OK)
        return nil;                         // out of memory
    
    // Decompress all of self
    do {
        // Allow for concatenated gzip streams (per RFC 1952)
        if (status == Z_STREAM_END)
            (void)inflateReset(&strm);
        
        // Provide input for inflate
        if (strm.avail_in == 0) {
            strm.avail_in = left > UINT_MAX ? UINT_MAX : (unsigned)left;
            left -= strm.avail_in;
        }
        
        // Decompress the available input
        do {
            // Allocate more output space if none left
            if (space == have) {
                // Double space, handle overflow
                space <<= 1;
                if (space < have) {
                    space = NSUIntegerMax;
                    if (space == have) {
                        // space was already maxed out!
                        (void)inflateEnd(&strm);
                        return nil;         // output exceeds integer size
                    }
                }
                
                // Increase space
                [decompressed setLength: space];
                space = [decompressed length];
                
                // Update output pointer (might have moved)
                strm.next_out = (Bytef *)[decompressed mutableBytes] + have;
            }
            
            // Provide output space for inflate
            strm.avail_out = space - have > UINT_MAX ? UINT_MAX :
            (unsigned)(space - have);
            have += strm.avail_out;
            
            // Inflate and update the decompressed size
            status = inflate (&strm, Z_SYNC_FLUSH);
            have -= strm.avail_out;
            
            // Bail out if any errors
            if (status != Z_OK && status != Z_BUF_ERROR &&
                status != Z_STREAM_END) {
                (void)inflateEnd(&strm);
                return nil;                 // invalid gzip stream
            }
            
            // Repeat until all output is generated from provided input (note
            // that even if strm.avail_in is zero, there may still be pending
            // output -- we're not done until the output buffer isn't filled)
        } while (strm.avail_out == 0);
        
        // Continue until all input consumed
    } while (left || strm.avail_in);
    
    // Free the memory allocated by inflateInit2()
    (void)inflateEnd(&strm);
    
    // Verify that the input is a valid gzip stream
    if (status != Z_STREAM_END)
        return nil;                         // incomplete gzip stream
    
    // Set the actual length and return the decompressed data
    [decompressed setLength: have];
    return decompressed;
}

- (NSData *)uncompressZippedData {
    if ([self length] == 0) return self;
    
    unsigned full_length = [self length];
    
    unsigned half_length = [self length] / 2;
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    z_stream strm;
    strm.next_in = (Bytef *)[self bytes];
    strm.avail_in = [self length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy: half_length];
        }
        // chadeltu 加了(Bytef *)
        strm.next_out = (Bytef *)[decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
        
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    } else {
        return nil;
    }
}

@end

@implementation NSData (fixImage)

+ (NSData *)getSelectImageData:(ALAsset*)asset{
    
    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
    Byte *buffer = (Byte *)malloc((unsigned long)assetRep.size);
    NSError *err = nil;
    NSUInteger gobyteCount = [assetRep getBytes:buffer  fromOffset:0.0 length:((unsigned long)assetRep.size) error:&err];
    if(gobyteCount)
    {
       if(err)
       {
           free(buffer);
           return nil;
       }
    }
    return [NSData dataWithBytesNoCopy:buffer length:gobyteCount freeWhenDone:YES];
}

@end


@implementation NSData (string)

// 将JSON串转化为字典或者数组
+ (id)toArrayOrNSDictionary:(NSData *)jsonData{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
}

@end
