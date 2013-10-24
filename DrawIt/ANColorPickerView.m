//
//  ANColorPickerView.m
//  DrawIt
//
//  Created by Andriy Zhuk on 23.10.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANColorPickerView.h"

@interface ANColorPickerView()

@property (nonatomic, assign) float redColor;
@property (nonatomic, assign) float blueColor;
@property (nonatomic, assign) float greenColor;
@property (nonatomic, assign) float alphaColor;

@end

@implementation ANColorPickerView

- (void)awakeFromNib {
    [super awakeFromNib];
    _redColor = 0.0f;
    _greenColor = 0.0f;
    _blueColor = 0.0f;
    _alphaColor = 1.0f;
    self.layer.cornerRadius = 10;
}

- (IBAction)redSliderAction:(UISlider *)sender {
    self.redColor = sender.value;
    [self updateSampleColor];
}

- (IBAction)greenSliderAction:(UISlider *)sender {
    self.greenColor = sender.value;
    [self updateSampleColor];
}

- (IBAction)blueSliderAction:(UISlider *)sender {
    self.blueColor = sender.value;
    [self updateSampleColor];
}

- (IBAction)alphaSliderAction:(UISlider *)sender {
    self.alphaColor = sender.value;
    self.alphaColorSampleView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:_alphaColor];
    [self updateSampleColor];
}

- (void) updateSampleColor {
    self.colorSampleView.backgroundColor = [UIColor colorWithRed:_redColor
                                                           green:_greenColor
                                                            blue:_blueColor
                                                           alpha:1.0f];
    [self.delegate colorPickerView:self didPickColor:self.color];
}

- (UIColor *) color {
    return [UIColor colorWithRed:_redColor green:_greenColor blue:_blueColor alpha:_alphaColor];
}
@end
