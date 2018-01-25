//
//  ViewController.m
//  Pellicola_Example
//
//  Created by francesco bigagnoli on 13/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

#import "ViewController.h"
#import "ImageCell.h"
#import "Pellicola-Swift.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong, nullable) PellicolaPresenter *pellicolaPresenter;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray<UIImage *> *images;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _images = [[NSMutableArray alloc] init];
    [self setupCollectionView];
}

- (void)setupCollectionView {
    _collectionView.allowsSelection = NO;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
}

- (IBAction)presentPellicola:(id)sender {
    _pellicolaPresenter = [[PellicolaPresenter alloc] initWithMaxNumberOfSelections:5];
    __weak typeof(self) weakSelf = self;
    _pellicolaPresenter.didSelectImages = ^(NSArray *array) {
        [weakSelf.images addObjectsFromArray:array];
        [weakSelf.collectionView reloadData];
    };
    
    _pellicolaPresenter.userDidCancel = ^{
        NSLog(@"User did cancel the flow.");
    };
    
    [self.pellicolaPresenter presentOn: self];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_images count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ImageCell *cell = (ImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell"
                                                                           forIndexPath:indexPath];
    
    cell.imageView.image = _images[indexPath.item];
    
    return cell;
    
}



@end
