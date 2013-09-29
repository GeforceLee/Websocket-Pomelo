//
//  Codec.m
//  protobuf.codec
//
//  Created by ETiV on 13-4-15.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import "PBCodec.h"

@implementation PBCodec

/**
 * codec UInt64
 */
+ (NSMutableData *)encodeUInt32:(uint64_t)n {
	unsigned char result[10] = {0}, count = 0;
	
	do {
		result[count++] = (unsigned char) ((n & 0x7F) | 0x80);
		n >>= 7;
	} while (n != 0);
	result[count - 1] &= 0x7F;
	return [NSMutableData dataWithBytes:result length:count];
	
	//log("encodeUInt64: 0x%@", dst);
	
	/***
	 * the original javascript impl
	 */
	//  do{
	//    uint tmp = n % 128;
	//    uint64_t next = floor(n / 128);
	//
	//    if(next != 0){
	//      tmp = tmp + 128;
	//    }
	//    result[count++] = tmp;
	//    n = next;
	//  }while(n != 0);
	//
	//  return [NSMutableData dataWithBytes:result length:count];
	/***
	 * end original js impl
	 */
}

+ (uint64_t)decodeUInt32:(NSData *)data {
	uint64_t x = 0; //, n = 0;
	unsigned char *ptr = (unsigned char *) data.bytes;
	uint64_t i = 0;
	
	/***
	 * the original javascript impl
	 */
	for (; i < data.length; i++) {
		unsigned int m = ptr[i];
		// n |= ((m & 0x7F) << (i == 0? 1 : (i * 7)));
		x += ((m & 0x7F) * pow(2, i*7) );
		if (m < 128) {
			return x;
		}
	}
	/***
	 * end original js impl
	 */
	
	/**
	 * our impl
	 */
	//  for (; i < data.length; i++) {
	//    n += ((ptr[i] * (int)pow((double)2, (double)(i*7))));
	//    if (ptr[i] < 128) {
	//      return n;
	//    }
	//  }
	/**
	 * end our impl
	 */
	
	//log("decodeUInt64: %u", n);
	return x;
}

/**
 * codec Int64
 */
+ (NSMutableData *)encodeSInt32:(int64_t)n {
	n = n < 0 ? ((llabs(n) * 2) - 1) : n * 2;
	return [PBCodec encodeUInt32:n];
	//log("encodeSInt64: %@", dst);
}

+ (int64_t)decodeSInt32:(NSData *)data {
	// even number means source number is >= 0
	// odd number means source number is < 0
	uint64_t n = [PBCodec decodeUInt32:data];
	bool isOddNumber = (bool) (n & 0x1);
	n >>= 1;
	//log("decodeSInt64: %d", ( (isOddNumber) ? (-1 * (n + 1)) : (n) ));
	return ((isOddNumber) ? (-1 * (n + 1)) : (n));
}

/**
 * codec Float
 */
+ (NSMutableData *)encodeFloat:(float)n {
	union u {
		float f;
		int32_t i;
	};
	union u tmp;
	tmp.f = n;
	return [NSMutableData dataWithBytes:&(tmp.i) length:sizeof(float)];
	//log("encodeFloat: %@", dst);
}

+ (float)decodeFloat:(NSData *)data from:(NSUInteger)offset {
	if (data == nil || data.length < (offset + sizeof(float))) {
		return 0.0;
	}
	
	union u {
		float f;
		int32_t i;
	};
	union u tmp;
	tmp.i = *(int32_t *) &(data.bytes[offset]);
	//log("decodeFloat: %f", tmp.f);
	return tmp.f;
}

/**
 * codec double
 */
+ (NSMutableData *)encodeDouble:(double)n {
	union u {
		double d;
		int64_t i;
	};
	union u tmp;
	tmp.d = n;
	return [NSMutableData dataWithBytes:&(tmp.i) length:sizeof(double)];
	//log("encodeDouble: %@", dst);
}

+ (double)decodeDouble:(NSData *)data from:(NSUInteger)offset {
	if (data == nil || data.length < (offset + sizeof(double))) {
		return 0.0;
	}
	union u {
		double d;
		long i;
	};
	union u tmp;
	tmp.i = *(long *) &(data.bytes[offset]);
	//log("decodeDouble: %lf", tmp.d);
	return tmp.d;
}

/**
 * codec String
 */
+ (NSUInteger)encodeStr:(NSString *)str dst:(NSMutableData *)dst from:(NSUInteger)offset {
	NSData *strAsData = [str dataUsingEncoding:NSUTF8StringEncoding];
	[dst replaceBytesInRange:NSMakeRange(offset, [str length])
				   withBytes:strAsData.bytes
					  length:[str length]];
	return (offset + [strAsData length]);
	//  [dst setData:[str dataUsingEncoding:NSUTF8StringEncoding]];
	//log("encodeStr: %@", dst);
}

+ (NSMutableString *)decodeStr:(NSData *)data from:(NSUInteger)offset withLength:(NSUInteger)length {
	return [[NSMutableString alloc] initWithData:[data subdataWithRange:NSMakeRange(offset, length)] encoding:NSUTF8StringEncoding];
	//log("decodeStr: %@", dst);
}

+ (unsigned long)byteLength:(NSString *)str {
	return [[str dataUsingEncoding:NSUTF8StringEncoding] length];
}

@end
