//
//  PBHelper.m
//  protobuf.codec
//
//  Created by ETiV on 13-4-16.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import "PBHelper.h"

@implementation PBHelper

+ (BOOL) isSimpleType:(ProtoBufType)pbType
{
    return (pbType == PBT_UInt32 ||
            pbType == PBT_SInt32 ||
            pbType == PBT_Int32 ||
            pbType == PBT_Double ||
//            pbType == PBT_String ||
//            pbType == PBT_Message ||
            pbType == PBT_Float
            );
}

+ (ProtoBufType) translatePBTypeFromStr:(NSString *)typeStr
{
    if ([typeStr isEqualToString:@"uInt32"]) {
        return PBT_UInt32;
    }
    if ([typeStr isEqualToString:@"int32"]) {
        return PBT_SInt32;
    }
    if ([typeStr isEqualToString:@"sInt32"]) {
        return PBT_SInt32;
    }
    if ([typeStr isEqualToString:@"float"]) {
        return PBT_Float;
    }
    if ([typeStr isEqualToString:@"double"]) {
        return PBT_Double;
    }
    if ([typeStr isEqualToString:@"string"]) {
        return PBT_String;
    }
    if ([typeStr isEqualToString:@"sInt64"]) {
        return PBT_Int32;
    }
    if ([typeStr isEqualToString:@"uInt64"]) {
        return PBT_Int32;
    }
    return PBT_Unknown;
}

@end
