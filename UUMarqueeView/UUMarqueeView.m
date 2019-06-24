//
//  UUMarqueeView.m
//  UUMarqueeView
//
//  Created by youyou on 16/12/5.
//  Copyright © 2016年 iceyouyou. All rights reserved.
//

#import "UUMarqueeView.h"

@interface UUMarqueeView () <UUMarqueeViewTouchResponder>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger visibleItemCount;
@property (nonatomic, strong) NSMutableArray<UUMarqueeItemView*> *items;
@property (nonatomic, assign) int firstItemIndex;
@property (nonatomic, assign) int dataIndex;
@property (nonatomic, strong) NSTimer *scrollTimer;
@property (nonatomic, strong) UUMarqueeViewTouchReceiver *touchReceiver;

@property (nonatomic, assign) BOOL isWaiting;
@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL isScrollNeedsToStop;
@property (nonatomic, assign) BOOL isPausingBeforeTouchesBegan;
@property (nonatomic, assign) BOOL isPausingBeforeResignActive;

@end

@implementation UUMarqueeView

static NSInteger const DEFAULT_VISIBLE_ITEM_COUNT = 2;
static NSTimeInterval const DEFAULT_TIME_INTERVAL = 4.0;
static NSTimeInterval const DEFAULT_TIME_DURATION = 1.0;
static float const DEFAULT_SCROLL_SPEED = 40.0f;
static float const DEFAULT_ITEM_SPACING = 20.0f;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _timeIntervalPerScroll = DEFAULT_TIME_INTERVAL;
        _timeDurationPerScroll = DEFAULT_TIME_DURATION;
        _scrollSpeed = DEFAULT_SCROLL_SPEED;
        _itemSpacing = DEFAULT_ITEM_SPACING;
        _touchEnabled = NO;
        _stopWhenLessData = NO;

        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

