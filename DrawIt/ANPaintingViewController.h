//
//  ANPaintingViewController.h
//  DrawIt
//
//  Created by Andrew Zhuk on 23.09.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANColorPickerDelegate.h"
#import "ANCreateImageDialogViewDelegate.h"

@interface ANPaintingViewController : UIViewController <
ANColorPickerDelegate,
ANCreateImageDialogViewDelegate>

@end
