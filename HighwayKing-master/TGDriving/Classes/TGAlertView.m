//
//  TGAlertView.m
//  TGDriving
//
//  Created by James Magahern on 12/19/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGAlertView.h"


@implementation TGAlertView
@synthesize alertTitle, alertMessage;

UILabel *titleLabel;
UILabel *descriptionLabel;

- (id)init {
	if ( (self = [super init]) ) {
		UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_back.png"]];
		background.center = CGPointMake(142, 60);
        background.tag = 1337;
		
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, -30.0, 257.0, 34.0)];
        [titleLabel setTextAlignment:UITextAlignmentCenter];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:28.0]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 8.0, 257.0, 77.0)];
        [descriptionLabel setTextAlignment:UITextAlignmentCenter];
        [descriptionLabel setFont:[UIFont systemFontOfSize:18.0]];
        [descriptionLabel setTextColor:[UIColor whiteColor]];
        [descriptionLabel setBackgroundColor:[UIColor clearColor]];
        [descriptionLabel setNumberOfLines:3];
		
		[self addSubview:background];
        [self addSubview:titleLabel];
        [self addSubview:descriptionLabel];
	}
	
	return self;
}

- (void)setAlertTitle:(NSString *)_title {
    [alertTitle autorelease];
    alertTitle = [_title retain];
    [titleLabel setText:_title];
}

- (void)setAlertMessage:(NSString *)_message {
    [alertMessage autorelease];
    alertMessage = [_message retain];
    [descriptionLabel setText:_message];
}

- (void)layoutSubviews {
	for (UIView *sub in [self subviews]) {
		if([sub class] == [UIImageView class] && sub.tag == 0) {
			[sub removeFromSuperview];
			break;
		}
	}
}

- (void)drawRect:(CGRect)rect {	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(context, rect);
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
	self = [super initWithTitle:@"" message:@"\n\n\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
	
	[self setAlertTitle:title];
    [self setAlertMessage:message];
	
	return self;
}

- (void)dealloc {
    [titleLabel release];
    [descriptionLabel release];
    [alertTitle release];
    [alertMessage release];
    
    [super dealloc];
}

@end
