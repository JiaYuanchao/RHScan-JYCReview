//
//  ViewController.m
//  RHScan
//
//  Created by river on 2018/2/1.
//  Copyright © 2018年 richinfo. All rights reserved.
//

#import "ViewController.h"
#import "RHScanViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goScan:(id)sender {
    
    RHScanViewController *vc = [RHScanViewController new];
    vc.isOpenInterestRect = YES;
    vc.isVideoZoom = YES;
    [self.navigationController pushViewController:vc animated:YES];
}




@end
