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

@property (strong, nonatomic) UITextField *currentLocationField;
@property (strong, nonatomic) UIImageView *currentLocationTag;

@end


@implementation TALocationField

@synthesize text = _text;

@synthesize leftViewText = _leftViewText;

@synthesize isComplete = _isComplete;

@synthesize contentType = _contentType;
@synthesize contentReference = _contentReference;

@synthesize delegate = _delegate;

@synthesize textField = _textField;

@synthesize currentLocationField = _currentLocationField;
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
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.delegate = self;
        [self addSubview:_textField];
                
        // A convenient way to hide the input cursor and show the current location text when needed
        _currentLocationField = [[UITextField alloc] initWithFrame:self.bounds];
        _currentLocationField.font = _textField.font;
        _currentLocationField.contentVerticalAlignment = _textField.contentVerticalAlignment;
        _currentLocationField.backgroundColor = _textField.backgroundColor;
        _currentLocationField.text = TALocationFieldCurrentLocationText;
        _currentLocationField.textColor = [UIColor currentLocationColor];
        _currentLocationField.hidden = YES;
        _currentLocationField.delegate = self;
        [self addSubview:_currentLocationField];
        
        // The current location tag displayed when a user selects the current location field
        _currentLocationTag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CurrentLocationTag"]];
        CGRect tagFrame = _currentLocationTag.frame;
        _currentLocationTag.frame = CGRectMake(tagFrame.origin.x + 37, tagFrame.origin.y + 4, tagFrame.size.width, tagFrame.size.height);
        _currentLocationTag.hidden = YES;
        [self addSubview:_currentLocationTag];
        
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

- (void)setLeftViewText:(NSString *)leftViewText
{
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.currentLocationField.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -1, 45, 31)];
    label.font = self.textField.font;
    label.textAlignment = UITextAlignmentRight;
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = leftViewText;
    
    // A view to shift the label up to align with text field input
    UIView *view = [[UIView alloc] init];
    view.frame = label.frame;
    view.backgroundColor = [UIColor clearColor];
    view.userInteractionEnabled = NO;
    [view addSubview:label];
    
    self.textField.leftView = view;
    
    NSData *temp = [NSKeyedArchiver archivedDataWithRootObject:view];
    UIView *viewCopy = [NSKeyedUnarchiver unarchiveObjectWithData:temp];
    self.currentLocationField.leftView = viewCopy;
    
    _leftViewText = leftViewText;
}

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
        self.currentLocationField.hidden = YES;
    } else {
        if (self.isFirstResponder) {
            self.currentLocationTag.hidden = NO;
            self.currentLocationField.clearButtonMode = UITextFieldViewModeAlways;
        } else {
            self.currentLocationTag.hidden = YES;
            self.currentLocationField.clearButtonMode = UITextFieldViewModeNever;
        }
        self.currentLocationField.hidden = NO;
        self.textField.text = TALocationFieldCurrentLocationText;
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
        self.currentLocationField.clearButtonMode = UITextFieldViewModeAlways;
        [self.textField becomeFirstResponder];
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
        self.currentLocationField.clearButtonMode = UITextFieldViewModeNever;
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
            self.currentLocationTag.hidden = YES;
            self.currentLocationField.hidden = YES;
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
            self.currentLocationTag.hidden = YES;
            self.currentLocationField.hidden = YES;
        }
        self.contentType = TALocationFieldContentTypeDefault;
        
        if (textField == self.currentLocationField) {
            return NO;
        }
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
