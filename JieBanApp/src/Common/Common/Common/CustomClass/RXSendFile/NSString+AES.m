//
//  NSString+AES.m
//  Chat
//
//  Created by 魏继源 on 17/3/9.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "NSString+AES.h"

#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonDigest.h>

#import "RXThirdPart.h"
#import "vm_crypto.h"
#import "NSData+Ext.h"
#import "EmojiConvertor.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
@implementation NSString (AES)
//加密
+ (NSString *)encodedData:(NSString *)srcData withKey:(NSString *)theKey
{
    if ( !srcData || srcData.length == 0 )
    {
        return nil;
    }
    
    const char *cstrOriBody = [srcData cStringUsingEncoding:NSUTF8StringEncoding];
    int cstrOriBodyLen = strlen(cstrOriBody);
    
    char *chEncodeBody = (char*)malloc(cstrOriBodyLen+8);
    memset(chEncodeBody, 0, cstrOriBodyLen+8);
    
    int encodelen = 0;
    
    encodelen = AES_Encrypt_1((const unsigned char*)cstrOriBody,
                              cstrOriBodyLen,
                              (unsigned char*)chEncodeBody,
                              (const unsigned char*)[theKey UTF8String]);
    
    NSData *encodedData = [[NSData alloc] initWithBytes:chEncodeBody length:encodelen];
//    NSString *base64 = [encodedData base64Encoding];
    NSString *base64 = [encodedData base64EncodedStringWithOptions:0];
    DDLogInfo(@"Encoded: %@", base64);

    free(chEncodeBody);
    
    //    NSData *mybody = [[[NSData alloc] initWithData:[base64 dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
    [encodedData release];
    
    return base64;
}

+ (NSString *)decodeData:(NSString *)srcData withKey:(NSString *)theKey
{
    if ( !srcData || srcData.length == 0 )
    {
        return nil;
    }
    
    NSData *encodedData = [[[NSData alloc] initWithData:[srcData dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
    
    //解密包体
    char *chDecodeBody = (char*)malloc([encodedData length]*2);
    memset(chDecodeBody, 0, [encodedData length]*2);
    
    
//    NSData *nsdataFromBase64String = [[NSData alloc]
//                                      initWithBase64EncodedString:base64Encoded options:0];
//    
//    // Decoded NSString from the NSData
//    NSString *base64Decoded = [[NSString alloc]
//                               initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
//    DDLogInfo(@"Decoded: %@", base64Decoded);

    
    NSString *base64Body = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
//    NSData *encodeData = [NSData dataWithBase64EncodedString:base64Body];
    NSData *encodeData = [[NSData alloc] initWithBase64EncodedString:base64Body options:0];
    [base64Body release];
    
    AES_Decrypt_1((unsigned char*)[encodeData bytes], encodeData.length, (unsigned char*)chDecodeBody, (const unsigned char*)[theKey UTF8String]);
    
    CFDataRef bodyData = CFDataCreate(NULL, (UInt8 *)chDecodeBody, strlen(chDecodeBody));
    //    NSData *data = (NSData *)bodyData;
    
    NSString *bodyMsg = [[NSString alloc] initWithData:(NSData *)bodyData encoding:NSUTF8StringEncoding];
    
    free(chDecodeBody);
    CFRelease(bodyData);
    
    return [bodyMsg autorelease];;
}

+ (NSData *)encoded_aseData:(NSData *)fileData withkey:(NSString *)encodedKey{
    
    NSUInteger dataLength = fileData.length;
    
    // 为结束符'\\0' +1
    char keyPtr[kCCKeySizeAES256 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [encodedKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // 密文长度 <= 明文长度 + BlockSize
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,  // 系统默认使用 CBC，然后指明使用 PKCS7Padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          NULL,
                                          fileData.bytes,
                                          dataLength,
                                          encryptedBytes,
                                          encryptSize,
                                          &actualOutSize);
    
    if (cryptStatus == kCCSuccess) {
        
        return  [[NSData dataWithBytes:(const void *)encryptedBytes length:(NSUInteger)actualOutSize] base64EncodedDataWithOptions:0];
    }
    free(encryptedBytes);
    return nil;
}

+ (NSData *)decoded_aseData:(NSData *)fileData withKey:(NSString *)decodedKey{
    
    //直接对data进行base64解密
    NSData *decryptData =[GTMBase64 decodeData:fileData];
    NSUInteger dataLength = decryptData.length;
    
    // 为结束符'\\0' +1
    char keyPtr[kCCKeySizeAES256 + 1];
    
    //const void *vkey = (const void *)[decodedKey UTF8String];
    bzero(keyPtr, sizeof(keyPtr));
    memset(keyPtr, 0,sizeof(keyPtr));
    [decodedKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // 密文长度 <= 明文长度 + BlockSize
    size_t decryptSize = dataLength + kCCBlockSizeAES128;
    void *decryptedBytes = malloc(decryptSize);
    size_t actualOutSize = 0;
    
    // NSData *initVector=[@"" dataUsingEncoding:NSUTF8StringEncoding];
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          (kCCOptionPKCS7Padding|kCCOptionECBMode),  // 系统默认使用 ECB，然后指明使用 PKCS7Padding
                                          [[decodedKey dataUsingEncoding:NSUTF8StringEncoding] bytes],
                                          kCCKeySizeAES128,
                                          NULL,
                                          decryptData.bytes,
                                          dataLength,
                                          decryptedBytes,
                                          decryptSize,
                                          &actualOutSize);
    
    if (cryptStatus == kCCSuccess) {
        
        return [NSData dataWithBytesNoCopy:decryptedBytes length:(NSInteger)actualOutSize];
    }
    free(decryptedBytes);
    return nil;
}

///addby 李晓杰 NSString AES加密
+ (NSString *)encryptStringWithString:(NSString *)string andKey:(NSString *)key{
    const char *cStr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cStr length:[string length]];
    //对数据进行加密
    NSData *result = [self encryptDataWithData:data Key:key];
    //转换为2进制字符串
    if(result && result.length > 0){
        Byte *datas = (Byte *)[result bytes];
        NSMutableString *outPut = [NSMutableString stringWithCapacity:result.length];
        for(int i = 0 ; i < result.length ; i++){
            [outPut appendFormat:@"%02x",datas[i]];
        }
        return outPut;
    }
    return nil;
}
+ (NSString *)decryptStringWithString:(NSString *)string andKey:(NSString *)key{
    NSMutableData *data = [NSMutableData dataWithCapacity:string.length/2.0];
    unsigned char whole_bytes;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for(i = 0 ; i < [string length]/2 ; i++){
        byte_chars[0] = [string characterAtIndex:i * 2];
        byte_chars[1] = [string characterAtIndex:i * 2 + 1];
        whole_bytes = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_bytes length:1];
    }
    NSData *result = [self decryptDataWithData:data andKey:key];
    if(result && result.length > 0){
        return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    }
    return nil;
}
@end
