//
//  UUMarqueeView.h
//  UUMarqueeView
//
//  Created by youyou on 16/12/5.
//  Copyright © 2016年 iceyouyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UUMarqueeView;

typedef NS_ENUM(NSUInteger, UUMarqueeViewDirection) {
    UUMarqueeViewDirectionUpward,   // scroll from bottom to top
    UUMarqueeViewDirectionLeftward  // scroll from right to left
};

#pragma mark - UUMarqueeViewDelegate
@protocol UUMarqueeViewDelegate <NSObject>
- (NSUInteger)numberOfDataForMarqueeView:(UUMarqueeView*)marqueeView;
- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView;
- (void)updateItemView:(UIView*)itemView atIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView;
@optional
- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView;   // only for [UUMarqueeViewDirectionUpward]
- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView;   // only for [UUMarqueeViewDirectionLeftward]
- (CGFloat)itemViewHeightAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView;   // only for [UUMarqueeViewDirectionUpward] and [useDynamicHeight = YES]
- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView;
@end

#pragma mark - UUMarqueeView
@interface UUMarqueeView : UIView
@property (nonatomic, weak) id<UUMarqueeViewDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval timeIntervalPerScroll;
@property (nonatomic, assign) NSTimeInterval timeDurationPerScroll; // only for [UUMarqueeViewDirectionUpward] and [useDynamicHeight = NO]
@property (nonatomic, assign) BOOL useDynamicHeight;    // only for [UUMarqueeViewDirectionUpward]
@property (nonatomic, assign) float scrollSpeed;    // only for [UUMarqueeViewDirectionLeftward] or [UUMarqueeViewDirectionUpward] with [useDynamicHeight = YES]
@property (nonatomic, assign) float itemSpacing;    // only for [UUMarqueeViewDirectionLeftward]
@property (nonatomic, assign) BOOL stopWhenLessData;    // do not scroll when all data has been shown
@property (nonatomic, assign) BOOL clipsToBounds;
@property (nonatomic, assign, getter=isTouchEnabled) BOOL touchEnabled;
@property (nonatomic, assign) UUMarqueeViewDirection direction;
- (instancetype)initWithDirection:(UUMarqueeViewDirection)direction;
- (instancetype)initWithFrame:(CGRect)frame direction:(UUMarqueeViewDirection)direction;
- (void)reloadData;
- (void)start;
- (void)pause;
@end

#pragma mark - UUMarqueeViewTouchResponder(Private)
@protocol UUMarqueeViewTouchResponder <NSObject>
- (void)touchesBegan;
- (void)touchesEndedAtPoint:(CGPoint)point;
- (void)touchesCancelled;
@end

#pragma mark - UUMarqueeViewTouchReceiver(Private)
@interface UUMarqueeViewTouchReceiver : UIView
@property (nonatomic, weak) id<UUMarqueeViewTouchResponder> touchDelegate;
@end

#pragma mark - UUMarqueeItemView(Private)
@interface UUMarqueeItemView : UIView   // UUMarqueeItemView's [tag] is the index of data source. if none data source then [tag] is -1
@property (nonatomic, assign) BOOL didFinishCreate;
@property (nonatomic, assign) CGFloat width;    // cache the item width, only for [UUMarqueeViewDirectionLeftward]
@property (nonatomic, assign) CGFloat height;   // cache the item height, only for [UUMarqueeViewDirectionUpward]
- (void)clear;
@end
