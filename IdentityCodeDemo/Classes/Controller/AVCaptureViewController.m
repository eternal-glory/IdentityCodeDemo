//
//  AVCaptureController.m
//  IdentityCodeDemo
//
//  Created by 西太科技 on 2017/4/6.
//  Copyright © 2017年 lei wenhao. All rights reserved.
//

#import "AVCaptureViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "excards.h"
#import "UIAlertController+AlertExtend.h"
#import "UIImage+ImgExtend.h"
#import "WHIdentityCardScaningView.h"
#import "IDInfoModel.h"
#import "RectManager.h"

@interface AVCaptureViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

/** 摄像头 */
@property (strong, nonatomic) AVCaptureDevice * device;

/** AVCaptureSession对象来执行输入设备和输出设备之间的数据传递 */
@property (strong, nonatomic) AVCaptureSession * session;

/** 输出格式 */
@property (strong, nonatomic) NSNumber * outPutSetting;

/** 出流对象 */
@property (strong, nonatomic) AVCaptureVideoDataOutput * videoDataOutput;

/** 预览图层 */
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * previewLayer;

/** 人脸检测框区域 */
@property (assign, nonatomic) CGRect faceDetectionFrame;

/** 队列 */
@property (strong, nonatomic) dispatch_queue_t queue;

/** 是否打开手电筒 */
@property (assign, nonatomic, getter = isTorchOn) BOOL torchOn;

@end

@implementation AVCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    self.navigationController.navigationBar.translucent = YES;
    
    self.navigationItem.title = @"扫描身份证";

    const char * thePath = [[[NSBundle mainBundle] resourcePath] UTF8String];
    
    int ret = EXCARDS_Init(thePath);
    
    if (ret != 0) {
        NSLog(@"初始化失败 : ret = %d",ret);
    }
    
    [self.view.layer addSublayer:self.previewLayer];
    
    WHIdentityCardScaningView * IDCardScaningView = [[WHIdentityCardScaningView alloc] initWithFrame:self.view.frame];
    
    self.faceDetectionFrame = IDCardScaningView.facePathRect;
    
    if ([self.identify isEqualToString:@"Back"]) {
        IDCardScaningView.titleStr = @"反";
    }
    
    
    [self.view addSubview:IDCardScaningView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(turnOnOrOffTorch)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
    
    self.navigationItem.rightBarButtonItem.image = [[UIImage imageNamed:@"nav_torch_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.torchOn = NO;
    [self checkAuthorizationStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
    
    [self stopSession];
}

- (void)turnOnOrOffTorch {
    
    self.torchOn = !self.isTorchOn;
    
    if ([self.device hasTorch]) { // 判断是否有闪光灯
        [self.device lockForConfiguration:nil];
        
        if (self.isTorchOn) {
            
            self.navigationItem.rightBarButtonItem.image = [[UIImage imageNamed:@"nav_torch_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self.device setTorchMode:AVCaptureTorchModeOn];
            
        } else {
            
            self.navigationItem.rightBarButtonItem.image = [[UIImage imageNamed:@"nav_torch_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self.device setTorchMode:AVCaptureTorchModeOff];
        }
        [self.device unlockForConfiguration]; // 请求解除独占访问硬件设备
    } else {
        
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        
        [self alertControllerWithTitle:@"提示" message:@"您的设备没有闪光设备，不能提供手电筒功能，请检查" okAction:okAction cancelAction:nil];
    }
}


#pragma mark - - -  getter 方法 - - - 
- (AVCaptureDevice *)device {
    
    if (!_device) {
        
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError * error = nil;
        
        if ([_device lockForConfiguration:&error]) {
            
            if ([_device isSmoothAutoFocusSupported]) {// 平滑对焦
                _device.smoothAutoFocusEnabled = YES;
            }
            
            if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {// 自动持续对焦
                _device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            }
            
            if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure ]) {// 自动持续曝光
                _device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            }
            
            if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {// 自动持续白平衡
                _device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
            }
            
            [_device unlockForConfiguration];
        }
        
    }
    
    return _device;
}

- (NSNumber *)outPutSetting {
    
    if (!_outPutSetting) {
        _outPutSetting = @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange);
    }
    
    return _outPutSetting;
}

- (AVCaptureVideoDataOutput *)videoDataOutput {
    
    if (!_videoDataOutput) {
        
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        
        _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:self.outPutSetting};
        
        [_videoDataOutput setSampleBufferDelegate:self queue:self.queue];
        
    }
    
    return _videoDataOutput;
}

- (AVCaptureSession *)session {
    
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
        
        if (error) {
            UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        
            [self alertControllerWithTitle:@"没有摄像设备" message:error.localizedDescription okAction:okAction cancelAction:nil];
            
        } else {
         
            if ([_session canAddInput:input]) {
                [_session addInput:input];
            }
            
            if ([_session canAddOutput:self.videoDataOutput]) {
                [_session addOutput:self.videoDataOutput];
            }
        }
    }
    
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    
    if (!_previewLayer) {
        
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.frame = self.view.frame;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    return _previewLayer;
}

- (dispatch_queue_t)queue {
    
    if (!_queue) {
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    
    return _queue;
}

#pragma mark - - 运行session
- (void)runSession {
    
    if (![self.session isRunning]) {
        
        dispatch_async(self.queue, ^{
            [self.session startRunning];
        });
    }
}
#pragma mark - - 停止session
- (void)stopSession {
    
    if ([self.session isRunning]) {
     
        dispatch_async(self.queue, ^{
            [self.session stopRunning];
        });
    }
}

#pragma mark - - - 展示UIAlertController
- (void)alertControllerWithTitle:(NSString *)title message:(NSString *)message okAction:(UIAlertAction *)okAction cancelAction:(UIAlertAction *)cancelAction {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message okAction:okAction cancelAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - -  检测摄像头权限
-(void)checkAuthorizationStatus {
    
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined:[self showAuthorizationNotDetermined]; break;// 用户尚未决定授权与否，那就请求授权
        case AVAuthorizationStatusAuthorized:[self showAuthorizationAuthorized]; break;// 用户已授权，那就立即使用
        case AVAuthorizationStatusDenied:[self showAuthorizationDenied]; break;// 用户明确地拒绝授权，那就展示提示
        case AVAuthorizationStatusRestricted:[self showAuthorizationRestricted]; break;// 无法访问相机设备，那就展示提示
    }
}

#pragma mark - 相机使用权限处理
#pragma mark 用户还未决定是否授权使用相机
- (void)showAuthorizationNotDetermined {
    __weak __typeof__(self) weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        granted? [weakSelf runSession]: [weakSelf showAuthorizationDenied];
    }];
}

#pragma mark 被授权使用相机
- (void)showAuthorizationAuthorized {
    [self runSession];
}

#pragma mark 未被授权使用相机
- (void)showAuthorizationDenied {
    
    NSString *title = @"相机未授权";
    NSString *message = @"请到系统的“设置-隐私-相机”中授权此应用使用您的相机";
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 跳转到该应用的隐私设授权置界面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    [self alertControllerWithTitle:title message:message okAction:okAction cancelAction:cancelAction];
}

#pragma mark 使用相机设备受限
- (void)showAuthorizationRestricted {
    
    NSString *title = @"相机设备受限";
    NSString *message = @"请检查您的手机硬件或设置";
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [self alertControllerWithTitle:title message:message okAction:okAction cancelAction:nil];
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
#pragma mark 从输出的数据流捕捉单一的图像帧
// AVCaptureVideoDataOutput获取实时图像，这个代理方法的回调频率很快，几乎与手机屏幕的刷新频率一样快
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if ([self.outPutSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]] || [self.outPutSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]]) {
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        if ([captureOutput isEqual:self.videoDataOutput]) {
            // 身份证信息识别
            [self IDCardRecognit:imageBuffer];
        }
    } else {
        NSLog(@"输出格式不支持");
    }
}

