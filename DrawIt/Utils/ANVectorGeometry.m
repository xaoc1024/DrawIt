//
//  ANVectorGeometry.m
//  DrawIt
//
//  Created by Andriy Zhuk on 30.10.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANVectorGeometry.h"


CGPoint * pointsArrayForCicle(CGPoint topLeft, float radius) {
    NSUInteger pointsCount = 50; // must be calculated according to cicle size
    CGPoint * pointArray = calloc(pointsCount, sizeof(CGPoint));
    
    // here must be written your code :)
    
    
    
    // log section
    NSMutableString * logString = [NSMutableString stringWithString:@"LOG for pints:\n"];
    
    for (int i = 0; i < pointsCount; i++) {
        [logString appendFormat:@"x - %d\ty - %d\n", (int)pointArray[i].x, (int)pointArray[i].y];
    }
    NSLog(logString, nil);
    return pointArray;
}
