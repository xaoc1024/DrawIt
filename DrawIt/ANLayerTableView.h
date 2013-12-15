//
//  ANLayerListView.h
//  DrawIt
//
//  Created by Andriy Zhuk on 09.11.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANLayerTableView : UIView <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *layersDataArray;
@property (weak, nonatomic) IBOutlet UITableView *layersTableView;
@end
