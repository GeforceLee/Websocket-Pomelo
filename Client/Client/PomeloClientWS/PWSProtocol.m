//
// Created by ETiV on 13-4-19.
// Copyright (c) 2013 ETiV. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PWSProtocol.h"

static NSUInteger const PKG_HEAD_BYTES = 4;
static NSUInteger const MSG_FLAG_BYTES = 1;
static NSUInteger const MSG_ROUTE_CODE_BYTES = 2;
static NSUInteger const MSG_ID_MAX_BYTES = 5;
static NSUInteger const MSG_ROUTE_LEN_BYTES = 1;

static NSUInteger const MSG_ROUTE_CODE_MAX = 0xffff;

static NSUInteger const MSG_COMPRESS_ROUTE_MASK = 0x1;
static NSUInteger const MSG_TYPE_MASK = 0x7;

static NSString *EXCEPTION_ROUTE_MUST_BE_A_NUMBER = @"Route Must Be A Number.";
static NSString *EXCEPTION_ROUTE_OVERFLOW_MAXLENGTH = @"Route MaxLength Overflow.";
static NSString *EXCEPTION_ROUTE_CODE_OVERFLOW_MAXVALUE = @"Route Code Max Value Overflow.";
static NSString *EXCEPTION_MSG_TYPE_UNKNOWN = @"Message Type Unknown.";
static NSString *EXCEPTION_MSG_ROUTE_TYPE_NOT_MATCH = @"The Route Value of the Message Instance is Neighter a NSNumber nor a NSString.";

#pragma mark - define PWSProtocol private methods
@interface PWSProtocol (
private)

+ (void)copyData:(NSMutableData *)dest
       dstOffset:(NSUInteger)dest_offset
             src:(NSData *)source
       srcOffset:(NSUInteger)source_offset
             len:(NSUInteger)length;

+ (BOOL)msgHasId:(PWSMessageType)type;

+ (BOOL)msgHasRoute:(PWSMessageType)type;

+ (NSUInteger)calculateMsgIdBytes:(NSInteger)msgId;

+ (NSUInteger)encodeMsgFlagWithType:(PWSMessageType)type
                   andCompressRoute:(BOOL)compressRoute
                          andBuffer:(NSMutableData *)buffer
                          andOffset:(NSUInteger)offset;

+ (NSUInteger)encodeMsgIdWithID:(NSInteger)msgId
                     andIDBytes:(NSUInteger)idBytes
                      andBuffer:(NSMutableData *)buffer
                      andOffset:(NSUInteger)offset;
+ (NSUInteger)encodeMsgIdWithID:(NSInteger)msgId
                      andBuffer:(NSMutableData *)buffer
                      andOffset:(NSUInteger)offset;
+ (NSUInteger)encodeMsgRouteWithCompressRoute:(BOOL)compressRoute
                                     andRoute:(id)route
                                   andBuffser:(NSMutableData *)buffer
                                    andOffset:(NSUInteger)offset;

+ (NSUInteger)encodeMsgBodyWithBody:(NSData *)body
                          andBuffer:(NSMutableData *)buffer
                          andOffset:(NSUInteger)offset;

@end

#pragma mark - PWSProtocol Public Methods

@implementation PWSProtocol

#pragma mark - String Encoder and Decoder

