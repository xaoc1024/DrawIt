//
//  ANVectorGeometry.m
//  DrawIt
//
//  Created by Andriy Zhuk on 30.10.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANVectorGeometry.h"


CGPoint * pointsArrayForCicle(CGPoint center, float radius, NSInteger *pointsNumber) {
    
    float x = 0;
    float y = radius;
    float delta = 1 - 2 * radius;
    float error = 0;
    int count = 0;
    
    while (y >= 0) {
    
        ++count;
        
        error = 2 * (delta + y) - 1;
		if (delta < 0 && error <= 0) {
            ++x;
            delta += 2 * x + 1;
            continue;
        }
        
		error = 2 * (delta - x) - 1;
		if (delta > 0 && error > 0) {
			--y;
			delta += 1 - 2 * y;
			continue;
        }
        
        ++x;
		delta += 2 * (x - y);
		--y;
    }
    
    NSUInteger pointsCount = 4 * count;
    *pointsNumber = pointsCount;
    
    CGPoint * pointArray = calloc(pointsCount, sizeof(CGPoint));
    
    x = 0;
    y = radius;
    delta = 1 - 2 * radius;
    error = 0;
    int i = 0;

    while (y >= 0) {
        
        pointArray[i] = CGPointMake(center.x + x, center.y + y);
        pointArray[i + 1] = CGPointMake(center.x + x, center.y - y);
        pointArray[i + 2] = CGPointMake(center.x - x, center.y + y);
        pointArray[i + 3] = CGPointMake(center.x - x, center.y - y);
        
        i += 4;
        
        error = 2 * (delta + y) - 1;
		if (delta < 0 && error <= 0) {
            ++x;
            delta += 2 * x + 1;
            continue;
        }
        
		error = 2 * (delta - x) - 1;
		if (delta > 0 && error > 0) {
			--y;
			delta += 1 - 2 * y;
			continue;
        }
        
        ++x;
		delta += 2 * (x - y);
		--y;
    }
    
    // log section
    NSMutableString * logString = [NSMutableString stringWithString:@"LOG for pints:\n"];
    
    for (int i = 0; i < pointsCount; i++) {
        [logString appendFormat:@"x - %d\ty - %d\n", (int)pointArray[i].x, (int)pointArray[i].y];
    }
    
    NSLog(logString, nil);
    return pointArray;
}
