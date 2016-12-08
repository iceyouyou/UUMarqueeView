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

## Compatibility
- Requires ARC.
- Supports iOS iOS7+.

## Additional
Using NSWeakTimer to avoid retain cycle problem.  
MSWeakTimer Github page: https://github.com/mindsnacks/MSWeakTimer

## License
`UUMarqueeView` is available under the MIT license. See the LICENSE file for more info.