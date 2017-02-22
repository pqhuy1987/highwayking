//
//  CCMenu+CorrectPadding.h
//  TGDriving
//
//  Created by James Magahern on 1/2/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCMenu(CorrectPadding)

-(void) alignItemsVerticallyWithPadding:(float)padding;

-(id) initWithItemsArray:(NSArray*)array;

@end
