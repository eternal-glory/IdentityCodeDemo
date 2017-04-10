//
//  UIImage+ImgExtend.h
//  IdentityCodeDemo
//
//  Created by 西太科技 on 2017/4/7.
//  Copyright © 2017年 lei wenhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface UIImage (ImgExtend)

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

+ (UIImage *)getImageStream:(CVImageBufferRef)imageBuffer;

+ (UIImage *)getSubImage:(CGRect)rect inImage:(UIImage *)imaeg;


@end
