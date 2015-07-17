//
// Created by Mustafin Askar on 30/11/14.
// Copyright (c) 2014 Asich. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "AMImageViewer.h"

@interface AMImageViewer() {
    CGFloat touchBeganY;
    BOOL isStartColing;
    CGPoint center;

    CGPoint lastOffset;
    NSTimeInterval lastOffsetCapture;
    BOOL isScrollingFast;
}
@property (nonatomic, strong) NSArray *imageUrls;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@end

@implementation AMImageViewer {}

- (id)initWithImageUrls:(NSArray *)imageUrls {
    if (self = [super initWithFrame:CGRectMake(0, 0, [self screenWidth], [self screenHeight])]) {
        self.imageUrls = imageUrls;
        [self configUI];
    }
    return self;
}

#pragma mark - config ui

- (void)configUI {
    __weak AMImageViewer *wSelf = self;

    CGFloat viewFrameWidth = [ASize screenWidth] + 20;

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewFrameWidth, [ASize screenHeight])];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    [self addSubview:self.scrollView];

    wSelf.scrollView.contentSize = CGSizeMake(viewFrameWidth * self.imageUrls.count, wSelf.scrollView.height);
    self.scrollView.contentOffset = CGPointMake(viewFrameWidth, 0);

    __block CGFloat rightInset = 0.0;
    for (NSString *imageUrls in self.imageUrls) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.height = self.scrollView.height;
        imageView.width = [ASize screenWidth];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrls] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imageView.x = rightInset;
            rightInset += viewFrameWidth;
        }];
        [self.scrollView addSubview:imageView];

        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        self.panGestureRecognizer.delegate = self;
        [imageView addGestureRecognizer:self.panGestureRecognizer];

        center = self.panGestureRecognizer.view.center;
    }
}

- (void)handleSwipeGesture:(UIPanGestureRecognizer *)pgr {
    CGPoint pointInView = [pgr locationInView:self];

    switch (pgr.state) {
        case UIGestureRecognizerStateBegan :  {
            touchBeganY = [pgr locationInView:self].y;
            break;

        } case UIGestureRecognizerStateChanged : {
            CGFloat dif = touchBeganY - pointInView.y;
            pgr.view.y = pgr.view.y - dif;
            touchBeganY = pointInView.y;

            CGFloat alpha = 1 - (abs((int) (center.y - pgr.view.center.y)) / center.y);
            self.scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];

            break;
        } case UIGestureRecognizerStateEnded : {
            CGPoint gestureVelocity = [pgr velocityInView:self];
            if (abs((int) gestureVelocity.y) > 300) {
                NSLog(@"fast");
                if (!isStartColing) {
                    [self hide];
                }
                break;
            }

            if (pgr.view.centerY < self.height / 5 || pgr.view.centerY > self.height - self.height / 5) {
                if (!isStartColing) {
                    [self hide];
                }
            } else {
                self.scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
                [UIView animateWithDuration:0.2 animations:^{
                    pgr.view.y = (CGFloat) (( self.scrollView.height - pgr.view.height ) * 0.5);
                }];
            }
            break;
        } default: break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [(UIPanGestureRecognizer *) gestureRecognizer velocityInView:self.scrollView];
        return fabs(velocity.x) < fabs(velocity.y);
    }
    return YES;
}

#pragma mark - show/hide animations

- (void)openPage:(NSString *)imgUrlString {
    NSInteger pageNumber = 0;
    for (int i = 0; i < self.imageUrls.count; i++) {
        NSString *string = self.imageUrls[i];
        if ([imgUrlString isEqualToString:string]) {
            pageNumber = i;
            break;
        }
    }


    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * pageNumber;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:NO];
}

- (void)show {
    [[self delegateWindow] addSubview:self];
    self.scrollView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)hide {
    isStartColing = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - helpers

- (CGFloat)screenWidth {
    return [self screenSize].width;
}

- (CGFloat)screenHeight {
    return [self screenSize].height;
}

- (CGSize) screenSize {
    return [self screenSizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGSize) screenSizeInOrientation:(UIInterfaceOrientation)orientation {
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        size = CGSizeMake(size.height, size.width);
    }
    return size;
}

-(UIWindow *)delegateWindow {
    return [[[UIApplication sharedApplication] delegate] window];
}

#pragma mark - dealloc

- (void)dealloc {
    NSLog(@"AMImageViewer dealloced");
}

@end