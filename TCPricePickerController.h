//
//  TCPricePickerController.h
//  Taxichief-Driver
//
//  Created by Alexandra Shmidt on 14.08.13.
//  Copyright (c) 2013 iQuest. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TCPricePicker;
@class TCTariff;

@interface TCPricePickerController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>{
    TCPricePicker *pickerView;
}

@property (nonatomic) TCTariff *maxPrice;
@property (nonatomic) TCTariff *minPrice;
@property (nonatomic) NSString *currency;

- (void)resetValues;
- (NSString*)stringValueForBoardPicker;
- (NSString*)stringValueForFarePicker;
- (NSString*)stringValueForWaitPicker;

- (NSNumber*)numberValueForBoardPicker;
- (NSNumber*)numberValueForFarePicker;
- (NSNumber*)numberValueForWaitPicker;

@end
