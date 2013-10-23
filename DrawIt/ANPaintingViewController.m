//
//  ANPaintingViewController.m
//  DrawIt
//
//  Created by Andrew Zhuk on 23.09.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANPaintingViewController.h"

#import "ANPaintingView.h"
#import "ANColorPickerView.h"

//CONSTANTS:

#define kBrightness             1.0
#define kSaturation             0.45

#define kPaletteHeight			30
#define kPaletteSize			5
#define kMinEraseInterval		0.5

// Padding for margins
#define kLeftMargin				10.0
#define kTopMargin				10.0
#define kRightMargin			10.0

//CLASS IMPLEMENTATIONS:

@interface ANPaintingViewController()
{
	CFTimeInterval		lastTime;
}

@property (nonatomic, weak) IBOutlet ANPaintingView * paintingView;
@property (nonatomic, weak) IBOutlet UISlider * slider;
@property (nonatomic, weak) IBOutlet UIView * colorPickerStub;
@property (nonatomic, weak) IBOutlet UIView * instrumentsView;

- (IBAction)button:(UIButton *)sender;
- (IBAction)sliderAction:(id)sender;
@end

@implementation ANPaintingViewController

- (IBAction)buttonPlus:(UIButton *)sender {
}

- (IBAction)buttonMinus:(UIButton *)sender {
}

- (void)viewDidLoad
{
    
	// Defer to the OpenGL view to set the brush color
    [self.paintingView setBrushWidth: (int)self.slider.value];
    ANColorPickerView * colorPickerView = [[[UINib nibWithNibName:@"ANColorPickerView" bundle:[NSBundle mainBundle]]
                                            instantiateWithOwner:self options:Nil]
                                           lastObject];
    colorPickerView.frame = self.colorPickerStub.frame;
    [self.instrumentsView addSubview:colorPickerView];
    colorPickerView.delegate = self;
    self.paintingView.color = colorPickerView.color;
}

// Change the brush color
- (void)changeBrushColor:(id)sender
{	
	// Define a new brush color
    CGColorRef color = [UIColor colorWithHue:(CGFloat)[sender selectedSegmentIndex] / (CGFloat)kPaletteSize
                                  saturation:kSaturation
                                  brightness:kBrightness
                                       alpha:1.0].CGColor;
    const CGFloat *components = CGColorGetComponents(color);
    
	// Defer to the OpenGL view to set the brush color
	[self.paintingView setBrushColorWithRed:components[0] green:components[1] blue:components[2]];
    
}

// Called when receiving the "shake" notification; plays the erase sound and redraws the view
- (IBAction)eraseButtonAction:(UIButton *)button
{
	if(CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval) {
		[self.paintingView erase];
		lastTime = CFAbsoluteTimeGetCurrent();
	}
}

- (IBAction)sliderAction:(id)sender {
    UISlider * slider = (UISlider *)sender;
    self.paintingView.brushWidth = slider.value;
}

#pragma mark - ANColorPickerDelegate
- (void)colorPickerView:(ANColorPickerView *)colorPickerView didPickColor:(UIColor *)color {
    self.paintingView.color = color;
}

@end
