//
//  Codec.h
//  protobuf.codec
//
//  Created by ETiV on 13-4-15.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define DEBUG_LOG 1
//
//#ifdef DEBUG_LOG
//#define log(fmt, args...) SSLog(@fmt, ##args)
//#else
//#define log(fmt, args...)
//#endif

#define JSON_stringify(data) [[NSString alloc] initWithData:([NSJSONSerialization dataWithJSONObject:(data) options:0 error:nil]) encoding:NSUTF8StringEncoding]
#define JSON_parse(string) [NSJSONSerialization JSONObjectWithData:([string dataUsingEncoding:NSUTF8StringEncoding]) options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil]

typedef enum {
	PBT_Unknown = -1,
	PBT_UInt32 = 0,
	PBT_SInt32 = 0,
	PBT_Int32 = 0,
	PBT_Double = 1,
	PBT_String = 2,
	PBT_Message = 2,
	PBT_Float = 5
} ProtoBufType;

//inline void translatePBTypeFromType(ProtoBufType type, NSMutableString *str) {
//  switch (type) {
//    case PBT_UInt32:
//      [str setString:@"uInt32"];
//      break;
//    case PBT_SInt32:
//      [str setString:@"sInt32"];
//      break;
//    case PBT_Float:
//      [str setString:@"float"];
//      break;
//    case PBT_Double:
//      [str setString:@"double"];
//      break;
//    case PBT_String:
//      [str setString:@"string"];
//      break;
//    default:
//      [str setString:@"unknown"];
//  }
//}

@interface PBCodec : NSObject

/**
 * unsigned long
 */
+ (NSMutableData *)encodeUInt32:(uint64_t)n;

+ (uint64_t)decodeUInt32:(NSData *)data;

/**
 * signed long
 */
+ (NSMutableData *)encodeSInt32:(int64_t)n;

+ (int64_t)decodeSInt32:(NSData *)data;

///**
// * unsigned long long
// */
//+ (NSMutableData *)encodeUInt64:(uint64_t)n;
//
//+ (uint64_t)decodeUInt64:(NSData *)data;
//
///**
// * signed long long
// */
//+ (NSMutableData *)encodeSInt64:(int64_t)n;
//
//+ (int64_t)decodeSInt64:(NSData *)data;

/**
 * float
 */
+ (NSMutableData *)encodeFloat:(float)n;

+ (float)decodeFloat:(NSData *)data from:(NSUInteger)offset;

/**
 * double
 */
+ (NSMutableData *)encodeDouble:(double)n;

+ (double)decodeDouble:(NSData *)data from:(NSUInteger)offset;

/**
 * string
 */
+ (NSUInteger)encodeStr:(NSString *)str dst:(NSMutableData *)dst from:(NSUInteger)offset;

+ (NSMutableString *)decodeStr:(NSData *)data from:(NSUInteger)offset withLength:(NSUInteger)length;

+ (unsigned long)byteLength:(NSString *)str;

@end
