//
//  UUMarqueeView.m
//  UUMarqueeView
//
//  Created by youyou on 16/12/5.
//  Copyright © 2016年 iceyouyou. All rights reserved.
//

#import "UUMarqueeView.h"
#import "MSWeakTimer.h"

@interface UUMarqueeView () <UUMarqueeViewTouchResponder>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger visibleItemCount;
@property (nonatomic, strong) NSMutableArray<UIView*> *items;
@property (nonatomic, assign) int topItemIndex;
@property (nonatomic, assign) int dataIndex;
@property (nonatomic, strong) MSWeakTimer *scrollTimer;
@property (nonatomic, strong) UUMarqueeViewTouchReceiver *touchReceiver;

@end

@implementation UUMarqueeView

static NSInteger const DEFAULT_VISIBLE_ITEM_COUNT = 2;
static NSTimeInterval const DEFAULT_TIME_INTERVAL = 4.0;
static NSTimeInterval const DEFAULT_TIME_DURATION = 1.0;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];

        self.timeIntervalPerScroll = DEFAULT_TIME_INTERVAL;
        self.timeDurationPerScroll = DEFAULT_TIME_DURATION;
        self.touchEnabled = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];

        self.timeIntervalPerScroll = DEFAULT_TIME_INTERVAL;
        self.timeDurationPerScroll = DEFAULT_TIME_DURATION;
        self.touchEnabled = NO;
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
    self.topItemIndex = 0;

    if (_items) {
        [_items makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_items removeAllObjects];
    } else {
        self.items = [NSMutableArray array];
    }

    if ([_delegate respondsToSelector:@selector(numberOfVisibleItemsForMarqueeView:)]) {
        self.visibleItemCount = [_delegate numberOfVisibleItemsForMarqueeView:self];
        if (_visibleItemCount <= 0) {
            return;
        }
    } else {
        self.visibleItemCount = DEFAULT_VISIBLE_ITEM_COUNT;
    }

    for (int i = 0; i < _visibleItemCount + 2; i++) {
        UIView *itemView = [[UIView alloc] init];
        [_contentView addSubview:itemView];
        [_items addObject:itemView];
    }

    [self repositionItemViews];

    for (int i = 0; i < _items.count; i++) {
        int index = (i + _topItemIndex) % _items.count;
        if (i == 0) {
            if ([_delegate respondsToSelector:@selector(createItemView:forMarqueeView:)]) {
                [_delegate createItemView:_items[index] forMarqueeView:self];
            }
        } else  {
            if ([_delegate respondsToSelector:@selector(createItemView:forMarqueeView:)]) {
                [_delegate createItemView:_items[index] forMarqueeView:self];
            }
            id data = [self nextData];
            _items[index].tag = _dataIndex;
            if ([_delegate respondsToSelector:@selector(updateItemView:withData:forMarqueeView:)]) {
                [_delegate updateItemView:_items[index] withData:data forMarqueeView:self];
            }
        }
    }

    [self resetTouchReceiver];
}

- (void)repositionItemViews {
    CGFloat itemWidth = CGRectGetWidth(self.frame);
    CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;
    for (int i = 0; i < _items.count; i++) {
        int index = (i + _topItemIndex) % _items.count;
        if (i == 0) {
            [_items[index] setFrame:CGRectMake(0.0f, -itemHeight, itemWidth, itemHeight)];
        } else if (i == _items.count - 1) {
            [_items[index] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, itemHeight)];
        } else {
            [_items[index] setFrame:CGRectMake(0.0f, itemHeight * (i - 1), itemWidth, itemHeight)];
        }
    }
}

- (int)itemIndexWithOffsetFromTop:(int)offsetFromTop {
    return (_topItemIndex + offsetFromTop) % (_visibleItemCount + 2);
}

- (void)moveToNextItemIndex {
    if (_topItemIndex >= _items.count - 1) {
        self.topItemIndex = 0;
    } else {
        self.topItemIndex++;
    }
}

#pragma mark - Timer & Animation(private)
- (void)startAfterTimeInterval:(BOOL)afterTimeInterval {
    if (_scrollTimer || _items.count <= 0) {
        return;
    }

    if (!afterTimeInterval) {
        [self scrollTimerDidFire:nil];
    }
    self.scrollTimer = [MSWeakTimer scheduledTimerWithTimeInterval:_timeIntervalPerScroll
                                                            target:self
                                                          selector:@selector(scrollTimerDidFire:)
                                                          userInfo:nil
                                                           repeats:YES
                                                     dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)scrollTimerDidFire:(MSWeakTimer *)timer {
    dispatch_async(dispatch_get_main_queue(), ^() {
        CGFloat itemWidth = CGRectGetWidth(self.frame);
        CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;

        // move the top item to bottom without animation
        [_items[_topItemIndex] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, itemHeight)];
        id data = [self nextData];
        _items[_topItemIndex].tag = _dataIndex;
        if ([_delegate respondsToSelector:@selector(updateItemView:withData:forMarqueeView:)]) {
            [_delegate updateItemView:_items[_topItemIndex] withData:data forMarqueeView:self];
        }

        int currentTopItemIndex = _topItemIndex;
        [UIView animateWithDuration:_timeDurationPerScroll animations:^{
            for (int i = 0; i < _items.count; i++) {
                int index = (i + currentTopItemIndex) % _items.count;
                if (i == 0) {
                    continue;
                } else if (i == 1) {
                    [_items[index] setFrame:CGRectMake(0.0f, -itemHeight, itemWidth, itemHeight)];
                } else {
                    [_items[index] setFrame:CGRectMake(0.0f, itemHeight * (i - 2), itemWidth, itemHeight)];
                }
            }
        }];
        [self moveToNextItemIndex];
    });
}

#pragma mark - Data source(private)
- (id)nextData {
    NSArray *dataSourceArray = nil;
    if ([_delegate respondsToSelector:@selector(dataSourceArrayForMarqueeView:)]) {
        dataSourceArray = [_delegate dataSourceArrayForMarqueeView:self];
    }

    if (!dataSourceArray || dataSourceArray.count <= 0) {
        return nil;
    }

    self.dataIndex = self.dataIndex + 1;
    if (_dataIndex < 0 || _dataIndex > dataSourceArray.count - 1) {
        self.dataIndex = 0;
    }
    return dataSourceArray[self.dataIndex];
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
