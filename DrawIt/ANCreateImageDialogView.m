//
//  ANCreateImageDialogView.m
//  DrawIt
//
//  Created by Andriy Zhuk on 24.10.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANCreateImageDialogView.h"

@implementation ANCreateImageDialogView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 10;
}

- (IBAction)okButtonAction:(UIButton *)sender {
    NSInteger width = [self.widthTextField.text integerValue];
    NSInteger heigth = [self.heigthTextField.text integerValue];
    if (width * heigth == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Image cannot have zero size"
                                                           delegate:Nil cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        [self.delegate createImageDialog:self didCreateImageWithWidth:width andHeigth:heigth];
    }
}
@end
