//
//  ViewController.m
//  UUMarqueeViewDemo
//
//  Created by youyou on 16/12/7.
//  Copyright © 2016年 iceyouyou. All rights reserved.
//

#import "ViewController.h"
#import "UUMarqueeView.h"

@interface ViewController () <UUMarqueeViewDelegate>

@property (nonatomic, strong) UUMarqueeView *upwardSingleMarqueeView;
@property (nonatomic, strong) UUMarqueeView *upwardMultiMarqueeView;
@property (nonatomic, strong) UUMarqueeView *upwardDynamicHeightMarqueeView;
@property (nonatomic, strong) UUMarqueeView *leftwardMarqueeView;

@property (nonatomic, strong) NSArray *upwardSingleMarqueeViewData;
@property (nonatomic, strong) NSArray *upwardMultiMarqueeViewData;
@property (nonatomic, strong) NSArray *upwardDynamicHeightMarqueeViewData;
@property (nonatomic, strong) NSArray *leftwardMarqueeViewData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    [self prepareDataSource];

    // Upward single line MarqueeView
    self.upwardSingleMarqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(20.0f, 105.0f, screenWidth - 40.0f, 20.0f)];
    _upwardSingleMarqueeView.delegate = self;
    _upwardSingleMarqueeView.timeIntervalPerScroll = 2.0f;
    _upwardSingleMarqueeView.timeDurationPerScroll = 1.0f;
    [self.view addSubview:_upwardSingleMarqueeView];
    [_upwardSingleMarqueeView reloadData];

    // Upward multi line MarqueeView
    self.upwardMultiMarqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(20.0f, 170.0f, screenWidth - 40.0f, 60.0f)];
    _upwardMultiMarqueeView.delegate = self;
    _upwardMultiMarqueeView.timeIntervalPerScroll = 1.0f;
    _upwardMultiMarqueeView.timeDurationPerScroll = 0.5f;
    _upwardMultiMarqueeView.touchEnabled = YES;
    [self.view addSubview:_upwardMultiMarqueeView];
    [_upwardMultiMarqueeView reloadData];

    // Upward multi line MarqueeView (Use Dynamic Height)
    self.upwardDynamicHeightMarqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(20.0f, 275.0f, screenWidth - 40.0f, 130.0f)];
    _upwardDynamicHeightMarqueeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    _upwardDynamicHeightMarqueeView.delegate = self;
    _upwardDynamicHeightMarqueeView.timeIntervalPerScroll = 0.0f;
    _upwardDynamicHeightMarqueeView.scrollSpeed = 20.0f;
    _upwardDynamicHeightMarqueeView.useDynamicHeight = YES;
    _upwardDynamicHeightMarqueeView.touchEnabled = YES;
    [self.view addSubview:_upwardDynamicHeightMarqueeView];
    [_upwardDynamicHeightMarqueeView reloadData];

    // Leftward MarqueeView
    self.leftwardMarqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(20.0f, 475.0f, screenWidth - 40.0f, 20.0f) direction:UUMarqueeViewDirectionLeftward];
    _leftwardMarqueeView.delegate = self;
    _leftwardMarqueeView.timeIntervalPerScroll = 0.0f;
    _leftwardMarqueeView.scrollSpeed = 60.0f;
    _leftwardMarqueeView.itemSpacing = 20.0f;
    [self.view addSubview:_leftwardMarqueeView];
    [_leftwardMarqueeView reloadData];

    // layout
    [self nothingImportant];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // something good for saving energy
    if (_upwardSingleMarqueeView) {
        [_upwardSingleMarqueeView start];
    }
    if (_upwardMultiMarqueeView) {
        [_upwardMultiMarqueeView start];
    }
    if (_upwardDynamicHeightMarqueeView) {
        [_upwardDynamicHeightMarqueeView start];
    }
    if (_leftwardMarqueeView) {
        [_leftwardMarqueeView start];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // something good for saving energy
    if (_upwardSingleMarqueeView) {
        [_upwardSingleMarqueeView pause];
    }
    if (_upwardMultiMarqueeView) {
        [_upwardMultiMarqueeView pause];
    }
    if (_upwardDynamicHeightMarqueeView) {
        [_upwardDynamicHeightMarqueeView pause];
    }
    if (_leftwardMarqueeView) {
        [_leftwardMarqueeView pause];
    }
}

