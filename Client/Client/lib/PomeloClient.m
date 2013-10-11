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

#define MESSAGE_CALLBACK_KEY(msgid) [NSString stringWithFormat:@"MESSAGE_CALLBACK_KEY_%d",msgid]
#define ROUTE_MAP_KEY(msgid) [NSString stringWithFormat:@"ROUTE_MAP_KEY_%d",msgid]

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
 *  处理握手信息
 *
 *  @param data 信息
 */
- (void)handleHandshake:(NSData *)data;

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


/**
 *  处理服务器发过的来数据
 *
 *  @param data 数据
 */
- (void)handleData:(NSData *)data;


/**
 *  处理消息数据
 *
 *  @param data 信息
 */
- (void)processMessage:(NSDictionary *)data;

/**
 *  发送消息
 *
 *  @param reqId requestid
 *  @param route 路由
 *  @param msg   消息体
 */
- (void)sendMessageWithRequestId:(NSInteger)reqId
                        andRoute:(NSString *)route
                          andMsg:(NSDictionary *)msg;




/**
 *  加密
 *
 *  @param reqId requestid
 *  @param route 路由
 *  @param msg   消息
 *
 *  @return 加密后的Data
 */
- (NSData *)encodeWithReqId:(NSInteger)reqId andRoute:(NSString *)route andMsg:(NSDictionary *)msg;
/**
 *  解密
 *
 *  @param data 原始数据
 *
 *  @return 解密后的数据
 */
- (NSDictionary *)decodeWithData:(NSData *)data;

/**
 *  解密消息体
 *
 *  @param msg 原始数据
 *
 *  @return 解密原始数据的消息体
 */
- (NSDictionary *)deCompose:(NSDictionary *)msg;
@end

@implementation PomeloClient


- (id)initWithDelegate:(id)delegate{
    if (self = [super init]) {
        _callBacks = [[NSMutableDictionary alloc] init];
        _gapThreshold = 0.1;
        _reqId = 0;
        _routeMap =[[NSMutableDictionary alloc] init];
        
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




- (void)requestWithRoute:(NSString *)route andParams:(NSDictionary *)params andCallback:(PomeloCallback)callback{
    NSDictionary *sendParams = params;
    if (!params) {
        sendParams = [NSDictionary dictionary];
    }
    _reqId++;
    
    if (callback) {
        [_callBacks setObject:callback forKey:MESSAGE_CALLBACK_KEY(_reqId)];
    }
    
    [_routeMap setObject:route forKey:ROUTE_MAP_KEY(_reqId)];
    [self sendMessageWithRequestId:_reqId andRoute:route andMsg:sendParams];
}


-(void)notifyWithRoute:(NSString *)route andParams:(NSDictionary *)params{
    NSDictionary *sendParams = params;
    if (!params) {
        sendParams = [NSDictionary dictionary];
    }
    
    [self sendMessageWithRequestId:0 andRoute:route andMsg:sendParams];
}


- (void)onRoute:(NSString *)route withCallback:(PomeloCallback)callback{
    if (callback) {
        [_callBacks setObject:callback forKey:route];
    }

}

- (void)offRoute:(NSString *)route{
    if (route) {
        [_callBacks removeObjectForKey:route];
    }
}

- (void)offAllRoute{
    [_callBacks removeAllObjects];
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
    DEBUGLOG(@"processPackage");
    PackageType type = [[package objectForKey:@"type"] intValue];
    id body = [package objectForKey:@"body"];
    switch (type) {
        case PackageTypeHandshake:
            
            [self handleHandshake:body];
            
            break;
        case PackageTypeHeartBeat:
            
            [self heartbeat:body];
            
            break;
        case PackageTypeData:
            
            [self handleData:body];
            
            break;
        case PackageTypeKick:
            
            break;
        default:
            break;
    }
}

- (void)handleHandshake:(NSData *)theData{
    NSDictionary *data = [PomeloClient decodeJSON:theData error:nil];
    NSInteger code = [[data objectForKey:@"code"] integerValue];
    if (code == ResCodeOldClient) {
        
        [self handleErrorcode:code];
        
    }else if (code == ResCodeFail){
        
        [self handleErrorcode:code];
        
    }else if (code == ResCodeOk ){
        
        [self handshakeInit:data];
        
        [self protobufDataInit:[data objectForKey:@"sys"]];
        
        NSData *handshakeAck = [PomeloProtocol packageEncodeWithType:PackageTypeHandshakeAck andBody:nil];
        [self send:handshakeAck];
        PomeloCallback handCb = [_callBacks objectForKey:kPomeloHandshakeCallback];
        if (handCb) {
            handCb(self);
        }
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
//        dict =         {
//            
//        };
//        heartbeat = 15;
//        protos =         {
//            client =             {
//            };
//            server =             {
//                
//                };
//            };
//            version = 1381463782000;
//        };
    if (data) {
        _dict = [data objectForKey:@"dict"];
        
        _abbrs =  [NSMutableDictionary dictionary];
        [_dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop) {
            [_abbrs setValue:key forKey:[NSString stringWithFormat:@"%@",obj]];
        }];
        _clientProtos = [[data objectForKey:@"protos"] objectForKey:@"client"];
        _serverProtos = [[data objectForKey:@"protos"] objectForKey:@"server"];
        _protoVersion = [[[data objectForKey:@"protos"] objectForKey:@"version"] integerValue];
    }
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
        [self handleErrorcode:ResCodeHeartBeatTimeout];
    }
}



- (void)handleData:(NSData *)data{
    NSDictionary   *theData = [self decodeWithData:data];
    
    [self processMessage:theData];
    
}


- (void)processMessage:(NSDictionary *)data{
    NSInteger msgId = [[data objectForKey:@"id"] integerValue];
    
    if (!msgId) {
        // server push message
        NSString *msgRoute = [data objectForKey:@"route"];
        if (msgRoute) {
            PomeloCallback pushCb = [_callBacks objectForKey:msgRoute];
            if (pushCb) {
                pushCb([data objectForKey:@"body"]);
            }
        }

        return;
    }
    
    PomeloCallback cb = [_callBacks objectForKey:MESSAGE_CALLBACK_KEY(msgId)];
    if (cb) {
        cb([data objectForKey:@"body"]);
    }
}


- (void)handleErrorcode:(ResCode)code{

    if (self.delegate && [self respondsToSelector:@selector(pomeloDisconnect:withError:)]) {
        [self.delegate pomeloDisconnect:self withError:[NSError errorWithDomain:@"pomeloclient" code:code userInfo:nil]];
    }
    
    [self disconnect];

}



- (NSDictionary *)decodeWithData:(NSData *)data{
    if ([self.delegate respondsToSelector:@selector(pomeloClientDecodeWithData:)]) {
        return [self.delegate pomeloClientDecodeWithData:data];
    }
    
    NSDictionary *msg = [PomeloProtocol messageDecode:data];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msg];
    NSInteger msgid = [[msg objectForKey:@"id"] intValue];
    if (msgid > 0) {
        NSString *route = [_routeMap objectForKey:ROUTE_MAP_KEY(msgid)];
        if (!route) {
            return nil;
        }
        [result setValue:route forKey:@"route"];
        [_routeMap removeObjectForKey:ROUTE_MAP_KEY(msgid)];
    }
    [result setValue:[self deCompose:result] forKey:@"body"];
    return result;
}

