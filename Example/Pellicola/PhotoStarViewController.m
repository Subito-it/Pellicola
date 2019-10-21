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
#import <SVProgressHUD.h>

@interface PhotoStarViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong, nullable) PellicolaPresenter *pellicolaPresenter;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic, strong) NSMutableArray<NSURL *> *urls;
@property (nonatomic) int maxNumberOfPhotos;

@end

@implementation PhotoStarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _urls = [[NSMutableArray alloc] init];
    _maxNumberOfPhotos = 30;
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
    _pellicolaPresenter.imageSize = CGSizeMake(1600, 1600);
    
    _pellicolaPresenter.didStartProcessingImages = ^{
        [SVProgressHUD show];
    };
    
    __weak typeof(self) weakSelf = self;
    _pellicolaPresenter.didFinishProcessingImages = ^(NSArray <NSURL *>*urls) {
        weakSelf.maxNumberOfPhotos -= (int) [urls count];
        [weakSelf.urls addObjectsFromArray:urls];
        [weakSelf.collectionView reloadData];
        [weakSelf updateMessage];
        [SVProgressHUD dismiss];
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
    return [_urls count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ImageCell *cell = (ImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell"
                                                                             forIndexPath:indexPath];
    CGSize size = cell.imageView.bounds.size;
    NSURL *imageURL = _urls[indexPath.item];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        UIImage *resizedImage = [weakSelf imageWithImage:image scaledToFillSize:size];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            cell.imageView.image = resizedImage;
        });
    });
    
    return cell;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);

    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



@end

