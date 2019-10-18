//
//  PhotoStartStyle.m
//  Pellicola_Example
//
//  Created by Andrea Antonioni on 01/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pellicola-Swift.h"
#import "PhotoStarStyle.h"

@implementation PhotoStarStyle

- (UIImage *)checkmarkImage {
    return [UIImage imageNamed:@"star"];
}

- (UIColor *)toolbarBackgroundColor {
    return [UIColor colorWithRed:0.9529411793
                           green:0.6862745285
                            blue:0.1333333403
                           alpha:1];
}

- (NSString *)fontNameBold {
    return @"ShonenPunk!CustomBold-Bold";
}

- (NSString *)fontNameNormal {
    return @"shonenpunk!custom";
}

- (NSString *)doneString {
    return @"Save";
}

- (NSString *)cancelString {
    return @"Cancel";
}

- (UIColor *)blackColor {
    return [UIColor blackColor];
}

- (UIColor *)grayColor {
    return [UIColor lightGrayColor];
}

- (NSString *)alertAccessDeniedTitle {
    return @"Allow access";
}

- (NSString *)alertAccessDeniedMessage {
    return @"We have not the authorization to access your Photo Library";
}

- (UIStatusBarStyle)statusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIColor *)backgroundColor {
    return [UIColor whiteColor];
}

@end
