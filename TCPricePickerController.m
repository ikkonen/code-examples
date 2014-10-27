//
//  TCPricePickerController.m
//  Taxichief-Driver
//
//  Created by Alexandra Shmidt on 14.08.13.
//  Copyright (c) 2013 iQuest. All rights reserved.
//

#import "TCPricePickerController.h"
#import "TCTariff.h"
#import "TCDriver.h"
#import "TCUserInfo.h"
#import "TCPricePicker.h"

@interface TCPricePickerController ()
@end

@implementation TCPricePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        pickerView = [[TCPricePicker alloc] init];
        self.view = pickerView;
        pickerView.pricePicker.dataSource = self;
        pickerView.pricePicker.delegate = self;
        pickerView.boardPricePicker.dataSource = self;
        pickerView.boardPricePicker.delegate = self;
        pickerView.waitPricePicker.dataSource = self;
        pickerView.waitPricePicker.delegate = self;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self resetValues];
}

#pragma mark - Properties

- (void)setMaxPrice:(TCTariff *)maxPrice{
    _maxPrice = maxPrice;
    [pickerView.pricePicker reloadAllComponents];
    [pickerView.boardPricePicker reloadAllComponents];
    [pickerView.waitPricePicker reloadAllComponents];
    
    [self resetValues];
}

- (void)setMinPrice:(TCTariff *)minPrice{
    _minPrice = minPrice;
    
    [pickerView.pricePicker reloadAllComponents];
    [pickerView.boardPricePicker reloadAllComponents];
    [pickerView.waitPricePicker reloadAllComponents];
    
    [self resetValues];
}

- (void)setCurrency:(NSString *)currency{
    pickerView.currency = currency;
    _currency = currency;
}

#pragma mark - Private

- (NSInteger)minValueForPicker:(UIPickerView *)tmpPickerView{
    if (!_minPrice) {
        return 0;
    }
    
    NSInteger minValue;
    if (tmpPickerView == pickerView.boardPricePicker) {
        minValue = _minPrice.boardPrice.integerValue;
    }else if (tmpPickerView == pickerView.pricePicker){
        minValue = _minPrice.farePrice.integerValue;
    }else{
        minValue = _minPrice.waitPrice.integerValue;
    }
    
    return minValue;
}

- (NSInteger)maxValueForPicker:(UIPickerView *)tmpPickerView{
    if (!_maxPrice) {
        return 0;
    }
    
    NSInteger minValue;
    if (tmpPickerView == pickerView.boardPricePicker) {
        minValue = _maxPrice.boardPrice.integerValue;
    }else if (tmpPickerView == pickerView.pricePicker){
        minValue = _maxPrice.farePrice.integerValue;
    }else{
        minValue = _maxPrice.waitPrice.integerValue;
    }
    
    return minValue;
}

#pragma mark - UIPickerView delegate

- (void)selectRowForPicker:(UIPickerView*)tmpPickerView{
    TCTariff *tariff = [TCUserInfo sharedInstance].driver.tariff;
    
    NSInteger intValue;
    NSInteger tailValue;
    if (tmpPickerView == pickerView.boardPricePicker) {
        intValue = tariff.boardPrice.integerValue;
        tailValue = tariff.boardPrice.floatValue*100 - intValue*100;
    }
    else if (tmpPickerView == pickerView.pricePicker){
        intValue = tariff.farePrice.integerValue;
        tailValue = tariff.farePrice.floatValue*100 - intValue*100;
    }
    else{
        intValue = tariff.waitPrice.integerValue;
        tailValue = tariff.waitPrice.floatValue*100 - intValue*100;
    }
    intValue -= [self minValueForPicker:tmpPickerView];
    if (intValue < 0) {
        intValue = 0;
    }
    
    [tmpPickerView selectRow:intValue inComponent:0 animated:NO];
    [tmpPickerView selectRow:tailValue inComponent:1 animated:NO];
}

- (NSString*)stringValueForPicker:(UIPickerView*)tmpPickerView{
    NSString *value = [NSString stringWithFormat:@"%d.%d",
                       (int)[tmpPickerView selectedRowInComponent:0] + (int)[self minValueForPicker:tmpPickerView],
                       (int)[tmpPickerView selectedRowInComponent:1]];
    return value;
}

- (NSNumber*)numberValueForPicker:(UIPickerView*)tmpPickerView{
    CGFloat result = [tmpPickerView selectedRowInComponent:0] + (CGFloat)[tmpPickerView selectedRowInComponent:1] / 100.0f;
    result += [self minValueForPicker:tmpPickerView];
    return @(result);
}


#pragma mark Picker Data Source & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)tmpPickerView{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)tmpPickerView numberOfRowsInComponent:(NSInteger)component{
    if (_maxPrice && _minPrice && !component) {
        return [self maxValueForPicker:tmpPickerView] - [self minValueForPicker:tmpPickerView] + 1;
    }
    
    return (component == 0) ? 201 : 100;
}

- (CGFloat)pickerView:(UIPickerView *)tmpPickerView widthForComponent:(NSInteger)component{
    return (component == 0) ? 50.0f: 40.0f;
}

- (NSAttributedString *)pickerView:(UIPickerView *)_pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *title;
    
    title = (component == 0) ?
            [NSString stringWithFormat:@"%03d", (int)row + (int)[self minValueForPicker:_pickerView]] :
            [NSString stringWithFormat:@"%02d", (int)row];
    
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:(SYSTEM_VERSION_LESS_THAN(@"7")) ? [UIColor blackColor] : [UIColor whiteColor]}];
    
    return attString;
}

#pragma mark - Public

- (void)resetValues{
    [self selectRowForPicker:pickerView.boardPricePicker];
    [self selectRowForPicker:pickerView.pricePicker];
    [self selectRowForPicker:pickerView.waitPricePicker];
}

- (NSString*)stringValueForBoardPicker{
    return [self stringValueForPicker:pickerView.boardPricePicker];
}

- (NSString*)stringValueForFarePicker{
    return [self stringValueForPicker:pickerView.pricePicker];
}

- (NSString*)stringValueForWaitPicker{
    return [self stringValueForPicker:pickerView.waitPricePicker];
}

- (NSNumber*)numberValueForBoardPicker{
    return [self numberValueForPicker:pickerView.boardPricePicker];
}

- (NSNumber*)numberValueForFarePicker{
    return [self numberValueForPicker:pickerView.pricePicker];
}

- (NSNumber*)numberValueForWaitPicker{
    return [self numberValueForPicker:pickerView.waitPricePicker];
}

@end
