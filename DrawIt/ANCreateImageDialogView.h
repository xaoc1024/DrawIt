//
//  ANCreateImageDialogView.h
//  DrawIt
//
//  Created by Andriy Zhuk on 24.10.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANCreateImageDialogViewDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface ANCreateImageDialogView : UIView
@property (nonatomic, weak) IBOutlet UITextField * widthTextField;
@property (nonatomic, weak) IBOutlet UITextField * heigthTextField;

@property (nonatomic, weak) id <ANCreateImageDialogViewDelegate> delegate;

- (IBAction)okButtonAction:(UIButton *)sender;

@end
