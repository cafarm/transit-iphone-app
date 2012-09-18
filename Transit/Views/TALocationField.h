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
    TALocationFieldContentTypeGooglePlace,
    TALocationFieldContentTypePlacemark
} TALocationFieldContentType;

@protocol TALocationFieldDelegate;

@class TAPlacemark;

@interface TALocationField : UIControl <UITextFieldDelegate, UITextInputTraits>

@property (copy, nonatomic) NSString *text;
@property (strong, nonatomic) UILabel *leftViewLabel;
@property (readonly, nonatomic) BOOL isComplete;

@property (nonatomic) TALocationFieldContentType contentType;

// A hidden reference for the displayed content, i.e. a google place reference or a placemark depending
@property (strong, nonatomic) id contentReference;

@property (weak, nonatomic) id<TALocationFieldDelegate> delegate;

- (void)fillWithPlacemark:(TAPlacemark *)placemark;

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
