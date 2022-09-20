//
//  RDStateSelectionViewController.m
//  RiverData
//
//  Created by Tim Kelly on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import "RDStateSelectionViewController.h"
#import "RDStateGaugesTableViewController.h"
#import "RDSingleStateModel.h"
#import "RDStateSelectionTableViewCell.h"
#import "RDSiteMapViewViewController.h"

@interface RDStateSelectionViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>


@property (weak, nonatomic) IBOutlet UITableView *statesTableView;
//@property (strong, nonatomic) RDStateModel *stateModel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) UIBarButtonItem *rightBarButton;

@property (strong, nonatomic) NSMutableArray *stateModels;          // Default states to select
@property (strong, nonatomic) NSMutableArray *filteredStateModels;  // Filtered states
@property (assign, nonatomic) BOOL isFiltered;

// Cluster map support
@property (strong, nonatomic) RDSiteMapViewViewController *mapVC;

@end

@implementation RDStateSelectionViewController

@synthesize stateModels = _stateModels, filteredStateModels = _filteredStateModels;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
   
    [self initStateModels];
    
    self.searchBar.delegate = self;
    
    self.navigationItem.title = @"State Gauges";
    NSString *rightBarButtonTitle = @"US Map";
    
    self.rightBarButton = [[UIBarButtonItem alloc] initWithTitle:rightBarButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(showSiteOnMap:)];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    
    self.mapVC = [[RDSiteMapViewViewController alloc] initWithNibName:@"RDSiteMapViewViewController" bundle:nil];
    //self.mapVC.filterOnTwoLetterStateCode = @"tx";
    [self.statesTableView reloadData];
}


- (void)initStateModels{
    
    NSArray *twoLetterStateNames = [[NSArray alloc] initWithObjects:@"AL",
                                @"AK", @"AZ", @"AR", @"CA",
                                @"CO", @"CT", @"DE", @"DC",@"FL",@"GA",@"HI",
                                @"ID",@"IL",@"IN",@"IA",@"KS",@"KY",@"LA",@"ME",@"MD",@"MA",@"MI",@"MN",@"MS",@"MO",
                                @"MT",@"NE",@"NV",@"NH",@"NJ",@"NM",@"NY",@"NC",@"ND",@"OH",@"OK",@"OR",@"PA",@"PR",@"RI",
                                @"SC",@"SD",@"TN",@"TX",@"UT",@"VT",@"VA",@"WA",@"WV",@"WI",@"WY", nil];
    
    NSArray *stateDisplayNames = [[NSArray alloc] initWithObjects:@"Alabama",
                       @"Alaska",
                       @"Arizona",
                       @"Arkansas",@"California",@"Colorado",@"Connecticut",
                       @"Delaware",@"District of Columbia",@"Florida",@"Georgia",
                       @"Hawaii",@"Idaho",@"Illinois",
                       @"Indiana",@"Iowa",@"Kansas",
                       @"Kentucky",@"Louisiana",
                       @"Maine",@"Maryland",
                       @"Massachusetts",@"Michigan",
                       @"Minnesota",@"Mississippi",@"Missouri",
                       @"Montana",@"Nebraska",@"Nevada",
                       @"New Hampshire",@"New Jersey",@"New Mexico",
                       @"New York",@"North Carolina",@"North Dakota",@"Ohio",
                       @"Oklahoma",@"Oregon",
                       @"Pennsylvania",@"Puerto Rico",
                       @"Rhode Island",@"South Carolina",
                       @"South Dakota",@"Tennessee",@"Texas",
                       @"Utah",@"Vermont",@"Virginia",
                       @"Washington",@"West Virginia",
                       @"Wisconsin",@"Wyoming",nil];
    
    self.stateModels = [NSMutableArray array];
    
    for (int i = 0; i < twoLetterStateNames.count; i++){
        
        NSString *stateNameLower = [[twoLetterStateNames objectAtIndex:i] lowercaseString];
        UIImage *stateThumb = [UIImage imageNamed:stateNameLower];
        
        RDSingleStateModel *state = [[RDSingleStateModel alloc] initStateWithDisplayName:[stateDisplayNames objectAtIndex:i] withCharCode:[twoLetterStateNames objectAtIndex:i] withThumbNail:stateThumb];
        
        [self.stateModels addObject:state];
        
    }
    
    self.filteredStateModels = [NSMutableArray arrayWithCapacity:[self.stateModels count]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    RDLog(@"Prepare for seque");
    if ([sender isKindOfClass:[UITableViewCell class]]){
        RDStateGaugesTableViewController *targetVC = [segue destinationViewController];

        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.statesTableView indexPathForCell:cell];
        
        if (self.isFiltered){
            targetVC.state = [self.filteredStateModels objectAtIndex:indexPath.row];
        } else {
            targetVC.state = [self.stateModels objectAtIndex:indexPath.row];
        }
    }
    
}

- (void)showSiteOnMap:(id)sender{
    
        [UIView transitionWithView:self.navigationController.view duration:1.00 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.navigationController pushViewController:self.mapVC animated:NO];
        } completion:^(BOOL finished) {
            // completion
        }];
    
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers{
    return YES;
}

#pragma mark UITableView delegate/data source


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.isFiltered){
        return [self.filteredStateModels count];
    } else {
        return [self.stateModels count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RDStateSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    /*
     *   If the cell is nil it means no cell was available for reuse and that we should
     *   create a new one.
     */
    if (cell == nil) {
        
        /*
         *   Actually create a new cell (with an identifier so that it can be dequeued).
         */
        
        cell = [[RDStateSelectionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    RDSingleStateModel *state;
    
    if (self.isFiltered){
        state = [self.filteredStateModels objectAtIndex:indexPath.row];
    } else {
       state = [self.stateModels objectAtIndex:indexPath.row];
    }
    
    
    cell.textLabel.text = state.displayName;
    
    cell.imageView.image = state.thumb;
    
    [cell layoutSubviews];
    
    return cell;
};

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark - UISearchDisplayController Delegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length == 0){
        self.isFiltered = NO;
    } else {
        self.isFiltered = YES;
        self.filteredStateModels = [NSMutableArray array];
        for (RDSingleStateModel *state in self.stateModels){
            
            NSRange nameRange = [state.displayName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange descriptionRange = [state.twoLetterCode rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (nameRange.location != NSNotFound || descriptionRange.location != NSNotFound){
                [self.filteredStateModels addObject:state];
            }
        }
    }
    
    [self.statesTableView reloadData];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.isFiltered = NO;
    [self.searchBar setText:@""];
    [self.searchBar resignFirstResponder];
    [self.statesTableView reloadData];
}



@end
