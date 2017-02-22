//
//  TGTask.m
//  TGDriving
//
//  Created by James Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGTask.h"

@implementation TGTaskIcon

@end


@implementation TGTask
@synthesize taskType;

-(id) initWithTGTaskType:(TGTaskType)tgTaskType {
	if ((self = [super init])) {
		self.taskType = tgTaskType;
	}
	
	return self;
}

@end
