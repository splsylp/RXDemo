//
//  HYTApiClient.h
//  HIYUNTON
//
//  Created by yuxuanpeng MINA on 14-10-11.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//
//HYTApiClient.h   是三方网络引擎MKNetwork管理的
#import <Foundation/Foundation.h>
#import "RX_MKNetworkKit.h"
#import "KCConstants_API.h"
/*
 *
 *  海运通接口
 *  支持多任务
 */
@interface HYTApiClient : NSObject

+ (RX_MKNetworkEngine *)engine;

/**
 *  GET请求
 *
 *  @param path     URL地址
 *  @param headers http header
 *  @param params  参数
 *
 *  @return 网络请求
 */
+ (RX_MKNetworkOperation *)requestWithPath:(NSString *)path headers:(NSDictionary *)headers params:(NSDictionary *)params;

/**
 *  POST请求
 *
 *  @param path     URL地址
 *  @param headers Http header
 *  @param data    POST数据
 *
 *  @return 网络请求
 */
+ (RX_MKNetworkOperation *)requestWithPath:(NSString *)path headers:(NSDictionary *)headers postBody:(NSData *)data;
/**
 *  POST请求 运动会专属
 *
 *  @param path     URL地址
 *  @param headers Http header
 *  @param data    POST数据
 *
 *  @return 网络请求
 */

+ (RX_MKNetworkOperation *)requestSportMeetWithPath:(NSString *)path headers:(NSDictionary *)headers postBody:(NSData *)data;

/**
 *  POST请求 自定义url
 *
 *  @param path     URL地址
 *  @param headers Http header
 *  @param data    POST数据
 *
 *  @return 网络请求
 */
+(RX_MKNetworkOperation *)requestCustomPath:(NSString *)path headers:(NSDictionary *)headers postBody:(NSData *)data;


@end
