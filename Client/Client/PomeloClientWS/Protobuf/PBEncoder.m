//
//  PBEncoder.m
//  protobuf.codec
//
//  Created by ETiV on 13-4-15.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import "PBEncoder.h"
#import "PBCodec.h"
#import "PBHelper.h"

static PBEncoder *_privateEncoder = nil;

@interface PBEncoder (
private)

+ (BOOL)checkMsg:(NSDictionary *)msg withProtos:(NSDictionary *)protos;

+ (NSUInteger)encodeMsg:(NSDictionary *)msg
             fromOffset:(NSUInteger)offset
             withProtos:(NSDictionary *)protos
               toBuffer:(NSMutableData *)dest;

+ (NSUInteger)encodeProp:(id)value
               asTypeStr:(NSString *)typeStr
               andProtos:(NSDictionary *)protos
                    from:(NSUInteger)offset
                toBuffer:(NSMutableData *)dest;

+ (NSUInteger)encodeArray:(NSArray *)array
                withProto:(NSDictionary *)proto
                andProtos:(NSDictionary *)protos
                     from:(NSUInteger)offset
                 toBuffer:(NSMutableData *)dest;

+ (NSUInteger)writeBytes:(NSMutableData *)source from:(NSUInteger)offset withData:(NSData *)data;

+ (NSMutableData *)encodeTag:(NSUInteger)tag withPBTypeStr:(NSString *)typeStr;

@end

@implementation PBEncoder {
  NSDictionary *_protos;
}

+ (void)initialize {
  if (_privateEncoder == nil) {
    _privateEncoder = [[PBEncoder alloc] init];
//    log("private encoder initialized.");
  }
}

- (void)setProtos:(NSDictionary *)protos {
  _protos = protos;
//  log("setProtos, pointer test:: %p, %p", _protos, protos);
}

- (NSDictionary *)protos {
  return _protos;
}

+ (void)protosInit:(NSDictionary *)protos {
  [_privateEncoder setProtos:protos];
}

+ (NSDictionary *)protos {
  return [_privateEncoder protos];
}

#pragma mark - encode
+ (NSMutableData *)encodeMsgWithRoute:(NSString *)route andMsg:(NSDictionary *)msg {

  NSMutableData *dest = [NSMutableData data];

  // Get protos from protos map use the route as key
  NSDictionary *protos = [[PBEncoder protos] objectForKey:route];

  //Check msg
  if ([PBEncoder checkMsg:msg withProtos:protos]) {
    //Set the length of the buffer 2 times bigger to prevent overflow
    NSUInteger length = JSON_stringify(msg).length;

    //Init buffer and offset
    NSMutableData *buffer = [NSMutableData dataWithLength:length];
    NSUInteger offset = 0;

    if (protos != nil) {
      offset = [PBEncoder encodeMsg:msg fromOffset:offset withProtos:protos toBuffer:buffer];
      if (offset > 0) {
        // OK
        [dest setData:[buffer subdataWithRange:NSMakeRange(0, offset)]];
      }
    }
  }

  return dest;
}


@end

#pragma mark - private methods
@implementation PBEncoder (
private)

+ (BOOL)checkMsg:(NSDictionary *)msg withProtos:(NSDictionary *)protos {
  if (protos == nil) {
    return NO;
  }

  for (id protosName in protos) {
    NSDictionary *proto = [protos objectForKey:protosName];
    NSDictionary *privateProtosMsg = [protos objectForKey:@"__messages"];

    NSString *protoOpt = [proto objectForKey:@"option"];
    NSString *protoTypeStr = [proto objectForKey:@"type"];

    id msgName = [msg objectForKey:@"name"];

    if ([protoOpt isEqualToString:@"required"]) {
      if (nil == msgName) {
        return NO;
      }
    }

    if ([protoOpt isEqualToString:@"optional"]) {
      if (nil != msgName) {
        if ([privateProtosMsg objectForKey:protoTypeStr] != nil) {
          return [PBEncoder checkMsg:msgName
                          withProtos:[privateProtosMsg objectForKey:protoTypeStr]];
        }
      }
    } else if ([protoOpt isEqualToString:@"repeated"]) {
      //Check nest message in repeated elements
      if (msgName != nil && [privateProtosMsg objectForKey:protoTypeStr] != nil) {
        for (id i in msgName) {
          if (NO == [PBEncoder checkMsg:[msgName objectForKey:i]
                             withProtos:[privateProtosMsg objectForKey:protoTypeStr]]) {
            return false;
          }
        }
      }
    }
  }
  return YES;
}

+ (NSUInteger)encodeMsg:(NSDictionary *)msg
             fromOffset:(NSUInteger)offset
             withProtos:(NSDictionary *)protos
               toBuffer:(NSMutableData *)dest {
  if (dest == nil) {
    dest = [NSMutableData data];
  }
  for (id name in msg) {
    if (nil != [protos objectForKey:name]) {
      id msgName = [msg objectForKey:name];

      NSDictionary *proto = [protos objectForKey:name];
      NSString *protoOpt = [proto objectForKey:@"option"];
      NSString *protoTypeStr = [proto objectForKey:@"type"];
      if ([protoOpt isEqualToString:@"required"] || [protoOpt isEqualToString:@"optional"]) {
        NSUInteger protoTag = [[proto objectForKey:@"tag"] unsignedIntegerValue];
        NSMutableData *_local_buffer_ = [PBEncoder encodeTag:protoTag withPBTypeStr:protoTypeStr];

        offset = [PBEncoder writeBytes:dest from:offset withData:_local_buffer_];
        offset = [PBEncoder encodeProp:msgName asTypeStr:protoTypeStr andProtos:protos from:offset toBuffer:dest];
      } else if ([protoOpt isEqualToString:@"repeated"]) {
        if ([msgName isKindOfClass:[NSArray class]] && [msgName count] > 0) {
          offset = [PBEncoder encodeArray:msgName
                                withProto:proto
                                andProtos:protos
                                     from:offset
                                 toBuffer:dest];
        }
      }
    }
  }

  return offset;
}

