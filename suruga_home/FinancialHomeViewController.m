//
//  FinancialHomeViewController.m
//  suruga_home
//
//  Created by Ted Tomlinson on 1/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FinancialHomeViewController.h"
#import "BudgetTableViewController.h"
#import "FinancialAdviceViewController.h"
#import "FinancialAdvisorAnswerViewController.h"
#import "suruga_homeAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "extThree20JSON/SBJson.h"
#import "DCRoundSwitch.h"
#import "UserData.h"

@implementation FinancialHomeViewController
@synthesize managedObjectContext;

@synthesize initialIncomeLabel;
@synthesize initialExpenseLabel;
@synthesize initialTotalLabel;
@synthesize runningIncomeLabel;
@synthesize runningExpenseLabel;
@synthesize runningTotalLabel;
@synthesize runningBudgetButton;
@synthesize isRentingSwitch;
@synthesize inititalBudgetButton;
@synthesize financialAdviceButton;
@synthesize initialIncomeTotalLabel;
@synthesize initialExpenseTotalLabel;
@synthesize initialTotalTotalLabel;
@synthesize runningIncomeTotalLabel;
@synthesize runningExpenseTotalLabel;
@synthesize runningTotalTotalLabel;
@synthesize adviceDict;

#pragma mark Private Methods
- (void) resizeAdviceButtonForString: (NSString *) adviceText {
    CGSize maximumLabelSize = CGSizeMake(300,10);
    CGSize expectedLabelSize = [adviceText sizeWithFont:financialAdviceButton.titleLabel.font
        constrainedToSize:maximumLabelSize 
        lineBreakMode:financialAdviceButton.titleLabel.lineBreakMode]; 
    
    //adjust the label the the new height.
    CGRect newFrame = financialAdviceButton.frame;
    newFrame.size.height = expectedLabelSize.height + 5;
    newFrame.size.width = expectedLabelSize.width + 15;
    //TODO somehow center the button or don't adjust width.
    financialAdviceButton.frame = newFrame;
    [financialAdviceButton setTitle:adviceText forState:UIControlStateNormal];
}
- (void) layoutBarChart {
    //Reset advice
    self.adviceDict = nil;
    //[financialAdviceButton setTitle:NSLocalizedString(@"Budget Advice", @"Budget Advice default text") forState:UIControlStateNormal];
    //Compute bar charts
    double initialIncome = (double)[BudgetItem sumItemsWithContext:managedObjectContext inInitial:YES isExpense:NO];
    double initialCost = (double)[BudgetItem sumItemsWithContext:managedObjectContext inInitial:YES isExpense:YES];
    double runningIncome = (double)[BudgetItem sumItemsWithContext:managedObjectContext inInitial:NO isExpense:NO];
    double runningCost = (double)[BudgetItem sumItemsWithContext:managedObjectContext inInitial:NO isExpense:YES];
    double initialLeftover = fabs(initialCost - initialIncome);
    if ( initialIncome > initialCost ) {
        double delta = (initialCost / (initialIncome <0.001 ? 1 : initialIncome));
        initialIncomeLabel.frame = CGRectMake(10, 0, 64, 100);
        initialExpenseLabel.frame = CGRectMake(76, 100 * (1 - delta), 64, 100 * delta);
        delta = (initialLeftover / (initialIncome <0.001 ? 1 : initialIncome));
        initialTotalLabel.frame = CGRectMake(147, 100 * (1- delta), 64, 100 * delta);
        initialTotalLabel.backgroundColor = [UIColor blackColor];
        initialTotalLabel.textColor = [UIColor whiteColor];
    } else {
        double delta = (initialIncome / (initialCost <0.001 ? 1 : initialCost));
        initialIncomeLabel.frame = CGRectMake(10, 100 * (1-delta), 64, 100 * delta);
        initialExpenseLabel.frame = CGRectMake(76, 0, 64, 100);
        delta = (initialLeftover / (initialCost <0.001 ? 1 : initialCost));
        initialTotalLabel.frame = CGRectMake(147, 100 * (1-delta), 64, 100 * delta);
        initialTotalLabel.backgroundColor = [UIColor redColor];
        initialTotalLabel.textColor = [UIColor blackColor];
    }
    double runningLeftover = fabs(runningCost - runningIncome);
    if ( runningIncome > runningCost ) {
        double delta = (runningCost / (runningIncome <0.001 ? 1 : runningIncome));
        runningIncomeLabel.frame = CGRectMake(10, 144, 64, 100);
        runningExpenseLabel.frame = CGRectMake(76, 144+100 * (1 - delta), 64, 100 * delta);
        delta = (runningLeftover / (runningIncome <0.001 ? 1 : runningIncome));
        runningTotalLabel.frame = CGRectMake(147, 144+100 * (1- delta), 64, 100 * delta);
        runningTotalLabel.backgroundColor = [UIColor blackColor];
        runningTotalLabel.textColor = [UIColor whiteColor];
    } else {
        double delta = (runningIncome / (runningCost <0.001 ? 1 : runningCost));
        runningIncomeLabel.frame = CGRectMake(10, 144+100 * (1-delta), 64, 100 * delta);
        runningExpenseLabel.frame = CGRectMake(76, 144, 64, 100);
        delta = (runningLeftover / (runningCost <0.001 ? 1 : runningCost));
        runningTotalLabel.frame = CGRectMake(147, 144+100 * (1-delta), 64, 100 * delta);
        runningTotalLabel.backgroundColor = [UIColor redColor];
        runningTotalLabel.textColor = [UIColor blackColor];
    } 
    //Set label Text
    //TODO internationalize
    initialExpenseTotalLabel.text = [NSString stringWithFormat:@"$%d",(int)initialCost];
    initialIncomeTotalLabel.text = [NSString stringWithFormat:@"$%d",(int)initialIncome];
    initialTotalTotalLabel.text = [NSString stringWithFormat:@"$%d",(int)initialLeftover];
    runningExpenseTotalLabel.text = [NSString stringWithFormat:@"$%d",(int)runningCost];
    runningIncomeTotalLabel.text = [NSString stringWithFormat:@"$%d",(int)runningIncome];
    runningTotalTotalLabel.text = [NSString stringWithFormat:@"$%d",(int)runningLeftover];
    
    //Set class instance variables
    initialAmount = (int)(initialIncome - initialCost);
    runningAmount = (int)(runningIncome - runningCost);
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Set renting switch
    self.isRentingSwitch.onText = NSLocalizedString(@"Renting", @"Renting Option");
	self.isRentingSwitch.offText = NSLocalizedString(@"Buying", @"Buying Option");
    self.title = NSLocalizedString(@"Budget Planning", @"Budget Planning Home Title");
    
    // Do any additional setup after loading the view from its nib.
    if (managedObjectContext == nil) { 
        self.managedObjectContext = [(suruga_homeAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutBarChart];
}
- (void)viewDidUnload
{
    self.managedObjectContext = nil;
    [self setInitialIncomeLabel:nil];
    [self setInitialExpenseLabel:nil];
    [self setInitialTotalLabel:nil];
    [self setRunningIncomeLabel:nil];
    [self setRunningExpenseLabel:nil];
    [self setRunningTotalLabel:nil];
    [self setRunningBudgetButton:nil];
    [self setInititalBudgetButton:nil];
    [self setFinancialAdviceButton:nil];
    self.adviceDict = nil;
    [loadingIndicator release];
    loadingIndicator = nil;
    [self setIsRentingSwitch:nil];
    [self setInitialIncomeTotalLabel:nil];
    [self setInitialExpenseTotalLabel:nil];
    [self setInitialTotalTotalLabel:nil];
    [self setRunningIncomeTotalLabel:nil];
    [self setRunningExpenseTotalLabel:nil];
    [self setRunningTotalTotalLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [initialIncomeLabel release];
    [initialExpenseLabel release];
    [initialTotalLabel release];
    [runningIncomeLabel release];
    [runningExpenseLabel release];
    [runningTotalLabel release];
    [runningBudgetButton release];
    [inititalBudgetButton release];
    [financialAdviceButton release];
    [adviceDict release];
    [loadingIndicator release];
    [isRentingSwitch release];
    [initialIncomeTotalLabel release];
    [initialExpenseTotalLabel release];
    [initialTotalTotalLabel release];
    [runningIncomeTotalLabel release];
    [runningExpenseTotalLabel release];
    [runningTotalTotalLabel release];
    [super dealloc];
}
- (IBAction)initialBudgetClicked:(id)sender {
    BudgetTableViewController *budgetController = [[[BudgetTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    budgetController.managedObjectContext = self.managedObjectContext;
    budgetController.isInitial = YES;
    [self.navigationController pushViewController:budgetController animated:YES];
}

- (IBAction)runningBudgetClicked:(id)sender {
    BudgetTableViewController *budgetController = [[[BudgetTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    budgetController.managedObjectContext = self.managedObjectContext;
    budgetController.isInitial = NO;
    [self.navigationController pushViewController:budgetController animated:YES];
}

- (IBAction)financialAdviceClicked:(id)sender {
    FinancialAdviceViewController * vc = [[FinancialAdviceViewController alloc] initWithNibName:@"FinancialAdviceViewController" bundle:nil]; 
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    

    /* Dynamic advice
    if (nil == self.adviceDict) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://glurban10.mit.edu/suruga/advisor/budget?running=%d&initial=%d", runningAmount, initialAmount]];
        __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setCompletionBlock:^{
            // Use when fetching binary data
            NSData *responseData = [request responseData];
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            //TODO validate the json string using an actual jsonParse rather than JSONValue shortcut
            NSDictionary *dataDict = [responseString JSONValue];
            NSString *adviceText = [dataDict valueForKey:@"advice_text"];
            [financialAdviceButton setTitle:adviceText forState:UIControlStateNormal];
            //Set dictionary that button should launch to
            self.adviceDict = [dataDict valueForKey:@"slide"];
            [responseString release];
            [loadingIndicator stopAnimating];
            [loadingIndicator setHidden:YES];
        }];
        [request setFailedBlock:^{
            //NSError *error = [request error];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", @"Network error alert dialog title") 
                message:NSLocalizedString(@"Please check that you have a network connection", @"Network Connection validation alert dialog")
                delegate:nil 
                cancelButtonTitle:NSLocalizedString(@"OK", @"dialog OK text")
                otherButtonTitles:nil];
            [alert show];
            [alert release];
        }];
        //Start request
        [loadingIndicator setHidden:NO];
        [loadingIndicator startAnimating]; 
        [request startAsynchronous];
    }
    else {
        if ([@"question_slide" isEqualToString:[adviceDict objectForKey:@"type"]]) {
            FinancialAdviceViewController * vc = [[FinancialAdviceViewController alloc] initWithNibName:@"FinancialAdviceViewController" bundle:nil];
            vc.dataDict = self.adviceDict;
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        } else {
            //Answer slide
            FinancialAdvisorAnswerViewController * vc = [[FinancialAdvisorAnswerViewController alloc] initWithNibName:@"FinancialAdvisorAnswerViewController" bundle:nil];
            vc.dataDict = self.adviceDict;
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
    }
     */
}

- (IBAction)isRentSwitched:(id)sender {
    [UserData setUserRentingWithContext:self.managedObjectContext val: self.isRentingSwitch.on];
    [self layoutBarChart];
}
@end
