//
//  ANColorPickerDelegate.h
//  DrawIt
//
//  Created by Andriy Zhuk on 23.10.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ANColorPickerView;

@protocol ANColorPickerDelegate <NSObject>
@required
- (void) colorPickerView:(ANColorPickerView *)colorPickerView didPickColor:(UIColor *)color;
@end
