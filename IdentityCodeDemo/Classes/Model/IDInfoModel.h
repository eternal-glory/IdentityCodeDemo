//
//  IDInfoModel.h
//  IdentityCodeDemo
//
//  Created by 西太科技 on 2017/4/7.
//  Copyright © 2017年 lei wenhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDInfoModel : NSObject

@property (nonatomic,assign) int type; ///<1:正面  2:反面;
@property (nonatomic,copy) NSString *num; ///<身份证号;
@property (nonatomic,copy) NSString *name; ///<姓名;
@property (nonatomic,copy) NSString *gender; ///<性别;
@property (nonatomic,copy) NSString *nation; ///<民族;
@property (nonatomic,copy) NSString *address; ///<地址;
@property (nonatomic,copy) NSString *issue; ///<签发机关;
@property (nonatomic,copy) NSString *valid; ///<有效期;


@end
