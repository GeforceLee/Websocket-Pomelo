//
//  PBDecoder.h
//  protobuf.codec
//
//  Created by ETiV on 13-4-15.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _PBHead {
  NSUInteger type;
  NSUInteger tag;
} PBHead;

@interface PBDecoder : NSObject

+ (void)protosInit:(NSDictionary *)protos;

+ (NSMutableDictionary *)decodeMsgWithRoute:(NSString *)route andData:(NSData *)data;

@end

