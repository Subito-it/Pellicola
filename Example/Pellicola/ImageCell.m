//
//  ImageCell.m
//  Pellicola_Example
//
//  Created by Andrea Antonioni on 25/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

#import "ImageCell.h"

@implementation ImageCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageURL = nil;
    self.imageView.image = nil;
}

@end
