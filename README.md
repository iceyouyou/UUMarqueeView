# UUMarqueeView
Customizable marquee view for iOS

## Demo
![UUMarqueeView](https://raw.githubusercontent.com/iceyouyou/UUMarqueeView/master/extra/demo.gif)

## Usage
Create the marquee view by:
```objective-c
self.marqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(20.0f, 40.0f, CGRectGetWidth(self.view.bounds) - 40.0f, 20.0f)];
self.marqueeView.delegate = self;
self.marqueeView.timeIntervalPerScroll = 2.0f;
self.marqueeView.timeDurationPerScroll = 1.0f;
[self.view addSubview:self.marqueeView];
[self.marqueeView reloadData];
```

Then implement `UUMarqueeViewDelegate` protocol:
```objective-c
@protocol UUMarqueeViewDelegate <NSObject>
@optional
- (NSInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView;
- (NSArray*)dataSourceArrayForMarqueeView:(UUMarqueeView*)marqueeView;
- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView;
- (void)updateItemView:(UIView*)itemView withData:(id)data forMarqueeView:(UUMarqueeView*)marqueeView;
@end
```

Sample code:
```objective-c
- (NSInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView {
    // set a row count that you want to display.
    return 1;
}

- (NSArray*)dataSourceArrayForMarqueeView:(UUMarqueeView*)marqueeView {
    // set an array that contains all data you want to show.
    // you can set an array variable as well and change it's content at any time.
    return @[@"Data A",
             @"Data B",
             @"Data C"];
}

- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView {
    // add any subviews you want but do not set any content.
    // this will be called to create every row view in '-(void)reloadData'.
    // ### give a tag on all of your changeable subviews then you can find it later.
    UILabel *content = [[UILabel alloc] initWithFrame:itemView.bounds];
    content.font = [UIFont systemFontOfSize:10.0f];
    content.tag = 1001;
    [itemView addSubview:content];
}

- (void)updateItemView:(UIView*)itemView withData:(id)data forMarqueeView:(UUMarqueeView*)marqueeView {
    // set content to subviews, this will be called on each time the MarqueeView scrolls.
    // 'data' is the element of data source array which set in '-(NSArray*)dataSourceArrayForMarqueeView:'.
    UILabel *content = [itemView viewWithTag:1001];
    content.text = data;
}
```

## Compatibility
- Requires ARC.
- Supports iOS7+.

## Additional
Using NSWeakTimer to avoid retain cycle problem.  
MSWeakTimer Github page: https://github.com/mindsnacks/MSWeakTimer

## License
`UUMarqueeView` is available under the MIT license. See the LICENSE file for more info.