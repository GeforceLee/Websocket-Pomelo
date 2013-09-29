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
	// Do any additional setup after loading the view, typically from a nib.
   
    client = [[PomeloClient alloc] initWithDelegate:self];
    [client connectToHost:@"10.0.1.8" onPort:@"3010" params:@{@"11111": @"22222"} withCallback:^(id arg) {
        NSLog(@"adfasdfasdf:%@",arg);
    }];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 40, 100, 100)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(diss) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];

}

- (void)diss{
    [client disconnectWithCallback:^(id arg) {
        NSLog(@"%@",arg);
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
