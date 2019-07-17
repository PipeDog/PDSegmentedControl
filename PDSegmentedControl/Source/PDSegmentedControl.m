//
//  PDSegmentedControl.m
//  PDSegmentedControl
//
//  Created by liang on 2018/3/27.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDSegmentedControl.h"

@interface PDSegmentedControlSegment ()

@property (nonatomic, assign) NSInteger index;

@end

@interface PDSegmentedControl () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    struct {
        unsigned numberOfItemsInSegmentedControl : 1;
        unsigned segmentForItemAtIndex : 1;
        unsigned selectedSegmentForItemAtIndex : 1;
    } _dataSourceHas;
    
    struct {
        unsigned widthForItemAtIndex : 1;
        unsigned didSelectItemAtIndex : 1;
        unsigned flagForSegmentedControl : 1;
        unsigned sizeForFlagAtIndex : 1;
        unsigned offsetForFlagAtIndex : 1;
        unsigned minimumLineSpacingForSegmentedControl : 1;
        
        // UIScrollViewDelegate.
        unsigned scrollViewDidScroll : 1;
        unsigned scrollViewWillBeginDragging : 1;
        unsigned scrollViewWillEndDragging : 1;
        unsigned scrollViewDidEndDragging : 1;
        unsigned scrollViewWillBeginDecelerating : 1;
        unsigned scrollViewDidEndDecelerating : 1;
        unsigned scrollViewDidEndScrollingAnimation : 1;
    } _delegateHas;
}

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong, nullable) UIView *flag;
@property (nonatomic, strong) NSMutableSet<Class> *registeredSegmentClasses;

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

- (void)reloadFlag {
    if (self.flag) {
        [self.flag removeFromSuperview];
        self.flag = nil;
    }
    if (_delegateHas.flagForSegmentedControl) {
        if (![self.dataSource numberOfItemsInSegmentedControl:self]) {
            return;
        }
        self.flag = [self.delegate flagForSegmentedControl:self];
        if (self.flag) {
            [self.collectionView addSubview:self.flag];
            [self flagScrollToIndex:self.selectedIndex animated:NO];
        }
    }
}

- (void)flagScrollToIndex:(NSInteger)index animated:(BOOL)animated {
    NSAssert(_delegateHas.widthForItemAtIndex, @"Protocol method segmentedControl:widthForItemAtIndex: must be implemented");
    
    if (!self.flag) return;
    if (!_delegateHas.sizeForFlagAtIndex) {
        [self.flag removeFromSuperview];
        self.flag = nil;
        return;
    }
    
    CGFloat segmentWidth = [self.delegate segmentedControl:self widthForItemAtIndex:index];
    CGSize flagSize = [self.delegate segmentedControl:self sizeForFlagAtIndex:index];
    
    CGFloat top = 0.f;
    CGFloat left = 0.f;
    
    for (NSInteger i = 0; i < index; i ++) {
        CGFloat width = [self.delegate segmentedControl:self widthForItemAtIndex:index];
        left += width;
    }
    left = left + (segmentWidth - flagSize.width) / 2.f;
    
    if (_delegateHas.offsetForFlagAtIndex) {
        CGPoint offset = [self.delegate segmentedControl:self offsetForFlagAtIndex:index];
        left += offset.x;
        top += offset.y;
    }

    CGRect rect = CGRectMake(left, top, flagSize.width, flagSize.height);

    void (^perform)(void) = ^{
        self.flag.frame = rect;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2f animations:perform];
    } else {
        perform();
    }
}

#pragma mark - Public Methods
- (void)reloadData {
    [self reloadFlag];
    [self.collectionView reloadData];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    _selectedIndex = selectedIndex;
    [self.collectionView reloadData];
    [self scrollToItemAtIndex:selectedIndex animated:animated];
}

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    [self flagScrollToIndex:index animated:animated];
}

