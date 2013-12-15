//
//  ANVectorGeometry.m
//  DrawIt
//
//  Created by Andriy Zhuk on 30.10.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANVectorGeometry.h"


CGPoint * pointsArrayForCicle(CGPoint center, float radius, NSInteger *pointsNumber) {
    NSUInteger pointsCount = 50; // must be calculated according to cicle size
    *pointsNumber = pointsCount;
    
    CGPoint * pointArray = calloc(pointsCount, sizeof(CGPoint));
    
    // here must be written your code :)
    for (int i = 0; i < pointsCount; i++){
        pointArray[i] = CGPointMake(i, 1.2 * i);
    }
    
    
    // log section
    NSMutableString * logString = [NSMutableString stringWithString:@"LOG for pints:\n"];
    
    for (int i = 0; i < pointsCount; i++) {
        [logString appendFormat:@"x - %d\ty - %d\n", (int)pointArray[i].x, (int)pointArray[i].y];
    }
    
    NSLog(logString, nil);
    return pointArray;
}