#pragma mark - UUMarqueeViewDelegate
- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView {
    if (marqueeView == _upwardSingleMarqueeView) {
        // for upwardSingleMarqueeView
        return 1;
    } else if (marqueeView == _upwardMultiMarqueeView) {
        // for upwardMultiMarqueeView
        return 3;
    } else {
        // for upwardDynamicHeightMarqueeView
        return 2;
    }
}

- (NSUInteger)numberOfDataForMarqueeView:(UUMarqueeView*)marqueeView {
    if (marqueeView == _upwardSingleMarqueeView) {
        // for upwardSingleMarqueeView
        return _upwardSingleMarqueeViewData ? _upwardSingleMarqueeViewData.count : 0;
    } else if (marqueeView == _upwardMultiMarqueeView) {
        // for upwardMultiMarqueeView
        return _upwardMultiMarqueeViewData ? _upwardMultiMarqueeViewData.count : 0;
    } else if (marqueeView == _upwardDynamicHeightMarqueeView) {
        // for upwardDynamicHeightMarqueeView
        return _upwardDynamicHeightMarqueeViewData ? _upwardDynamicHeightMarqueeViewData.count : 0;
    } else {
        // for leftwardMarqueeView
        return _leftwardMarqueeViewData ? _leftwardMarqueeViewData.count : 0;
    }
}

- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView {
    if (marqueeView == _upwardSingleMarqueeView) {
        // for upwardSingleMarqueeView
        itemView.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:228.0f/255.0f blue:228.0f/255.0f alpha:1.0f];

        UILabel *content = [[UILabel alloc] initWithFrame:itemView.bounds];
        content.font = [UIFont systemFontOfSize:10.0f];
        content.tag = 1001;
        [itemView addSubview:content];
    } else if (marqueeView == _upwardMultiMarqueeView) {
        // for upwardMultiMarqueeView
        itemView.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:228.0f/255.0f blue:228.0f/255.0f alpha:1.0f];

        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, (CGRectGetHeight(itemView.bounds) - 16.0f) / 2.0f, 16.0f, 16.0f)];
        icon.tag = 1003;
        [itemView addSubview:icon];

        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(itemView.bounds) - 75.0f, 0.0f, 70.0f, CGRectGetHeight(itemView.bounds))];
        time.textAlignment = NSTextAlignmentRight;
        time.font = [UIFont systemFontOfSize:9.0f];
        time.tag = 1002;
        [itemView addSubview:time];

        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(5.0f + 16.0f, 0.0f, CGRectGetWidth(itemView.bounds) - 5.0f - 16.0f - 75.0f, CGRectGetHeight(itemView.bounds))];
        content.font = [UIFont systemFontOfSize:10.0f];
        content.tag = 1001;
        [itemView addSubview:content];
    } else if (marqueeView == _upwardDynamicHeightMarqueeView) {
        // for upwardDynamicHeightMarqueeView
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, CGRectGetWidth(itemView.bounds) - 5.0f - 5.0f, CGRectGetHeight(itemView.bounds) - 5.0f - 5.0f)];
        bgView.tag = 1002;
        bgView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6f];
        bgView.layer.cornerRadius = (CGRectGetHeight(itemView.bounds) - 5.0f - 5.0f) / 2.0f;
        [itemView addSubview:bgView];

        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, (CGRectGetHeight(itemView.bounds) - 16.0f) / 2.0f, 16.0f, 16.0f)];
        icon.tag = 1003;
        [itemView addSubview:icon];

        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(5.0f + 16.0f, 0.0f, CGRectGetWidth(itemView.bounds) - 5.0f - 16.0f - 5.0f, CGRectGetHeight(itemView.bounds))];
        content.numberOfLines = 0;
        content.font = [UIFont systemFontOfSize:10.0f];
        content.tag = 1001;
        [itemView addSubview:content];
    } else {
        // for leftwardMarqueeView
        itemView.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:228.0f/255.0f blue:228.0f/255.0f alpha:1.0f];

        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, (CGRectGetHeight(itemView.bounds) - 16.0f) / 2.0f, 16.0f, 16.0f)];
        icon.tag = 1002;
        [itemView addSubview:icon];

        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(5.0f + 16.0f + 5.0f, 0.0f, CGRectGetWidth(itemView.bounds) - 5.0f - 16.0f - 5.0f - 5.0f, CGRectGetHeight(itemView.bounds))];
        content.font = [UIFont systemFontOfSize:10.0f];
        content.tag = 1001;
        [itemView addSubview:content];
    }
}

