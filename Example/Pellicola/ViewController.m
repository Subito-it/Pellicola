//
//  ViewController.m
//  Pellicola_Example
//
//  Created by francesco bigagnoli on 13/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

#import "ViewController.h"

#import "Pellicola-Swift.h"

@interface ViewController ()

@property (nonatomic, strong, nullable) PellicolaPresenter *pellicolaPresenter;

@end

@implementation ViewController

- (IBAction)presentPellicola:(id)sender {
    self.pellicolaPresenter = [[PellicolaPresenter alloc] initWithMaxNumberOfSelections:3];
    [self.pellicolaPresenter presentOn: self];
}

@end
