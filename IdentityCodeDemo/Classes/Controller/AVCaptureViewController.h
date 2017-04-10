//
//  AVCaptureController.h
//  IdentityCodeDemo
//
//  Created by 西太科技 on 2017/4/6.
//  Copyright © 2017年 lei wenhao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AVCaptureBlock)(UIImage * image);


@interface AVCaptureViewController : UIViewController

@property (copy, nonatomic) AVCaptureBlock block;

@property (strong, nonatomic) NSString * identify;

@end
