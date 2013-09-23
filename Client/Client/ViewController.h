//
//  ViewController.h
//  Client
//
//  Created by xiaochuan on 13-9-23.
//  Copyright (c) 2013年 xiaochuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"
@interface ViewController : UIViewController<SRWebSocketDelegate>{
    SRWebSocket *_webSocket;
}

@end
