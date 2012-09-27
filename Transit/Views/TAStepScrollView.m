//
//  TAStepScrollView.m
//  Transit
//
//  Created by Mark Cafaro on 8/3/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//
//  Modified from https://github.com/100grams/HGPageScrollView

#import <QuartzCore/QuartzCore.h>

#import "TAStepScrollView.h"
#import "TAStepView.h"

@interface TAStepScrollView()

@property (strong, nonatomic) NSMutableArray *visibleSteps;
@property (strong, nonatomic) NSMutableDictionary *reusableSteps;

@property (weak, nonatomic) UIScrollView *scrollView;

@property (nonatomic) NSInteger numberOfSteps;

@property (nonatomic) NSRange visibleIndexes;

@property (strong, nonatomic) TAStepView *selectedStep;

@property (nonatomic) BOOL isPendingDelegateDidScrollToStep;
@property (nonatomic) BOOL isPendingTapGestureCompletion;

@end


@implementation TAStepScrollView

@synthesize visibleSteps = _visibleSteps;
@synthesize reusableSteps = _reusableSteps;

@synthesize scrollView = _scrollView;

@synthesize numberOfSteps = _numberOfSteps;

@synthesize visibleIndexes = _visibleIndexes;

@synthesize selectedStep = _selectedStep;

@synthesize isPendingDelegateDidScrollToStep = _isPendingDelegateDidScrollToStep;
@synthesize isPendingTapGestureCompletion = _isPendingTapGestureCompletion;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        
        // Init internal data structures
        _visibleSteps = [[NSMutableArray alloc] initWithCapacity:3];
        _reusableSteps = [[NSMutableDictionary alloc] initWithCapacity:3]; 
        
        // Setup scrollView
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.clipsToBounds = NO;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.alwaysBounceHorizontal = YES;
        scrollView.delegate = self;
        _scrollView = scrollView;
        [self addSubview:scrollView];
        
        // Setup tap recognizer for tapping on the previous/next step
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handleTapGestureFrom:)];
        tapRecognizer.delegate = self;
        [scrollView addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)scrollToStepAtIndex:(NSInteger)index animated:(BOOL)animated
{
    CGPoint offset = CGPointMake(index * self.scrollView.frame.size.width, 0);
    [self.scrollView setContentOffset:offset animated:animated];
}

- (TAStepView *)dequeueReusableStepWithIdentifier:(NSString *)identifier;
{
    TAStepView *reusableStep = nil;
    NSArray *reusables = [self.reusableSteps objectForKey:identifier];
    if (reusables) {
        NSEnumerator *enumerator = [reusables objectEnumerator];
        while ((reusableStep = [enumerator nextObject])) {
            if(![self.visibleSteps containsObject:reusableStep]){
                [reusableStep prepareForReuse];
                break;
            }
        }
    }
    return reusableStep;
}

- (void)reloadData
{    
    // Reset visible steps array
    [self.visibleSteps removeAllObjects];
    
    // Reset indexes
    _visibleIndexes.location = 0;
    _visibleIndexes.length = 1;
    
    // Remove all subviews from scrollView
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    self.numberOfSteps = 1;
    if ([self.dataSource respondsToSelector:@selector(numberOfStepsInScrollView:)]) {
        self.numberOfSteps = [self.dataSource numberOfStepsInScrollView:self];
    }
    
    if (self.numberOfSteps > 0) {
        for (int index = 0; index < self.visibleIndexes.length; index++) {
            TAStepView *step = [self loadStepAtIndex:(self.visibleIndexes.location + index) insertIntoVisibleIndex:index];
            [self addStepToScrollView:step atIndex:(self.visibleIndexes.location + index)];
        }
    }
    
    self.selectedStep = [self.visibleSteps objectAtIndex:0];
    
    self.scrollView.contentSize = CGSizeMake(_numberOfSteps * self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    [self scrollToStepAtIndex:0 animated:NO];
    
    // Load any additional views
    [self updateVisibleSteps];
    
    // Set initial alpha values for all visible steps
    [self.visibleSteps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self setAlphaForStep:obj];
    }];
}

- (TAStepView *)loadStepAtIndex:(NSInteger)index insertIntoVisibleIndex:(NSInteger)visibleIndex
{
    TAStepView *visibleStep = [self.dataSource stepScrollView:self viewForStepAtIndex:index];
    if (visibleStep.reuseIdentifier) {
        NSMutableArray *reusables = [self.reusableSteps objectForKey:visibleStep.reuseIdentifier];
        if (!reusables) {
            reusables = [[NSMutableArray alloc] initWithCapacity:4];
        }
        if (![reusables containsObject:visibleStep]) {
            [reusables addObject:visibleStep];
        }
        [self.reusableSteps setObject:reusables forKey:visibleStep.reuseIdentifier];
    }
    
    // Add the step to the visible steps array
    [self.visibleSteps insertObject:visibleStep atIndex:visibleIndex];
    
    return visibleStep;
}

