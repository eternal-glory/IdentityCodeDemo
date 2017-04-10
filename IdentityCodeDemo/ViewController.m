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

    self.title = @"身份证识别Demo";

    UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearance];
    // 将文字减小并设其颜色为透明以隐藏
    [barButtonItemAppearance setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:0.1], NSForegroundColorAttributeName: [UIColor clearColor]} forState:UIControlStateNormal];
    
    // 设置图片
    // 获取全局的navigationBar外观
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    // 获取原图
    UIImage *image = [[UIImage imageNamed:@"nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 修改navigationBar上的返回按钮的图片，注意：这两个属性要同时设置
    navigationBarAppearance.backIndicatorImage = image;
    navigationBarAppearance.backIndicatorTransitionMaskImage = image;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    
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