+ (NSData *)strEncode:(NSString *)str {
  return [str dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)strDecode:(NSData *)data {
  return [[NSString alloc] initWithData:data
                               encoding:NSUTF8StringEncoding];
}

#pragma mark - Package Encoder and Decoder


+ (NSData *)packageEncodeWithType:(PWSPackageType)type
                          andBody:(NSData *)body {
  unsigned char iTmp = 0;

  NSUInteger length = (body == nil) ? 0 : [body length];
  NSMutableData *buffer = [NSMutableData dataWithLength:(PKG_HEAD_BYTES + length)];
  NSUInteger index = 0;

  iTmp = type & 0xff;
  [buffer replaceBytesInRange:NSMakeRange(index++, 1)
                    withBytes:&iTmp
                       length:1];

  iTmp = (unsigned char) ((length >> 16) & 0xff);
  [buffer replaceBytesInRange:NSMakeRange(index++, 1)
                    withBytes:(const void *) &iTmp
                       length:1];

  iTmp = (unsigned char) ((length >> 8) & 0xff);
  [buffer replaceBytesInRange:NSMakeRange(index++, 1)
                    withBytes:(const void *) &iTmp
                       length:1];

  iTmp = (unsigned char) (length & 0xff);
  [buffer replaceBytesInRange:NSMakeRange(index++, 1)
                    withBytes:(const void *) &iTmp
                       length:1];

  if (length > 0) {
    [PWSProtocol copyData:buffer dstOffset:index src:body srcOffset:0 len:length];
  }

  return buffer;
}


+ (PWSPackage *)packageDecode:(NSData *)data {
  unsigned char *bytes = (unsigned char *) data.bytes;
  PWSPackageType type = (PWSPackageType) bytes[0];
  unsigned int index = 1;
  unsigned int length = ((bytes[index++]) << 16 | (bytes[index++]) << 8 | bytes[index++]) >> 0;
  NSData *body = [NSData dataWithBytes:&(bytes[index]) length:length];

  return PWSMakePackage(type, body);
//  return [PWSPackage packageWithType:type andBody:body];
}

#pragma mark - Message Encoder and Decoder


+ (NSData *)messageEncodeWithID:(NSInteger)msgId
                        andType:(PWSMessageType)type
                    andCompress:(BOOL)compressRoute
                       andRoute:(id)route
                        andBody:(NSData *)body {
  NSUInteger idBytes = (YES == [PWSProtocol msgHasId:type]) ? [PWSProtocol calculateMsgIdBytes:msgId] : 0;
  NSUInteger msgLen = MSG_FLAG_BYTES + idBytes;

  NSNumber *routeNumCode = nil;
  NSData *routeEncoded = nil;

  BOOL isRouteUseNumber = NO;

  if ([PWSProtocol msgHasRoute:type]) {
    if (compressRoute) {
      // route is numberic
      if (![route isKindOfClass:[NSNumber class]]) {
        [NSException raise:EXCEPTION_ROUTE_MUST_BE_A_NUMBER format:@"Message Encode Need a Numberic Route Code."];
      }
      msgLen += MSG_ROUTE_CODE_BYTES;
      isRouteUseNumber = YES;
      routeNumCode = [route copy];
    } else {
      // route is string
      msgLen += MSG_ROUTE_LEN_BYTES;
      if (route != nil && [route isKindOfClass:[NSString class]] && ![route isEqualToString:@""]) {
        routeEncoded = [PWSProtocol strEncode:route];
        if ([routeEncoded length] > 255) {
          [NSException raise:EXCEPTION_ROUTE_OVERFLOW_MAXLENGTH format:@"Encoded Route Length is Overflow the Max Value."];
        }
        msgLen += [routeEncoded length];
      }
    }
  }

  if (body != nil) {
    msgLen += [body length];
  }

  NSMutableData *buffer = [NSMutableData dataWithLength:msgLen];
  NSUInteger offset = 0;

  // add flag
  offset = [PWSProtocol encodeMsgFlagWithType:type andCompressRoute:compressRoute andBuffer:buffer andOffset:offset];

  // add message id
  if ([PWSProtocol msgHasId:type]) {
//    offset = [PWSProtocol encodeMsgIdWithID:msgId andIDBytes:idBytes andBuffer:buffer andOffset:offset];
	  offset = [PWSProtocol encodeMsgIdWithID:msgId andBuffer:buffer andOffset:offset];
  }

  // add route
  if ([PWSProtocol msgHasRoute:type]) {
    offset = [PWSProtocol encodeMsgRouteWithCompressRoute:compressRoute andRoute:(isRouteUseNumber ? routeNumCode : routeEncoded) andBuffser:buffer andOffset:offset];
  }

  // add body
  if (body != nil) {
    /*offset = */[PWSProtocol encodeMsgBodyWithBody:body andBuffer:buffer andOffset:offset];
  }

  return buffer;
}


+ (PWSMessage *)messageDecode:(NSData *)data {
  unsigned char *bytes = (unsigned char *) data.bytes;
  unsigned long bytesLen = [data length];
  unsigned long offset = 0;
  unsigned long msgId = 0;

  // parse flag (compressedRoute and msgType)
  unsigned char flag = bytes[offset++];
  BOOL compressRoute = (flag & MSG_COMPRESS_ROUTE_MASK) == 1 ? YES : NO;
  PWSMessageType type = (PWSMessageType) ((flag >> 1) & MSG_TYPE_MASK);

  // parse id
  if ([PWSProtocol msgHasId:type]) {
//    unsigned char byte = bytes[offset++];
//    msgId = byte & 0x7f;
//    while (byte & 0x80) {
//      msgId <<= 7;
//      byte = bytes[offset++];
//      msgId |= byte & 0x7f;
//    }
	  
	NSInteger m = bytes[offset];
	int i = 0;
	do{
		m = bytes[offset];
		msgId = msgId +((m & 0x7f) *pow(2, 7*i));
		offset++;
		i++;
	}while(m>=128);
  }

  // parse route
  NSNumber *routeCode = nil;
  NSString *routeDecoded = @"";
  if ([PWSProtocol msgHasRoute:type]) {
    if (compressRoute) {
      // numberic route
      unsigned long routeNumber = (bytes[offset++]) << 8 | bytes[offset++];
      routeCode = [NSNumber numberWithUnsignedLong:routeNumber];
    } else {
      // string route
      unsigned long routeLen = bytes[offset++];
      if (routeLen) {
        NSMutableData *routeEncoded = [NSMutableData dataWithLength:routeLen];
        [PWSProtocol copyData:routeEncoded dstOffset:0 src:data srcOffset:offset len:routeLen];
        routeDecoded = [PWSProtocol strDecode:routeEncoded];
      }
      offset += routeLen;
    }
  }

  unsigned long bodyLen = bytesLen - offset;
  NSMutableData *body = [NSMutableData dataWithLength:bodyLen];
  [PWSProtocol copyData:body dstOffset:0 src:data srcOffset:offset len:bodyLen];
  // TODO may has bug here for Message.route

	
  return PWSMakeMessage(msgId, type, compressRoute, (routeCode == nil ? routeDecoded : routeCode ), body);
}

@end

#pragma mark -
#pragma mark PWSProtocol Private Methods

@implementation PWSProtocol (
private)

+ (void)copyData:(NSMutableData *)dest
       dstOffset:(NSUInteger)dest_offset
             src:(NSData *)source
       srcOffset:(NSUInteger)source_offset
             len:(NSUInteger)length {
  unsigned char *ptr_tmp = (unsigned char *) source.bytes;

  [dest replaceBytesInRange:NSMakeRange(dest_offset, length)
                  withBytes:&(ptr_tmp[source_offset])
                     length:length];
}

+ (BOOL)msgHasId:(PWSMessageType)type {
  return (type == PWS_MT_REQUEST || type == PWS_MT_RESPONSE);
}

+ (BOOL)msgHasRoute:(PWSMessageType)type {
  return (type == PWS_MT_REQUEST || type == PWS_MT_NOTIFY || type == PWS_MT_PUSH);
}

+ (NSUInteger)calculateMsgIdBytes:(NSInteger)msgId {
  NSUInteger len = 0;
  do {
    len += 1;
    msgId >>= 7;
  } while (msgId > 0);
  return len;
}

+ (NSUInteger)encodeMsgFlagWithType:(PWSMessageType)type
                   andCompressRoute:(BOOL)compressRoute
                          andBuffer:(NSMutableData *)buffer
                          andOffset:(NSUInteger)offset {
  if (type != PWS_MT_REQUEST && type != PWS_MT_NOTIFY &&
      type != PWS_MT_RESPONSE && type != PWS_MT_PUSH) {
    [NSException raise:EXCEPTION_MSG_TYPE_UNKNOWN
                format:@"Message Type Unknown, Value : %d", type];
  }

  unsigned char tmp = (type << 1) | (compressRoute == YES ? 1 : 0);

  [buffer replaceBytesInRange:NSMakeRange(offset, 1)
                    withBytes:&tmp
                       length:1];  // magin number 1, for 1 byte, size of one byte

  return offset + MSG_FLAG_BYTES;
}

+ (NSUInteger)encodeMsgIdWithID:(NSInteger)msgId
                     andIDBytes:(NSUInteger)idBytes
                      andBuffer:(NSMutableData *)buffer
                      andOffset:(NSUInteger)offset {
  unsigned long index = offset + idBytes - 1;

  unsigned char tmp = (unsigned char) (msgId & 0x7f);
  [buffer replaceBytesInRange:NSMakeRange(index--, 1)
                    withBytes:&tmp
                       length:1];

  while (index >= offset) {
    msgId >>= 7;
    tmp = (unsigned char) ((msgId & 0x7f) | 0x80);
    [buffer replaceBytesInRange:NSMakeRange(index--, 1)
                      withBytes:&tmp
                         length:1];
  }

  return offset + idBytes;
}


+ (NSUInteger)encodeMsgIdWithID:(NSInteger)msgId
                      andBuffer:(NSMutableData *)buffer
                      andOffset:(NSUInteger)offset {
	NSUInteger tmpOffset = offset;
	NSInteger tmpMsgId = msgId;
	do {
		NSInteger tmp = tmpMsgId % 128;
		NSInteger next = tmpMsgId /128;
		if (next != 0) {
			tmp += 128;
		}
		[buffer replaceBytesInRange:NSMakeRange(tmpOffset++, 1) withBytes:&tmp length:1];
		tmpMsgId = next;
	} while (tmpMsgId != 0);
	
	return tmpOffset;

}

+ (NSUInteger)encodeMsgRouteWithCompressRoute:(BOOL)compressRoute
                                     andRoute:(id)route
                                   andBuffser:(NSMutableData *)buffer
                                    andOffset:(NSUInteger)offset {
  unsigned char tmp = 0;
  if (compressRoute) {
    if (![route isKindOfClass:[NSNumber class]]) {
      [NSException raise:EXCEPTION_MSG_ROUTE_TYPE_NOT_MATCH format:@"Route %@ Must Be A NSNumber.", route];
    } else {
      NSUInteger routeNumber = [route unsignedIntegerValue];
      if (routeNumber > MSG_ROUTE_CODE_MAX) {
        [NSException raise:EXCEPTION_ROUTE_CODE_OVERFLOW_MAXVALUE
                    format:@"Route Code is Overflow the Max Value."];
      }
      tmp = (unsigned char) ((routeNumber >> 8) & 0xff);
      [buffer replaceBytesInRange:NSMakeRange(offset++, 1)
                        withBytes:&tmp
                           length:1];

      tmp = (unsigned char) (routeNumber & 0xff);
      [buffer replaceBytesInRange:NSMakeRange(offset++, 1)
                        withBytes:&tmp
                           length:1];
    }
  } else {
    // if (route != nil && ![route isKindOfClass:[NSString class]]) {
    if (route != nil && [route length] == 0) {
      [NSException raise:EXCEPTION_MSG_ROUTE_TYPE_NOT_MATCH format:@"Route %@ Must Be A NSString.", route];
    } else {
      route = (NSString *) route;
      if (route != nil /* && [route isEqualToString:@""] == NO */) {
        tmp = (unsigned char) ([route length] & 0xff);
        [buffer replaceBytesInRange:NSMakeRange(offset++, 1)
                          withBytes:&tmp
                             length:1];

        [PWSProtocol copyData:buffer
                    dstOffset:offset
                          src:route //[(NSString *) route dataUsingEncoding:NSUTF8StringEncoding]
                    srcOffset:0
                          len:[route length]];

        offset += [route length];
      } else {
        tmp = 0;
        [buffer replaceBytesInRange:NSMakeRange(offset++, 1)
                          withBytes:&tmp
                             length:1];
      }
    }
  }

  return offset;
}

+ (NSUInteger)encodeMsgBodyWithBody:(NSData *)body
                          andBuffer:(NSMutableData *)buffer
                          andOffset:(NSUInteger)offset {

  [PWSProtocol copyData:buffer dstOffset:offset src:body srcOffset:0 len:[body length]];

  return (offset + [body length]);
}

@end

