//
//  ANLayerListView.m
//  DrawIt
//
//  Created by Andriy Zhuk on 09.11.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANLayerTableView.h"
#import "ANLayerTableViewCell.h"
#import "ANLayerData.h"
#import "UIView+NIB.h"

@interface ANLayerTableView ()

@end

@implementation ANLayerTableView 

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void) setLayersDataArray:(NSArray *)layersDataArray {
    _layersDataArray = layersDataArray;
    [self.layersTableView reloadData];
}

#pragma mark - UITableViewDataSourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.layersDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"LayerDataCell";
    ANLayerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [ANLayerTableViewCell loadViewFromNIB];
    }
    cell.layerSnapshotImageView.image = ((ANLayerData *)self.layersDataArray[indexPath.row]).snapShotImage;
    cell.layerNameLabel.text = ((ANLayerData *)self.layersDataArray[indexPath.row]).layerNameString;
    return cell;
}

#pragma makr - UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

 @end
