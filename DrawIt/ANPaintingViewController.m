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
#import "ANCreateImageDialogView.h"

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
@property (nonatomic, weak) IBOutlet UIScrollView * contentScrollView;

@property (nonatomic, strong) UIView * transparentView;

@property (nonatomic, assign) CGPoint prevLocation;

@property (nonatomic, strong) ANCreateImageDialogView * createImageDialog;

@property (nonatomic, weak) IBOutlet UISlider * zoomSlider;
@property (nonatomic, weak) IBOutlet UILabel * zoomLabel;

@property (nonatomic, assign) float zoomFactor;

- (IBAction)brushWidthSliderAction:(UISlider *)sender;
- (IBAction)zoomSliderAction:(UISlider *)sender;

@end

@implementation ANPaintingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Defer to the OpenGL view to set the brush color
    [self.paintingView setBrushWidth: (int)self.slider.value];
    ANColorPickerView * colorPickerView = [[[UINib nibWithNibName:@"ANColorPickerView" bundle:[NSBundle mainBundle]]
                                            instantiateWithOwner:self options:Nil]
                                           lastObject];
    colorPickerView.frame = self.colorPickerStub.frame;
    [self.colorPickerStub removeFromSuperview];
    [self.instrumentsView addSubview:colorPickerView];
    colorPickerView.delegate = self;
    self.paintingView.color = colorPickerView.color;
    
    self.contentScrollView.panGestureRecognizer.maximumNumberOfTouches = 2;
    self.contentScrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    
    [self.contentScrollView.pinchGestureRecognizer addTarget:self action:@selector(contentScrollViewPinchGestureAction:)];
    
    self.transparentView = [[UIView alloc] initWithFrame:self.view.frame];
    self.transparentView.backgroundColor = [UIColor blackColor];
    self.transparentView.alpha = 0.5f;
    [self.view addSubview:self.transparentView];
    
    self.createImageDialog = [[[UINib nibWithNibName:@"ANCreateImageDialogView" bundle:[NSBundle mainBundle]]
                               instantiateWithOwner:self options:nil]
                              lastObject];
    CGPoint center = self.view.center;
    center.x = roundf(center.x);
    center.y = roundf(center.y);
    
    self.createImageDialog.center = center;
    [self.view addSubview:self.createImageDialog];
    self.createImageDialog.delegate = self;
}

- (void) setZoomFactor:(float)zoomFactor {
    _zoomFactor = zoomFactor;
    NSInteger intVal = (NSInteger)(_zoomFactor * 100);
    self.zoomLabel.text = [NSString stringWithFormat:@"%d %%", intVal];
    self.zoomSlider.value = zoomFactor;
    
}

#pragma mark IBActions
- (IBAction)eraseButtonAction:(UIButton *)button
{
	if(CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval) {
		[self.paintingView erase];
		lastTime = CFAbsoluteTimeGetCurrent();
	}
}

- (IBAction)brushWidthSliderAction:(id)sender {
    UISlider * slider = (UISlider *)sender;
    self.paintingView.brushWidth = slider.value;
}

- (IBAction)zoomSliderAction:(UISlider *)sender {
    float val = sender.value;
    [self.contentScrollView setZoomScale:val animated:NO];
    [self setZoomFactor:val];
    [self contentScrollViewPinchGestureAction:Nil];
}

#pragma mark - ANColorPickerDelegate
- (void)colorPickerView:(ANColorPickerView *)colorPickerView didPickColor:(UIColor *)color {
    self.paintingView.color = color;
}
#pragma mark - gesture actions
- (void) contentScrollViewPinchGestureAction:(UIPinchGestureRecognizer *)gesture {
    CGRect viewFrame = self.paintingView.frame;
    if ((viewFrame.size.height < self.contentScrollView.frame.size.height) &&
        (viewFrame.size.width < self.contentScrollView.frame.size.width)) {
        self.paintingView.center = [self.contentScrollView convertPoint:self.contentScrollView.center
                                                               fromView:self.view];
        self.contentScrollView.contentSize = self.contentScrollView.frame.size;
    } else {
        self.contentScrollView.contentSize = self.paintingView.frame.size;
    }
}

- (IBAction)longPressGestureAction:(UILongPressGestureRecognizer *)sender {
    UIGestureRecognizerState state = sender.state;
    CGRect bound = self.paintingView.bounds;
    CGPoint location;
    
    switch (state) {
        case  UIGestureRecognizerStateBegan:
            location = [sender locationInView:self.paintingView];
            location.y = bound.size.height - location.y;
            self.prevLocation = location;
            break;
        default:
            location = [sender locationInView:self.paintingView];
            location.y = bound.size.height - location.y;
            break;
    }
   
    [self.paintingView renderLineFromPoint:self.prevLocation toPoint:location];
    self.prevLocation = location;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.paintingView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setZoomFactor:scrollView.zoomScale];
}
#pragma mark - ANCreateImageDialogDelegate
- (void) createImageDialog:(ANCreateImageDialogView *)dialog
   didCreateImageWithWidth:(NSInteger)width
                 andHeigth:(NSInteger)heigth
{
    [self.transparentView removeFromSuperview];
    [self.createImageDialog removeFromSuperview];
    CGRect frame = self.paintingView.frame;
    frame.size.width = width;
    frame.size.height = heigth;
    self.paintingView.frame = frame;
    self.paintingView.center = [self.contentScrollView convertPoint:self.contentScrollView.center
                                                           fromView:self.view];
    self.contentScrollView.contentSize = self.contentScrollView.frame.size;
}

@end
