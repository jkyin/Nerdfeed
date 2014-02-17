//
//  ListViewController.h
//  Nerdfeed
//
//  Created by Yin on 14-2-17.
//  Copyright (c) 2014年 Jack Yin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListViewController : UITableViewController
{
    NSURLConnection *connection;
    NSMutableData *xmlData;
}

- (void)fetchEntries;

@end
