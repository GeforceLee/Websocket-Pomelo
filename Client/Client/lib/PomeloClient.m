//
//  PomeloClient.m
//  Client
//
//  Created by xiaochuan on 13-9-23.
//  Copyright (c) 2013年 xiaochuan. All rights reserved.
//

#import "PomeloClient.h"
#import "PomeloProtocol.h"
#define POMELO_CLIENT_TYPE @"ios-websocket"
#define POMELO_CLIENT_VERSION @"0.0.1"

#define kPomeloHandshakeCallback @"kPomeloHandshakeCallback"
#define kPomeloCloseCallback @"kPomeloCloseCallback"


#if  DEBUG == 1
#define DEBUGLOG(...) NSLog(__VA_ARGS__)
#else
#define DEBUGLOG(...)
#endif



@interface PomeloClient (PrivateMethod)
/**
 *  发送消息
 *
 *  @param data 发送的数据
 */
- (void)send:(NSData *)data;


/**
 *  处理服务端返回的数据
 *
 *  @param package PomeloPackage
 */
- (void)processPackage:(PomeloPackage *)package;


/**
 *  处理服务器返回的握手信息
 *
 *  @param data 信息
 */
- (void)handshakeInit:(NSDictionary *)data;


/**
 *  处理错误
 *
 *  @param code 错误码
 */
- (void)handleErrorcode:(ResCode)code;

/**
 *  protobuf数据初始化
 *
 *  @param data 信息
 */
- (void)protobufDataInit:(NSDictionary *)data;

/**
 *  心跳包处理
 *
 *  @param data 信息
 */
- (void)heartbeat:(NSDictionary *)data;

/**
 *  清空超时标识
 *
 *  @param timeout 超时标识
 */
- (void)clearTimeout:(BOOL *)timeout;

/**
 *  发送心跳包
 */
- (void)sendHeartbeat;


/**
 *  当前时间
 *
 *  @return 返回当前时间的自1970年的秒数
 */
- (NSTimeInterval)timeNow;

/**
 *  处理超时
 */
- (void)handleHeartbeatTimeout;
@end

@implementation PomeloClient


- (id)initWithDelegate:(id)delegate{
    if (self = [super init]) {
        _callBacks = [[NSMutableDictionary alloc] init];
        _gapThreshold = 0.1;
    }
    return self;
}


- (void)connectToHost:(NSString *)host onPort:(NSString *)port{
    [self connectToHost:host onPort:port params:nil withCallback:nil];
}

- (void)connectToHost:(NSString *)host
               onPort:(NSString *)port
           withParams:(NSDictionary *)params{
    [self connectToHost:host onPort:port params:params withCallback:nil];
    
}

- (void)connectToHost:(NSString *)host
               onPort:(NSString *)port
         withCallback:(PomeloCallback)callback{
    [self connectToHost:host onPort:port params:nil withCallback:callback];
}

- (void)connectToHost:(NSString *)host
               onPort:(NSString *)port
               params:(NSDictionary *)params
         withCallback:(PomeloCallback)callback{
    NSString *urlStr = [NSString stringWithFormat:@"ws://%@:%@",host,port];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    _webSocket = [[SRWebSocket alloc] initWithURL:url];
    _webSocket.delegate = self;
    _connectionParam = params;
    
    if (callback) {
        [_callBacks setObject:callback forKey:kPomeloHandshakeCallback];
    }
    [_webSocket open];
}

- (void)disconnect{
    
    [self disconnectWithCallback:nil];
    
}

- (void)disconnectWithCallback:(PomeloCallback)callback{
    if (callback) {
        [_callBacks setObject:callback forKey:kPomeloCloseCallback];
    }
    [_webSocket close];
    
    if (_heartbeatId) {
        _heartbeatId = NO;
    }
    if (_heartbeatTimeoutId) {
        _heartbeatTimeoutId = NO;
    }
}

#pragma mark - JSON helper
+ (id)decodeJSON:(NSData *)data error:(NSError **)error {
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:0
                                             error:error];
}

