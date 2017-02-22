//
//  CCMenuItemToggle+ItemsArray.h
//  TGDriving
//
//  Created by James Magahern on 1/3/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCMenuItemToggle(ItemsArray)

-(id) initWithTarget:(id)t selector:(SEL)s itemsArray:(NSMutableArray*)items;

@end
