//
//  TALocationField.h
//  Transit
//
//  Created by Mark Cafaro on 8/18/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const TALocationFieldCurrentLocationText;

typedef enum {
    TALocationFieldContentTypeDefault,
    TALocationFieldContentTypeCurrentLocation,
    TALocationFieldContentTypeGooglePlace
} TALocationFieldContentType;

@protocol TALocationFieldDelegate;

@interface TALocationField : UIControl <UITextFieldDelegate, UITextInputTraits>

@property (copy, nonatomic) NSString *text;

@property (copy, nonatomic) NSString *leftViewText;

@property (readonly, nonatomic) BOOL isComplete;

@property (nonatomic) TALocationFieldContentType contentType;

// A hidden reference for displayed content, only used for Google Places at the moment
@property (weak, nonatomic) id contentReference;

@property (weak, nonatomic) id<TALocationFieldDelegate> delegate;

@property (nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (nonatomic) UITextAutocorrectionType autocorrectionType;
@property (nonatomic) BOOL enablesReturnKeyAutomatically;
@property (nonatomic) UIKeyboardAppearance keyboardAppearance;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;
@property (nonatomic) UITextSpellCheckingType spellCheckingType;

@end


@protocol TALocationFieldDelegate <NSObject>

@optional

- (BOOL)locationFieldShouldBeginEditing:(TALocationField *)locationField;
- (void)locationFieldDidBeginEditing:(TALocationField *)locationField;
- (BOOL)locationFieldShouldEndEditing:(TALocationField *)locationField;
- (void)locationFieldDidEndEditing:(TALocationField *)locationField;

- (BOOL)locationField:(TALocationField *)locationField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)locationFieldShouldClear:(TALocationField *)locationField;
- (BOOL)locationFieldShouldReturn:(TALocationField *)locationField;

@end
