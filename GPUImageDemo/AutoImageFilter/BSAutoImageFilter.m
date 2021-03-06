//
//  BSAutoImageFilter.m
//  GPUImageDemo
//
//  Created by casa on 4/21/15.
//  Copyright (c) 2015 alibaba. All rights reserved.
//

#import "BSAutoImageFilter.h"
#import "ImageAnalyzer.h"
#import <GPUImage/GPUImage.h>

@interface BSAutoImageFilter ()

@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, strong) ImageAnalyzer *imageAnalyzer;

@property (nonatomic, strong) GPUImagePicture *originPicture;
@property (nonatomic, strong) GPUImageBrightnessFilter *brightnessFilter;
@property (nonatomic, strong) GPUImageSaturationFilter *saturationFilter;
@property (nonatomic, strong) GPUImageWhiteBalanceFilter *whiteBalanceFilter;
@property (nonatomic, strong) GPUImageSharpenFilter *sharpenFilter;

@end

@implementation BSAutoImageFilter

- (void)autoFiltWithImage:(UIImage *)image
{
    self.originImage = image;
    self.originPicture = [[GPUImagePicture alloc] initWithImage:image];
    
    NSDictionary *imageInfo = [self.imageAnalyzer analyzeImage:image];
    
    CGFloat brightness = [imageInfo[IABrightness] floatValue];
    CGFloat saturation = [imageInfo[IASaturation] floatValue];
    CGFloat temperature = [imageInfo[IASaturation] floatValue];
    
    if (brightness >= 100 && brightness <= 179 && saturation >= 0 && saturation <= 29) {
        self.brightnessFilter.brightness = 0.09678525;
        self.saturationFilter.saturation = 1.30892633333333;
    }
    
    if (brightness >= 40 && brightness < 100 && saturation >= 0 && saturation <= 29) {
        self.brightnessFilter.brightness = 0.0841906315789474;
        self.saturationFilter.saturation = 1.28635494736842;
    }
    
    if (brightness >= 100 && brightness <= 179 && saturation > 29 && saturation <= 69) {
        self.brightnessFilter.brightness = 0.012097;
        self.saturationFilter.saturation = 1.25332047368421;
    }
    
    if (brightness > 179 && brightness <= 240 && saturation >= 0 && saturation <= 29) {
        self.brightnessFilter.brightness = -0.0274915;
        self.saturationFilter.saturation = 1.34100875;
    }
    
    if (brightness > 179 && brightness <= 240 && saturation > 70 && saturation <= 100 ) {
        self.brightnessFilter.brightness = -0.24214625;
        self.saturationFilter.saturation = 1.28037075;
    }
    
    if (temperature > 8167 && temperature <= 9713) {
        self.whiteBalanceFilter.temperature = 6394.95285377778;
    }
    
    if (temperature > 9713 && temperature <= 19706) {
        self.whiteBalanceFilter.temperature = 5952.19968580435;
    }
    
    if (temperature > 19706) {
        self.whiteBalanceFilter.temperature = 6951.805664;
    }
    
    self.sharpenFilter.sharpness = 0.793325327586207;
    [self processImage];
}

#pragma mark - private methods
- (void)processImage
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.originPicture removeAllTargets];
        
        [strongSelf.originPicture addTarget:strongSelf.brightnessFilter];
        [strongSelf.brightnessFilter addTarget:strongSelf.saturationFilter];
        [strongSelf.saturationFilter addTarget:strongSelf.whiteBalanceFilter];
        [strongSelf.whiteBalanceFilter addTarget:strongSelf.sharpenFilter];
        
        [strongSelf.sharpenFilter useNextFrameForImageCapture];
        [strongSelf.originPicture processImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([strongSelf.delegate respondsToSelector:@selector(autoImageFilter:didFinishedWithOriginImage:processedImage:)]) {
                [strongSelf.delegate autoImageFilter:strongSelf didFinishedWithOriginImage:strongSelf.originImage processedImage:[strongSelf.sharpenFilter imageFromCurrentFramebufferWithOrientation:strongSelf.originImage.imageOrientation]];
            }
            strongSelf.originImage = nil;
            strongSelf.originPicture = nil;
        });
    });
}

#pragma mark - getters and setters
- (ImageAnalyzer *)imageAnalyzer
{
    if (_imageAnalyzer == nil) {
        _imageAnalyzer = [[ImageAnalyzer alloc] init];
    }
    return _imageAnalyzer;
}

- (GPUImageBrightnessFilter *)brightnessFilter
{
    if (_brightnessFilter == nil) {
        _brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    }
    return _brightnessFilter;
}

- (GPUImageSaturationFilter *)saturationFilter
{
    if (_saturationFilter == nil) {
        _saturationFilter = [[GPUImageSaturationFilter alloc] init];
    }
    return _saturationFilter;
}

- (GPUImageWhiteBalanceFilter *)whiteBalanceFilter
{
    if (_whiteBalanceFilter == nil) {
        _whiteBalanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
    }
    return _whiteBalanceFilter;
}

- (GPUImageSharpenFilter *)sharpenFilter
{
    if (_sharpenFilter == nil) {
        _sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    }
    return _sharpenFilter;
}

@end
