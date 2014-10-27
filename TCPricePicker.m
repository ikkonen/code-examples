//
//  TCPricePicker.m
//  Taxichief-Driver
//
//  Created by Alexandra Shmidt on 06.02.14.
//  Copyright (c) 2014 iQuest. All rights reserved.
//

#import "TCPricePicker.h"

@interface TCPricePicker()
- (UIPickerView*)createPicker;
- (UILabel*)createPickerLabel;
@end

@implementation TCPricePicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = BACKGROUND_COLOR;
        
        _boardPricePicker = [self createPicker];
        _pricePicker = [self createPicker];
        _waitPricePicker = [self createPicker];
        
        boardTitle = [self createPickerLabel];
        priceTitle = [self createPickerLabel];
        waitTitle = [self createPickerLabel];
        boardTitle.text = NSLocalizedString(@"Boarding", @"");
        priceTitle.text = NSLocalizedString(@"Fare", @"");
        waitTitle.text = NSLocalizedString(@"Waiting", @"");
    }
    return self;
}

- (void)updateConstraints{
    if (![self.constraints filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.firstItem == %@", _boardPricePicker]].count) {
        //Check for landscape
        NSNumber *width = @([UIScreen mainScreen].bounds.size.width / 3.0f);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[boardTitle(priceTitle)][priceTitle(waitTitle)][waitTitle(width)]|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:NSDictionaryOfVariableBindings(width)
                                                                       views:NSDictionaryOfVariableBindings(boardTitle, priceTitle, waitTitle)]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_boardPricePicker(_pricePicker)][_pricePicker(_waitPricePicker)][_waitPricePicker(width)]|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:NSDictionaryOfVariableBindings(width)
                                                                       views:NSDictionaryOfVariableBindings(_boardPricePicker, _pricePicker, _waitPricePicker)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[boardTitle]-[_boardPricePicker]|"
                                                                     options:NSLayoutFormatAlignAllCenterX
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(boardTitle, _boardPricePicker)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[priceTitle]-[_pricePicker]|"
                                                                     options:NSLayoutFormatAlignAllCenterX
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(priceTitle, _pricePicker)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[waitTitle]-[_waitPricePicker]|"
                                                                     options:NSLayoutFormatAlignAllCenterX
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(waitTitle, _waitPricePicker)]];
    }
    [super updateConstraints];
}

#pragma mark - Property
- (void)setCurrency:(NSString *)currency{
    boardTitle.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Boarding", @""), NSLocalizedString(currency, @"")];
    priceTitle.text = [NSString stringWithFormat:@"%@ %@/km", NSLocalizedString(@"Fare", @""), NSLocalizedString(currency, @"")];
    waitTitle.text = [NSString stringWithFormat:@"%@ %@/min", NSLocalizedString(@"Waiting", @""), NSLocalizedString(currency, @"")];
    _currency = currency;
}

#pragma mark - Private

- (UIPickerView*)createPicker{
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    [self addSubview:pickerView];
    pickerView.translatesAutoresizingMaskIntoConstraints = NO;
    pickerView.showsSelectionIndicator = YES;
    
    return pickerView;
}

- (UILabel*)createPickerLabel{
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = CLEAR_COLOR;
    label.font = TEXT_BOLD_FONT_12;
    label.textColor = MAIN_YELLOW_TEXT_COLOR;
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:label];
    return label;
}

@end
