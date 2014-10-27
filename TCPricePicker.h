//
//  TCPricePicker.h
//  Taxichief-Driver
//
//  Created by Alexandra Shmidt on 06.02.14.
//  Copyright (c) 2014 iQuest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCPricePicker : UIView{
    UILabel *boardTitle;
    UILabel *priceTitle;
    UILabel *waitTitle;
}

@property (nonatomic) UIPickerView *boardPricePicker;
@property (nonatomic) UIPickerView *pricePicker;
@property (nonatomic) UIPickerView *waitPricePicker;

@property (nonatomic) NSString *currency;

@end
