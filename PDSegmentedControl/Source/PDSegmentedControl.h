//
//  PDSegmentedControl.h
//  PDSegmentedControl
//
//  Created by liang on 2018/3/27.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDSegmentedControl;
@class PDSegmentedControlSegment;

NS_ASSUME_NONNULL_BEGIN

@protocol PDSegmentedControlDataSource <NSObject>

- (NSInteger)numberOfItemsInSegmentedControl:(PDSegmentedControl *)segmentedControl;
- (__kindof PDSegmentedControlSegment *)segmentedControl:(PDSegmentedControl *)segmentedControl segmentForItemAtIndex:(NSInteger)index;

@optional
- (__kindof PDSegmentedControlSegment *)segmentedControl:(PDSegmentedControl *)segmentedControl segmentForSelectedItemAtIndex:(NSInteger)index;

@end

@protocol PDSegmentedControlDelegate <NSObject>

- (CGFloat)segmentedControl:(PDSegmentedControl *)segmentedControl widthForItemAtIndex:(NSInteger)index;

@optional
- (void)segmentedControl:(PDSegmentedControl *)segmentedControl didSelectItemAtIndex:(NSInteger)index;
// For indicator.
- (nullable UIView *)indicatorForSegmentedControl:(PDSegmentedControl *)segmentedControl;
- (CGSize)segmentedControl:(PDSegmentedControl *)segmentedControl indicatorSizeAtIndex:(NSInteger)index;

@end

@interface PDSegmentedControl : UIView

@property (nonatomic, weak) id<PDSegmentedControlDataSource> dataSource;
@property (nonatomic, weak) id<PDSegmentedControlDelegate> delegate;

@property (nonatomic, assign, readonly) NSUInteger selectedIndex;
@property (nonatomic, assign) BOOL alwaysBounceHorizontal; // Default is NO.
@property (nonatomic, assign) BOOL bounces; // Default is YES.

- (void)reloadData;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

- (nullable PDSegmentedControlSegment *)segmentForItemAtIndex:(NSInteger)index;

- (void)registerClass:(nullable Class)segmentClass forSegmentWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(nullable UINib *)nib forSegmentWithReuseIdentifier:(NSString *)identifier;

- (__kindof PDSegmentedControlSegment *)dequeueReusableSegmentWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

@end

@interface PDSegmentedControlSegment : UICollectionViewCell

@property (nonatomic, strong) UILabel *textLabel;

@end

NS_ASSUME_NONNULL_END
