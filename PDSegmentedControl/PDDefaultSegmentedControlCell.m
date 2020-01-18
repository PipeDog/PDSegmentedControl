//
//  PDDefaultSegmentedControlCell.m
//  PDSegmentedControl
//
//  Created by liang on 2020/1/18.
//  Copyright © 2020 PipeDog. All rights reserved.
//

#import "PDDefaultSegmentedControlCell.h"
#import <Masonry.h>

@implementation PDDefaultSegmentedControlCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _commitInit];
        [self _createViewHierarchy];
        [self _layoutContentViews];
    }
    return self;
}

- (void)_commitInit {
    self.backgroundColor = [UIColor whiteColor];
}

- (void)_createViewHierarchy {
    [self.contentView addSubview:self.textLabel];
}

- (void)_layoutContentViews {
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

#pragma mark - Getter Methods
- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.numberOfLines = 1;
        _textLabel.font = [UIFont systemFontOfSize:12.f];
        _textLabel.textColor = [UIColor darkTextColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _textLabel;
}

@end