#pragma mark - - - 身份证信息识别
- (void)IDCardRecognit:(CVImageBufferRef)imageBuffer {
    
    CVBufferRetain(imageBuffer);
    
    if (CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
        
        size_t width= CVPixelBufferGetWidth(imageBuffer);// 1920
        size_t height = CVPixelBufferGetHeight(imageBuffer);// 1080
        
        CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
        size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);
        size_t rowBytes = NSSwapBigIntToHost(planar->componentInfoY.rowBytes);
        unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
        unsigned char* pixelAddress = baseAddress + offset;
        
        static unsigned char *buffer = NULL;
        if (buffer == NULL) {
            buffer = (unsigned char *)malloc(sizeof(unsigned char) * width * height);
        }
        
        memcpy(buffer, pixelAddress, sizeof(unsigned char) * width * height);
        
        unsigned char pResult[1024];
        int ret = EXCARDS_RecoIDCardData(buffer, (int)width, (int)height, (int)rowBytes, (int)8, (char*)pResult, sizeof(pResult));
        
        if (ret <= 0) {
            NSLog(@"错误 ret = [%d]",ret);
        } else {
            
            NSLog(@"成功 ret = [%d]",ret);
            
            AudioServicesPlaySystemSound(1108);
            
            if ([self.session isRunning]) {
                [self.session stopRunning];
            }
            
            char ctype;
            char content[256];
            int xlen;
            int i = 0;
            
            IDInfoModel * infoModel = [[IDInfoModel alloc] init];
            
            ctype = pResult[i++];
            
            while (i < ret) {
                ctype = pResult[i++];
                
                for (xlen = 0; i < ret; ++i) {
                    if (pResult[i] == ' ') {
                        ++i;
                        break;
                    }
                    content[xlen++] = pResult[i];
                }
                
                content[xlen] = 0;
                
                if (xlen) {
                    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                    
                    if (ctype == 0x21) {
                        infoModel.num = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if (ctype == 0x22) {
                        infoModel.name = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if (ctype == 0x23) {
                        infoModel.gender = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if (ctype == 0x24) {
                        infoModel.nation = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if (ctype == 0x25) {
                        infoModel.address = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if (ctype == 0x26) {
                        infoModel.issue = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if (ctype == 0x27) {
                        infoModel.valid = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    }
                    
                }
            }
            
            if (infoModel) {
                
                NSLog(@"\n正面\n姓名：%@\n性别：%@\n民族：%@\n住址：%@\n公民身份证号码：%@\n\n反面\n签发机关：%@\n有效期限：%@",infoModel.name,infoModel.gender,infoModel.nation,infoModel.address,infoModel.num,infoModel.issue,infoModel.valid);
    
                CGRect effectRect = [RectManager getEffectImageRect:CGSizeMake(width, height)];
                
                CGRect rect = [RectManager getGuideFrame:effectRect];
                
                UIImage *image = [UIImage getImageStream:imageBuffer];
                
                UIImage *subImage = [UIImage getSubImage:rect inImage:image];
                
                if ([self.identify isEqualToString:@"Back"] && infoModel.name == nil) {
                    
                    [self sendImgWith:subImage];
                    
                }
                
                if ([self.identify isEqualToString:@"Frond"] && infoModel.issue == nil) {
                    [self sendImgWith:subImage];
                }
                
            }
        }
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
    CVBufferRelease(imageBuffer);
}


- (void)sendImgWith:(UIImage *)subImage {
    
    if (subImage) {
        if (self.block) {
            
            self.block(subImage);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        }
    }

}

@end
