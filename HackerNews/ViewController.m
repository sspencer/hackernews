//
//  ViewController.m
//  HackerNews
//
//  Created by Steven Spencer on 12/12/12.
//  Copyright (c) 2012 Steven Spencer. All rights reserved.
//

#import "ViewController.h"
#import "RXMLElement.h"

#define ARTICLE_TITLE @"title"
#define ARTICLE_HOST  @"articleHost"
#define ARTICLE_LINK  @"articleLink"
#define COMMENTS_LINK @"commentsLink"

enum {
    kTitleLabel = 1,
    kHostLabel = 2,
    kNumberLabel = 3
};

@interface ViewController ()
@property(strong, nonatomic) NSArray *articles;
@end


@implementation ViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    RXMLElement *rootXML = [[RXMLElement alloc] initFromURL:[NSURL URLWithString:@"http://news.ycombinator.com/rss"]];

    /*
     [rootXML iterate:@"rss.channel" usingBlock:^(RXMLElement *item) {
     NSLog(@"ITEM: %@", item);
     }];
     */
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:30];
    [rootXML iterateWithRootXPath:@"//channel/item" usingBlock:^(RXMLElement *item) {
        NSDictionary *article = @{
            ARTICLE_TITLE : [item child:@"title"].text,
            ARTICLE_HOST  : [[NSURL URLWithString:[item child:@"link"].text] host],
            ARTICLE_LINK  : [item child:@"link"].text,
            COMMENTS_LINK : [item child:@"comments"].text
        };
        [array addObject:article];
    }];

    self.articles = [NSArray arrayWithArray:array];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _articles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *article = self.articles[indexPath.row];
    NSString *number = [NSString stringWithFormat:@"%d.", (indexPath.row+1)];

    [(UILabel *)[cell viewWithTag:kTitleLabel] setText:[article valueForKey:ARTICLE_TITLE]];
    [(UILabel *)[cell viewWithTag:kHostLabel] setText:[article valueForKey:ARTICLE_HOST]];
    [(UILabel *)[cell viewWithTag:kNumberLabel] setText:number];

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
