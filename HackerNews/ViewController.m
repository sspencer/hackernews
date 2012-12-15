//
//  ViewController.m
//  HackerNews
//
//  Created by Steven Spencer on 12/12/12.
//  Copyright (c) 2012 Steven Spencer. All rights reserved.
//

#import "ViewController.h"
#import "RXMLElement.h"
#import "WebViewController.h"

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
@property(strong, nonatomic) UIFont *defaultFont;
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
    _defaultFont = [UIFont systemFontOfSize:14.0];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor orangeColor];
    [refreshControl addTarget:self action:@selector(refreshNews:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self fetchData:nil];
}

- (void)refreshNews:(id)sender
{
    [self fetchData:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchData:(UIRefreshControl *)refreshControl
{
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(concurrentQueue, ^{
        __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:30];
        dispatch_sync(concurrentQueue, ^{
            RXMLElement *rootXML = [[RXMLElement alloc] initFromURL:[NSURL URLWithString:@"http://news.ycombinator.com/rss"]];

            [rootXML iterateWithRootXPath:@"//channel/item" usingBlock:^(RXMLElement *item) {
                NSDictionary *article = @{
                ARTICLE_TITLE : [item child:@"title"].text,
                ARTICLE_HOST  : [[NSURL URLWithString:[item child:@"link"].text] host],
                ARTICLE_LINK  : [item child:@"link"].text,
                COMMENTS_LINK : [item child:@"comments"].text
                };
                [array addObject:article];
            }];

        });

        dispatch_sync(dispatch_get_main_queue(), ^{
            self.articles = [NSArray arrayWithArray:array];
            [self.tableView reloadData];
            [refreshControl endRefreshing];
        });
    });
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

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat y = 4.0;
    
    UILabel *label = (UILabel *)[cell viewWithTag:kTitleLabel];
    CGRect rect = label.frame;
    label.frame = CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height);

    label = (UILabel *)[cell viewWithTag:kNumberLabel];
    rect = label.frame;
    label.frame = CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height);
}
 */

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *article = self.articles[indexPath.row];
    NSString *text = [article valueForKey:ARTICLE_TITLE];

    CGSize size = [text sizeWithFont: _defaultFont constrainedToSize:CGSizeMake(tableView.frame.size.width-80, 240)];

    float height = size.height + 26.0; // add padding to text height for rest of cell
    return MAX(44.0, height);
}

#pragma mark - Table view delegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *article = self.articles[indexPath.row];
    NSLog(@"open browser to %@", [article valueForKey:ARTICLE_LINK]);
    [self performSegueWithIdentifier:@"web" sender:self];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *article = self.articles[indexPath.row];
    NSLog(@"show comments for %@", [article valueForKey:COMMENTS_LINK]);
    //[self performSegueWithIdentifier:@"comment" sender:self];
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Segue: %@", segue.identifier);

    if ([segue.identifier isEqualToString:@"web"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *article = self.articles[indexPath.row];
        [(WebViewController *)segue.destinationViewController setUrl:[article valueForKey:ARTICLE_LINK]];
    }
}

@end
