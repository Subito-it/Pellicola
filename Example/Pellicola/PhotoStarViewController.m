//
//  ViewController.m
//  Pellicola_Example
//
//  Created by francesco bigagnoli on 13/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

#import "PhotoStarViewController.h"
#import "ImageCell.h"
#import "Pellicola-Swift.h"
#import "PhotoStarStyle.h"

@interface PhotoStarViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong, nullable) PellicolaPresenter *pellicolaPresenter;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic, strong) NSMutableArray<UIImage *> *images;
@property (nonatomic) int maxNumberOfPhotos;

@end

@implementation PhotoStarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _images = [[NSMutableArray alloc] init];
    _maxNumberOfPhotos = 10;
    [self setupCollectionView];
    [self setupPellicola];
    [self updateMessage];
}

- (void)setupCollectionView {
    _collectionView.allowsSelection = NO;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
}

- (void)setupPellicola {
    PhotoStarStyle* customStyle = [[PhotoStarStyle alloc] init];
    _pellicolaPresenter = [[PellicolaPresenter alloc] initWithStyle:customStyle];
    
    __weak typeof(self) weakSelf = self;
    _pellicolaPresenter.didSelectImages = ^(NSArray *array) {
        weakSelf.maxNumberOfPhotos -= (int) [array count];
        [weakSelf.images addObjectsFromArray:array];
        [weakSelf.collectionView reloadData];
        [weakSelf updateMessage];
    };
    
    _pellicolaPresenter.userDidCancel = ^{
        NSLog(@"User did cancel the flow.");
    };
}

- (IBAction)presentPellicola:(id)sender {
    if (_maxNumberOfPhotos > 0) {
        [self.pellicolaPresenter presentOn: self maxNumberOfSelections:_maxNumberOfPhotos];
    }
}

- (void)updateMessage {
    _messageLabel.text = [[NSString alloc] initWithFormat:@"You can still select %d photos", _maxNumberOfPhotos ];
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