- (void)updateItemView:(UIView*)itemView atIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    if (marqueeView == _upwardSingleMarqueeView) {
        // for upwardSingleMarqueeView
        UILabel *content = [itemView viewWithTag:1001];
        content.text = _upwardSingleMarqueeViewData[index];
    } else if (marqueeView == _upwardMultiMarqueeView) {
        // for upwardMultiMarqueeView
        UILabel *content = [itemView viewWithTag:1001];
        content.text = [_upwardMultiMarqueeViewData[index] objectForKey:@"content"];

        UILabel *time = [itemView viewWithTag:1002];
        time.text = [_upwardMultiMarqueeViewData[index] objectForKey:@"time"];

        UIImageView *icon = [itemView viewWithTag:1003];
        icon.image = [UIImage imageNamed:[_upwardMultiMarqueeViewData[index] objectForKey:@"icon"]];
    } else if (marqueeView == _upwardDynamicHeightMarqueeView) {
        // for upwardDynamicHeightMarqueeView
        UILabel *content = [itemView viewWithTag:1001];
        content.text = [_upwardDynamicHeightMarqueeViewData[index] objectForKey:@"content"];

        UIImageView *icon = [itemView viewWithTag:1003];
        [icon setFrame:CGRectMake(5.0f, (CGRectGetHeight(itemView.bounds) - 16.0f) / 2.0f, 16.0f, 16.0f)];
        icon.image = [UIImage imageNamed:[_upwardDynamicHeightMarqueeViewData[index] objectForKey:@"icon"]];

        CGSize contentFitSize = [content sizeThatFits:CGSizeMake(CGRectGetWidth(itemView.bounds) - 5.0f - 16.0f - 5.0f, MAXFLOAT)];
        UIView *bgView = [itemView viewWithTag:1002];
        [bgView setFrame:CGRectMake(5.0f, 5.0f, 16.0f + contentFitSize.width + 4.0f, CGRectGetHeight(itemView.bounds) - 5.0f - 5.0f)];
        bgView.layer.cornerRadius = (CGRectGetHeight(itemView.bounds) - 5.0f - 5.0f) / 2.0f;
    } else {
        // for leftwardMarqueeView
        UILabel *content = [itemView viewWithTag:1001];
        content.text = _leftwardMarqueeViewData[index];

        UIImageView *icon = [itemView viewWithTag:1002];
        icon.image = [UIImage imageNamed:@"speaker"];
    }
}

- (CGFloat)itemViewHeightAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    // for upwardDynamicHeightMarqueeView
    UILabel *content = [[UILabel alloc] init];
    content.numberOfLines = 0;
    content.font = [UIFont systemFontOfSize:10.0f];
    content.text = [_upwardDynamicHeightMarqueeViewData[index] objectForKey:@"content"];
    CGSize contentFitSize = [content sizeThatFits:CGSizeMake(CGRectGetWidth(marqueeView.frame) - 5.0f - 16.0f - 5.0f, MAXFLOAT)];
    return contentFitSize.height + 20.0f;
}

- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    // for leftwardMarqueeView
    UILabel *content = [[UILabel alloc] init];
    content.font = [UIFont systemFontOfSize:10.0f];
    content.text = _leftwardMarqueeViewData[index];
    return (5.0f + 16.0f + 5.0f) + content.intrinsicContentSize.width;  // icon width + label width (it's perfect to cache them all)
}

- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    NSLog(@"Touch at index %lu - \"%@\"", (unsigned long)index, [_upwardMultiMarqueeViewData[index] objectForKey:@"content"]);
}

