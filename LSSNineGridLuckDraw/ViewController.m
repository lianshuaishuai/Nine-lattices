//
//  ViewController.m
//  LSSNineGridLuckDraw
//
//  Created by 连帅帅 on 2018/9/26.
//  Copyright © 2018年 连帅帅. All rights reserved.
//

#import "ViewController.h"
#import "LSSLuckDraw.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"加载");
    NSMutableArray  * arr =[NSMutableArray array];
    for (int i =0; i<9; i++) {
        [arr addObject:[NSString stringWithFormat:@"%d",i+1]];
    }
    LSSLuckDraw *  luckV = [[LSSLuckDraw alloc] initWithFrame:CGRectMake((self.view.frame.size.width-350)/2.0,(self.view.frame.size.height-350)/2.0, 350, 350) imagesArray:[arr copy]];
    luckV.cycleCount =4;
    luckV.endCount = 6;
    [self.view addSubview:luckV];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
