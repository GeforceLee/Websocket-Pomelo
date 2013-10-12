//
//  ViewController.m
//  Client
//
//  Created by xiaochuan on 13-9-23.
//  Copyright (c) 2013年 xiaochuan. All rights reserved.
//

#import "ViewController.h"

#import "PBCodec.h"
#import "ProtobufCodec.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
//    NSDictionary *d1 = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"1", nil];
//    NSDictionary *d2 = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"2", nil];
    

//    return;
	// Do any additional setup after loading the view, typically from a nib.
   
    client = [[PomeloClient alloc] initWithDelegate:self];
    [client connectToHost:@"10.0.1.8" onPort:@"3010" params:@{@"11111": @"22222"} withCallback:^(id arg) {
        NSLog(@"adfasdfasdf:%@",arg);
    }];
    
//    client1 = [[PomeloWS alloc] initWithDelegate:self];
//    [client1 connectToHost:@"10.0.1.8" onPort:3010];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 40, 100, 100)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(diss) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];

    [client onRoute:@"onRoomStand" withCallback:^(id arg) {
        NSLog(@"%@",arg);
    }];
//    [client1 onRoute:@"onRoomStand" withCallback:^(id arg) {
//        NSLog(@"%@" ,arg);
//    }];
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(60, 140, 100, 100)];
    btn1.backgroundColor = [UIColor redColor];
    [btn1 addTarget:self action:@selector(pysh) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn1];

}

- (void)diss{
//    [client disconnectWithCallback:^(id arg) {
//        NSLog(@"%@",arg);
//    }];
    
    [client requestWithRoute:@"connector.entryHandler.entry" andParams:@{@"a": @"adfasdfasf",
                                                                         @"b":@"abbbbb",
                                                                         @"c":@-1,
                                                                         @"d":@2,
                                                                         @"f":@1.2,
                                                                         @"e":@2.333333,
                                                                         @"g":@{@"a": @"adf",@"b":@12313},
                                                                         @"h":@[@{@"a": @"addddf",@"b":@1212313},@{@"a": @"asdfadf",@"b":@12313}]} andCallback:^(id arg) {
        NSLog(@"%@",arg);
    }];
}


- (void)pysh{
//    [client requestWithRoute:@"connector.entryHandler.push" andParams:@{@"adfasdf": @"adfasdfasf"} andCallback:^(id arg) {
//        NSLog(@"%@",arg);
//    }];
    
    [client notifyWithRoute:@"connector.entryHandler.push" andParams:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
