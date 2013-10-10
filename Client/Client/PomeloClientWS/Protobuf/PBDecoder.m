//
//  PBDecoder.m
//  protobuf.codec
//
//  Created by ETiV on 13-4-15.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import "PBDecoder.h"
#import "PBCodec.h"
#import "PBHelper.h"

//static PBDecoder *_privateDecoder = nil;

static NSDictionary *_protos = nil;
static NSMutableData *_buffer = nil;
static NSUInteger _offset = 0;

@interface PBDecoder (
private)

+ (NSMutableDictionary *)decodeMsg:(NSMutableDictionary *)msg withProtos:(NSDictionary *)protos length:(NSUInteger)length;

+ (id)decodeProp:(NSString *)typeStr withProtos:(NSDictionary *)protos;

+ (BOOL)isFinish:(NSDictionary *)msg withProtos:(NSDictionary *)protos;

+ (PBHead)getHead;

+ (PBHead)peekHead;

+ (void)decodeArray:(NSMutableArray *)array withTypeStr:(NSString *)typeStr andProtos:(NSDictionary *)protos;

+ (void)getBytes:(BOOL)flag toBuffer:(NSMutableData *)dest;

+ (void)peekBytesToBuffer:(NSMutableData *)dest;

@end

@implementation PBDecoder {
//  NSDictionary *_protos;
//  NSMutableData *_buffer;
//  NSUInteger _offset;
}

+ (void)initialize {
//  if (_privateDecoder == nil) {
////    _privateDecoder = [[PBDecoder alloc] init];
//    log("private encoder initialized.");
//  }
  _offset = 0;
  _buffer = [NSMutableData data];
}

//- (void)setProtos:(NSDictionary *)protos {
//  _protos = protos;
//  log("setProtos, pointer test:: %p, %p", _protos, protos);
//}
//
//- (NSDictionary *)protos {
//  return _protos;
//}
//
//- (void)setOffset:(NSUInteger)n {
//  _offset = n;
//}
//
//- (NSUInteger)offset {
//  return _offset;
//}
//
//- (void)setBuffer:(NSData *)data {
//  [_buffer setData:data];
//}
//
//- (NSMutableData *)buffer {
//  return _buffer;
//}

+ (void)protosInit:(NSDictionary *)protos {
  _protos = protos;
}

+ (NSDictionary *)protos {
  return _protos;
}

+ (void)setOffset:(NSUInteger)n {
  _offset = n;
}

+ (NSUInteger)offset {
  return _offset;
}

+ (void)setBuffer:(NSData *)data {
  [_buffer setData:data];
}

+ (NSMutableData *)buffer {
  return _buffer;
}

#pragma mark - decode
+ (NSMutableDictionary *)decodeMsgWithRoute:(NSString *)route andData:(NSData *)data {

  NSMutableDictionary *msg = [NSMutableDictionary dictionary];

  NSDictionary *protos = [[PBDecoder protos] objectForKey:route];

  [PBDecoder setBuffer:data];
  [PBDecoder setOffset:0];

  if (protos != nil && [protos count] > 0) {
    return [PBDecoder decodeMsg:msg withProtos:protos length:[PBDecoder buffer].length];
  }

  return [NSMutableDictionary dictionary];
}

@end

#pragma mark - private methods
@implementation PBDecoder (
private)

+ (NSMutableDictionary *)decodeMsg:(NSMutableDictionary *)msg withProtos:(NSDictionary *)protos length:(NSUInteger)length {
  while ([PBDecoder offset] < length) {
    PBHead head = [PBDecoder getHead];
    NSString *name = [[protos objectForKey:@"__tags"] objectForKey:[NSString stringWithFormat:@"%u", head.tag]];
    NSString *protosNameOption = [[protos objectForKey:name] objectForKey:@"option"];

    if ([protosNameOption isEqualToString:@"optional"] || [protosNameOption isEqualToString:@"required"]) {
      // msg[name] = decodeProp(protos[name].type, protos);
      [msg setObject:[PBDecoder decodeProp:[[protos objectForKey:name] objectForKey:@"type"] withProtos:protos] forKey:name];
    } else if ([protosNameOption isEqualToString:@"repeated"]) {
      id msgName = [msg objectForKey:name];
      if (msgName == nil || ![msgName isKindOfClass:[NSMutableArray class]]) {
        msgName = [NSMutableArray array];
		[msg setObject:msgName forKey:name];
      }
      [PBDecoder decodeArray:msgName withTypeStr:[[protos objectForKey:name] objectForKey:@"type"] andProtos:protos];
    }
  }

  return msg;
}