// Add a step to the scroll view at a given index. No adjustments are made to existing step offsets.
- (void)addStepToScrollView:(TAStepView *)step atIndex:(NSInteger)index
{
    // Configure the step frame
    [self setFrameForStep:step atIndex:index];
    
    if (!step.maskLayer) {
        [self setLayerPropertiesForStep:step];
    }
    
    // Add the step to the scroller
    [self.scrollView insertSubview:step atIndex:0];
}

- (void)setFrameForStep:(UIView *)step atIndex:(NSInteger)index
{
	CGFloat contentOffset = index * self.scrollView.frame.size.width;
	CGFloat margin = (self.scrollView.frame.size.width - step.frame.size.width) / 2;
	CGRect frame = step.frame;
	frame.origin.x = contentOffset + margin;
	frame.origin.y = 0.0;
	step.frame = frame;
}

- (void)setLayerPropertiesForStep:(TAStepView *)step
{
    // Add shadow (use shadowPath to improve rendering performance)
//    step.layer.shadowColor = [[UIColor blackColor] CGColor];
//    step.layer.shadowOffset = CGSizeMake(3.0f, 8.0f);
//    step.layer.shadowOpacity = 1.0f;
//    step.layer.shadowRadius = 7.0;
//    step.layer.masksToBounds = NO;
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:step.bounds];
//    step.layer.shadowPath = path.CGPath;
    
//    step.maskLayer = [[CALayer alloc] init];
//    CGSize size = step.frame.size;
//    step.maskLayer.frame = CGRectMake(0, 0, size.width, size.height);
//    step.maskLayer.backgroundColor = [[UIColor blackColor] CGColor];
//    step.maskLayer.opaque = NO;
//    step.maskLayer.opacity = 0.0f;
//    [step.layer addSublayer:step.maskLayer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(stepScrollViewWillBeginDragging:)]) {
        [self.delegate stepScrollViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(stepScrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate stepScrollViewDidEndDragging:self willDecelerate:decelerate];
    }
    
    [self delegateDidScrollToStep];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(stepScrollViewWillBeginDecelerating:)]) {
        [self.delegate stepScrollViewWillBeginDecelerating:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(stepScrollViewDidEndDecelerating:)]) {
        [self.delegate stepScrollViewDidEndDecelerating:self];
    }
    
    [self delegateDidScrollToStep];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.isPendingTapGestureCompletion) {
        [self delegateDidScrollToStep];
        self.isPendingTapGestureCompletion = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Update the visible steps
    [self updateVisibleSteps];
    
    // Adjust alpha for all visible steps
    [self.visibleSteps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self setAlphaForStep:obj];
    }];
    
    CGFloat delta = scrollView.contentOffset.x - self.selectedStep.frame.origin.x;
    BOOL toggleNextItem = (fabs(delta) > scrollView.frame.size.width / 2);
    if (toggleNextItem && [self.visibleSteps count] > 1) {
        
        NSInteger selectedIndex = [self.visibleSteps indexOfObject:self.selectedStep];
        BOOL neighborExists = ((delta < 0 && selectedIndex > 0) || (delta > 0 && selectedIndex < [self.visibleSteps count] - 1));
        
        if (neighborExists) {
            NSInteger neighborStepVisibleIndex = [self.visibleSteps indexOfObject:self.selectedStep] + (delta > 0 ? 1 : -1);
            TAStepView *neighborStep = [self.visibleSteps objectAtIndex:neighborStepVisibleIndex];
            NSInteger neighborIndex = self.visibleIndexes.location + neighborStepVisibleIndex;
            
            [self updateScrolledStep:neighborStep index:neighborIndex];
        }
    }
}

- (void) delegateDidScrollToStep
{    
    if ([self isScrollViewSettled] && self.isPendingDelegateDidScrollToStep) {
        if ([self.delegate respondsToSelector:@selector(stepScrollView:didScrollToStep:atIndex:)]) {
            NSInteger selectedIndex = [self.visibleSteps indexOfObject:self.selectedStep] + self.visibleIndexes.location;
            [self.delegate stepScrollView:self didScrollToStep:self.selectedStep atIndex:selectedIndex];
        }
        self.isPendingDelegateDidScrollToStep = NO;
    }
}

