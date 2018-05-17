# UUMarqueeView
Customizable marquee view for iOS

## Demo
![UUMarqueeView](https://raw.githubusercontent.com/iceyouyou/UUMarqueeView/master/extra/demo.gif)

## Revision History
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
    // ### give a tag on all of your changeable subviews then you can find it later(updateItemView:withData:forMarqueeView:).
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
    // is good to cache the width once and reuse it in next time. if you do so, remember to clear the cache when you chang the data source array.
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

## Compatibility
- Requires ARC.
- Supports iOS7+.

## License
`UUMarqueeView` is available under the MIT license. See the [LICENSE](LICENSE) file for more info.