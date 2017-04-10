//
//  ViewController.m
//  IdentityCodeDemo
//
//  Created by 西太科技 on 2017/4/6.
//  Copyright © 2017年 lei wenhao. All rights reserved.
//

#import "ViewController.h"

#import "AVCaptureViewController.h"


#define k_ScreenWidth [UIScreen mainScreen].bounds.size.width
#define k_ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *cardFrondImg;
@property (weak, nonatomic) IBOutlet UIImageView *cardBackImg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];



}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
        self.navigationController.navigationBar.translucent = NO;//（0，64）
}

- (IBAction)cardFrondAction:(id)sender {
    
    AVCaptureViewController * captureVC = [[AVCaptureViewController alloc] init];
    
    captureVC.identify = @"Frond";
    
    captureVC.block = ^(UIImage * image) {
        
        self.cardFrondImg.image = image;
        
    };
    
    [self.navigationController pushViewController:captureVC animated:YES];
    
    
}


- (IBAction)cardBackAction:(id)sender {
    
    
    AVCaptureViewController * captureVC = [[AVCaptureViewController alloc] init];
    
    captureVC.identify = @"Back";
    
    captureVC.block = ^(UIImage * image) {
        
        self.cardBackImg.image = image;
        
    };
    
    [self.navigationController pushViewController:captureVC animated:YES];
    
    
}


@end
