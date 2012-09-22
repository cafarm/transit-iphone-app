//
//  TAStepScrollView.h
//  Transit
//
//  Created by Mark Cafaro on 8/3/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAStepView;

@protocol TAStepScrollViewDataSource;
@protocol TAStepScrollViewDelegate;

@interface TAStepScrollView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <TAStepScrollViewDataSource> dataSource;
@property (weak, nonatomic) id <TAStepScrollViewDelegate> delegate;

- (void)scrollToStepAtIndex:(NSInteger)index animated:(BOOL)animated;

// Used by the delegate to acquire an already allocated step, instead of allocating a new one
- (TAStepView *)dequeueReusableStepWithIdentifier:(NSString *)identifier;

- (void)reloadData;

@end


@protocol TAStepScrollViewDataSource <NSObject>

@required

// Step display. Implementers should *always* try to reuse stepViews by setting each step's reuseIdentifier.
// This mechanism works the same as in UITableViewCells.
- (TAStepView *)stepScrollView:(TAStepScrollView *)scrollView viewForStepAtIndex:(NSInteger)index;

@optional

// Default is 1 if not implemented
- (NSInteger)numberOfStepsInScrollView:(TAStepScrollView *)scrollView;

@end


@protocol TAStepScrollViewDelegate <NSObject, UIScrollViewDelegate>

@optional

// Dragging
- (void)stepScrollViewWillBeginDragging:(TAStepScrollView *)scrollView;
- (void)stepScrollViewDidEndDragging:(TAStepScrollView *)scrollView willDecelerate:(BOOL)decelerate;

// Deceleration
- (void)stepScrollViewWillBeginDecelerating:(TAStepScrollView *)scrollView;
- (void)stepScrollViewDidEndDecelerating:(TAStepScrollView *)scrollView;

// Called before the step scrolls into the center of the view
- (void)stepScrollView:(TAStepScrollView *)scrollView willScrollToStep:(TAStepView *)step atIndex:(NSInteger)index;

// Called after the step scrolls into the center of the view
- (void)stepScrollView:(TAStepScrollView *)scrollView didScrollToStep:(TAStepView *)step atIndex:(NSInteger)index;

@end