//
//  ViewController.h
//  Client
//
//  Created by xiaochuan on 13-9-23.
//  Copyright (c) 2013年 xiaochuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PomeloClient.h"
#import "PomeloWS.h"
@interface ViewController : UIViewController{
    PomeloClient *client;
    
    PomeloWS *client1;
}

@end
