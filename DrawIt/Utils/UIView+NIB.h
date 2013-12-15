//
//  UIView+NIB.h
//  CopaCocaCola
//
//  Created by Alex Maydanik on 10/21/13.
//  Copyright (c) 2013 DataArt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (NIB)

+ (id)loadViewFromNIB;
+ (id)loadViewFromNIBWithFrame:(CGRect)frame;

@end