- (instancetype)initWithDirection:(UUMarqueeViewDirection)direction {
    if (self = [super init]) {
        _direction = direction;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame direction:(UUMarqueeViewDirection)direction {
    if (self = [super initWithFrame:frame]) {
        _direction = direction;
        _timeIntervalPerScroll = DEFAULT_TIME_INTERVAL;
        _timeDurationPerScroll = DEFAULT_TIME_DURATION;
        _scrollSpeed = DEFAULT_SCROLL_SPEED;
        _itemSpacing = DEFAULT_ITEM_SPACING;
        _touchEnabled = NO;
        _stopWhenLessData = NO;

        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _timeIntervalPerScroll = DEFAULT_TIME_INTERVAL;
        _timeDurationPerScroll = DEFAULT_TIME_DURATION;
        _scrollSpeed = DEFAULT_SCROLL_SPEED;
        _itemSpacing = DEFAULT_ITEM_SPACING;
        _touchEnabled = NO;
        _stopWhenLessData = NO;

        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)setClipsToBounds:(BOOL)clipsToBounds {
    _contentView.clipsToBounds = clipsToBounds;
}

- (void)setTouchEnabled:(BOOL)touchEnabled {
    _touchEnabled = touchEnabled;
    [self resetTouchReceiver];
}

- (void)reloadData {
    if (_isWaiting) {
        if (_scrollTimer) {
            [_scrollTimer invalidate];
            self.scrollTimer = nil;
        }
        [self resetAll];
        [self startAfterTimeInterval:YES];
    } else if (_isScrolling) {
        [self resetAll];
    } else {
        // stopped
        [self resetAll];
        [self startAfterTimeInterval:YES];
    }
}

- (void)start {
    self.isScrollNeedsToStop = NO;
    if (!_isScrolling && !_isWaiting) {
        [self startAfterTimeInterval:NO];
    }
}

- (void)pause {
    self.isScrollNeedsToStop = YES;
}

- (void)repeat {
    if (!_isScrollNeedsToStop) {
        [self startAfterTimeInterval:YES];
    }
}

- (void)repeatWithAnimationFinished:(BOOL)finished {
    if (!_isScrollNeedsToStop) {
        [self startAfterTimeInterval:YES animationFinished:finished];
    }
}

- (void)startAfterTimeInterval:(BOOL)afterTimeInterval {
    [self startAfterTimeInterval:afterTimeInterval animationFinished:YES];
}

- (void)startAfterTimeInterval:(BOOL)afterTimeInterval animationFinished:(BOOL)finished {
    if (_isScrolling || _items.count <= 0) {
        return;
    }

    self.isWaiting = YES;
    NSTimeInterval timeInterval = 1.0;
    if (finished) {
        timeInterval = afterTimeInterval ? _timeIntervalPerScroll : 0.0;
    }
    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                        target:self
                                                      selector:@selector(scrollTimerDidFire:)
                                                      userInfo:nil
                                                       repeats:NO];
}

#pragma mark - Override(private)
- (void)layoutSubviews {
    [super layoutSubviews];

    [_contentView setFrame:self.bounds];
    [self repositionItemViews];
    if (_touchEnabled && _touchReceiver) {
        [_touchReceiver setFrame:self.bounds];
    }
}

- (void)dealloc {
    if (_scrollTimer) {
        [_scrollTimer invalidate];
        self.scrollTimer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Notification
- (void)handleResignActiveNotification:(NSNotification*)notification {
    self.isPausingBeforeResignActive = _isScrollNeedsToStop;
    [self pause];
}

- (void)handleBecomeActiveNotification:(NSNotification*)notification {
    if (!_isPausingBeforeResignActive) {
        [self start];
    }
}

#pragma mark - ItemView(private)
- (void)resetAll {
    self.dataIndex = -1;
    self.firstItemIndex = 0;

    if (_items) {
        [_items makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_items removeAllObjects];
    } else {
        self.items = [NSMutableArray array];
    }

    if (_direction == UUMarqueeViewDirectionLeftward) {
        self.visibleItemCount = 1;
    } else {
        if ([_delegate respondsToSelector:@selector(numberOfVisibleItemsForMarqueeView:)]) {
            self.visibleItemCount = [_delegate numberOfVisibleItemsForMarqueeView:self];
            if (_visibleItemCount <= 0) {
                return;
            }
        } else {
            self.visibleItemCount = DEFAULT_VISIBLE_ITEM_COUNT;
        }
    }

    for (int i = 0; i < _visibleItemCount + 2; i++) {
        UUMarqueeItemView *itemView = [[UUMarqueeItemView alloc] init];
        [_contentView addSubview:itemView];
        [_items addObject:itemView];
    }

    if (_direction == UUMarqueeViewDirectionLeftward) {
        CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;
        CGFloat lastMaxX = 0.0f;
        for (int i = 0; i < _items.count; i++) {
            int index = (i + _firstItemIndex) % _items.count;

            CGFloat itemWidth = CGRectGetWidth(self.frame);
            if (i == 0) {
                [_items[index] setFrame:CGRectMake(-itemWidth, 0.0f, itemWidth, itemHeight)];
                lastMaxX = 0.0f;

                [self createItemView:_items[index]];
            } else  {
                [self moveToNextDataIndex];
                _items[index].tag = _dataIndex;
                _items[index].width = [self itemWidthAtIndex:_items[index].tag];
                itemWidth = MAX(_items[index].width + _itemSpacing, itemWidth);

                [_items[index] setFrame:CGRectMake(lastMaxX, 0.0f, itemWidth, itemHeight)];
                lastMaxX = lastMaxX + itemWidth;

                [self updateItemView:_items[index] atIndex:_items[index].tag];
            }
        }
    } else {
        if (_useDynamicHeight) {
            CGFloat itemWidth = CGRectGetWidth(self.frame);
            for (int i = 0; i < _items.count; i++) {
                int index = (i + _firstItemIndex) % _items.count;
                if (i == _items.count - 1) {
                    [self moveToNextDataIndex];
                    _items[index].tag = _dataIndex;
                    _items[index].height = [self itemHeightAtIndex:_items[index].tag];
                    _items[index].alpha = 0.0f;

                    [_items[index] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, _items[index].height)];
                    [self updateItemView:_items[index] atIndex:_items[index].tag];
                } else {
                    _items[index].tag = _dataIndex;
                    _items[index].alpha = 0.0f;

                    [_items[index] setFrame:CGRectMake(0.0f, 0.0f, itemWidth, 0.0f)];
                }
            }
        } else {
            NSUInteger dataCount = 0;
            if ([_delegate respondsToSelector:@selector(numberOfDataForMarqueeView:)]) {
                dataCount = [_delegate numberOfDataForMarqueeView:self];
            }

            CGFloat itemWidth = CGRectGetWidth(self.frame);
            CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;
            for (int i = 0; i < _items.count; i++) {
                int index = (i + _firstItemIndex) % _items.count;
                if (i == 0) {
                    _items[index].tag = _dataIndex;

                    [_items[index] setFrame:CGRectMake(0.0f, -itemHeight, itemWidth, itemHeight)];
                    [self createItemView:_items[index]];
                } else {
                    [self moveToNextDataIndex];
                    _items[index].tag = _dataIndex;

                    [_items[index] setFrame:CGRectMake(0.0f, itemHeight * (i - 1), itemWidth, itemHeight)];

                    if (_stopWhenLessData) {
                        if (i <= dataCount) {
                            [self updateItemView:_items[index] atIndex:_items[index].tag];
                        } else {
                            [self createItemView:_items[index]];
                        }
                    } else {
                        [self updateItemView:_items[index] atIndex:_items[index].tag];
                    }
                }
            }
        }
    }

    [self resetTouchReceiver];
}

- (void)repositionItemViews {
    if (_direction == UUMarqueeViewDirectionLeftward) {
        CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;
        CGFloat lastMaxX = 0.0f;
        for (int i = 0; i < _items.count; i++) {
            int index = (i + _firstItemIndex) % _items.count;

            CGFloat itemWidth = MAX(_items[index].width + _itemSpacing, CGRectGetWidth(self.frame));

            if (i == 0) {
                [_items[index] setFrame:CGRectMake(-itemWidth, 0.0f, itemWidth, itemHeight)];
                lastMaxX = 0.0f;
            } else {
                [_items[index] setFrame:CGRectMake(lastMaxX, 0.0f, itemWidth, itemHeight)];
                lastMaxX = lastMaxX + itemWidth;
            }
        }
    } else {
        if (_useDynamicHeight) {
            CGFloat itemWidth = CGRectGetWidth(self.frame);
            CGFloat lastMaxY = 0.0f;
            for (int i = 0; i < _items.count; i++) {
                int index = (i + _firstItemIndex) % _items.count;
                if (i == 0) {
                    [_items[index] setFrame:CGRectMake(0.0f, 0.0f, itemWidth, 0.0f)];
                    lastMaxY = 0.0f;
                } else if (i == _items.count - 1) {
                    [_items[index] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, _items[index].height)];
                } else {
                    [_items[index] setFrame:CGRectMake(0.0f, lastMaxY, itemWidth, _items[index].height)];
                    lastMaxY = lastMaxY + _items[index].height;
                }
            }

            CGFloat offsetY = CGRectGetHeight(self.frame) - lastMaxY;
            for (int i = 0; i < _items.count; i++) {
                int index = (i + _firstItemIndex) % _items.count;
                if (i > 0 && i < _items.count - 1) {
                    [_items[index] setFrame:CGRectMake(CGRectGetMinX(_items[index].frame),
                                                       CGRectGetMinY(_items[index].frame) + offsetY,
                                                       itemWidth,
                                                       _items[index].height)];
                }
            }
        } else {
            CGFloat itemWidth = CGRectGetWidth(self.frame);
            CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;
            for (int i = 0; i < _items.count; i++) {
                int index = (i + _firstItemIndex) % _items.count;
                if (i == 0) {
                    [_items[index] setFrame:CGRectMake(0.0f, -itemHeight, itemWidth, itemHeight)];
                } else {
                    [_items[index] setFrame:CGRectMake(0.0f, itemHeight * (i - 1), itemWidth, itemHeight)];
                }
            }
        }
    }
}

- (int)itemIndexWithOffsetFromTop:(int)offsetFromTop {
    return (_firstItemIndex + offsetFromTop) % (_visibleItemCount + 2);
}

- (void)moveToNextItemIndex {
    if (_firstItemIndex >= _items.count - 1) {
        self.firstItemIndex = 0;
    } else {
        self.firstItemIndex++;
    }
}

- (CGFloat)itemWidthAtIndex:(NSInteger)index {
    CGFloat itemWidth = 0.0f;
    if (index >= 0) {
        if ([_delegate respondsToSelector:@selector(itemViewWidthAtIndex:forMarqueeView:)]) {
            itemWidth = [_delegate itemViewWidthAtIndex:index forMarqueeView:self];
        }
    }
    return itemWidth;
}

- (CGFloat)itemHeightAtIndex:(NSInteger)index {
    CGFloat itemHeight = 0.0f;
    if (index >= 0) {
        if ([_delegate respondsToSelector:@selector(itemViewHeightAtIndex:forMarqueeView:)]) {
            itemHeight = [_delegate itemViewHeightAtIndex:index forMarqueeView:self];
        }
    }
    return itemHeight;
}

- (void)createItemView:(UUMarqueeItemView*)itemView {
    if (!itemView.didFinishCreate) {
        if ([_delegate respondsToSelector:@selector(createItemView:forMarqueeView:)]) {
            [_delegate createItemView:itemView forMarqueeView:self];
            itemView.didFinishCreate = YES;
        }
    }
}

- (void)updateItemView:(UUMarqueeItemView*)itemView atIndex:(NSInteger)index {
    if (index < 0) {
        [itemView clear];
    }

    if (!itemView.didFinishCreate) {
        if ([_delegate respondsToSelector:@selector(createItemView:forMarqueeView:)]) {
            [_delegate createItemView:itemView forMarqueeView:self];
            itemView.didFinishCreate = YES;
        }
    }

    if (index >= 0) {
        if ([_delegate respondsToSelector:@selector(updateItemView:atIndex:forMarqueeView:)]) {
            [_delegate updateItemView:itemView atIndex:index forMarqueeView:self];
        }
    }
}

#pragma mark - Timer & Animation(private)
- (void)scrollTimerDidFire:(NSTimer *)timer {
    self.isWaiting = NO;
    if (_isScrollNeedsToStop) {
        return;
    }

    self.isScrolling = YES;
    if (_stopWhenLessData) {
        NSUInteger dataCount = 0;
        if ([_delegate respondsToSelector:@selector(numberOfDataForMarqueeView:)]) {
            dataCount = [_delegate numberOfDataForMarqueeView:self];
        }
        if (_direction == UUMarqueeViewDirectionLeftward) {
            if (dataCount <= 1) {
                CGFloat itemWidth = MAX(_items[1].width + _itemSpacing, CGRectGetWidth(self.frame));
                if (itemWidth <= CGRectGetWidth(self.frame)) {
                    __weak __typeof(self) weakSelf = self;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_timeDurationPerScroll * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        __strong __typeof(self) self = weakSelf;
                        if (self) {
                            self.isScrolling = NO;
                            [self repeat];
                        }
                    });
                    return;
                }
            }
        } else {
            if (dataCount <= _visibleItemCount) {
                __weak __typeof(self) weakSelf = self;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_timeDurationPerScroll * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    __strong __typeof(self) self = weakSelf;
                    if (self) {
                        self.isScrolling = NO;
                        [self repeat];
                    }
                });
                return;
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (_direction == UUMarqueeViewDirectionLeftward) {
            [self moveToNextDataIndex];

            CGFloat itemHeight = CGRectGetHeight(self.frame);
            CGFloat firstItemWidth = CGRectGetWidth(self.frame);
            CGFloat currentItemWidth = CGRectGetWidth(self.frame);
            CGFloat lastItemWidth = CGRectGetWidth(self.frame);
            for (int i = 0; i < _items.count; i++) {
                int index = (i + _firstItemIndex) % _items.count;

                CGFloat itemWidth = MAX(_items[index].width + _itemSpacing, CGRectGetWidth(self.frame));

                if (i == 0) {
                    firstItemWidth = itemWidth;
                } else if (i == 1) {
                    currentItemWidth = itemWidth;
                } else {
                    lastItemWidth = itemWidth;
                }
            }

            // move the left item to right without animation
            _items[_firstItemIndex].tag = _dataIndex;
            _items[_firstItemIndex].width = [self itemWidthAtIndex:_items[_firstItemIndex].tag];
            CGFloat nextItemWidth = MAX(_items[_firstItemIndex].width + _itemSpacing, CGRectGetWidth(self.frame));
            [_items[_firstItemIndex] setFrame:CGRectMake(lastItemWidth, 0.0f, nextItemWidth, itemHeight)];
            if (firstItemWidth != nextItemWidth) {
                // if the width of next item view changes, then recreate it by delegate
                [_items[_firstItemIndex] clear];
            }
            [self updateItemView:_items[_firstItemIndex] atIndex:_items[_firstItemIndex].tag];

            __weak __typeof(self) weakSelf = self;
            [UIView animateWithDuration:(currentItemWidth / _scrollSpeed) delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                CGFloat lastMaxX = 0.0f;
                for (int i = 0; i < _items.count; i++) {
                    int index = (i + _firstItemIndex) % _items.count;

                    CGFloat itemWidth = MAX(_items[index].width + _itemSpacing, CGRectGetWidth(self.frame));

                    if (i == 0) {
                        continue;
                    } else if (i == 1) {
                        [_items[index] setFrame:CGRectMake(-itemWidth, 0.0f, itemWidth, itemHeight)];
                        lastMaxX = 0.0f;
                    } else {
                        [_items[index] setFrame:CGRectMake(lastMaxX, 0.0f, itemWidth, itemHeight)];
                        lastMaxX = lastMaxX + itemWidth;
                    }
                }
            } completion:^(BOOL finished) {
                __strong __typeof(self) self = weakSelf;
                if (self) {
                    self.isScrolling = NO;
                    [self repeatWithAnimationFinished:finished];
                }
            }];
            [self moveToNextItemIndex];
        } else {
            [self moveToNextDataIndex];

            CGFloat itemWidth = CGRectGetWidth(self.frame);
            CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;

            // move the top item to bottom without animation
            _items[_firstItemIndex].tag = _dataIndex;
            if (_useDynamicHeight) {
                CGFloat firstItemWidth = _items[_firstItemIndex].height;
                _items[_firstItemIndex].height = [self itemHeightAtIndex:_items[_firstItemIndex].tag];
                [_items[_firstItemIndex] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, _items[_firstItemIndex].height)];
                if (firstItemWidth != _items[_firstItemIndex].height) {
                    // if the height of next item view changes, then recreate it by delegate
                    [_items[_firstItemIndex] clear];
                }
            } else {
                [_items[_firstItemIndex] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, itemHeight)];
            }
            [self updateItemView:_items[_firstItemIndex] atIndex:_items[_firstItemIndex].tag];

            if (_useDynamicHeight) {
                int lastItemIndex = (int)(_items.count - 1 + _firstItemIndex) % _items.count;
                CGFloat lastItemHeight = _items[lastItemIndex].height;
                __weak __typeof(self) weakSelf = self;
                [UIView animateWithDuration:(lastItemHeight / _scrollSpeed) delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                    for (int i = 0; i < _items.count; i++) {
                        int index = (i + _firstItemIndex) % _items.count;
                        if (i == 0) {
                            continue;
                        } else if (i == 1) {
                            [_items[index] setFrame:CGRectMake(CGRectGetMinX(_items[index].frame),
                                                               CGRectGetMinY(_items[index].frame) - lastItemHeight,
                                                               itemWidth,
                                                               _items[index].height)];
                            _items[index].alpha = 0.0f;
                        } else {
                            [_items[index] setFrame:CGRectMake(CGRectGetMinX(_items[index].frame),
                                                               CGRectGetMinY(_items[index].frame) - lastItemHeight,
                                                               itemWidth,
                                                               _items[index].height)];
                            _items[index].alpha = 1.0f;
                        }
                    }
                } completion:^(BOOL finished) {
                    __strong __typeof(self) self = weakSelf;
                    if (self) {
                        self.isScrolling = NO;
                        [self repeatWithAnimationFinished:finished];
                    }
                }];
            } else {
                UIViewAnimationOptions animationOptions = UIViewAnimationOptionCurveEaseInOut;
                if (_timeIntervalPerScroll <= 0.0) {
                    // smooth animation
                    animationOptions = UIViewAnimationOptionCurveLinear;
                }
                __weak __typeof(self) weakSelf = self;
                [UIView animateWithDuration:_timeDurationPerScroll delay:0.0 options:animationOptions animations:^{
                    for (int i = 0; i < _items.count; i++) {
                        int index = (i + _firstItemIndex) % _items.count;
                        if (i == 0) {
                            continue;
                        } else if (i == 1) {
                            [_items[index] setFrame:CGRectMake(0.0f, -itemHeight, itemWidth, itemHeight)];
                        } else {
                            [_items[index] setFrame:CGRectMake(0.0f, itemHeight * (i - 2), itemWidth, itemHeight)];
                        }
                    }
                } completion:^(BOOL finished) {
                    __strong __typeof(self) self = weakSelf;
                    if (self) {
                        self.isScrolling = NO;
                        [self repeatWithAnimationFinished:finished];
                    }
                }];
            }

            [self moveToNextItemIndex];
        }
    });
}

