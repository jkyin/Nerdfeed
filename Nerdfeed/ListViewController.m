//
//  ListViewController.m
//  Nerdfeed
//
//  Created by Yin on 14-2-17.
//  Copyright (c) 2014年 Jack Yin. All rights reserved.
//

#import "ListViewController.h"
#import "RSSChannel.h"
#import "RSSItem.h"
#import "WebViewController.h"

@implementation ListViewController

@synthesize webViewController;

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
                  @"limit=7_DAY&sort_by=standard&feed_type=RSS2.0&feed_style=COMPACT"];
    
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
    // 创建 NSXMLParser 对象并传入获取自 Web 服务的数据
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    
    [parser setDelegate:self];
    
    // 启动解析过程：在解析 XML 数据的过程中
    // NSXMLParser 对象会向其委托对象发送相应的委托消息
    // 在本行代码结束运行前，主线程会阻塞（blocking）
    [parser parse];
    
    // 不再需要使用 xmlData 指向的对象，释放之
    xmlData = nil;
    
    // 不再需要使用 connection 指向的对象，释放之
    connection = nil;
    
    NSLog(@"\n %@\n %@\n %@\n", channel, [channel title], [channel infoString]);
    
    // 刷新 UITableView 对象，该对象目前不会显示任何数据
    [[self tableView] reloadData];
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

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser
    didStartElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    NSLog(@"\n%@ found a %@ element", self, elementName);
    if ([elementName isEqualToString:@"channel"]) {
        
        // 如果 NSXMLParser 对象找到了 channel 元素的起始标记，就创建新对象并将其地址赋给相应的实例变量
        channel = [[RSSChannel alloc] init];
        
        // 为新创建的 RSSChannel 对象设置「上一个委托对象」属性，指向当前对象
        [channel setParentParserDelegate:self];
        
        // 将 NSXMLParser 对象的委托对象设置为新创建的 RSSChannel 对象
        [parser setDelegate:channel];
    }
}

#pragma mark - tableView

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 将 WebViewController 对象压入 UINavigationBar 栈
    // 当应用首次显示 WebViewController 对象时，
    // 会创建 WebViewController 对象的视图
    [[self navigationController] pushViewController:webViewController animated:YES];
    
    // 获取选中的 RSSitem 对象
    RSSItem *entry = [[channel items] objectAtIndex:[indexPath row]];
    
    // 根据 RSSItem 对象的 link 属性创建 URL
    NSURL *url = [NSURL URLWithString:[entry link]];
    
    // 根据之前创建的 URL 创建 NSURLRequest 对象
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    // 要求 UIWebView 对象根据 NSURLRquest 对象载入相应的网页
    [[webViewController webView] loadRequest:req];
    
    // 设置 WebViewController 对象的导航条标题
    [[webViewController navigationItem] setTitle:[entry title]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[channel items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    RSSItem *item = [[channel items] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[item title]];
    
    return cell;
}

@end
