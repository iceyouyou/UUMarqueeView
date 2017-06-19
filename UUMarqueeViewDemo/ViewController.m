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

@property (nonatomic, strong) UUMarqueeView *simpleMarqueeView;
@property (nonatomic, strong) UUMarqueeView *customMarqueeView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    // Simple Style
    self.simpleMarqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(20.0f, 105.0f, screenWidth - 40.0f, 20.0f)];
    _simpleMarqueeView.delegate = self;
    _simpleMarqueeView.timeIntervalPerScroll = 2.0f;
    _simpleMarqueeView.timeDurationPerScroll = 1.0f;
    [self.view addSubview:_simpleMarqueeView];
    [_simpleMarqueeView reloadData];

    // Custom Style
    self.customMarqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(20.0f, 195.0f, screenWidth - 40.0f, 60.0f)];
    _customMarqueeView.delegate = self;
    _customMarqueeView.timeIntervalPerScroll = 1.0f;
    _customMarqueeView.timeDurationPerScroll = 0.5f;
    [self.view addSubview:_customMarqueeView];
    [_customMarqueeView reloadData];

    [self nothingImportant];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_simpleMarqueeView) {
        [_simpleMarqueeView start];
    }
    if (_customMarqueeView) {
        [_customMarqueeView start];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (_simpleMarqueeView) {
        [_simpleMarqueeView pause];
    }
    if (_customMarqueeView) {
        [_customMarqueeView pause];
    }
}

#pragma mark - UUMarqueeViewDelegate

- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView {
    if (marqueeView == _simpleMarqueeView) {
        // for simpleMarqueeView
        return 1;
    } else {
        // for customMarqueeView
        return 3;
    }
}

- (NSArray*)dataSourceArrayForMarqueeView:(UUMarqueeView*)marqueeView {
    if (marqueeView == _simpleMarqueeView) {
        // for simpleMarqueeView
        return @[@"Do not go gentle into that good night,",
                 @"Old age should burn and rave at close of day;",
                 @"Rage, rage against the dying of the light."];
    } else {
        // for customMarqueeView
        return @[@{@"content":@"First snow at Forbidden City", @"time":@"10 seconds ago", @"icon":@"icon-1"},
                 @{@"content":@"Night view of Longmen Grottoes", @"time":@"12 minutes ago", @"icon":@"icon-2"},
                 @{@"content":@"Unexpected surprise for travelers", @"time":@"20 minutes ago", @"icon":@"icon-3"},
                 @{@"content":@"Drinking tea in outer space", @"time":@"1 hour ago", @"icon":@"icon-4"},
                 @{@"content":@"Food along the Silk Road", @"time":@"2 hour ago", @"icon":@"icon-5"}];
    }
}

- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView {
    if (marqueeView == _simpleMarqueeView) {
        // for simpleMarqueeView
        itemView.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:228.0f/255.0f blue:228.0f/255.0f alpha:1.0f];

        UILabel *content = [[UILabel alloc] initWithFrame:itemView.bounds];
        content.font = [UIFont systemFontOfSize:10.0f];
        content.tag = 1001;
        [itemView addSubview:content];
    } else {
        // for customMarqueeView
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
    }
}

- (void)updateItemView:(UIView*)itemView withData:(id)data forMarqueeView:(UUMarqueeView*)marqueeView {
    if (marqueeView == _simpleMarqueeView) {
        // for simpleMarqueeView
        UILabel *content = [itemView viewWithTag:1001];
        content.text = data;
    } else {
        // for customMarqueeView
        UILabel *content = [itemView viewWithTag:1001];
        content.text = [data objectForKey:@"content"];

        UILabel *time = [itemView viewWithTag:1002];
        time.text = [data objectForKey:@"time"];

        UIImageView *icon = [itemView viewWithTag:1003];
        icon.image = [UIImage imageNamed:[data objectForKey:@"icon"]];
    }
}

#pragma mark - Nothing Important

- (void)nothingImportant {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 40.0f, screenWidth - 40.0f, 20.0f)];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"UUMarqueeView Demo";
    title.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:title];

    // Simple Style
    UILabel *simpleTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 80.0f, screenWidth - 40.0f, 20.0f)];
    simpleTitle.text = @"Simple Style";
    simpleTitle.font = [UIFont systemFontOfSize:12.0f];
    [self.view addSubview:simpleTitle];

    UIButton *simpleStartBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 20.0f - 50.0f - 10.0f - 50.0f, 130.0f, 50.0f, 20.0f)];
    simpleStartBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [simpleStartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [simpleStartBtn setTitle:@"Start" forState:UIControlStateNormal];
    simpleStartBtn.layer.cornerRadius = 4.0f;
    simpleStartBtn.layer.borderWidth = 1.0f;
    [self.view addSubview:simpleStartBtn];
    [simpleStartBtn addTarget:self action:@selector(handleSimpleStartAction:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *simplePauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 20.0f - 50.0f, 130.0f, 50.0f, 20.0f)];
    simplePauseBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [simplePauseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [simplePauseBtn setTitle:@"Pause" forState:UIControlStateNormal];
    simplePauseBtn.layer.cornerRadius = 4.0f;
    simplePauseBtn.layer.borderWidth = 1.0f;
    [self.view addSubview:simplePauseBtn];
    [simplePauseBtn addTarget:self action:@selector(handleSimplePauseAction:) forControlEvents:UIControlEventTouchUpInside];

    // Custom Style
    UILabel *customTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 170.0f, screenWidth - 40.0f, 20.0f)];
    customTitle.text = @"Custom Style";
    customTitle.font = [UIFont systemFontOfSize:12.0f];
    [self.view addSubview:customTitle];

    UIButton *customStartBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 20.0f - 50.0f - 10.0f - 50.0f, 260.0f, 50.0f, 20.0f)];
    customStartBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [customStartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [customStartBtn setTitle:@"Start" forState:UIControlStateNormal];
    customStartBtn.layer.cornerRadius = 4.0f;
    customStartBtn.layer.borderWidth = 1.0f;
    [self.view addSubview:customStartBtn];
    [customStartBtn addTarget:self action:@selector(handleCustomStartAction:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *customPauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 20.0f - 50.0f, 260.0f, 50.0f, 20.0f)];
    customPauseBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [customPauseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [customPauseBtn setTitle:@"Pause" forState:UIControlStateNormal];
    customPauseBtn.layer.cornerRadius = 4.0f;
    customPauseBtn.layer.borderWidth = 1.0f;
    [self.view addSubview:customPauseBtn];
    [customPauseBtn addTarget:self action:@selector(handleCustomPauseAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleSimpleStartAction:(id)sender {
    if (_simpleMarqueeView) {
        [_simpleMarqueeView start];
    }
}

- (void)handleSimplePauseAction:(id)sender {
    if (_simpleMarqueeView) {
        [_simpleMarqueeView pause];
    }
}

- (void)handleCustomStartAction:(id)sender {
    if (_customMarqueeView) {
        [_customMarqueeView start];
    }
}

- (void)handleCustomPauseAction:(id)sender {
    if (_customMarqueeView) {
        [_customMarqueeView pause];
    }
}

@end
