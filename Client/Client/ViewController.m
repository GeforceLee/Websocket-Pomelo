//
//  ViewController.m
//  Client
//
//  Created by xiaochuan on 13-9-23.
//  Copyright (c) 2013年 xiaochuan. All rights reserved.
//

#import "ViewController.h"

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
    
    

    
    UIButton *btn0 = [[UIButton alloc] initWithFrame:CGRectMake(500, 440, 100, 100)];
    btn0.backgroundColor = [UIColor redColor];
    [btn0 setTitle:@"connect" forState:UIControlStateNormal];
    [btn0 addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn0];
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 40, 100, 100)];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"entry" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];

    [client onRoute:@"onRoomStand" withCallback:^(id arg) {
        
        NSLog(@"%@",arg);
        
    }];

    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(60, 140, 100, 100)];
    btn1.backgroundColor = [UIColor redColor];
    [btn1 addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setTitle:@"push" forState:UIControlStateNormal];
    [self.view addSubview:btn1];
    
    
    
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(160, 240, 100, 100)];
    btn2.backgroundColor = [UIColor redColor];
    [btn2 addTarget:self action:@selector(sendProto) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setTitle:@"sendProto" forState:UIControlStateNormal];
    [self.view addSubview:btn2];

    
    
    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(260, 340, 100, 100)];
    btn3.backgroundColor = [UIColor redColor];
    [btn3 addTarget:self action:@selector(dissconnect) forControlEvents:UIControlEventTouchUpInside];
    [btn3 setTitle:@"dissconnect" forState:UIControlStateNormal];
    [self.view addSubview:btn3];

}

- (void)connect{
    [client connectToHost:@"10.0.1.8" onPort:@"3010" params:@{@"11111": @"22222"} withCallback:^(id arg) {
        NSLog(@"adfasdfasdf:%@",arg);
    }];
}

- (void)enter{

    
    [client requestWithRoute:@"connector.entryHandler.entry" andParams:@{@"a": @"adfasdfasf",
                                                                         @"b":@"abbbbb",
                                                                         @"c":@-1,
                                                                         @"d":@2,
                                                                         @"f":@1.2,
                                                                         @"e":@2.333333,
                                                                         @"g":@{@"a": @"adf",@"b":@12313},
                                                                         @"h":@[@{@"a": @"addddf",@"b":@1212313},@{@"a": @"asdfadf",@"b":@12313}],
                                                                         @"i":@[@-1,@22,@1],
                                                                         @"j":@[@1.1,@-1.2]} andCallback:^(id arg) {
        NSLog(@"%@",arg);
    }];
}


- (void)push{

    
    [client notifyWithRoute:@"connector.entryHandler.push" andParams:nil];
}


- (void)sendProto{
    [client requestWithRoute:@"connector.entryHandler.proto" andParams:@{@"a": @"adfasdfasf",
                                                                         @"b":@"abbbbb",
                                                                         @"c":@-1,
                                                                         @"d":@2,
                                                                         @"f":@1.2,
                                                                         @"e":@2.333333,
                                                                         @"g":@{@"a": @"adf",@"b":@12313},
                                                                         @"h":@[@{@"a": @"addddf",@"b":@1212313},@{@"a": @"asdfadf",@"b":@12313}],
                                                                         @"i":@[@-1,@22,@1],
                                                                         @"j":@[@1.1,@-1.2]} andCallback:^(id arg) {
                                                                             NSLog(@"%@",arg);
                                                                         }];

}



- (void)dissconnect{
    [client disconnectWithCallback:^(id arg) {
        NSLog(@"断线了");
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
