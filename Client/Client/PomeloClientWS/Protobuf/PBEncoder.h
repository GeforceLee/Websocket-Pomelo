//
//  PBEncoder.h
//  protobuf.codec
//
//  Created by ETiV on 13-4-15.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBEncoder : NSObject

+ (void)protosInit:(NSDictionary *)protos;
+ (NSMutableData *)encodeMsgWithRoute:(NSString *)route andMsg:(NSDictionary *)msg;

@end
