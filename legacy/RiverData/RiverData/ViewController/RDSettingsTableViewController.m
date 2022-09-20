//
//  RDSettingsTableViewController.m
//  RiverData
//
//  Created by Tim Kelly on 4/14/15.
//  Copyright (c) 2015 Tim Kelly. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "RDSettingsTableViewController.h"
#import "RDUserDefaults.h"

// 3rd party
#import "UIAlertView+Blocks.h"

@interface RDSettingsTableViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *filterNumbericSitesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *startAppOnFavorites;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation RDSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.filterNumbericSitesSwitch setOn:[RDUserDefaults getFilterNumericSites]];
    [self.startAppOnFavorites setOn:[RDUserDefaults getStartAppOnFavorites]];
    
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)launchMail{
    
//    NSString *appversion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
//    
//    NSString *subject  = [NSString stringWithFormat:@"River Data Support: %@", appversion];
//   
//    NSMutableString *mailbody  = [NSMutableString string];
//    [mailbody appendString:@"What's on your mind?"];
//    
//    NSString *recipients = [NSString stringWithFormat:@"mailto:fizzyartwerks@gmail.com?&subject=%@!",subject];
//    
//    NSString *body = [NSString stringWithFormat:@"&body=%@!",mailbody];;
//    
//    NSString *emailString = [NSString stringWithFormat:@"%@%@", recipients, body];
//    
//    emailString = [emailString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailString]];
    
    if ([MFMailComposeViewController canSendMail])
    {
        
        NSString *appversion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString *subject  = [NSString stringWithFormat:@"River Data Support: %@", appversion];
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:subject];
        [mail setMessageBody:@"What's on your mind?" isHTML:NO];
        [mail setToRecipients:@[@"fizzyartwerks@gmail.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
    
}

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1 && indexPath.row == 1){
        // contact support
        [self launchMail];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    if (section == 1){
        return 3;
    } else if (section == 0){
        return 2;
    }
    return 0;
}

- (IBAction)filterSitesSwitchChanged:(id)sender {
    
    bool isOn = ((UISwitch *)sender).isOn;
    
    RDLog(@"Filter switch =  %d", isOn);
    
    [RDUserDefaults setFilterNumericSites:isOn];
    
}

- (IBAction)startAppOnFavoritesSwitchChanged:(id)sender {
    
    bool isOn = ((UISwitch *)sender).isOn;
    
    RDLog(@"Favorites switch =  %d", isOn);
    
    [RDUserDefaults setStartAppOnFavorites:isOn];
    
}

#pragma mark 

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            [UIAlertView showWithTitle:@"Thanks!" message:@"Thanks for contacting us. We'll be in touch shortly." handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                // nothing to do
            }];
            
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
