//
//  PomeloProtocol.h
//  Client
//
//  Created by xiaochuan on 13-9-23.
//  Copyright (c) 2013年 xiaochuan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  消息类型枚举
 */
typedef enum{
    MessageTypeRequest = 0,
    MessageTypeNotify,
    MessageTypeResponse,
    MessageTypePush
}MessageType;

/**
 *  包类型枚举
 */
typedef enum{
    PackageTypeHandshake = 1,
    PackageTypeHandshakeAck,
    PackageTypeHeartBeat,
    PackageTypeData,
    PackageTypeKick
}PackageType;


#define PKG_HEAD_BYTES  4
#define MSG_FLAG_BYTES  1
#define MSG_ROUTE_CODE_BYTES  2
#define MSG_ID_MAX_BYTES  5
#define MSG_ROUTE_LEN_BYTES  1

#define MSG_ROUTE_CODE_MAX  0xffff

#define MSG_COMPRESS_ROUTE_MASK  0x1
#define MSG_TYPE_MASK  0x7



typedef NSMutableDictionary PomeloMessage;
typedef NSMutableDictionary PomeloPackage;
@interface PomeloProtocol : NSObject


/**
 *  Encode String to Data use UTF8
 *
 *  @param str 要转换的String
 *
 *  @return 转换成的Data
 */
+ (NSData *)strEncode:(NSString *)str;

/**
 *  Decode Data to String use UTF8
 *
 *  @param data 要转换的data
 *
 *  @return 转换成的String
 */
+ (NSString *)strDecode:(NSData *)data;

/**
 *
 *  Package protocol encode.
 *
 *  Pomelo package format:
 *  +------+-------------+------------------+
 *  | type | body length |       body       |
 *  +------+-------------+------------------+
 *
 *  Head: 4bytes
 *   0: package type,
 *      1 - handshake,
 *      2 - handshake ack,
 *      3 - heartbeat,
 *      4 - data
 *      5 - kick
 *   1 - 3: big-endian body length
 *  Body: body length bytes
 *
 *
 *  @param type package type
 *  @param body body content in bytes
 *
 *  @return new byte array that contains encode result
 */
+ (NSData *)packageEncodeWithType:(PackageType)type andBody:(NSData *)body;



/**
 *  * Package protocol decode.
 *  See encode for package format.
 *
 *  @param buffer buffer byte array containing package content
 *
 *  @return PomeloPackage
 */
+ (PomeloPackage *)packageDecode:(NSData *)buffer;

@end

//PomeloMessage * MakePomeloMessage(NSUndoManager msgId,MessageType type, BOOL compressRoute)


PomeloPackage * MakePomeloPackage(PackageType type,NSData *body){
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:type],@"type",
            body,@"body", nil];
}
