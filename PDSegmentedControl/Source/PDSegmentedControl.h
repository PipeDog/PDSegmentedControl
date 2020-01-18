//
//  PDSegmentedControl.h
//  PDSegmentedControl
//
//  Created by liang on 2018/3/27.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PDSegmentedControl;

@protocol PDSegmentedControlDataSource, PDSegmentedControlDelegate;

typedef UICollectionViewCell PDSegmentedControlCell;

@interface PDSegmentedControl : UIView

@property (nonatomic, weak) id<PDSegmentedControlDataSource> dataSource;
@property (nonatomic, weak) id<PDSegmentedControlDelegate> delegate;

@property (nonatomic, assign, readonly) NSUInteger selectedIndex;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL alwaysBounceHorizontal; // Default is NO.
@property (nonatomic, assign) BOOL bounces; // Default is YES.

- (void)reloadData;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

- (__kindof PDSegmentedControlCell *)dequeueReusableCellOfClass:(Class)aClass forIndex:(NSInteger)index;

@end

@protocol PDSegmentedControlDataSource <NSObject>

- (NSInteger)numberOfItemsInSegmentedControl:(PDSegmentedControl *)segmentedControl;
- (__kindof PDSegmentedControlCell *)segmentedControl:(PDSegmentedControl *)segmentedControl cellForItemAtIndex:(NSInteger)index;

@optional
- (__kindof PDSegmentedControlCell *)segmentedControl:(PDSegmentedControl *)segmentedControl cellForSelectedItemAtIndex:(NSInteger)index;

@end

@protocol PDSegmentedControlDelegate <UIScrollViewDelegate>

- (CGFloat)segmentedControl:(PDSegmentedControl *)segmentedControl widthForItemAtIndex:(NSInteger)index;

@optional
- (CGFloat)segmentedControl:(PDSegmentedControl *)segmentedControl widthForSelectedItemAtIndex:(NSInteger)index;
- (void)segmentedControl:(PDSegmentedControl *)segmentedControl didSelectItemAtIndex:(NSInteger)index;

- (nullable UIView *)flagForSegmentedControl:(PDSegmentedControl *)segmentedControl;
- (CGSize)segmentedControl:(PDSegmentedControl *)segmentedControl sizeForFlagAtIndex:(NSInteger)index;
- (CGPoint)segmentedControl:(PDSegmentedControl *)segmentedControl offsetForFlagAtIndex:(NSInteger)index;
- (CGFloat)minimumInteritemSpacingForSegmentedControl:(PDSegmentedControl *)segmentedControl;

@end

NS_ASSUME_NONNULL_END
