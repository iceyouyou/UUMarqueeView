# UUMarqueeView
[![Build Status](https://travis-ci.org/iceyouyou/UUMarqueeView.svg?branch=master)](https://travis-ci.org/iceyouyou/UUMarqueeView)

Customizable marquee view for iOS. [Usage in English](#usage) / [中文使用方法](#使用方法)

## Demo
![UUMarqueeView](https://raw.githubusercontent.com/iceyouyou/UUMarqueeView/master/extra/demo.gif)

## Revision History
- 2018/08/15 - Add dynamic height support
- 2018/05/16 - Add leftward scrolling support
- 2017/06/20 - Add touch event handler
- 2016/12/08 - Basic marquee view function

## Usage
There are two scroll directions for a marquee view:
```objective-c
UUMarqueeViewDirectionUpward,   // scroll from bottom to top
UUMarqueeViewDirectionLeftward  // scroll from right to left
```

Create a upward scrolling marquee view by:
```objective-c
self.marqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(20.0f, 40.0f, 100.0f, 20.0f)];
self.marqueeView.delegate = self;
self.marqueeView.timeIntervalPerScroll = 2.0f;
self.marqueeView.timeDurationPerScroll = 1.0f;
self.marqueeView.touchEnabled = YES;	// Set YES if you want to handle touch event. Default is NO.
[self.view addSubview:self.marqueeView];
[self.marqueeView reloadData];
```

Or a leftward scrolling marquee view by:
```objective-c
self.marqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(20.0f, 40.0f, 100.0f, 20.0f) direction:UUMarqueeViewDirectionLeftward];
self.marqueeView.delegate = self;
self.marqueeView.timeIntervalPerScroll = 0.0f;
self.marqueeView.scrollSpeed = 60.0f;
self.marqueeView.itemSpacing = 20.0f;	// the minimum spacing between items
self.marqueeView.touchEnabled = YES;	// Set YES if you want to handle touch event. Default is NO.
[self.view addSubview:self.marqueeView];
[self.marqueeView reloadData];
```

Then implement `UUMarqueeViewDelegate` protocol:
```objective-c
@protocol UUMarqueeViewDelegate <NSObject>
- (NSUInteger)numberOfDataForMarqueeView:(UUMarqueeView*)marqueeView;
- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView;
- (void)updateItemView:(UIView*)itemView atIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView;
@optional
- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView;   // only for [UUMarqueeViewDirectionUpward]
- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView;   // only for [UUMarqueeViewDirectionLeftward]
- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView;
@end
```

Sample code:
```objective-c
- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView {
    // this will be called only when direction is [UUMarqueeViewDirectionUpward].
    // set a row count that you want to display.
    return 1;
}

- (NSUInteger)numberOfDataForMarqueeView:(UUMarqueeView*)marqueeView {
    // the count of data source array.
    // For example: if data source is @[@"A", @"B", @"C"]; then return 3.
    return 3;
}

- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView {
    // add any subviews you want but do not set any content.
    // this will be called to create every row view in '-(void)reloadData'.
    // ### give a tag on all of your changeable subviews then you can find it later('-(void)updateItemView:withData:forMarqueeView:').
    UILabel *content = [[UILabel alloc] initWithFrame:itemView.bounds];
    content.font = [UIFont systemFontOfSize:10.0f];
    content.tag = 1001;
    [itemView addSubview:content];
}

- (void)updateItemView:(UIView*)itemView atIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    // set content to subviews, this will be called on each time the MarqueeView scrolls.
    // 'index' is the index of data source array.
    UILabel *content = [itemView viewWithTag:1001];
    content.text = dataSource[index];
}

- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    // this will be called only when direction is [UUMarqueeViewDirectionLeftward].
    // give the width of item view when the data source setup.
    // ### is good to cache the width once and reuse it in next time. if you do so, remember to clear the cache when you chang the data source array.
    UILabel *content = [[UILabel alloc] init];
    content.font = [UIFont systemFontOfSize:10.0f];
    content.text = dataSource[index];
    return content.intrinsicContentSize.width;
}

- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    // if 'touchEnabled' is 'YES', this will call back when touch on the item view.
    // if you ever changed data source array, becareful in using the index.
    NSLog(@"Touch at index %lu", (unsigned long)index);
}
```

## 使用方法
marquee view可以指定两种滑动方向:
```objective-c
UUMarqueeViewDirectionUpward,   // 从下向上
UUMarqueeViewDirectionLeftward  // 从右向左
```

可通过以下代码创建一个[从下向上]滑动的marquee view:
```objective-c
self.marqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(20.0f, 40.0f, 100.0f, 20.0f)];
self.marqueeView.delegate = self;
self.marqueeView.timeIntervalPerScroll = 2.0f;	// 条目滑动间隔
self.marqueeView.timeDurationPerScroll = 1.0f;	// 条目滑动时间
self.marqueeView.touchEnabled = YES;	// 设置为YES可监听点击事件，默认值为NO
[self.view addSubview:self.marqueeView];
[self.marqueeView reloadData];
```

或以下代码创建一个[从右向左]滑动的marquee view:
```objective-c
self.marqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(20.0f, 40.0f, 100.0f, 20.0f) direction:UUMarqueeViewDirectionLeftward];
self.marqueeView.delegate = self;
self.marqueeView.timeIntervalPerScroll = 0.0f;	// 条目滑动间隔
self.marqueeView.scrollSpeed = 60.0f;	// 滑动速度
self.marqueeView.itemSpacing = 20.0f;	// 左右相邻两个条目的间距，当左侧条目内容的长度超出marquee view整体长度时有效
self.marqueeView.touchEnabled = YES;	// 设置为YES可监听点击事件，默认值为NO
[self.view addSubview:self.marqueeView];
[self.marqueeView reloadData];
```

实现 `UUMarqueeViewDelegate` protocol:
```objective-c
@protocol UUMarqueeViewDelegate <NSObject>
- (NSUInteger)numberOfDataForMarqueeView:(UUMarqueeView*)marqueeView;   // 数据源个数
- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView;   // 创建初始条目视图
- (void)updateItemView:(UIView*)itemView atIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView;   // 更新条目内容
@optional
- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView;   // 可视条目数量，仅[UUMarqueeViewDirectionUpward]时被调用
- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView;   // 条目显示指定内容后的宽度，仅[UUMarqueeViewDirectionLeftward]时被调用
- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView;   // 点击事件回调
@end
```

protocol示例代码:
```objective-c
- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView {
    // 指定可视条目的行数，仅[UUMarqueeViewDirectionUpward]时被调用。
    // 当[UUMarqueeViewDirectionLeftward]时行数固定为1。
    return 1;
}

- (NSUInteger)numberOfDataForMarqueeView:(UUMarqueeView*)marqueeView {
    // 指定数据源的个数。例:数据源是字符串数组@[@"A", @"B", @"C"]时，return 3。
    return 3;
}

- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView {
    // 在marquee view创建时（即'-(void)reloadData'调用后），用于创建条目视图的初始结构，可自行添加任意subview。
    // ### 给必要的subview添加tag，可在'-(void)updateItemView:withData:forMarqueeView:'调用时快捷获取并设置内容。
    UILabel *content = [[UILabel alloc] initWithFrame:itemView.bounds];
    content.font = [UIFont systemFontOfSize:10.0f];
    content.tag = 1001;
    [itemView addSubview:content];
}

- (void)updateItemView:(UIView*)itemView atIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    // 设定即将显示的条目内容，在每次marquee view滑动时被调用。
    // 'index'即为数据源数组的索引值。
    UILabel *content = [itemView viewWithTag:1001];
    content.text = dataSource[index];
}

- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    // 指定条目在显示数据源内容时的视图宽度，仅[UUMarqueeViewDirectionLeftward]时被调用。
    // ### 在数据源不变的情况下，宽度可以仅计算一次并缓存复用。
    UILabel *content = [[UILabel alloc] init];
    content.font = [UIFont systemFontOfSize:10.0f];
    content.text = dataSource[index];
    return content.intrinsicContentSize.width;
}

- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    // 点击事件回调。在'touchEnabled'设置为YES后，触发点击事件时被调用。
    NSLog(@"Touch at index %lu", (unsigned long)index);
}
```

## Compatibility
- Requires ARC.
- Supports iOS7+.

## License
`UUMarqueeView` is available under the MIT license. See the [LICENSE](LICENSE) file for more info.