//
//  ANCreateImageDialogViewDelegate.h
//  DrawIt
//
//  Created by Andriy Zhuk on 24.10.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ANCreateImageDialogView;

@protocol ANCreateImageDialogViewDelegate <NSObject>
- (void) createImageDialog:(ANCreateImageDialogView *) dialog didCreateImageWithWidth:(NSInteger)width andHeigth:(NSInteger)heigth; 
@end
