//
//  ViewController.m
//  PDSegmentedControl
//
//  Created by liang on 2018/3/27.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "ViewController.h"
#import "PDSegmentedControl.h"

@interface ViewController () <PDSegmentedControlDelegate, PDSegmentedControlDataSource>

@property (nonatomic, strong) PDSegmentedControl *segmentedControl;
@property (nonatomic, copy) NSArray<NSString *> *items;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.segmentedControl];
}

#pragma mark - PDSegmentedControlDataSource Methods
- (NSInteger)numberOfItemsInSegmentedControl:(PDSegmentedControl *)segmentedControl {
    return self.items.count;
}

- (PDSegmentedControlSegment *)segmentedControl:(PDSegmentedControl *)segmentedControl segmentForItemAtIndex:(NSInteger)index {
    PDSegmentedControlSegment *segment = [segmentedControl dequeueReusableSegmentOfClass:[PDSegmentedControlSegment class] forIndex:index];
    segment.textLabel.font = [UIFont boldSystemFontOfSize:14];
    segment.textLabel.textColor = [UIColor darkTextColor];
    segment.textLabel.text = self.items[index];
    return segment;
}

- (PDSegmentedControlSegment *)segmentedControl:(PDSegmentedControl *)segmentedControl segmentForSelectedItemAtIndex:(NSInteger)index {
    PDSegmentedControlSegment *segment = [segmentedControl dequeueReusableSegmentOfClass:[PDSegmentedControlSegment class] forIndex:index];
    segment.textLabel.font = [UIFont boldSystemFontOfSize:20];
    segment.textLabel.textColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
    segment.textLabel.text = self.items[index];
    return segment;
}

#pragma mark - PDSegmentedControlDelegate Methods
- (CGFloat)segmentedControl:(PDSegmentedControl *)segmentedControl widthForItemAtIndex:(NSInteger)index {
    return 100.f;
}

- (void)segmentedControl:(PDSegmentedControl *)segmentedControl didSelectItemAtIndex:(NSInteger)index {
    self.textLabel.text = self.items[index];
}

- (UIView *)flagForSegmentedControl:(PDSegmentedControl *)segmentedControl {
    UIView *flag = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 5.f)];
    flag.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3f];
    flag.layer.cornerRadius = 2.5f;
    flag.layer.maskedCorners = YES;
    return flag;
}

- (CGSize)segmentedControl:(PDSegmentedControl *)segmentedControl flagSizeAtIndex:(NSInteger)index {
    return CGSizeMake(10 * index + 20, 5 + index);
}

#pragma mark - Getter Methods
- (PDSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        CGRect rect = CGRectMake(10,
                                 100,
                                 CGRectGetWidth(self.view.bounds) - 10 * 2,
                                 44);
        _segmentedControl = [[PDSegmentedControl alloc] initWithFrame:rect];
        _segmentedControl.dataSource = self;
        _segmentedControl.delegate = self;
        _segmentedControl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    }
    return _segmentedControl;
}

- (NSArray<NSString *> *)items {
    if (!_items) {
        _items = @[@"Dog", @"Cat", @"Pig", @"Shark", @"Fish", @"Martini"];
    }
    return _items;
}

@end
