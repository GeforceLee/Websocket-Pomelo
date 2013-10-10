//
//  PomeloWSProtobuf.h
//  pomeloClient
//
//  Created by ETiV on 13-4-10.
//
//

#import <Foundation/Foundation.h>

#import "PomeloWSProtobuf.h"

@interface PomeloWSProtobuf : NSObject

+ (void)protosInit:(NSDictionary *)protos;

+ (NSData *)encodeWithRoute:(NSString *)route andMsg:(NSDictionary *)msg;

+ (NSDictionary *)decodeWithRoute:(NSString *)route andData:(NSData *)data;

@end