+ (NSUInteger)encodeProp:(id)value
               asTypeStr:(NSString *)typeStr
               andProtos:(NSDictionary *)protos
                    from:(NSUInteger)offset
                toBuffer:(NSMutableData *)dest {
  if (dest == nil) {
    dest = [NSMutableData data];
  }

  if ([typeStr isEqualToString:@"uInt32"]) {
    offset = [PBEncoder writeBytes:dest from:offset withData:[PBCodec encodeUInt32:(uint32_t) [value unsignedIntegerValue]]];
  } else if ([typeStr isEqualToString:@"int32"] || [typeStr isEqualToString:@"sInt32"]) {
    offset = [PBEncoder writeBytes:dest from:offset withData:[PBCodec encodeSInt32:(int32_t) [value integerValue]]];
  } else if ([typeStr isEqualToString:@"float"]) {
    offset = [PBEncoder writeBytes:dest from:offset withData:[PBCodec encodeFloat:[value floatValue]]];
  } else if ([typeStr isEqualToString:@"double"]) {
    offset = [PBEncoder writeBytes:dest from:offset withData:[PBCodec encodeDouble:[value doubleValue]]];
  } else if ([typeStr isEqualToString:@"string"]) {
    // value is NSString
    NSUInteger length = [PBCodec byteLength:value];

    offset = [PBEncoder writeBytes:dest from:offset withData:[PBCodec encodeUInt32:(uint32_t) length]];

    [PBCodec encodeStr:value dst:dest from:offset];

    offset += length;
  } else if (protos != nil) {
    NSDictionary *privateProtosMsg = [protos objectForKey:@"__messages"];
    if ([privateProtosMsg objectForKey:typeStr] != nil) {
      //Use a tmp buffer to build an internal msg
      NSMutableData *_tmp_buffer_ = [NSMutableData dataWithLength:[PBCodec byteLength:JSON_stringify(value)]];
      NSUInteger length = 0;

      length = [PBEncoder encodeMsg:value
                         fromOffset:length
                         withProtos:[privateProtosMsg objectForKey:typeStr]
                           toBuffer:_tmp_buffer_];

      //Encode length
      offset = [PBEncoder writeBytes:dest from:offset withData:[PBCodec encodeUInt32:(uint32_t) length]];
      //contact the object
      [dest replaceBytesInRange:NSMakeRange(offset, length) withBytes:_tmp_buffer_.bytes length:length];

      offset += length;
    }
  }

  return offset;
}

+ (NSUInteger)encodeArray:(NSArray *)array
                withProto:(NSDictionary *)proto
                andProtos:(NSDictionary *)protos
                     from:(NSUInteger)offset
                 toBuffer:(NSMutableData *)dest {
  if (dest == nil) {
    dest = [NSMutableData data];
  }
  int i = 0;
  NSString *protoTypeStr = [[proto objectForKey:@"type"] stringValue];
  NSUInteger protoTag = [[proto objectForKey:@"tag"] unsignedIntegerValue];

  if ([PBHelper isSimpleType:[PBHelper translatePBTypeFromStr:protoTypeStr]]) {
    offset = [PBEncoder writeBytes:dest from:offset withData:[PBEncoder encodeTag:protoTag withPBTypeStr:protoTypeStr]];

    offset = [PBEncoder writeBytes:dest from:offset withData:[PBCodec encodeUInt32:(uint32_t) [array count]]];
    for (i = 0; i < [array count]; i++) {
      offset = [PBEncoder encodeProp:[array objectAtIndex:i]
                           asTypeStr:protoTypeStr
                           andProtos:nil from:offset
                            toBuffer:dest];
    }
  } else {
    for (i = 0; i < [array count]; i++) {
      offset = [PBEncoder writeBytes:dest from:offset withData:[PBEncoder encodeTag:protoTag withPBTypeStr:protoTypeStr]];
      offset = [PBEncoder encodeProp:[array objectAtIndex:i] asTypeStr:protoTypeStr andProtos:protos from:offset toBuffer:dest];
    }
  }
  return offset;
}

+ (NSUInteger)writeBytes:(NSMutableData *)source from:(NSUInteger)offset withData:(NSData *)data {
  [source replaceBytesInRange:NSMakeRange(offset, data.length) withBytes:data.bytes length:data.length];
  return (offset + data.length);
}

+ (NSMutableData *)encodeTag:(NSUInteger)tag withPBTypeStr:(NSString *)typeStr {

  ProtoBufType type = [PBHelper translatePBTypeFromStr:typeStr];
  int value = (type == 0) ? 2 : type;

  return [PBCodec encodeUInt32:(uint32_t) ((tag << 3) | value)];
}

@end
