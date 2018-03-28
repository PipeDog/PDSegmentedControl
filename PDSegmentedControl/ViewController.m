//
//  ViewController.m
//  PDSegmentedControl
//
//  Created by liang on 2018/3/27.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "ViewController.h"
#import "PDSegmentedControl.h"

static NSString *const kDefaultSegmentId = @"kDefaultSegmentId";
static NSString *const kSelectedSegmentId = @"kSelectedSegmentId";

@interface ViewController () <PDSegmentedControlDelegate, PDSegmentedControlDataSource>

@property (nonatomic, strong) PDSegmentedControl *segmentedControl;
@property (nonatomic, copy) NSArray<NSString *> *items;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.segmentedControl registerClass:[PDSegmentedControlSegment class] forSegmentWithReuseIdentifier:kDefaultSegmentId];
    [self.segmentedControl registerClass:[PDSegmentedControlSegment class] forSegmentWithReuseIdentifier:kSelectedSegmentId];
    
    [self.segmentedControl setSelectedIndex:2 animated:NO];
}

#pragma mark - PDSegmentedControlDataSource Methods
- (NSInteger)numberOfItemsInSegmentedControl:(PDSegmentedControl *)segmentedControl {
    return self.items.count;
}

- (PDSegmentedControlSegment *)segmentedControl:(PDSegmentedControl *)segmentedControl segmentForItemAtIndex:(NSInteger)index {
    PDSegmentedControlSegment *segment = [segmentedControl dequeueReusableSegmentWithReuseIdentifier:kDefaultSegmentId forIndex:index];
    segment.textLabel.frame = CGRectMake(0, 0, CGRectGetWidth(segment.frame), CGRectGetHeight(segment.frame));
    segment.textLabel.font = [UIFont boldSystemFontOfSize:14];
    segment.textLabel.textColor = [UIColor darkTextColor];
    segment.textLabel.text = self.items[index];
    return segment;
}

- (PDSegmentedControlSegment *)segmentedControl:(PDSegmentedControl *)segmentedControl selectedSegmentForItemAtIndex:(NSInteger)index {
    PDSegmentedControlSegment *segment = [segmentedControl dequeueReusableSegmentWithReuseIdentifier:kSelectedSegmentId forIndex:index];
    segment.textLabel.frame = CGRectMake(0, 0, CGRectGetWidth(segment.frame), CGRectGetHeight(segment.frame));
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
        [self.view addSubview:_segmentedControl];
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
