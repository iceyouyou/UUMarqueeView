//
//  UUMarqueeView.m
//  UUMarqueeView
//
//  Created by youyou on 16/12/5.
//  Copyright © 2016年 iceyouyou. All rights reserved.
//

#import "UUMarqueeView.h"
#import "MSWeakTimer.h"

@interface UUMarqueeView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger visibleItemCount;
@property (nonatomic, strong) NSMutableArray<UIView*> *items;
@property (nonatomic, assign) int topItemIndex;
@property (nonatomic, assign) int dataIndex;
@property (nonatomic, strong) MSWeakTimer *scrollTimer;

@end

@implementation UUMarqueeView

static NSInteger DEFAULT_VISIBLE_ITEM_COUNT = 2;
static NSTimeInterval DEFAULT_TIME_INTERVAL = 4.0;
static NSTimeInterval DEFAULT_TIME_DURATION = 1.0;

- (instancetype)init {
    self = [super init];
    if (self) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];

        _timeIntervalPerScroll = DEFAULT_TIME_INTERVAL;
        _timeDurationPerScroll = DEFAULT_TIME_DURATION;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];

        _timeIntervalPerScroll = DEFAULT_TIME_INTERVAL;
        _timeDurationPerScroll = DEFAULT_TIME_DURATION;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.contentView setFrame:self.bounds];
    [self repositionItemViews];
}

- (void)reloadData {
    [self pause];

    if (_items) {
        [_items makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_items removeAllObjects];
    } else {
        _items = [NSMutableArray array];
    }

    if ([_delegate respondsToSelector:@selector(numberOfVisibleItemsForMarqueeView:)]) {
        _visibleItemCount = [_delegate numberOfVisibleItemsForMarqueeView:self];
        if (_visibleItemCount <= 0) {
            return;
        }
    } else {
        _visibleItemCount = DEFAULT_VISIBLE_ITEM_COUNT;
    }

    _dataIndex = 0;

    for (int i = 0; i < _visibleItemCount + 2; i++) {
        UIView *itemView = [[UIView alloc] init];
        [_contentView addSubview:itemView];
        [_items addObject:itemView];
    }
    _topItemIndex = 0;

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
            if ([_delegate respondsToSelector:@selector(updateItemView:withData:forMarqueeView:)]) {
                [_delegate updateItemView:_items[index] withData:[self nextData] forMarqueeView:self];
            }
        }
    }

    [self start];
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

- (void)start {
    if (_scrollTimer || _items.count <= 0) {
        return;
    }

    [self scrollTimerDidFire:nil];
    _scrollTimer = [MSWeakTimer scheduledTimerWithTimeInterval:_timeIntervalPerScroll
                                                        target:self
                                                      selector:@selector(scrollTimerDidFire:)
                                                      userInfo:nil
                                                       repeats:YES
                                                 dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)pause {
    if (_scrollTimer) {
        [_scrollTimer invalidate];
        _scrollTimer = nil;
    }
}

- (void)scrollTimerDidFire:(MSWeakTimer *)timer {
    dispatch_async(dispatch_get_main_queue(), ^() {
        CGFloat itemWidth = CGRectGetWidth(self.frame);
        CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;

        // move the top item to bottom without animation
        [_items[_topItemIndex] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, itemHeight)];
        if ([_delegate respondsToSelector:@selector(updateItemView:withData:forMarqueeView:)]) {
            [_delegate updateItemView:_items[_topItemIndex] withData:[self nextData] forMarqueeView:self];
        }

        [UIView animateWithDuration:_timeDurationPerScroll animations:^{
            for (int i = 0; i < _items.count; i++) {
                int index = (i + _topItemIndex) % _items.count;
                if (i == 0) {
                    continue;
                } else if (i == 1) {
                    [_items[index] setFrame:CGRectMake(0.0f, -itemHeight, itemWidth, itemHeight)];
                } else {
                    [_items[index] setFrame:CGRectMake(0.0f, itemHeight * (i - 2), itemWidth, itemHeight)];
                }
            }
        } completion:^(BOOL finished) {
            [self moveToNextItemIndex];
        }];
    });
}

- (int)itemIndexWithOffsetFromTop:(int)offsetFromTop {
    return (_topItemIndex + offsetFromTop) % (_visibleItemCount + 2);
}

- (void)moveToNextItemIndex {
    if (_topItemIndex >= _items.count - 1) {
        _topItemIndex = 0;
    } else {
        _topItemIndex++;
    }
}

- (id)nextData {
    NSArray *dataSourceArray = nil;
    if ([_delegate respondsToSelector:@selector(dataSourceArrayForMarqueeView:)]) {
        dataSourceArray = [_delegate dataSourceArrayForMarqueeView:self];
    }

    if (!dataSourceArray) {
        return nil;
    }

    if (_dataIndex < 0 || _dataIndex > dataSourceArray.count - 1) {
        _dataIndex = 0;
    }
    return dataSourceArray[_dataIndex++];
}

- (void)dealloc {
    if (self.scrollTimer) {
        [self.scrollTimer invalidate];
        self.scrollTimer = nil;
    }
}

@end
