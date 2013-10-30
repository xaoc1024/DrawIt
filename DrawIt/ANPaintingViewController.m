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
#import "ANVectorGeometry.h"

//CONSTANTS:

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

@property (nonatomic, strong) UIView * transparentView;

@property (nonatomic, assign) CGPoint prevLocation;

@property (nonatomic, strong) ANCreateImageDialogView * createImageDialog;

@property (nonatomic, weak) IBOutlet UISlider * zoomSlider;
@property (nonatomic, weak) IBOutlet UILabel * zoomLabel;

@property (nonatomic, assign) float zoomFactor;

- (IBAction)zoomInButonAction:(id)sender;

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
    self.zoomFactor = 1;
    
    // TODO: test for Serhiy
    CGPoint * pointsArray = pointsArrayForCicle(CGPointMake(10.0f, 10.0f), 100.0f);
}
- (void) locatePaintingView {
    CGSize newSize = self.paintingView.frame.size;
    if (newSize.width <= self.paintingView.superview.frame.size.width &&
        newSize.height <= self.paintingView.superview.frame.size.width){
        self.paintingView.center = [self.view convertPoint:self.paintingView.superview.center
                                                    toView:self.paintingView.superview];
    }
}

- (void) setZoomFactor:(float)zoomFactor {
    _zoomFactor = zoomFactor;
    [self updateUIForScale:zoomFactor];
}

- (void) updateUIForScale:(float)scaleFactor {
    NSInteger intVal = (NSInteger)(scaleFactor * 100);
    self.zoomLabel.text = [NSString stringWithFormat:@"%d %%", intVal];
    self.zoomSlider.value = scaleFactor;
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
//    [self.contentScrollView setZoomScale:val animated:NO];
    [self setZoomFactor:val];
//    [self contentScrollViewPinchGestureAction:nil];
    self.paintingView.scaleFactor = sender.value;
}

#pragma mark - ANColorPickerDelegate
- (void)colorPickerView:(ANColorPickerView *)colorPickerView didPickColor:(UIColor *)color {
    self.paintingView.color = color;
}


- (IBAction)longPressGestureAction:(UILongPressGestureRecognizer *)sender {
    UIGestureRecognizerState state = sender.state;
    
    CGPoint location;
    
    switch (state) {
        case  UIGestureRecognizerStateBegan:
            location = [sender locationInView:self.paintingView];
            self.prevLocation = location;
            break;
        case  UIGestureRecognizerStateChanged:
            location = [sender locationInView:self.paintingView];
            break;
        default:
            location = [sender locationInView:self.paintingView];
            break;
    }
   
    [self.paintingView renderLineFromPoint:self.prevLocation toPoint:location];
    self.prevLocation = location;
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
    self.paintingView.center = [self.view convertPoint:self.paintingView.superview.center
                                                      toView:self.paintingView.superview];
    [self.paintingView resizeFromLayer:(CAEAGLLayer *)_paintingView.layer];
    self.paintingView.imageSize = frame.size;
}


- (IBAction)zoomInButonAction:(UIButton *)sender {
    CGRect frame = self.paintingView.frame;
    frame.size.height += 40;
    frame.size.width += 40;
    self.paintingView.frame = frame;
}

- (IBAction)panGestureAction:(UIPanGestureRecognizer *)sender {
    
}

- (IBAction)pinchGestureAction:(UIPinchGestureRecognizer *)sender {
    UIGestureRecognizerState state = sender.state;
    float scale = sender.scale;
    static float curretnScale;
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
            curretnScale = self.zoomFactor;
            scale = curretnScale * scale;
            break;
            
        case UIGestureRecognizerStateChanged:
            scale = curretnScale * scale;
            break;

        default:
            scale = curretnScale * scale;
            if (scale >= 10) {
                scale = 10;
            }
            self.zoomFactor = scale;
            break;
    }
    if (scale >= 10) {
        scale = 10;
    }
    self.paintingView.scaleFactor = scale;
    [self locatePaintingView];
    [self updateUIForScale:scale];
}

@end
