//
//  ViewController.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "ViewController.h"
#import "BrowserViewModel.h"
#import "BrowserVC.h"


@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)jumpToBrowser:(id)sender
{
    BrowserViewModel * viewModel = [[BrowserViewModel alloc] initWithParams:nil];
    viewModel.requestURL = @"https://www.baidu.com";
    
    BrowserVC * vc = [[BrowserVC alloc] initWithViewModel:viewModel];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
