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

@implementation PomeloClient


- (id)initWithDelegate:(id)delegate{
    if (self = [super init]) {
        _callBacks = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)connectToHost:(NSString *)host onPort:(NSString *)port{
    
}

- (void)connectToHost:(NSString *)host
               onPort:(NSString *)port
           withParams:(NSDictionary *)params{
    
}

- (void)connectToHost:(NSString *)host
               onPort:(NSString *)port
         withCallback:(PomeloCallback)callback{
    
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
    [_webSocket open];
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


#pragma mark --
#pragma mark SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    //打开后握手
    
}



- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    
}
@end
