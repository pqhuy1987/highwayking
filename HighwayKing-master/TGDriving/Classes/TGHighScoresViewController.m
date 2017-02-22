//
//  HighScoresViewController.m
//  Chain2
//
//  Created by Charles Magahern on 10/1/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGHighScoresViewController.h"
#import "TGHighScoresController.h"
#import "cocos2d.h"

NSMutableArray *_highScores;

@implementation TGHighScoresViewController
@synthesize noScoresView, scoresTableView, gameTypeSwitcher;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_highScores = [[NSMutableArray alloc] initWithArray:[[TGHighScoresController sharedHighScoresController] highScoresForGameType:TGGameTypeCareer]];
	
	if ([_highScores count] == 0) {
        [noScoresView setHidden:NO];
        [scoresTableView setScrollEnabled:NO];
    } else {
   		[noScoresView setHidden:YES];
        [scoresTableView setScrollEnabled:YES];
    }
    
    CGRect noScoresRect = [noScoresView bounds];
    noScoresRect.origin.x = round( ((self.view.frame.size.width - noScoresRect.size.width) / 2.0) );
    noScoresRect.origin.y = round( (self.view.frame.size.height / 2.0) - (noScoresRect.size.height / 2.0) + 50.0 );
    [noScoresView setFrame:noScoresRect];
    [self.view addSubview:noScoresView];
    
    [scoresTableView setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellID = @"HighScoreCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellID] autorelease];
    }
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary *cur = [_highScores objectAtIndex:indexPath.row];
    
	if (indexPath.row >= 3)
		cell.textLabel.text = [[NSString stringWithFormat:@"%uth.   ", indexPath.row + 1] stringByAppendingString:[[cur objectForKey:@"score"] stringValue]];
	else
		cell.textLabel.text = [[cur objectForKey:@"score"] stringValue];
    
    cell.detailTextLabel.text = [cur objectForKey:@"level"];
	
	switch (indexPath.row) {
		case 0:
			cell.imageView.image = [UIImage imageNamed:@"1st-place.png"];
			break;
		case 1:
			cell.imageView.image = [UIImage imageNamed:@"2nd-place.png"];
			break;
		case 2:
			cell.imageView.image = [UIImage imageNamed:@"3rd-place.png"];
			break;
        default:
            cell.imageView.image = nil;
            break;
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_highScores count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (IBAction)doneButtonTapped:(id)sender {
    EAGLView *v = [[CCDirector sharedDirector] openGLView];
    [v setUserInteractionEnabled:YES];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[v superview] cache:YES];
    
    [self.view removeFromSuperview];
    
    [UIView commitAnimations];
    
    
    [self autorelease];
}

- (IBAction)clearButtonTapped:(id)sender {
    NSString *dstrct = ([gameTypeSwitcher selectedSegmentIndex] == 0 ? @"Clear All Career Scores" : @"Clear All Endless Scores");
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:dstrct otherButtonTitles:nil];
	[actionSheet showInView:self.view];
}

- (IBAction)gameModeSwitched:(id)sender {
    int sel = [gameTypeSwitcher selectedSegmentIndex];
    [_highScores removeAllObjects];
    if (sel == 0) {
        [_highScores addObjectsFromArray:[[TGHighScoresController sharedHighScoresController] highScoresForGameType:TGGameTypeCareer]];
    } else if (sel == 1) {
        [_highScores addObjectsFromArray:[[TGHighScoresController sharedHighScoresController] highScoresForGameType:TGGameTypeEndless]];
    }
    
    [scoresTableView reloadData];
    
    if ([_highScores count] == 0) {
        [noScoresView setHidden:NO];
        [scoresTableView setScrollEnabled:NO];
    } else {
   		[noScoresView setHidden:YES];
        [scoresTableView setScrollEnabled:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([gameTypeSwitcher selectedSegmentIndex] == 0) {
            [[TGHighScoresController sharedHighScoresController] clearHighScoresForGameType:TGGameTypeCareer];
        } else if ([gameTypeSwitcher selectedSegmentIndex] == 1) {
            [[TGHighScoresController sharedHighScoresController] clearHighScoresForGameType:TGGameTypeEndless];            
        }
        
        [_highScores removeAllObjects];
        
        [scoresTableView reloadData];
        [noScoresView setHidden:NO];
        [scoresTableView setScrollEnabled:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.noScoresView = nil;
    self.scoresTableView = nil;
    self.gameTypeSwitcher = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end