- (PDSegmentedControlSegment *)dequeueReusableSegmentOfClass:(Class)aClass forIndex:(NSInteger)index {
    if (!aClass || index < 0) {
        NSAssert(NO, @"Invalid parameter");
        return nil;
    }
    
    NSString *segmentId = NSStringFromClass(aClass);
    
    if (![self.registeredSegmentClasses containsObject:aClass]) {
        [self.registeredSegmentClasses addObject:aClass];
        [self.collectionView registerClass:aClass forCellWithReuseIdentifier:segmentId];
    }
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:segmentId forIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
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
        PDSegmentedControlSegment *segment = [self.dataSource segmentedControl:self segmentForSelectedItemAtIndex:indexPath.row];
        segment.index = indexPath.row;
        return segment;
    } else {
        NSAssert(_dataSourceHas.segmentForItemAtIndex, @"Protocol method segmentedControl:segmentForItemAtIndex: must be implemented");
        
        PDSegmentedControlSegment *segment = [self.dataSource segmentedControl:self segmentForItemAtIndex:indexPath.row];
        segment.index = indexPath.row;
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

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (_delegateHas.minimumLineSpacingForSegmentedControl) {
        return [self.delegate minimumLineSpacingForSegmentedControl:self];
    }
    return 0.f;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_delegateHas.scrollViewDidScroll) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_delegateHas.scrollViewWillBeginDragging) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (_delegateHas.scrollViewWillEndDragging) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_delegateHas.scrollViewDidEndDragging) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (_delegateHas.scrollViewWillBeginDecelerating) {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_delegateHas.scrollViewDidEndDecelerating) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_delegateHas.scrollViewDidEndScrollingAnimation) {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

#pragma mark - Override Methods
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self reloadData];
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
    _dataSourceHas.selectedSegmentForItemAtIndex = [_dataSource respondsToSelector:@selector(segmentedControl:segmentForSelectedItemAtIndex:)];
}

- (void)setDelegate:(id<PDSegmentedControlDelegate>)delegate {
    _delegate = delegate;
    
    _delegateHas.widthForItemAtIndex = [_delegate respondsToSelector:@selector(segmentedControl:widthForItemAtIndex:)];
    _delegateHas.didSelectItemAtIndex = [_delegate respondsToSelector:@selector(segmentedControl:didSelectItemAtIndex:)];
    _delegateHas.flagForSegmentedControl = [_delegate respondsToSelector:@selector(flagForSegmentedControl:)];
    _delegateHas.sizeForFlagAtIndex = [_delegate respondsToSelector:@selector(segmentedControl:sizeForFlagAtIndex:)];
    _delegateHas.offsetForFlagAtIndex = [_delegate respondsToSelector:@selector(segmentedControl:offsetForFlagAtIndex:)];
    _delegateHas.minimumLineSpacingForSegmentedControl = [_delegate respondsToSelector:@selector(minimumLineSpacingForSegmentedControl:)];

    // UIScrollViewDelegate.
    _delegateHas.scrollViewDidScroll = [_delegate respondsToSelector:@selector(scrollViewDidScroll:)];
    _delegateHas.scrollViewWillBeginDragging = [_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)];
    _delegateHas.scrollViewWillEndDragging = [_delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)];
    _delegateHas.scrollViewDidEndDragging = [_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)];
    _delegateHas.scrollViewWillBeginDecelerating = [_delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)];
    _delegateHas.scrollViewDidEndDecelerating = [_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)];
    _delegateHas.scrollViewDidEndScrollingAnimation = [_delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)];

    [self reloadFlag];
}

- (UIScrollView *)scrollView {
    return self.collectionView;
}

- (void)setAlwaysBounceHorizontal:(BOOL)alwaysBounceHorizontal {
    _alwaysBounceHorizontal = alwaysBounceHorizontal;
    self.collectionView.alwaysBounceHorizontal = alwaysBounceHorizontal;
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    self.collectionView.bounces = _bounces;
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

- (NSMutableSet<Class> *)registeredSegmentClasses {
    if (!_registeredSegmentClasses) {
        _registeredSegmentClasses = [NSMutableSet set];
    }
    return _registeredSegmentClasses;
}

@end

@implementation PDSegmentedControlSegment

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.frame = self.bounds;
        _textLabel.numberOfLines = 1;
        _textLabel.font = [UIFont systemFontOfSize:12.f];
        _textLabel.textColor = [UIColor darkTextColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_textLabel];
    }
    return _textLabel;
}

@end
