//
//  ANLayerTableViewCell.h
//  DrawIt
//
//  Created by Andriy Zhuk on 09.11.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANLayerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *layerNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *layerSnapshotImageView;

@end
