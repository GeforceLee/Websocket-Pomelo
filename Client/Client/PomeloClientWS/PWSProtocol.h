//
// Created by ETiV on 13-4-19.
// Copyright (c) 2013 ETiV. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#define DICT_KEY(dict, key) [dict objectForKey:key]

typedef enum {
  PWS_MT_REQUEST = 0,
  PWS_MT_NOTIFY,
  PWS_MT_RESPONSE,
  PWS_MT_PUSH
} PWSMessageType;

typedef enum {
  PWS_PT_HANDSHAKE = 1,
  PWS_PT_HANDSHAKE_ACK,
  PWS_PT_HEARTBEAT,
  PWS_PT_DATA,
  PWS_PT_KICK
} PWSPackageType;

//@class PWSPackage, PWSMessage;
typedef NSMutableDictionary PWSMessage;
typedef NSMutableDictionary PWSPackage;

#pragma mark - define PWSProtocol

@interface PWSProtocol : NSObject

// String encoder and decoder
+ (NSData *)strEncode:(NSString *)str;

+ (NSString *)strDecode:(NSData *)data;

// Package encoder and decoder
+ (NSData *)packageEncodeWithType:(PWSPackageType)type
                          andBody:(NSData *)body;

+ (PWSPackage *)packageDecode:(NSData *)data;

// Message encoder and decoder
+ (NSData *)messageEncodeWithID:(NSInteger)msgId
                        andType:(PWSMessageType)type
                    andCompress:(BOOL)compressRoute
                       andRoute:(id)route
                        andBody:(NSData *)body;

+ (PWSMessage *)messageDecode:(NSData *)data;

@end

#pragma mark - define PWSMessage

NS_INLINE

PWSMessage *PWSMakeMessage(NSUInteger msgId, PWSMessageType type, BOOL compressRoute, id route, NSData *body) {
  return [NSMutableDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithUnsignedInteger:msgId], @"msgId",
      [NSNumber numberWithUnsignedInteger:type], @"type",
      [NSNumber numberWithBool:compressRoute], @"compressRoute",
      route, @"route",
      body, @"body",
      nil];
}

#pragma mark - define PWSPackage

NS_INLINE

PWSPackage *PWSMakePackage(PWSPackageType type, NSData *body) {
  return [NSMutableDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithUnsignedInteger:type], @"type",
      body, @"body",
      nil];
}

