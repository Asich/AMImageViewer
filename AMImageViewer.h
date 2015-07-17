//
// Created by Mustafin Askar on 30/11/14.
// Copyright (c) 2014 Asich. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMImageViewer : UIView <UIGestureRecognizerDelegate>

- (id)initWithImageUrls:(NSArray *)imageUrls;
- (void)openPage:(NSString *)imgUrlString;
- (void)show;
- (void)hide;

@end