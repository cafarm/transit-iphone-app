//
//  TALocationField.m
//  Transit
//
//  Created by Mark Cafaro on 8/18/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationField.h"
#import "UIColor+Transit.h"

NSString *const TALocationFieldCurrentLocationText = @"Current Location";

@interface TALocationField ()

@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIImageView *currentLocationTag;

@end


@implementation TALocationField

@synthesize text = _text;
@synthesize leftViewLabel = _leftViewLabel;
@synthesize isComplete = _isComplete;

@synthesize contentType = _contentType;
@synthesize contentReference = _contentReference;

@synthesize delegate = _delegate;

@synthesize textField = _textField;
@synthesize currentLocationTag = _currentLocationTag;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _textField = [[UITextField alloc] initWithFrame:self.bounds];
        _textField.font = [UIFont systemFontOfSize:15];
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.keyboardType = UIKeyboardTypeDefault;
        _textField.returnKeyType = UIReturnKeyNext;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.enablesReturnKeyAutomatically = YES;
        //_textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.background = [[UIImage imageNamed:@"LocationField"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
        _textField.delegate = self;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        [self addSubview:_textField];
        
        _leftViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -1, 51, 31)];
        _leftViewLabel.font = self.textField.font;
        _leftViewLabel.textAlignment = UITextAlignmentRight;
        _leftViewLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
        _leftViewLabel.backgroundColor = [UIColor clearColor];
        _textField.leftView = _leftViewLabel;
        
        // The current location tag displayed when a user selects the current location field
        UILabel *currentLocationLabel = [[UILabel alloc] init];
        currentLocationLabel.text = TALocationFieldCurrentLocationText;
        currentLocationLabel.textColor = [UIColor whiteColor];
        currentLocationLabel.font = _textField.font;
        currentLocationLabel.backgroundColor = [UIColor clearColor];
        [currentLocationLabel sizeToFit];
        UIEdgeInsets tagInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        UIImage *tagImage = [[UIImage imageNamed:@"TagSelected"] resizableImageWithCapInsets:tagInsets];
        _currentLocationTag = [[UIImageView alloc] initWithImage:tagImage];
        _currentLocationTag.frame = CGRectMake(_leftViewLabel.frame.size.width - 8, 4, currentLocationLabel.frame.size.width + 16, currentLocationLabel.frame.size.height + 6);
        _currentLocationTag.userInteractionEnabled = YES;
        currentLocationLabel.center = CGPointMake(_currentLocationTag.frame.size.width / 2, _currentLocationTag.frame.size.height / 2 - 1);
        [_currentLocationTag addSubview:currentLocationLabel];
        [self addSubview:_currentLocationTag];
        _currentLocationTag.hidden = YES;
        
        _contentType = TALocationFieldContentTypeDefault;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    self.textField.text = text;
}

- (NSString *)text
{
    return self.textField.text;
}

//- (void)setLeftViewText:(NSString *)leftViewText
//{
////    self.textField.leftViewMode = UITextFieldViewModeAlways;
////    self.currentLocationField.leftViewMode = UITextFieldViewModeAlways;
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -1, 45, 31)];
//    label.font = self.textField.font;
//    label.textAlignment = UITextAlignmentRight;
//    label.textColor = [UIColor grayColor];
//    label.backgroundColor = [UIColor clearColor];
//    label.text = leftViewText;
//    
//    self.textField.leftView = label;
//    
////    NSData *temp = [NSKeyedArchiver archivedDataWithRootObject:label];
////    UIView *viewCopy = [NSKeyedUnarchiver unarchiveObjectWithData:temp];
////    self.currentLocationField.leftView = viewCopy;
//    
//    _leftViewText = leftViewText;
//}

- (BOOL)isComplete
{
    return [self.textField.text length] > 0;
}

- (void)setContentType:(TALocationFieldContentType)contentType
{
    // Clear out the content reference because it's no longer valid
    self.contentReference = nil;
    
    if (contentType != TALocationFieldContentTypeCurrentLocation) {
        self.currentLocationTag.hidden = YES;
        self.textField.textColor = [UIColor blackColor];
//        self.currentLocationField.hidden = YES;
    } else {
        if (self.isFirstResponder) {
            self.currentLocationTag.hidden = NO;
//            self.currentLocationField.clearButtonMode = UITextFieldViewModeAlways;
        } else {
            self.currentLocationTag.hidden = YES;
//            self.currentLocationField.clearButtonMode = UITextFieldViewModeNever;
        }
//        self.currentLocationField.hidden = NO;
        self.textField.text = TALocationFieldCurrentLocationText;
        self.textField.textColor = [UIColor currentLocationColor];
    }
    _contentType = contentType;
}

