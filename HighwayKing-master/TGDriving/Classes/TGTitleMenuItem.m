//
//  TGTitleMenuItem.m
//  TGDriving
//
//  Created by James Magahern on 1/1/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "TGTitleMenuItem.h"


@implementation TGTitleMenuItem

- (void)selected {
	[super selected];
	
	[self runAction:[CCRotateTo actionWithDuration:0.1 angle:15]];
}

- (void)unselected {
	[super selected];
	
	[self runAction:[CCEaseBounceOut actionWithAction:[CCRotateTo actionWithDuration:0.3 angle:0]]];
}

@end
