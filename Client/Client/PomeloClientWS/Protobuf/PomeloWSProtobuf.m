//
//  PomeloWSProtobuf.m
//  pomeloClient
//
//  Created by ETiV on 13-4-10.
//
//

#import "PomeloWSProtobuf.h"
#import "PBEncoder.h"
#import "PBDecoder.h"

@implementation PomeloWSProtobuf

+ (void)protosInit:(NSDictionary *)protos {

  [PBEncoder protosInit:[protos objectForKey:@"encoderProtos"]];
  [PBDecoder protosInit:[protos objectForKey:@"decoderProtos"]];
}

+ (NSData *)encodeWithRoute:(NSString *)route andMsg:(NSDictionary *)msg {
  return [PBEncoder encodeMsgWithRoute:route andMsg:msg];
}

+ (NSDictionary *)decodeWithRoute:(NSString *)route andData:(NSData *)data {
  return [PBDecoder decodeMsgWithRoute:route andData:data];
}

@end