#pragma mark - Nothing Important
- (void)prepareDataSource {
    self.upwardSingleMarqueeViewData = @[@"Do not go gentle into that good night,",
                                         @"Old age should burn and rave at close of day;",
                                         @"Rage, rage against the dying of the light."];

    self.upwardMultiMarqueeViewData = @[@{@"content":@"First snow at Forbidden City", @"time":@"10 seconds ago", @"icon":@"icon-1"},
                                        @{@"content":@"Night view of Longmen Grottoes", @"time":@"12 minutes ago", @"icon":@"icon-2"},
                                        @{@"content":@"Unexpected surprise for travelers", @"time":@"20 minutes ago", @"icon":@"icon-3"},
                                        @{@"content":@"Drinking tea in outer space", @"time":@"1 hour ago", @"icon":@"icon-4"},
                                        @{@"content":@"Food along the Silk Road", @"time":@"2 hour ago", @"icon":@"icon-5"}];

    self.upwardDynamicHeightMarqueeViewData = @[@{@"content":@"First snow at Forbidden City", @"time":@"10 seconds ago", @"icon":@"icon-1"},
                                                @{@"content":@"Night view of Longmen Grottoes; Night view of Longmen Grottoes", @"time":@"12 minutes ago", @"icon":@"icon-2"},
                                                @{@"content":@"Unexpected surprise for travelers", @"time":@"20 minutes ago", @"icon":@"icon-3"},
                                                @{@"content":@"Drinking tea in outer space; Drinking tea in outer space; Drinking tea in outer space", @"time":@"1 hour ago", @"icon":@"icon-4"},
                                                @{@"content":@"Food along the Silk Road", @"time":@"2 hour ago", @"icon":@"icon-5"}];

    self.leftwardMarqueeViewData = @[@"Do not go gentle into that good night,",
                                     @"Old age should burn and rave at close of day; Rage, rage against the dying of the light.",
                                     @"Though wise men at their end know dark is right, Because their words had forked no lightning they Do not go gentle into that good night.",
                                     @"Good men, the last wave by, crying how bright"];
}