- (BOOL) isScrollViewSettled
{
    return fmod(self.scrollView.contentOffset.x, self.scrollView.frame.size.width) == 0;
}

- (void) updateVisibleSteps
{
    CGFloat stepWidth = self.scrollView.frame.size.width;
    
    // Get x origin of left- and right-most steps in scrollView's superview coordinate space (i.e. self)
    CGFloat leftViewOriginX = self.scrollView.frame.origin.x - self.scrollView.contentOffset.x + (self.visibleIndexes.location * stepWidth);
    CGFloat rightViewOriginX = self.scrollView.frame.origin.x - self.scrollView.contentOffset.x + (self.visibleIndexes.location + self.visibleIndexes.length - 1) * stepWidth;
    
    if (leftViewOriginX > 0) {
        // New step is entering the visible range from the left
        if (self.visibleIndexes.location > 0) { // Is it not the first step?
            _visibleIndexes.length += 1;
            _visibleIndexes.location -= 1;
            
            // Add the step to the scroll view (to make it actually visible)
            TAStepView *step = [self loadStepAtIndex:self.visibleIndexes.location insertIntoVisibleIndex:0];
            [self addStepToScrollView:step atIndex:self.visibleIndexes.location];
        }
    } else if (leftViewOriginX < -stepWidth) {
        // Left step is exiting the visible range
        UIView *step = [self.visibleSteps objectAtIndex:0];
        [self.visibleSteps removeObject:step];
        
        // Remove from the scroll view
        [step removeFromSuperview];
        
        _visibleIndexes.location += 1;
        _visibleIndexes.length -= 1;
    }
    
    if (rightViewOriginX > self.frame.size.width) {
        // Right step is exiting the visible range
        UIView *step = [self.visibleSteps lastObject];
        [self.visibleSteps removeObject:step];
        
        // Remove from the scroll view
        [step removeFromSuperview];
        
        _visibleIndexes.length -= 1;
    } else if (rightViewOriginX + stepWidth < self.frame.size.width) {
        // New step is entering the visible range from the right
        if (self.visibleIndexes.location + self.visibleIndexes.length < self.numberOfSteps) { // Is is not the last step?
            _visibleIndexes.length += 1;
            NSInteger index = self.visibleIndexes.location + self.visibleIndexes.length - 1;
            
            TAStepView *step = [self loadStepAtIndex:index insertIntoVisibleIndex:self.visibleIndexes.length - 1];
            [self addStepToScrollView:step atIndex:index];
        }
    }
}

- (void) updateScrolledStep:(TAStepView*)step index:(NSInteger)index
{
    if (step == nil) {
        return;
    }
    
    // Notify delegate
    if ([self.delegate respondsToSelector:@selector(stepScrollView:willScrollToStep:atIndex:)]) {
        [self.delegate stepScrollView:self willScrollToStep:step atIndex:index];
    }
    
    self.selectedStep = step;
    
    self.isPendingDelegateDidScrollToStep = YES;
}

- (void)setAlphaForStep:(TAStepView *)step
{
    CGFloat delta = self.scrollView.contentOffset.x - step.frame.origin.x;
    CGFloat width = self.frame.size.width;
    CGFloat alpha = fabs(delta / width) * 2.0 / 5.0;
    if (alpha > 0.2) {
        alpha = 0.2;
    }
    if (alpha < 0.05) {
        alpha = 0.0;
    }
    
    [step.maskLayer setOpacity:alpha];
}

- (void)handleTapGestureFrom:(UITapGestureRecognizer *)gestureRecognizer
{
    CGFloat tappedX = [gestureRecognizer locationInView:self].x;
    
    CGFloat leftOfScrollView = self.scrollView.frame.origin.x;
    CGFloat rightOfScrollView = leftOfScrollView + self.scrollView.frame.size.width;
    
    if (tappedX < leftOfScrollView) {
        [self scrollToStepAtIndex:self.visibleIndexes.location animated:YES];
    } else if (tappedX > rightOfScrollView) {
        [self scrollToStepAtIndex:(self.visibleIndexes.location + self.visibleIndexes.length - 1) animated:YES];
    }
    
    self.isPendingTapGestureCompletion = YES;
}

// Suppress gestures while the scrollView is unsettled
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [self isScrollViewSettled];
}

// Modifies the hitTest to includes views outside the clipping bounds
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView* subView in self.scrollView.subviews) {
        CGPoint subViewPoint = [self convertPoint:point toView:subView];
        UIView *result = [subView hitTest:subViewPoint withEvent:event];
        if (result) {
            return result;
        }
    }
    return nil;
}

@end
