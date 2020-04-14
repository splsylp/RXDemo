//
//  HYTApiClient.m
//  HIYUNTON
//
//  Created by yuxuanpeng MINA on 14-10-11.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import "HYTApiClient.h"

@implementation HYTApiClient

+ (RX_MKNetworkEngine *)engine
{
    static dispatch_once_t onceToken;
    static RX_MKNetworkEngine *shareEngine;
    dispatch_once(&onceToken, ^ {
     
        //加一个业务服务器
        
        shareEngine = [[RX_MKNetworkEngine alloc] initWithHostName:@"5"];
    });
    return shareEngine;
}

+ (RX_MKNetworkOperation *)requestWithPath:(NSString *)path headers:(NSDictionary *)headers params:(NSDictionary *)params
{
    NSAssert(path!=nil, @"the url path can't be null");
    RX_MKNetworkOperation *operation = [[HYTApiClient engine] operationWithPath:path params:params httpMethod:@"GET" ssl:YES];
    if (headers) {
        [operation addHeaders:headers];
    }
    return operation;
}

+ (RX_MKNetworkOperation *)requestWithPath:(NSString *)path headers:(NSDictionary *)headers postBody:(NSData *)data
{
    NSAssert(path!=nil, @"the url path can't be null");
    RX_MKNetworkOperation *operation = [[HYTApiClient engine] operationWithPath:path params:nil httpMethod:@"POST" ssl:YES];
    [operation setStringEncoding:NSUTF8StringEncoding];
    [operation setShouldContinueWithInvalidCertificate:YES];
    [operation setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    if (headers) {
        [operation addHeaders:headers];
    }
    if (data) {
        [operation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lu", (unsigned long)data.length], @"Content-Length", nil]];
        [operation setHttpPostData:data];
    }
#ifdef DEBUG
   // HYTDLog(@"http headers=%@", [headers description]);
    //HYTDLog(@"http postdata=%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#endif
    return operation;
}
//运动会专属
+ (RX_MKNetworkOperation *)requestSportMeetWithPath:(NSString *)path headers:(NSDictionary *)headers postBody:(NSData *)data
{
    NSAssert(path!=nil, @"the url path can't be null");
//  暂时屏蔽
    RX_MKNetworkOperation *operation = [[HYTApiClient engine] operationWithURLString:[NSString stringWithFormat:@"%@%@",/*[RXUser sharedInstance].friendGroupUrl*/@"",path] params:nil httpMethod:@"POST"];

    [operation setStringEncoding:NSUTF8StringEncoding];
    [operation setShouldContinueWithInvalidCertificate:YES];
    [operation setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    if (headers) {
        [operation addHeaders:headers];
    }
    if (data) {
        [operation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lu", (unsigned long)data.length], @"Content-Length", nil]];
        [operation setHttpPostData:data];
    }
#ifdef DEBUG
//     HYTDLog(@"http headers=%@", [headers description]);
//    HYTDLog(@"http postdata=%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//    HYTDLog(@"request url= %@",[NSString stringWithFormat:@"%@%@",[RXUser sharedInstance].friendGroupUrl,path]);
#endif
    return operation;
}
//自定义url path自己拼接
+(RX_MKNetworkOperation *)requestCustomPath:(NSString *)path headers:(NSDictionary *)headers postBody:(NSData *)data
{
    RX_MKNetworkOperation *operation = [[HYTApiClient engine] operationWithURLString:path params:nil httpMethod:@"POST"];
    
    [operation setStringEncoding:NSUTF8StringEncoding];
    [operation setShouldContinueWithInvalidCertificate:YES];
    [operation setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    if (headers) {
        [operation addHeaders:headers];
    }
    if (data) {
        [operation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lu", (unsigned long)data.length], @"Content-Length", nil]];
        [operation setHttpPostData:data];
    }
#ifdef DEBUG
    // HYTDLog(@"http headers=%@", [headers description]);
    //HYTDLog(@"http postdata=%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#endif
    return operation;
}


@end