#pragma mark - Data source(private)
- (void)moveToNextDataIndex {
    NSUInteger dataCount = 0;
    if ([_delegate respondsToSelector:@selector(numberOfDataForMarqueeView:)]) {
        dataCount = [_delegate numberOfDataForMarqueeView:self];
    }

    if (dataCount <= 0) {
        self.dataIndex = -1;
    } else {
        self.dataIndex = _dataIndex + 1;
        if (_dataIndex < 0 || _dataIndex > dataCount - 1) {
            self.dataIndex = 0;
        }
    }
}

#pragma mark - Touch handler(private)
- (void)resetTouchReceiver {
    if (_touchEnabled) {
        if (!_touchReceiver) {
            self.touchReceiver = [[UUMarqueeViewTouchReceiver alloc] init];
            _touchReceiver.touchDelegate = self;
            [self addSubview:_touchReceiver];
        } else {
            [self bringSubviewToFront:_touchReceiver];
        }
    } else {
        if (_touchReceiver) {
            [_touchReceiver removeFromSuperview];
            self.touchReceiver = nil;
        }
    }
}

#pragma mark - UUMarqueeViewTouchResponder(private)
- (void)touchesBegan {
    self.isPausingBeforeTouchesBegan = _isScrollNeedsToStop;
    [self pause];
}

