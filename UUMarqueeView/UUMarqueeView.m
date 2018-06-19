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
@property (nonatomic, strong) NSMutableArray<UIView*> *items;
@property (nonatomic, assign) int firstItemIndex;
@property (nonatomic, assign) int dataIndex;
@property (nonatomic, strong) NSTimer *scrollTimer;
@property (nonatomic, strong) UUMarqueeViewTouchReceiver *touchReceiver;

@end

@implementation UUMarqueeView

static NSInteger const DEFAULT_VISIBLE_ITEM_COUNT = 2;
static NSTimeInterval const DEFAULT_TIME_INTERVAL = 4.0;
static NSTimeInterval const DEFAULT_TIME_DURATION = 1.0;
static float const DEFAULT_SCROLL_SPEED = 40.0f;
static float const DEFAULT_ITEM_SPACING = 20.0f;

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

        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
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

        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
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
    [self pause];
    [self resetAll];
    [self startAfterTimeInterval:YES];
}

- (void)start {
    [self startAfterTimeInterval:NO];
}

- (void)pause {
    if (_scrollTimer) {
        [_scrollTimer invalidate];
        self.scrollTimer = nil;
    }
}

- (void)repeat {
    [self pause];
    [self startAfterTimeInterval:YES];
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
        UIView *itemView = [[UIView alloc] init];
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

                if ([_delegate respondsToSelector:@selector(createItemView:forMarqueeView:)]) {
                    [_delegate createItemView:_items[index] forMarqueeView:self];
                }
            } else  {
                [self moveToNextDataIndex];
                _items[index].tag = _dataIndex;

                if ([_delegate respondsToSelector:@selector(itemViewWidthAtIndex:forMarqueeView:)]) {
                    itemWidth = MAX([_delegate itemViewWidthAtIndex:_items[index].tag forMarqueeView:self] + DEFAULT_ITEM_SPACING, itemWidth);
                }

                [_items[index] setFrame:CGRectMake(lastMaxX, 0.0f, itemWidth, itemHeight)];
                lastMaxX = lastMaxX + itemWidth;

                if ([_delegate respondsToSelector:@selector(createItemView:forMarqueeView:)]) {
                    [_delegate createItemView:_items[index] forMarqueeView:self];
                }

                if ([_delegate respondsToSelector:@selector(updateItemView:atIndex:forMarqueeView:)]) {
                    [_delegate updateItemView:_items[index] atIndex:_items[index].tag forMarqueeView:self];
                }
            }
        }
    } else {
        [self repositionItemViews];

        for (int i = 0; i < _items.count; i++) {
            int index = (i + _firstItemIndex) % _items.count;
            if (i == 0) {
                if ([_delegate respondsToSelector:@selector(createItemView:forMarqueeView:)]) {
                    [_delegate createItemView:_items[index] forMarqueeView:self];
                }
                _items[index].tag = _dataIndex;
            } else  {
                if ([_delegate respondsToSelector:@selector(createItemView:forMarqueeView:)]) {
                    [_delegate createItemView:_items[index] forMarqueeView:self];
                }
                [self moveToNextDataIndex];
                _items[index].tag = _dataIndex;
                if ([_delegate respondsToSelector:@selector(updateItemView:atIndex:forMarqueeView:)]) {
                    [_delegate updateItemView:_items[index] atIndex:_items[index].tag forMarqueeView:self];
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

            CGFloat itemWidth = CGRectGetWidth(self.frame);
            if (_items[index].tag != -1) {
                if ([_delegate respondsToSelector:@selector(itemViewWidthAtIndex:forMarqueeView:)]) {
                    itemWidth = MAX([_delegate itemViewWidthAtIndex:_items[index].tag forMarqueeView:self] + DEFAULT_ITEM_SPACING, itemWidth);
                }
            }

            if (i == 0) {
                [_items[index] setFrame:CGRectMake(-itemWidth, 0.0f, itemWidth, itemHeight)];
                lastMaxX = 0.0f;
            } else {
                [_items[index] setFrame:CGRectMake(lastMaxX, 0.0f, itemWidth, itemHeight)];
                lastMaxX = lastMaxX + itemWidth;
            }
        }
    } else {
        CGFloat itemWidth = CGRectGetWidth(self.frame);
        CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;
        for (int i = 0; i < _items.count; i++) {
            int index = (i + _firstItemIndex) % _items.count;
            if (i == 0) {
                [_items[index] setFrame:CGRectMake(0.0f, -itemHeight, itemWidth, itemHeight)];
            } else if (i == _items.count - 1) {
                [_items[index] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, itemHeight)];
            } else {
                [_items[index] setFrame:CGRectMake(0.0f, itemHeight * (i - 1), itemWidth, itemHeight)];
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

#pragma mark - Timer & Animation(private)
- (void)startAfterTimeInterval:(BOOL)afterTimeInterval {
    if (_scrollTimer || _items.count <= 0) {
        return;
    }

    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:afterTimeInterval ? _timeIntervalPerScroll : 0.0
                                                        target:self
                                                      selector:@selector(scrollTimerDidFire:)
                                                      userInfo:nil
                                                       repeats:NO];
}

- (void)scrollTimerDidFire:(NSTimer *)timer {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (_direction == UUMarqueeViewDirectionLeftward) {
            [self moveToNextDataIndex];
            if (_dataIndex < 0) {
                return;
            }

            CGFloat itemHeight = CGRectGetHeight(self.frame);
            CGFloat firstItemWidth = CGRectGetWidth(self.frame);
            CGFloat currentItemWidth = CGRectGetWidth(self.frame);
            CGFloat lastItemWidth = CGRectGetWidth(self.frame);
            for (int i = 0; i < _items.count; i++) {
                int index = (i + _firstItemIndex) % _items.count;

                CGFloat itemWidth = CGRectGetWidth(self.frame);
                if (_items[index].tag != -1) {
                    if ([_delegate respondsToSelector:@selector(itemViewWidthAtIndex:forMarqueeView:)]) {
                        itemWidth = MAX([_delegate itemViewWidthAtIndex:_items[index].tag forMarqueeView:self] + DEFAULT_ITEM_SPACING, itemWidth);
                    }
                }

                if (i == 0) {
                    firstItemWidth = itemWidth;
                } else if (i == 1) {
                    currentItemWidth = itemWidth;
                } else {
                    lastItemWidth = itemWidth;
                }
            }

            // move the top item to bottom without animation
            _items[_firstItemIndex].tag = _dataIndex;
            CGFloat nextItemWidth = CGRectGetWidth(self.frame);
            if ([_delegate respondsToSelector:@selector(itemViewWidthAtIndex:forMarqueeView:)]) {
                nextItemWidth = MAX([_delegate itemViewWidthAtIndex:_items[_firstItemIndex].tag forMarqueeView:self] + DEFAULT_ITEM_SPACING, nextItemWidth);
            }
            [_items[_firstItemIndex] setFrame:CGRectMake(lastItemWidth, 0.0f, nextItemWidth, itemHeight)];
            if (firstItemWidth != nextItemWidth) {
                // if the width of next item view changes, then recreate it by delegate
                if ([_delegate respondsToSelector:@selector(createItemView:forMarqueeView:)]) {
                    [_items[_firstItemIndex].subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                    [_delegate createItemView:_items[_firstItemIndex] forMarqueeView:self];
                }
            }
            if ([_delegate respondsToSelector:@selector(updateItemView:atIndex:forMarqueeView:)]) {
                [_delegate updateItemView:_items[_firstItemIndex] atIndex:_items[_firstItemIndex].tag forMarqueeView:self];
            }

            [UIView animateWithDuration:(currentItemWidth / _scrollSpeed) delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                CGFloat lastMaxX = 0.0f;
                for (int i = 0; i < _items.count; i++) {
                    int index = (i + _firstItemIndex) % _items.count;

                    CGFloat itemWidth = CGRectGetWidth(self.frame);
                    if (_items[index].tag != -1) {
                        if ([_delegate respondsToSelector:@selector(itemViewWidthAtIndex:forMarqueeView:)]) {
                            itemWidth = MAX([_delegate itemViewWidthAtIndex:_items[index].tag forMarqueeView:self] + DEFAULT_ITEM_SPACING, itemWidth);
                        }
                    }

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
                if (_scrollTimer) {
                    [self repeat];
                }
            }];
            [self moveToNextItemIndex];
        } else {
            [self moveToNextDataIndex];
            if (_dataIndex < 0) {
                return;
            }

            CGFloat itemWidth = CGRectGetWidth(self.frame);
            CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;

            // move the top item to bottom without animation
            _items[_firstItemIndex].tag = _dataIndex;
            [_items[_firstItemIndex] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, itemHeight)];
            if ([_delegate respondsToSelector:@selector(updateItemView:atIndex:forMarqueeView:)]) {
                [_delegate updateItemView:_items[_firstItemIndex] atIndex:_items[_firstItemIndex].tag forMarqueeView:self];
            }

            [UIView animateWithDuration:_timeDurationPerScroll animations:^{
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
                if (_scrollTimer) {
                    [self repeat];
                }
            }];
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

    self.dataIndex = _dataIndex + 1;
    if (_dataIndex < 0 || _dataIndex > dataCount - 1) {
        self.dataIndex = 0;
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
- (void)touchAtPoint:(CGPoint)point {
    for (UIView *itemView in _items) {
        if ([itemView.layer.presentationLayer hitTest:point]) {
            if ([self.delegate respondsToSelector:@selector(didTouchItemViewAtIndex:forMarqueeView:)]) {
                [self.delegate didTouchItemViewAtIndex:itemView.tag forMarqueeView:self];
            }
            break;
        }
    }
}

@end

#pragma mark - UUMarqueeViewTouchReceiver(private)
@implementation UUMarqueeViewTouchReceiver

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    if (_touchDelegate) {
        [_touchDelegate touchAtPoint:touchLocation];
    }
}

@end
