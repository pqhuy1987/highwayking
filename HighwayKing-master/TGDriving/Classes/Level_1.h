//
//  Level_1.h
//  TGDriving
//
//  Created by James Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGLevel.h"
#import "TGTruckGoal.h"
#import "Restaurant.h"

@interface Level_1 : TGLevel {
    TGTruckGoal *blueGoal;
    TGTruckGoal *orangeGoal;
    
	BOOL showTutorial;
}

@end
