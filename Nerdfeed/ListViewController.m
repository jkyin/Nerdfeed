//
//  ListViewController.m
//  Nerdfeed
//
//  Created by Yin on 14-2-17.
//  Copyright (c) 2014年 Jack Yin. All rights reserved.
//

#import "ListViewController.h"

@implementation ListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self) {
        [self fetchEntries];
    }
    return self;
}

- (void)fetchEntries
{
    // 创建数据容器对象，用于存放返回自 Web 服务的数据
    xmlData = [[NSMutableData alloc] init];
    
    // 构建 URL 以便向 Web 服务器发起请求
    // 注意，可以通过以下途径分多行定义 literal string
    // 这段代码只会创建一个 NSString 对象
    NSURL *url = [NSURL URLWithString:
                  @"http://forums.bignerdranch.com/smartfeed.php?"
                  @"limit=1_DAY&sort_by=standard$feed_type=RSS2.0&feed_style=COMPACT"];
    
    // 要获取 Apple 的「最新要闻」（Hot News feed），可以将以上代码替换为，
    // NSURL *url = [NSURL URLWithString:@"http://www.apple.com/pr/feeds/pr.rss"];
    
    // 将创建的 NSURL 对象赋给 NSURLRequest 对象
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    // 创建 NSURLConnection 对象，该对象将根据指定的 URL 和服务器通信
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}

#pragma mark - NSURLConnection

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //将收到的数据片加入之前准备好的容器对象
    // 应用一定会按序依次收到数据
    [xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    // 检查是否收到了正确的 XML 数据
    NSString *xmlCheck = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSLog(@"xmlCheck = %@", xmlCheck);
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    // 不再需要使用 connection 指向的对象，释放之
    connection = nil;
    
    // 不再需要使用 xmlData 指向的对象，释放之
    xmlData = nil;
    
    // 根据传入的 NSError 对象获取错误描述信息
    NSString *errorString = [NSString stringWithFormat:@"\nFetch failed: %@", [error description]];
    
    // 创建并打开警告视图，显示之前获取的错误描述信息
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [av show];
}

#pragma mark - tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