- (void)touchesEndedAtPoint:(CGPoint)point {
    for (UUMarqueeItemView *itemView in _items) {
        if ([itemView.layer.presentationLayer hitTest:point]) {
            NSUInteger dataCount = 0;
            if ([_delegate respondsToSelector:@selector(numberOfDataForMarqueeView:)]) {
                dataCount = [_delegate numberOfDataForMarqueeView:self];
            }

            if (dataCount > 0 && itemView.tag >= 0 && itemView.tag < dataCount) {
                if ([self.delegate respondsToSelector:@selector(didTouchItemViewAtIndex:forMarqueeView:)]) {
                    [self.delegate didTouchItemViewAtIndex:itemView.tag forMarqueeView:self];
                }
            }
            break;
        }
    }
    if (!_isPausingBeforeTouchesBegan) {
        [self start];
    }
}

- (void)touchesCancelled {
    if (!_isPausingBeforeTouchesBegan) {
        [self start];
    }
}

@end

#pragma mark - UUMarqueeViewTouchReceiver(private)
@implementation UUMarqueeViewTouchReceiver

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_touchDelegate) {
        [_touchDelegate touchesBegan];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    if (_touchDelegate) {
        [_touchDelegate touchesEndedAtPoint:touchLocation];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_touchDelegate) {
        [_touchDelegate touchesCancelled];
    }
}

@end

#pragma mark - UUMarqueeItemView(Private)
@implementation UUMarqueeItemView

- (void)clear {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _didFinishCreate = NO;
}

@end