+ (NSString *)encodeJSON:(id)object error:(NSError **)error {
    NSData *data = [NSJSONSerialization dataWithJSONObject:object
                                                   options:0
                                                     error:error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


#pragma mark -
#pragma mark private method

- (void)send:(NSData *)data{
    if (_webSocket ) {
        [_webSocket send:data];
    }
}

- (void)processPackage:(PomeloPackage *)package{
    
    PackageType type = [[package objectForKey:@"type"] intValue];
    id body = [package objectForKey:@"body"];
    switch (type) {
        case PackageTypeHandshake:{
            NSDictionary *data = [PomeloClient decodeJSON:body error:nil];
            NSInteger code = [[data objectForKey:@"code"] integerValue];
            if (code == ResCodeOldClient) {
                
                [self handleErrorcode:code];
                
            }else if (code == ResCodeFail){
                
                [self handleErrorcode:code];
                
            }else if (code == ResCodeOk ){
                
                [self handshakeInit:data];
                
                [self protobufDataInit:data];
                
                NSData *handshakeAck = [PomeloProtocol packageEncodeWithType:PackageTypeHandshakeAck andBody:nil];
                [self send:handshakeAck];
                PomeloCallback handCb = [_callBacks objectForKey:kPomeloHandshakeCallback];
                if (handCb) {
                    handCb(self);
                }
            }
            
        }
            break;
        case PackageTypeHeartBeat:
            DEBUGLOG(@"心跳");
            [self heartbeat:body];
            break;
        case PackageTypeData:
            
            break;
        case PackageTypeKick:
            
            break;
        default:
            break;
    }
}



- (void)handshakeInit:(NSDictionary *)data{
    NSTimeInterval iter =    [[[data objectForKey:@"sys"] objectForKey:@"heartbeat"] doubleValue];
    if (iter) {
        _heartbeatInterval = iter;
        _heartbeatTimeout = _heartbeatInterval * 2;
    }else{
        _heartbeatInterval = 0;
        _heartbeatTimeout = 0;
    }
}


- (void)protobufDataInit:(NSDictionary *)data{
    
}


- (void)heartbeat:(NSDictionary *)data{
    if (!_heartbeatInterval) {
        //没设置心跳
        return;
    }
    
    if (_heartbeatTimeoutId) {
        _heartbeatTimeoutId = NO;
    }
    
    
    if (_heartbeatId) {
        //已经发心跳包了
        return;
    }
    
    _heartbeatId = YES;
    [self performSelector:@selector(sendHeartbeat) withObject:nil afterDelay:_heartbeatInterval];

    
}

- (void)sendHeartbeat{
    NSData *heart = [PomeloProtocol packageEncodeWithType:PackageTypeHeartBeat andBody:nil];
    [self send:heart];
    _heartbeatId = NO;
    _nextHeartbeatTimeout = [self timeNow] + _heartbeatTimeout;
    
    _heartbeatTimeoutId = YES;
    [self performSelector:@selector(handleHeartbeatTimeout) withObject:nil afterDelay:_heartbeatTimeout];
}


- (void)handleHeartbeatTimeout{
    if (!_heartbeatTimeoutId) {
        return;
    }
    NSTimeInterval gap = _nextHeartbeatTimeout  - [self timeNow];
    if (gap > _gapThreshold) {
        _heartbeatTimeoutId = YES;
        [self performSelector:@selector(handleHeartbeatTimeout) withObject:nil afterDelay:gap];
    }else{
        DEBUGLOG(@"server heartbeat timeout");
        [self disconnect];
    }
}


- (void)handleErrorcode:(ResCode)code{
    //TODO
    
}


- (void)clearTimeout:(BOOL *)timeout
{
    *timeout = NO;
}


- (NSTimeInterval)timeNow{
    return [[NSDate date] timeIntervalSince1970];
}
#pragma mark --
#pragma mark SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    PomeloPackage *package = [PomeloProtocol packageDecode:message];
    [self processPackage:package];
}



- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    //打开后握手
    NSMutableDictionary *handshakeDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *sysDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *rsaDict = [NSMutableDictionary dictionary];
    [sysDict setObject:POMELO_CLIENT_TYPE forKey:@"type"];
    [sysDict setObject:POMELO_CLIENT_VERSION forKey:@"version"];
    [sysDict setObject:rsaDict forKey:@"rsa"];
    [handshakeDict setObject:sysDict forKey:@"sys"];
    [handshakeDict setObject:_connectionParam forKey:@"user"];
    //TODO rsa   protobuf
    
    
    NSString *handStr = [PomeloClient encodeJSON:handshakeDict error:nil];
    NSData *handData = [PomeloProtocol strEncode:handStr];
    NSData *handshakeData = [PomeloProtocol packageEncodeWithType:PackageTypeHandshake andBody:handData];
    
    [self send:handshakeData];
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    DEBUGLOG(@"error:%@",error);
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    DEBUGLOG(@"close code :%d   reason:%@",code,reason);
    PomeloCallback callback = [_callBacks objectForKey:kPomeloCloseCallback];
    if(callback) {
        callback(self);
    }
}
@end
