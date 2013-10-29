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

//CLASS INTERFACES:

@interface ANPaintingView : UIView

@property(nonatomic, readwrite) CGPoint location;
@property(nonatomic, readwrite) CGPoint previousLocation;
@property(nonatomic, assign) NSInteger brushWidth;
@property (nonatomic, strong) UIColor * color;

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) float scaleFactor;

- (void)erase;
- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void)testFunc:(NSInteger)val;
@end