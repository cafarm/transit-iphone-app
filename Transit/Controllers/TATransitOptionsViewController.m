//
//  TATransitOptionsViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/11/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TATransitOptionsViewController.h"

typedef enum {
    TARoutingSection,
    TATimeSection,
    TAItinerariesSection
} TATransitOptionSection;

@interface TATransitOptionsViewController ()
{
    UIBarButtonItem *_doneButton;
    NSArray *_sectionKeys;
    NSDictionary *_tableContent;
}

@end

@implementation TATransitOptionsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [[self navigationItem] setTitle:@"Transit Options"];
        
        _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
        self.navigationItem.rightBarButtonItem = _doneButton;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *routingKey = @"Routing";
    NSString *timeKey = @"Time";
    NSString *itinerariesKey = @"Itineraries";
    
    _sectionKeys = [NSArray arrayWithObjects:routingKey,timeKey, itinerariesKey, nil];
    
    NSArray *routing = [NSArray arrayWithObjects:@"Best Route", @"Fewer Transfers", @"Less Walking", nil];
    NSArray *time = [NSArray arrayWithObject:[NSDate date]];
    NSMutableArray *itineraries = [NSArray arrayWithObjects:@"", @"", @"", nil];
    
    _tableContent = [NSMutableDictionary dictionaryWithObjectsAndKeys:routing, routingKey, time, timeKey, itineraries, itinerariesKey, nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)dismissViewController
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_tableContent count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [_sectionKeys objectAtIndex:section];
    return [[_tableContent objectForKey:key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSString *key = [_sectionKeys objectAtIndex:[indexPath section]];
    NSArray *contents = [_tableContent objectForKey:key];
    NSObject *contentForRow = [contents objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", contentForRow];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TATransitOptionSection section = indexPath.section;
    switch (section) {
        case TARoutingSection:

            break;
        case TATimeSection:

            break;
        case TAItinerariesSection:

            break;
        default:
            break;
    }
}

@end