- (NSData *)encodeWithReqId:(NSInteger)reqId andRoute:(NSString *)route andMsg:(NSDictionary *)msg{
    if ([self.delegate respondsToSelector:@selector(pomeloClientEncodeWithReqId:andRoute:andMsg:)]) {
        return [self.delegate pomeloClientEncodeWithReqId:reqId andRoute:route andMsg:msg];
    }
    MessageType type = reqId ? MessageTypeRequest : MessageTypeNotify;
    
    
    NSData *data = nil;
    if (_clientProtos && [_clientProtos objectForKey:route]) {
        //TODO
    }else{
        NSString *str =[PomeloClient encodeJSON:msg error:nil];
        DEBUGLOG(@"%@",str);
        data = [PomeloProtocol strEncode:str];
    }
    
    BOOL compressRoute = NO;
    if (_dict && [_dict objectForKey:route]) {
        route = [_dict objectForKey:route];
        compressRoute = YES;
    }
    return [PomeloProtocol messageEncodeWithId:reqId andType:type andCompressRoute:compressRoute andRoute:route andBody:data];
}

- (NSDictionary *)deCompose:(NSMutableDictionary *)msg{
    NSString *route = [msg objectForKey:@"route"];
    
    BOOL compressRoute = [[msg objectForKey:@"compressRoute"] boolValue];
    if (compressRoute) {
        id abbRoute = [_abbrs objectForKey:route];
        if (!abbRoute) {
            return [NSDictionary dictionary];
        }
        [msg setObject:abbRoute forKey:@"route"];
        route = abbRoute;
    }
    
    if (_serverProtos && [_serverProtos objectForKey:route]) {
        //TODO protobuf
    }else{
        return [PomeloClient decodeJSON:[msg objectForKey:@"body"] error:nil];
    }
    return msg;
}



- (void)sendMessageWithRequestId:(NSInteger)reqId
                        andRoute:(NSString *)route
                          andMsg:(NSDictionary *)msg{

    //TODO 加密 protobuf
    
    NSData *data = [self encodeWithReqId:reqId andRoute:route andMsg:msg];
    
    NSData *packet = [PomeloProtocol packageEncodeWithType:PackageTypeData andBody:data];
    
    [self send:packet];
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
    DEBUGLOG(@"webSocket receive data");
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
    DEBUGLOG(@"close code :%d   reason:%@  wasClean:%d",code,reason,wasClean);
    PomeloCallback callback = [_callBacks objectForKey:kPomeloCloseCallback];
    if(callback) {
        callback(self);
    }
}
@end
