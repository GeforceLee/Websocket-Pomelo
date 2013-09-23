//
//  PomeloProtocol.m
//  Client
//
//  Created by xiaochuan on 13-9-23.
//  Copyright (c) 2013年 xiaochuan. All rights reserved.
//

#import "PomeloProtocol.h"
@interface PomeloProtocol(PrivateMethod)
+ (void)copyData:(NSMutableData *)dest
       dstOffset:(NSUInteger)dest_offset
             src:(NSData *)source
       srcOffset:(NSUInteger)source_offset
             len:(NSUInteger)length;
@end
@implementation PomeloProtocol


+ (NSData *)strEncode:(NSString *)str{
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)strDecode:(NSData *)data{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSData *)packageEncodeWithType:(PackageType)type andBody:(NSData *)body{
    NSUInteger length = body == nil ? 0 : body.length;
    NSMutableData *buffer = [[NSMutableData alloc] initWithCapacity:(PKG_HEAD_BYTES + length)];
    
    unsigned char iTmp = 0;
    
    iTmp = type & 0xff;
    [buffer replaceBytesInRange:NSMakeRange(0, 1) withBytes:&iTmp length:1];
    
    iTmp = (unsigned char)(length >> 16) & 0xff;
    [buffer replaceBytesInRange:NSMakeRange(1, 1) withBytes:&iTmp length:1];
    
    iTmp = (unsigned char)(length >> 8) & 0xff;
    [buffer replaceBytesInRange:NSMakeRange(2, 1) withBytes:&iTmp length:1];
    
    iTmp = (unsigned char)length & 0xff;
    [buffer replaceBytesInRange:NSMakeRange(3, 1) withBytes:&iTmp length:1];
    //上面似乎可以优化成 直接 length & 0xffffff
    
    if (body) {
        [[self class] copyData:buffer dstOffset:4 src:body srcOffset:0 len:length];
    }
    return buffer;
}
   
+ (PomeloPackage *)packageDecode:(NSData *)buffer{
    unsigned char * bytes  = (unsigned char *)[buffer bytes];
    PackageType type = (PackageType) bytes[0];
    unsigned int length = ((bytes[1]) << 16 | (bytes[2]) << 8 | bytes[3]) >> 0;
    NSData *body= [NSData dataWithBytes:&(bytes[4]) length:length];
    
    return MakePomeloPackage(type, body);
}


#pragma mark -
#pragma mark PrivateMethod
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
   
@end
