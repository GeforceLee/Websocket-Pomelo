//
// Created by ETiV on 13-4-19.
// Copyright (c) 2013 ETiV. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

extern NSString *const kPWSHandshakeDataUser;

extern NSString *const kPWSConnectCallback;
extern NSString *const kPWSUserCallback;
extern NSString *const kPWSDisconnectCallback;

typedef void(^PomeloWSCallback)(id arg);

@class PomeloWS;

@protocol PomeloWSDelegate <NSObject>

@optional
- (void)PomeloDidConnect:(PomeloWS *)pomelo;

- (void)PomeloDidDisconnect:(PomeloWS *)pomelo withError:(NSError *)error;

- (void)Pomelo:(PomeloWS *)pomelo didReceiveMessage:(NSArray *)message;

@end

@interface PomeloWS : NSObject <SRWebSocketDelegate> {
  // pointer to the delegate
  __unsafe_unretained id <PomeloWSDelegate> _delegate;

  // the main connector
  SRWebSocket *_webSocket;

  // callbacks and routes register
  NSMutableDictionary *_callbacks;
  NSMutableDictionary *_routeMap;

  // sequence request id
  NSUInteger _reqId;

  // heart beat config values
  NSUInteger _heartbeatInterval;
  NSUInteger _heartbeatTimeout;
  NSUInteger _nextHeartbeatTimeout;
  NSUInteger _gapThreshold;   // heartbeat gap threashold

  // used for enable/clear timeout callback
  BOOL _heartbeatShouldExe;
  BOOL _heartbeatTimeoutShouldExe;

  // hand shake data in initWithDelegate
  NSDictionary *_handShakeData_Sys;
  NSDictionary *_handShakeData_User;
  NSDictionary *_handShakeData;

  // base data structure
  // store dict/protos ect.
  NSMutableDictionary *_data;
}
#pragma mark - init
- (id)initWithDelegate:(id <PomeloWSDelegate>)delegate;

#pragma mark - connect
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port;

- (void)connectToHost:(NSString *)host onPort:(NSInteger)port withCallback:(PomeloWSCallback)callback;

- (void)connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params;
/**
 *	本地添加
 *
 *	@param	host
 *	@param	port
 *	@param	params
 *	@param	callback	
 */
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port params:(NSDictionary *)params withCallback:(PomeloWSCallback)callback;

#pragma mark - disconnect
- (void)disconnect;

- (void)disconnectWithCallback:(PomeloWSCallback)callback;

#pragma mark - main api

- (void)requestWithRoute:(NSString *)route andParams:(NSDictionary *)params andCallback:(PomeloWSCallback)callback;

- (void)notifyWithRoute:(NSString *)route andParams:(NSDictionary *)params;

- (void)onRoute:(NSString *)route withCallback:(PomeloWSCallback)callback;

- (void)offRoute:(NSString *)route;
- (void)offAllRoute;//本地添加 用于测试

#pragma mark - JSON helper
+ (id)decodeJSON:(NSData *)data error:(NSError **)error;

+ (NSString *)encodeJSON:(id)object error:(NSError **)error;

@end