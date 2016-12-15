//
//  UUMarqueeView.h
//  UUMarqueeView
//
//  Created by youyou on 16/12/5.
//  Copyright © 2016年 iceyouyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UUMarqueeView;
@protocol UUMarqueeViewDelegate;

@protocol UUMarqueeViewDelegate <NSObject>
- (NSInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView;
- (NSArray*)dataSourceArrayForMarqueeView:(UUMarqueeView*)marqueeView;
- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView;
- (void)updateItemView:(UIView*)itemView withData:(id)data forMarqueeView:(UUMarqueeView*)marqueeView;
@end

@interface UUMarqueeView : UIView

@property (nonatomic, weak) id<UUMarqueeViewDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval timeIntervalPerScroll;
@property (nonatomic, assign) NSTimeInterval timeDurationPerScroll;
@property (nonatomic, assign) BOOL clipsToBounds;

- (void)reloadData;
- (void)start;
- (void)pause;

@end
