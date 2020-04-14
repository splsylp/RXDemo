//
//  NSString+AES.h
//  Chat
//
//  Created by 魏继源 on 17/3/9.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TRIPLEDESKEY @"hfbank2016101011"
#define ALGORITHMSTR   @"AES/ECB/PKCS5Padding"

@interface NSString (AES)
+ (NSString *)encodedData:(NSString *)srcData withKey:(NSString *)theKey;
+ (NSString *)decodeData:(NSString *)srcData withKey:(NSString *)theKey;
+ (NSData *)encoded_aseData:(NSData *)fileData withkey:(NSString *)encodedKey;
+ (NSData *)decoded_aseData:(NSData *)fileData withKey:(NSString *)decodedKey;


+ (NSString *)encryptStringWithString:(NSString *)string andKey:(NSString *)key;
+ (NSString *)decryptStringWithString:(NSString *)string andKey:(NSString *)key;

@end
