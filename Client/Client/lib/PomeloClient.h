//
//  PomeloClient.h
//  Client
//
//  Created by xiaochuan on 13-9-23.
//  Copyright (c) 2013年 xiaochuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
@interface PomeloClient : NSObject<SRWebSocketDelegate>{
    SRWebSocket *_webSocket;
}
@property (nonatomic,assign) id delegate;

/**
 *  初始化方法
 *
 *  @param delegate 代理
 *
 *  @return PomeloClient
 */
- (id)initWithDelegate:(id)delegate;


@end
