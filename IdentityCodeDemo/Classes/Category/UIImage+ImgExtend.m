//
//  UIImage+ImgExtend.m
//  IdentityCodeDemo
//
//  Created by 西太科技 on 2017/4/7.
//  Copyright © 2017年 lei wenhao. All rights reserved.
//

#import "UIImage+ImgExtend.h"

@implementation UIImage (ImgExtend)

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    // 得到一个CMSampleBuffer的核心视频图像缓冲区的媒体数据
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁的基地址像素缓冲区
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 让每一行的像素缓冲区的字节数
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // 像素缓冲区宽度和高度
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个设备相关的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 创建一个位图图形上下文与样品缓冲数据
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 创建一个Quartz图像像素数据的位图图形上下文
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁像素缓冲区
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    // 释放 上下文 和 颜色 的空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 从Quartz对象中创建一个image对象
    UIImage * image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
    // 释放Quartz
    CGImageRelease(quartzImage);
    
    return (image);
}

+ (UIImage *)getImageStream:(CVImageBufferRef)imageBuffer {
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
    
    UIImage *image = [[UIImage alloc] initWithCGImage:videoImage];
    
    CGImageRelease(videoImage);
    
    return image;
}

+ (UIImage *)getSubImage:(CGRect)rect inImage:(UIImage *)image {
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, smallBounds, subImageRef);
    
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CFRelease(subImageRef);
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}

@end
