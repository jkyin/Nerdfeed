//
//  RSSChannel.m
//  Nerdfeed
//
//  Created by Yin on 14-2-17.
//  Copyright (c) 2014年 Jack Yin. All rights reserved.
//

#import "RSSChannel.h"
#import "RSSItem.h"

@implementation RSSChannel

@synthesize parentParserDelegate, title, infoString, items;

- (id)init
{
    self = [super init];
    
    if (self) {
        // 创建容器对象，用于存放当前的 RSSChannel 对象所包含的 RSSItem 对象
        // 稍后回创建 RssItem 类
        items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"\n\t%@ found a %@ element", self, elementName);
    
    if ([elementName isEqual:@"title"]) {
        currentString = [[NSMutableString alloc] init];
        [self setTitle:currentString];
    }
    else if ([elementName isEqual:@"description"]) {
        currentString = [[NSMutableString alloc]init];
        [self setInfoString:currentString];
    }
    else if ([elementName isEqual:@"item"]) {
        // 如果 NSXMLParser 对象找到了 item 元素的起始标记，就创建 RSSItem 对象
        RSSItem *entry = [[RSSItem alloc] init];
        // 为新创建的 RSSItem 对象设置「上一个委托对象」属性，并指向当前对象
        [entry setParentParserDelegate:self];
        // 将 NSXMLParser 对象的委托对象设置为新创建的 RSSItem 对象
        [parser setDelegate:entry];
        // 将新创建的 RSSItem 对象加入 items 数组
        [items addObject:entry];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // 如果 RSSChannel 对象曾向 currentString 追加过字符，
    // 那么代码就会释放相应的对象
    currentString = nil;
    
    // 如果 NSXMLParser 对象找到的是 channel 元素的结束标记，
    // 就将 NSXMLParser 对象的委托对象设置为之前的委托对象
    if ([elementName isEqualToString:@"channel"]) {
        [parser setDelegate:parentParserDelegate];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentString appendString:string];
}

@end
