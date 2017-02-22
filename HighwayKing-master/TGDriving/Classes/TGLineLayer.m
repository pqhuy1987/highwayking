//
//  TGLineLayer.m
//  TGDriving
//
//  Created by Charles Magahern on 10/23/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGLineLayer.h"
#import "CCDrawingPrimitives.h"

@implementation TGLineLayer
@synthesize drawingMode, trucks;

- (id)initWithTrucksArray:(NSArray *)_trucks {
	if ( (self = [super init]) ) {
		self.trucks = _trucks;
		self.drawingMode = TGLineLayerDrawingModeDrivingPath;
        [self setOpacity:255];
	}
	return self;
}

-(id) init {
	if ((self = [super init])) {
		self.drawingMode = TGLineLayerDrawingModeDrivingPath;
		[self setOpacity:255];
	}
	
	return self;
}

- (void)draw {
	glEnable(GL_BLEND);
    glEnable(GL_MULTISAMPLE);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	for (TGTruck *truck in self.trucks) {
		PointNode *pathNode = NULL;
		ccColor4B col;
		if (self.drawingMode == TGLineLayerDrawingModeRawPath) {
			pathNode = truck.curRawPathNode;
			col = ccc4(255, 0, 0, self.opacity);
		} else if (self.drawingMode == TGLineLayerDrawingModeDrivingPath) {
			pathNode = truck.curDrivingPathNode;
			col = ccc4(255, 255, 255, (self.opacity / 3));
		}
			
		if (pathNode) {
			glColor4ub(col.r, col.g, col.b, col.a);
			glLineWidth(3.0);
			for (PointNode *cur = pathNode->next; cur != NULL; cur = cur->next)
				ccDrawLine(cur->prev->point, cur->point);
		}
	}
    
	glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
}

- (void)dealloc {
	[trucks release];
	
	[super dealloc];
}

@end
