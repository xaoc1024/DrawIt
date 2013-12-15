//
//  ANPaintingView.h
//  DrawIt
//
//  Created by Andrew Zhuk on 23.09.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "ANVectorGeometry.h"

//CLASS INTERFACES:

@interface ANPaintingView : UIView

@property(nonatomic, readwrite) CGPoint location;
@property(nonatomic, readwrite) CGPoint previousLocation;
@property(nonatomic, assign) NSInteger brushWidth;
@property (nonatomic, strong) UIColor * color;

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) float scaleFactor;

@property (nonatomic, assign) NSUInteger currentLayer;
@property (nonatomic, assign) CGPoint *circlePoints;
@property (nonatomic, assign) NSInteger circlePointsNumber;

- (void)erase;
- (void)eraseForLayers;
- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void) addLayer;
- (void)drawCircleWithRadius:(CGFloat)radius;
@end