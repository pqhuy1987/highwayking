//
//  TGTask.h
//  TGDriving
//
//  Created by James Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TGTaskIcon : CCSprite {
    
}

@end


typedef enum tgTasks {
	TGTaskFood,
	TGTaskSleep,
	TGTaskFuel,
	TGTaskWhoreHouse
} TGTaskType;


@interface TGTask : NSObject {
	NSString *name;
	TGTaskType taskType;
	
	UIImage *icon;
}

@property (assign) TGTaskType taskType;

-(id) initWithTGTaskType:(TGTaskType)tgTaskType;

@end
