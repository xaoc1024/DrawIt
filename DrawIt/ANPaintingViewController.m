//
//  ANPaintingViewController.m
//  DrawIt
//
//  Created by Andrew Zhuk on 23.09.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANPaintingViewController.h"

#import "ANPaintingView.h"

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

- (IBAction)button:(UIButton *)sender;
@end

@implementation ANPaintingViewController

- (IBAction)buttonPlus:(UIButton *)sender {
    ANPaintingView *view = (ANPaintingView *)self.view;
    [view increaseScale];
}

- (IBAction)buttonMinus:(UIButton *)sender {
    ANPaintingView *view = (ANPaintingView *)self.view;
    [view decreaseScale];
}
- (void)viewDidLoad
{
    // Create a segmented control so that the user can choose the brush color.
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"Red.png"],
                                             [UIImage imageNamed:@"Yellow.png"],
                                             [UIImage imageNamed:@"Green.png"],
                                             [UIImage imageNamed:@"Blue.png"],
                                             [UIImage imageNamed:@"Purple.png"],
                                             nil]];
	
	// Compute a rectangle that is positioned correctly for the segmented control you'll use as a brush color palette
    CGRect rect = self.view.bounds;
	CGRect frame = CGRectMake(rect.origin.x + kLeftMargin, rect.size.height - kPaletteHeight - kTopMargin, rect.size.width - (kLeftMargin + kRightMargin), kPaletteHeight);
	segmentedControl.frame = frame;
	// When the user chooses a color, the method changeBrushColor: is called.
	[segmentedControl addTarget:self action:@selector(changeBrushColor:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	// Make sure the color of the color complements the black background
	segmentedControl.tintColor = [UIColor darkGrayColor];
	// Set the third color (index values start at 0)
	segmentedControl.selectedSegmentIndex = 2;
	
	// Add the control to the window
	[self.view addSubview:segmentedControl];
    
    // Define a starting color
    CGColorRef color = [UIColor colorWithHue:(CGFloat)2.0 / (CGFloat)kPaletteSize
                                  saturation:kSaturation
                                  brightness:kBrightness
                                       alpha:1.0].CGColor;
    const CGFloat *components = CGColorGetComponents(color);
    
	// Defer to the OpenGL view to set the brush color
	[(ANPaintingView *)self.view setBrushColorWithRed:1.0f green:0.0f blue:0.0f];
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
	[(ANPaintingView *)self.view setBrushColorWithRed:components[0] green:components[1] blue:components[2]];
    
}

// Called when receiving the "shake" notification; plays the erase sound and redraws the view
- (void)eraseView
{
	if(CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval) {
		[(ANPaintingView *)self.view erase];
		lastTime = CFAbsoluteTimeGetCurrent();
	}
}

@end
