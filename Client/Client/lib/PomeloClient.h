//
//  PomeloClient.h
//  Client
//
//  Created by xiaochuan on 13-9-23.
//  Copyright (c) 2013年 xiaochuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"


typedef void(^PomeloCallback)(id arg);


@interface PomeloClient : NSObject<SRWebSocketDelegate>{
    SRWebSocket *_webSocket;
}
@property (nonatomic,assign) id delegate;


#pragma mark --  连接
/**
 *  初始化方法
 *
 *  @param delegate 代理
 *
 *  @return PomeloClient
 */
- (id)initWithDelegate:(id)delegate;

/**
 *  连接
 *
 *  @param host 地址
 *  @param port 端口
 */
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port;

/**
 *  连接
 *
 *  @param host     地址
 *  @param port     端口
 *  @param callback 完成后的回调
 */
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port withCallback:(PomeloCallback)callback;

/**
 *  连接
 *
 *  @param host   地址
 *  @param port   端口
 *  @param params 发出去的参数
 */
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params;

/**
 *  连接
 *
 *  @param host     地址
 *  @param port     端口
 *  @param params   发出去的参数
 *  @param callback 完成后的回调
 */
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port params:(NSDictionary *)params withCallback:(PomeloCallback)callback;

#pragma mark -- 断开

/**
 *  断开连接
 */
- (void)disconnect;

/**
 *  断开连接
 *
 *  @param callback 完成后的回调
 */
- (void)disconnectWithCallback:(PomeloCallback)callback;


#pragma mark -- 通信
/**
 *  发送请求
 *
 *  @param route    路由地址
 *  @param params   发送的参数
 *  @param callback 完成后的回调函数
 */
- (void)requestWithRoute:(NSString *)route andParams:(NSDictionary *)params andCallback:(PomeloCallback)callback;


/**
 *  发送通知
 *
 *  @param route  路由地址
 *  @param params 发送的参数
 */
- (void)notifyWithRoute:(NSString *)route andParams:(NSDictionary *)params;


/**
 *  注册通知回调函数
 *
 *  @param route    路由地址
 *  @param callback 通知出发的回调函数
 */
- (void)onRoute:(NSString *)route withCallback:(PomeloCallback)callback;

/**
 *  注销通知
 *
 *  @param route 路由地址
 */
- (void)offRoute:(NSString *)route;

/**
 *  注销所有通知
 */
- (void)offAllRoute;



+ (id)decodeJSON:(NSData *)data error:(NSError **)error;
+ (NSString *)encodeJSON:(id)object error:(NSError **)error;
@end