- (BOOL)isFirstResponder
{
    return self.textField.isFirstResponder;
}

- (BOOL)becomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL shouldBegin = YES;
    
    if ([self.delegate respondsToSelector:@selector(locationFieldShouldBeginEditing:)]) {
        shouldBegin = [self.delegate locationFieldShouldBeginEditing:self];
    }
    
    return shouldBegin;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.contentType == TALocationFieldContentTypeCurrentLocation) {
        self.currentLocationTag.hidden = NO;
//        self.currentLocationField.clearButtonMode = UITextFieldViewModeAlways;
//        [self.textField becomeFirstResponder];
    }
    
    if ([self.delegate respondsToSelector:@selector(locationFieldDidBeginEditing:)]) {
        [self.delegate locationFieldDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    BOOL shouldEnd = YES;
    
    if ([self.delegate respondsToSelector:@selector(locationFieldShouldEndEditing:)]) {
        shouldEnd = [self.delegate locationFieldShouldEndEditing:self];
    }
    
    return shouldEnd;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.contentType == TALocationFieldContentTypeCurrentLocation) {
        self.currentLocationTag.hidden = YES;
//        self.currentLocationField.clearButtonMode = UITextFieldViewModeNever;
    }
    
    if ([self.delegate respondsToSelector:@selector(locationFieldDidEndEditing:)]) {
        [self.delegate locationFieldDidEndEditing:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChange = YES;
    
    // Changing characters with a current location field replaces the entire contents of the field
    if (self.contentType == TALocationFieldContentTypeCurrentLocation) {
        range.length = [TALocationFieldCurrentLocationText length];
        range.location = 0;
    }
    
    if ([self.delegate respondsToSelector:@selector(locationField:shouldChangeCharactersInRange:replacementString:)]) {
        shouldChange = [self.delegate locationField:self shouldChangeCharactersInRange:range replacementString:string];
    }
    
    if (shouldChange) {        
        if (self.contentType == TALocationFieldContentTypeCurrentLocation) {
            self.textField.text = nil;
            self.textField.textColor = [UIColor blackColor];
            self.currentLocationTag.hidden = YES;
//            self.currentLocationField.hidden = YES;
        }
        self.contentType = TALocationFieldContentTypeDefault;
    }
    
    return shouldChange;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    BOOL shouldClear = YES;
    
    if ([self.delegate respondsToSelector:@selector(locationFieldShouldClear:)]) {
        shouldClear = [self.delegate locationFieldShouldClear:self];
    }
    
    if (shouldClear) {
        if (self.contentType == TALocationFieldContentTypeCurrentLocation) {
            self.textField.text = nil;
            self.textField.textColor = [UIColor blackColor];
            self.currentLocationTag.hidden = YES;
//            self.currentLocationField.hidden = YES;
        }
        self.contentType = TALocationFieldContentTypeDefault;
        
//        if (textField == self.currentLocationField) {
//            return NO;
//        }
    }
    
    return shouldClear;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL shouldReturn = YES;
    
    if ([self.delegate respondsToSelector:@selector(locationFieldShouldReturn:)]) {
        shouldReturn = [self.delegate locationFieldShouldReturn:self];
    }
    
    return shouldReturn;
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType
{
    self.textField.autocapitalizationType = autocapitalizationType;
}

- (UITextAutocapitalizationType)autocapitalizationType
{
    return self.textField.autocapitalizationType;
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType
{
    self.textField.autocorrectionType = autocorrectionType;
}

- (UITextAutocorrectionType)autocorrectionType
{
    return self.textField.autocorrectionType;
}

- (void)setEnablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAutomatically
{
    self.textField.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically;
}

- (BOOL)enablesReturnKeyAutomatically
{
    return self.textField.enablesReturnKeyAutomatically;
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance
{
    self.textField.keyboardAppearance = keyboardAppearance;
}

- (UIKeyboardAppearance)keyboardAppearance
{
    return self.textField.keyboardAppearance;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
    self.textField.keyboardType = keyboardType;
}

- (UIKeyboardType)keyboardType
{
    return self.textField.keyboardType;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
    self.textField.returnKeyType = returnKeyType;
}

- (UIReturnKeyType)returnKeyType
{
    return self.textField.returnKeyType;
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry
{
    self.textField.secureTextEntry = secureTextEntry;
}

- (BOOL)isSecureTextEntry
{
    return self.textField.isSecureTextEntry;
}

- (void)setSpellCheckingType:(UITextSpellCheckingType)spellCheckingType
{
    self.textField.spellCheckingType = spellCheckingType;
}

- (UITextSpellCheckingType)spellCheckingType
{
    return self.textField.spellCheckingType;
}

@end
