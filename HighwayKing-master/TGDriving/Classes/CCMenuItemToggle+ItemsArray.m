//
//  CCMenuItemToggle+ItemsArray.m
//  TGDriving
//
//  Created by James Magahern on 1/3/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "CCMenuItemToggle+ItemsArray.h"


@implementation CCMenuItemToggle(ItemsArray)

-(id) initWithTarget:(id)t selector:(SEL)s itemsArray:(NSMutableArray*)items {
	if( (self=[super initWithTarget:t selector:s]) ) {
		
		self.subItems = items;
		
		selectedIndex_ = NSUIntegerMax;
		[self setSelectedIndex:0];
	}
	
	return self;
}

@end
