//
//  UIAlertController+AlertExtend.m
//  IdentityCodeDemo
//
//  Created by 西太科技 on 2017/4/6.
//  Copyright © 2017年 lei wenhao. All rights reserved.
//

#import "UIAlertController+AlertExtend.h"

@implementation UIAlertController (AlertExtend)

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle okAction:(UIAlertAction *)okAction cancelAction:(UIAlertAction *)cancelAction {
    
    UIAlertController * alertVC = [self alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    
    if (cancelAction) {
        [alertVC addAction:cancelAction];
    }
    
    if (okAction) {
        [alertVC addAction:okAction];
    }
    
    return alertVC;
}


/** AlertController */
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message okAction:(UIAlertAction *)okAction cancelAction:(UIAlertAction *)cancelAction {
    
    return [self alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert okAction:okAction cancelAction:cancelAction];
}

/** ActionSheetController */
+ (instancetype)alertSheetControllerWithTitle:(NSString *)title message:(NSString *)message okAction:(UIAlertAction *)okAction cancelAction:(UIAlertAction *)cancelAction {
    
    return [self alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet okAction:okAction cancelAction:cancelAction];
}



@end
