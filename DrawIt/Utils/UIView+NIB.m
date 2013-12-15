//
//  UIView+NIB.m
//  CopaCocaCola
//
//  Created by Alex Maydanik on 10/21/13.
//  Copyright (c) 2013 DataArt. All rights reserved.
//

#import "UIView+NIB.h"

@implementation UIView (NIB)

#pragma mark - public
+ (id)loadViewFromNIB {
    return [self loadViewFromNIBWithName:NSStringFromClass([self class])];
}

+ (id)loadViewFromNIBWithFrame:(CGRect)frame {
    id view = [self loadViewFromNIB];
    [view setFrame:frame];
    return view;
}

#pragma mark - private
+ (id)loadViewFromNIBWithName:(NSString *)name {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:name
                                                         owner:nil
                                                       options:nil];
    
    for (UIView *view in nibContents) {
        if ([view isKindOfClass:[self class]]) {
            return view;
        }
    }
    NSAssert(NO, @"Attempt to load view from wrong or corrupted NIB");
    return nil;
}

@end
