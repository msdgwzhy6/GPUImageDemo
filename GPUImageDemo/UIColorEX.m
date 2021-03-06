//
//  UIColorEX.m
//  TmallClient-iOS-Common
//
//  Created by zhouyi.hyh@taobao.com on 12-7-9.
//  Copyright (c) 2012年 Tmall.com. All rights reserved.
//

#import "UIColorEX.h"

@interface UIAMonochromeColorComponents : UIAColorComponents {
    CGFloat _components[2];
}

@end


@implementation UIAMonochromeColorComponents

- (id)initWithCGColor:(CGColorRef)color {
    self = [super init];
    if (self != nil) {
        const CGFloat *components = CGColorGetComponents(color);
        self->_components[0] = components[0];
        self->_components[1] = components[1];
    }
    return self;
}


- (CGFloat)red {
    return self->_components[0];
}

- (CGFloat)green {
    return self->_components[0];
}

- (CGFloat)blue {
    return self->_components[0];
}

- (CGFloat)alpha {
    return self->_components[1];
}

@end


@interface UIARGBColorComponents : UIAColorComponents {
    CGFloat _components[4];
}

@end


@implementation UIARGBColorComponents

- (id)initWithCGColor:(CGColorRef)color {
    self = [super init];
    if (self != nil) {
        const CGFloat *components = CGColorGetComponents(color);
        self->_components[0] = components[0];
        self->_components[1] = components[1];
        self->_components[2] = components[2];
        self->_components[3] = components[3];
    }
    return self;
}


- (CGFloat)red {
    return self->_components[0];
}

- (CGFloat)green {
    return self->_components[1];
}

- (CGFloat)blue {
    return self->_components[2];
}

- (CGFloat)alpha {
    return self->_components[3];
}

@end


@implementation UIAColorComponents

@dynamic red, green, blue, alpha;

- (id)initWithColor:(UIColor *)color {
    return [self initWithCGColor:color.CGColor];
}

+ (id)componentsWithColor:(UIColor *)color {
    return [self componentsWithCGColor:color.CGColor];
}

- (id)initWithCGColor:(CGColorRef)color {
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(color);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
    switch (colorSpaceModel) {
        case kCGColorSpaceModelMonochrome: {
            self = [[UIAMonochromeColorComponents alloc] initWithCGColor:color];
        }   break;
        case kCGColorSpaceModelRGB: {
            self = [[UIARGBColorComponents alloc] initWithCGColor:color];
        }   break;
        default:
            self = nil;
            break;
    }
    return self;
}

+ (id)componentsWithCGColor:(CGColorRef)color {
    return [(UIAColorComponents *)[self alloc] initWithCGColor:color];
}

@end

@implementation UIColor (EX)

+ (NSUInteger)hexValueOfString:(NSString *)string
{
    NSUInteger result = 0;
    NSString *newString = string;
    if([newString hasPrefix:@"#"])
    {
        newString = [string substringFromIndex:1];
    }
    else if([newString hasPrefix:@"0x"])
    {
        newString = [string substringFromIndex:2];
    }
    if(newString.length == 3)
    {
        unichar str[6] = {0};
        for(int i = 0; i < 3; i++)
        {
            unichar ch = [newString characterAtIndex:i];
            str[i*2] = ch;
            str[i*2+1] = ch;
        }
        newString = [NSString stringWithCharacters:str length:6];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:newString];
    [scanner scanHexInt:&result];
    return result;
}

+ (UIColor *)colorWithHexValue:(NSUInteger)hexValue alpha:(NSUInteger)alpha
{
    CGFloat r = ((hexValue & 0x00FF0000) >> 16) / 255.0;
    CGFloat g = ((hexValue & 0x0000FF00) >> 8) / 255.0;
    CGFloat b = (hexValue & 0x000000FF) / 255.0;
    CGFloat a = alpha / 255.0;
    
    return [self colorWithRed:r green:g blue:b alpha:a];
}

+ (UIColor *)colorWithHexValue:(NSUInteger)hexValue
{
    return [self colorWithHexValue:hexValue alpha:255];
}

+ (UIColor *)colorWithString:(NSString *)string
{
    int len = [string length];
    NSUInteger hexValue = 0;
    NSUInteger alpha = 1.f;
    if (len == 8 || (len == 9 && [string characterAtIndex:0] == (unichar)'#')) {
        hexValue = [UIColor hexValueOfString:[string lowercaseString]];
        alpha = (hexValue & 0xFF000000) >> 24;
        hexValue = hexValue & 0x00FFFFFF;
    }
    else if (len == 6 || (len == 7 && [string characterAtIndex:0] == (unichar)'#')) {
        hexValue = [UIColor hexValueOfString:[string lowercaseString]];
        alpha = 255.f;
    }
    return [UIColor colorWithHexValue:hexValue alpha:alpha];
}

#pragma mark - UIAColorComponents

- (UIAColorComponents *)components
{
    return [UIAColorComponents componentsWithColor:self];
}

- (UIColor *)colorWithAlpha:(CGFloat)alpha
{
    UIAColorComponents *components = self.components;
    return [UIColor colorWithRed:components.red green:components.green blue:components.blue alpha:alpha];
}

- (UIColor *)mixedColorWithColor:(UIColor *)color ratio:(CGFloat)ratio
{
    UIAColorComponents *c1 = self.components;
    UIAColorComponents *c2 = color.components;
    
    CGFloat ratio2 = 1.0f - ratio;
    CGFloat aratio1 = ratio * c1.alpha;
    CGFloat aratio2 = ratio2 * c2.alpha;
    CGFloat aratios = aratio1 + aratio2;
    CGFloat cratio1 = aratio1 / aratios;
    CGFloat cratio2 = aratio2 / aratios;
    
    return [UIColor colorWithRed:c1.red * cratio1 + c2.red * cratio2
                           green:c1.green * cratio1 + c2.green * cratio2
                            blue:c1.blue * cratio1 + c2.blue * cratio2
                           alpha:c1.alpha * ratio + c2.alpha * ratio2];
}

#pragma mark - IOS7Patch

- (UIColor *)highligtedColorForBackgroundColor:(UIColor *)backgroundColor
{
    return [[self mixedColorWithColor:backgroundColor ratio:0.25] colorWithAlpha:self.components.alpha];
}

- (UIColor *)highligtedColor
{
    return [self highligtedColorForBackgroundColor:[UIColor whiteColor]];
}

@end
