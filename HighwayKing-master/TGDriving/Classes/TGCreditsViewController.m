//
//  TGCreditsViewController.m
//  TGDriving
//
//  Created by Charles Magahern on 1/3/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "TGCreditsViewController.h"
#import "cocos2d.h"

#define kActionSheetObjectiveCodersTag 0
#define kActionSheetOmegaHernTag       1

static NSString *objCodersURL           = @"http://objectivecoders.com";
static NSString *objCodersTwitterURL    = @"http://twitter.com/objectivecoders";
static NSString *objCodersFacebookURL   = @"http://www.facebook.com/objectivecoders";
static NSString *omegahernURL           = @"http://omegahern.com/";

int lolz;

@implementation TGCreditsViewController
@synthesize versionLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	lolz = 0;
	
	NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
	[versionLabel setText:[NSString stringWithFormat:@"version %@", versionStr]];
}

#pragma mark -


#pragma mark Action Handlers

- (IBAction)dismissAction:(id)sender {
    EAGLView *v = [[CCDirector sharedDirector] openGLView];
    [v setUserInteractionEnabled:YES];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[v superview] cache:YES];
    
    [self.view removeFromSuperview];
    
    [UIView commitAnimations];
    
    
    [self autorelease];
}

- (IBAction)objectiveCodersAction:(id)sender {
    UIActionSheet *sht = [[UIActionSheet alloc] initWithTitle:@"Objective Coders LLC." 
                                                     delegate:self 
                                            cancelButtonTitle:@"Cancel" 
                                       destructiveButtonTitle:nil 
                                            otherButtonTitles:@"Official Website", @"Twitter", @"Facebook", nil];
    sht.tag = kActionSheetObjectiveCodersTag;
    [sht showInView:self.view];
    [sht release];
}

- (IBAction)omegaHernAction:(id)sender {
    UIActionSheet *sht = [[UIActionSheet alloc] initWithTitle:@"omegaHern LLC." 
                                                     delegate:self 
                                            cancelButtonTitle:@"Cancel" 
                                       destructiveButtonTitle:nil 
                                            otherButtonTitles:@"Official Website", nil];
    sht.tag = kActionSheetOmegaHernTag;
    [sht showInView:self.view];
    [sht release];
}

- (IBAction)omhrn:(id)sender {
	lolz++;
	
	if (lolz == 10) {
		UIImageView *brutherz = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"brutherz.png"]];
		[brutherz setFrame:[((UIView*)sender) frame]];
		
		[brutherz setTransform:CGAffineTransformMakeScale(0.1, 0.1)];
		[self.view addSubview:brutherz];
		
		[UIView beginAnimations:@"brutherz" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.8];
		[brutherz setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark Delegate Callbacks

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kActionSheetObjectiveCodersTag) {
        switch (buttonIndex) {
            case 0:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:objCodersURL]];
                break;
            case 1:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:objCodersTwitterURL]];
                break;
            case 2:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:objCodersFacebookURL]];
                break;
            default:
                break;
        }
    } else if (actionSheet.tag == kActionSheetOmegaHernTag) {
        if (buttonIndex == 0)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:omegahernURL]];
    }
}

#pragma mark -


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    [super dealloc];
}


@end
