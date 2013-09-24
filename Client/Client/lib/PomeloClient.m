//
//  PomeloClient.m
//  Client
//
//  Created by xiaochuan on 13-9-23.
//  Copyright (c) 2013年 xiaochuan. All rights reserved.
//

#import "PomeloClient.h"

@implementation PomeloClient
#pragma mark - JSON helper
+ (id)decodeJSON:(NSData *)data error:(NSError **)error {
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:0
                                             error:error];
}

+ (NSString *)encodeJSON:(id)object error:(NSError **)error {
    NSData *data = [NSJSONSerialization dataWithJSONObject:object
                                                   options:0
                                                     error:error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end
