//
//  UUMarqueeView.h
//  UUMarqueeView
//
//  Created by youyou on 16/12/5.
//  Copyright © 2016年 iceyouyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UUMarqueeView;

#pragma mark - UUMarqueeViewDelegate
@protocol UUMarqueeViewDelegate <NSObject>
- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView;
- (NSArray*)dataSourceArrayForMarqueeView:(UUMarqueeView*)marqueeView;
- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView;
- (void)updateItemView:(UIView*)itemView withData:(id)data forMarqueeView:(UUMarqueeView*)marqueeView;
@optional
- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView;   // if you ever changed data source array, becareful in using the index.
@end

#pragma mark - UUMarqueeView
@interface UUMarqueeView : UIView
@property (nonatomic, weak) id<UUMarqueeViewDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval timeIntervalPerScroll;
@property (nonatomic, assign) NSTimeInterval timeDurationPerScroll;
@property (nonatomic, assign) BOOL clipsToBounds;
@property (nonatomic, assign, getter=isTouchEnabled) BOOL touchEnabled;
- (void)reloadData;
- (void)start;
- (void)pause;
@end

#pragma mark - UUMarqueeViewTouchResponder(Private)
@protocol UUMarqueeViewTouchResponder <NSObject>
- (void)touchAtPoint:(CGPoint)point;
@end

#pragma mark - UUMarqueeViewTouchReceiver(Private)
@interface UUMarqueeViewTouchReceiver : UIView
@property (nonatomic, weak) id<UUMarqueeViewTouchResponder> touchDelegate;
@end
