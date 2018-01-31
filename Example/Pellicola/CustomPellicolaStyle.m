//
//  CustomPellicolaStyle.m
//  Pellicola_Example
//
//  Created by Andrea Antonioni on 31/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Pellicola-Swift.h"
#import "CustomPellicolaStyle.h"

@implementation CustomPellicolaStyle

- (UIImage *)checkmarkImage {
    return [UIImage imageNamed:@"checkmark_icon"];
}

- (UIColor *)toolbarBackgroundColor {
    return [UIColor colorWithRed:247.0f/255.0f
                           green:245.0f/255.0f
                            blue:241.0f/255.0f
                           alpha:1];
}

- (UIColor *)blackColor {
    return [UIColor colorWithRed:90.0f/255.0f
                           green:90.0f/255.0f
                            blue:90.0f/255.0f
                           alpha:1];
}

- (UIColor *)grayColor {
    return [UIColor colorWithRed:150.0f/255.0f
                           green:150.0f/255.0f
                            blue:150.0f/255.0f
                           alpha:1];
}

- (NSString *)fontNameNormal {
    return @"LFTEtica-Book";
}

- (NSString *)fontNameBold {
    return @"LFTEtica-Semibold";
}

- (NSString *)cancelString {
    return @"Cancel";
}

- (NSString *)doneString {
    return @"Add";
}

@end
