//
//  PDSegmentedControl.m
//  PDSegmentedControl
//
//  Created by liang on 2018/3/27.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDSegmentedControl.h"

@interface PDSegmentedControl () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    struct {
        unsigned numberOfItemsInSegmentedControl : 1;
        unsigned segmentForItemAtIndex : 1;
        unsigned selectedSegmentForItemAtIndex : 1;
    } _dataSourceHas;
    
    struct {
        unsigned widthForItemAtIndex : 1;
        unsigned didSelectItemAtIndex : 1;
    } _delegateHas;
}

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation PDSegmentedControl

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    _selectedIndex = selectedIndex;
    [self.collectionView reloadData];
    [self scrollToItemAtIndex:selectedIndex animated:animated];
}

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}

- (void)registerClass:(Class)segmentClass forSegmentWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:segmentClass forCellWithReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forSegmentWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (UICollectionViewCell *)dequeueReusableSegmentWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (PDSegmentedControlSegment *)segmentForItemAtIndex:(NSInteger)index {
    return (PDSegmentedControlSegment *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

#pragma mark - UICollectionView Delegate && DataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSAssert(_dataSourceHas.numberOfItemsInSegmentedControl, @"Protocol method numberOfItemsInSegmentedControl: must be implemented");
    
    return [self.dataSource numberOfItemsInSegmentedControl:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL currentIndexIsSelected = (indexPath.row == self.selectedIndex);
    BOOL hasSelectedSegment = _dataSourceHas.selectedSegmentForItemAtIndex;

    if (currentIndexIsSelected && hasSelectedSegment) {
        PDSegmentedControlSegment *segment = [self.dataSource segmentedControl:self selectedSegmentForItemAtIndex:indexPath.row];
        return segment;
    } else {
        NSAssert(_dataSourceHas.segmentForItemAtIndex, @"Protocol method segmentedControl:segmentForItemAtIndex: must be implemented");
        
        PDSegmentedControlSegment *segment = [self.dataSource segmentedControl:self segmentForItemAtIndex:indexPath.row];
        return segment;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    [collectionView reloadData];
    [self scrollToItemAtIndex:indexPath.row animated:YES];
    
    if (_delegateHas.didSelectItemAtIndex) {
        [self.delegate segmentedControl:self didSelectItemAtIndex:indexPath.row];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(_delegateHas.widthForItemAtIndex, @"Protocol method segmentedControl:widthForItemAtIndex: must be implemented");
    
    CGFloat height = CGRectGetHeight(collectionView.frame);
    CGFloat width = [self.delegate segmentedControl:self widthForItemAtIndex:indexPath.row];
    return CGSizeMake(width, height);
}

#pragma mark - Setter Methods
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.collectionView.frame = self.bounds;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.collectionView.frame = self.bounds;
}

- (void)setDataSource:(id<PDSegmentedControlDataSource>)dataSource {
    _dataSource = dataSource;

    _dataSourceHas.numberOfItemsInSegmentedControl = [_dataSource respondsToSelector:@selector(numberOfItemsInSegmentedControl:)];
    _dataSourceHas.segmentForItemAtIndex = [_dataSource respondsToSelector:@selector(segmentedControl:segmentForItemAtIndex:)];
    _dataSourceHas.selectedSegmentForItemAtIndex = [_dataSource respondsToSelector:@selector(segmentedControl:selectedSegmentForItemAtIndex:)];
}

- (void)setDelegate:(id<PDSegmentedControlDelegate>)delegate {
    _delegate = delegate;
    
    _delegateHas.widthForItemAtIndex = [_delegate respondsToSelector:@selector(segmentedControl:widthForItemAtIndex:)];
    _delegateHas.didSelectItemAtIndex = [_delegate respondsToSelector:@selector(segmentedControl:didSelectItemAtIndex:)];
}

- (void)setAlwaysBounceHorizontal:(BOOL)alwaysBounceHorizontal {
    _alwaysBounceHorizontal = alwaysBounceHorizontal;
    self.collectionView.alwaysBounceHorizontal = alwaysBounceHorizontal;
}

#pragma mark - Getter Methods
- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
    }
    return _layout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = NO;
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

@end

@implementation PDSegmentedControlSegment

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.numberOfLines = 1;
        _textLabel.font = [UIFont systemFontOfSize:12.f];
        _textLabel.textColor = [UIColor darkTextColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_textLabel];
    }
    return _textLabel;
}

@end