- (void)nothingImportant {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 40.0f, screenWidth - 40.0f, 20.0f)];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"UUMarqueeView Demo";
    title.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:title];

    // Upward single line MarqueeView
    UILabel *singleTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 80.0f, screenWidth - 40.0f, 20.0f)];
    singleTitle.text = @"Direction = Upward";
    singleTitle.font = [UIFont systemFontOfSize:12.0f];
    [self.view addSubview:singleTitle];

    UIButton *singleStartBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 20.0f - 50.0f - 10.0f - 50.0f, 130.0f, 50.0f, 20.0f)];
    singleStartBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [singleStartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [singleStartBtn setTitle:@"Start" forState:UIControlStateNormal];
    singleStartBtn.layer.cornerRadius = 4.0f;
    singleStartBtn.layer.borderWidth = 1.0f;
    [self.view addSubview:singleStartBtn];
    [singleStartBtn addTarget:self action:@selector(handleSingleStartAction:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *singlePauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 20.0f - 50.0f, 130.0f, 50.0f, 20.0f)];
    singlePauseBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [singlePauseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [singlePauseBtn setTitle:@"Pause" forState:UIControlStateNormal];
    singlePauseBtn.layer.cornerRadius = 4.0f;
    singlePauseBtn.layer.borderWidth = 1.0f;
    [self.view addSubview:singlePauseBtn];
    [singlePauseBtn addTarget:self action:@selector(handleSinglePauseAction:) forControlEvents:UIControlEventTouchUpInside];

    // Upward multi line MarqueeView
    UIButton *multiStartBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 20.0f - 50.0f - 10.0f - 50.0f, 235.0f, 50.0f, 20.0f)];
    multiStartBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [multiStartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [multiStartBtn setTitle:@"Start" forState:UIControlStateNormal];
    multiStartBtn.layer.cornerRadius = 4.0f;
    multiStartBtn.layer.borderWidth = 1.0f;
    [self.view addSubview:multiStartBtn];
    [multiStartBtn addTarget:self action:@selector(handleMultiStartAction:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *multiPauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 20.0f - 50.0f, 235.0f, 50.0f, 20.0f)];
    multiPauseBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [multiPauseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [multiPauseBtn setTitle:@"Pause" forState:UIControlStateNormal];
    multiPauseBtn.layer.cornerRadius = 4.0f;
    multiPauseBtn.layer.borderWidth = 1.0f;
    [self.view addSubview:multiPauseBtn];
    [multiPauseBtn addTarget:self action:@selector(handleMultiPauseAction:) forControlEvents:UIControlEventTouchUpInside];

    // Upward multi line MarqueeView (Use Dynamic Height)
    UIButton *dynamicHeightStartBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 20.0f - 50.0f - 10.0f - 50.0f, 410.0f, 50.0f, 20.0f)];
    dynamicHeightStartBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [dynamicHeightStartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dynamicHeightStartBtn setTitle:@"Start" forState:UIControlStateNormal];
    dynamicHeightStartBtn.layer.cornerRadius = 4.0f;
    dynamicHeightStartBtn.layer.borderWidth = 1.0f;
    [self.view addSubview:dynamicHeightStartBtn];
    [dynamicHeightStartBtn addTarget:self action:@selector(handleDynamicHeightStartAction:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *dynamicHeightPauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 20.0f - 50.0f, 410.0f, 50.0f, 20.0f)];
    dynamicHeightPauseBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [dynamicHeightPauseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dynamicHeightPauseBtn setTitle:@"Pause" forState:UIControlStateNormal];
    dynamicHeightPauseBtn.layer.cornerRadius = 4.0f;
    dynamicHeightPauseBtn.layer.borderWidth = 1.0f;
    [self.view addSubview:dynamicHeightPauseBtn];
    [dynamicHeightPauseBtn addTarget:self action:@selector(handleDynamicHeightPauseAction:) forControlEvents:UIControlEventTouchUpInside];

    // leftward MarqueeView
    UILabel *leftwardTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 450.0f, screenWidth - 40.0f, 20.0f)];
    leftwardTitle.text = @"Direction = Leftward";
    leftwardTitle.font = [UIFont systemFontOfSize:12.0f];
    [self.view addSubview:leftwardTitle];

    UIButton *leftwardStartBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 20.0f - 50.0f - 10.0f - 50.0f, 500.0f, 50.0f, 20.0f)];
    leftwardStartBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [leftwardStartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftwardStartBtn setTitle:@"Start" forState:UIControlStateNormal];
    leftwardStartBtn.layer.cornerRadius = 4.0f;
    leftwardStartBtn.layer.borderWidth = 1.0f;
    [self.view addSubview:leftwardStartBtn];
    [leftwardStartBtn addTarget:self action:@selector(handleLeftwardStartAction:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *leftwardPauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 20.0f - 50.0f, 500.0f, 50.0f, 20.0f)];
    leftwardPauseBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [leftwardPauseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftwardPauseBtn setTitle:@"Pause" forState:UIControlStateNormal];
    leftwardPauseBtn.layer.cornerRadius = 4.0f;
    leftwardPauseBtn.layer.borderWidth = 1.0f;
    [self.view addSubview:leftwardPauseBtn];
    [leftwardPauseBtn addTarget:self action:@selector(handleLeftwardPauseAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleSingleStartAction:(id)sender {
    if (_upwardSingleMarqueeView) {
        [_upwardSingleMarqueeView start];
    }
}

- (void)handleSinglePauseAction:(id)sender {
    if (_upwardSingleMarqueeView) {
        [_upwardSingleMarqueeView pause];
    }
}

- (void)handleMultiStartAction:(id)sender {
    if (_upwardMultiMarqueeView) {
        [_upwardMultiMarqueeView start];
    }
}

- (void)handleMultiPauseAction:(id)sender {
    if (_upwardMultiMarqueeView) {
        [_upwardMultiMarqueeView pause];
    }
}

- (void)handleDynamicHeightStartAction:(id)sender {
    if (_upwardDynamicHeightMarqueeView) {
        [_upwardDynamicHeightMarqueeView start];
    }
}

- (void)handleDynamicHeightPauseAction:(id)sender {
    if (_upwardDynamicHeightMarqueeView) {
        [_upwardDynamicHeightMarqueeView pause];
    }
}

- (void)handleLeftwardStartAction:(id)sender {
    if (_leftwardMarqueeView) {
        [_leftwardMarqueeView start];
    }
}

- (void)handleLeftwardPauseAction:(id)sender {
    if (_leftwardMarqueeView) {
        [_leftwardMarqueeView pause];
    }
}

@end