+ (id)decodeProp:(NSString *)typeStr withProtos:(NSDictionary *)protos {

  NSMutableData *_local_buffer_ = [NSMutableData data];

  if ([typeStr isEqualToString:@"uInt32"]) {
    [PBDecoder getBytes:NO toBuffer:_local_buffer_];
    uint64_t ui = [PBCodec decodeUInt32:_local_buffer_];
	return [NSNumber numberWithUnsignedLongLong:ui];
    // return [NSNumber numberWithUnsignedInt:ui];
  } else if ([typeStr isEqualToString:@"int32"] || [typeStr isEqualToString:@"sInt32"]) {
    [PBDecoder getBytes:NO toBuffer:_local_buffer_];
    int64_t si = [PBCodec decodeSInt32:_local_buffer_];
	return [NSNumber numberWithLongLong:si];
	// return [NSNumber numberWithInt:si];
  } else if ([typeStr isEqualToString:@"float"]) {
    float flt = [PBCodec decodeFloat:[PBDecoder buffer] from:[PBDecoder offset]];
    [PBDecoder setOffset:([PBDecoder offset] + 4)];
    return [NSNumber numberWithFloat:flt];
  } else if ([typeStr isEqualToString:@"double"]) {
    double dbl = [PBCodec decodeDouble:[PBDecoder buffer] from:[PBDecoder offset]];
    [PBDecoder setOffset:([PBDecoder offset] + 8)];
    return [NSNumber numberWithDouble:dbl];
  } else if ([typeStr isEqualToString:@"string"]) {
    [PBDecoder getBytes:NO toBuffer:_local_buffer_];
    NSUInteger length = (NSUInteger)[PBCodec decodeUInt32:_local_buffer_];

    NSMutableString *str = [PBCodec decodeStr:[PBDecoder buffer] from:[PBDecoder offset] withLength:length];
    [PBDecoder setOffset:([PBDecoder offset] + length)];
    return str;
  } else {
    NSDictionary *privateProtosMsg = [protos objectForKey:@"__messages"];
    NSDictionary *privateProtosMsgType = [privateProtosMsg objectForKey:typeStr];
    if (protos != nil && privateProtosMsgType != nil) {
      [PBDecoder getBytes:NO toBuffer:_local_buffer_];
      NSUInteger length = (NSUInteger)[PBCodec decodeUInt32:_local_buffer_];
      NSMutableDictionary *msg = [NSMutableDictionary dictionary];
      [PBDecoder decodeMsg:msg withProtos:privateProtosMsgType length:(length + [PBDecoder offset])];
      return msg;
    }
  }
  return nil;
}

// what is this for ?
+ (BOOL)isFinish:(NSDictionary *)msg withProtos:(NSDictionary *)protos {
  PBHead head = [PBDecoder getHead];
  NSDictionary *privateProtosTags = [protos objectForKey:@"__tags"];
  return (nil == [privateProtosTags objectForKey:[NSString stringWithFormat:@"%u", head.tag]]);
  // return (!protos.__tags[peekHead().tag]);
}

+ (PBHead)getHead {
  NSMutableData *_local_buffer_ = [NSMutableData dataWithLength:4];

  [PBDecoder getBytes:NO toBuffer:_local_buffer_];
  NSUInteger tag = (NSUInteger)[PBCodec decodeUInt32:_local_buffer_];

  PBHead head;
  head.type = (NSUInteger) tag & 0x07;
  head.tag = (NSUInteger) tag >> 3;

  return head;
}

+ (PBHead)peekHead {
  NSMutableData *_local_buffer_ = [NSMutableData dataWithLength:4];

  [PBDecoder peekBytesToBuffer:_local_buffer_];
  NSUInteger tag = (NSUInteger)[PBCodec decodeUInt32:_local_buffer_];

  PBHead head;
  head.type = (NSUInteger) tag & 0x07;
  head.tag = (NSUInteger) tag >> 3;

  return head;
}

+ (void)decodeArray:(NSMutableArray *)array withTypeStr:(NSString *)typeStr andProtos:(NSDictionary *)protos {
  NSMutableData *_local_buffer_ = [NSMutableData data];
  if ([PBHelper isSimpleType:[PBHelper translatePBTypeFromStr:typeStr]]) {
    [PBDecoder getBytes:NO toBuffer:_local_buffer_];
    NSUInteger length = (NSUInteger)[PBCodec decodeUInt32:_local_buffer_];
    NSUInteger i = 0;
    for (; i < length; i++) {
      [array addObject:[PBDecoder decodeProp:typeStr withProtos:nil]];
    }
  } else {
    [array addObject:[PBDecoder decodeProp:typeStr withProtos:protos]];
  }
}

+ (void)getBytes:(BOOL)flag toBuffer:(NSMutableData *)dest {
  if (dest == nil) {
    dest = [NSMutableData data];
  }
  NSUInteger pos = [PBDecoder offset];
  NSUInteger count = 0;
  unsigned char c = 0;

  unsigned char *buff = (unsigned char *) [PBDecoder buffer].bytes;
  unsigned char *_dst = malloc([PBDecoder buffer].length);

  do {
    c = buff[pos++];
    _dst[count++] = c;
  } while (c >= 128);

  if (NO == flag) {
    [PBDecoder setOffset:pos];
  }

  NSData *tmpData = [NSData dataWithBytes:_dst length:count];
  [dest setData:tmpData];

  free(_dst);
}

+ (void)peekBytesToBuffer:(NSMutableData *)dest {
  [PBDecoder getBytes:YES toBuffer:dest];
}


@end
