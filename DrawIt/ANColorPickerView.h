//
//  ANColorPickerView.h
//  DrawIt
//
//  Created by Andriy Zhuk on 23.10.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANColorPickerDelegate.h"

@interface ANColorPickerView : UIView

@property (nonatomic, weak) IBOutlet UISlider * redSlider;
@property (nonatomic, weak) IBOutlet UISlider * greenSlider;
@property (nonatomic, weak) IBOutlet UISlider * blueSlider;
@property (nonatomic, weak) IBOutlet UISlider * alphaSlider;
@property (nonatomic, weak) IBOutlet UIView * colorSampleView;

@property (nonatomic, weak) IBOutlet UIView * redColorSampleView;
@property (nonatomic, weak) IBOutlet UIView * greenColorSampleView;
@property (nonatomic, weak) IBOutlet UIView * blueColorSampleView;
@property (nonatomic, weak) IBOutlet UIView * alphaColorSampleView;

- (IBAction)redSliderAction:(UISlider *)sender;
- (IBAction)greenSliderAction:(UISlider *)sender;
- (IBAction)blueSliderAction:(UISlider *)sender;
- (IBAction)alphaSliderAction:(UISlider *)sender;


@property (nonatomic, weak) id <ANColorPickerDelegate> delegate;
@property (nonatomic, strong) UIColor *color;

@end
