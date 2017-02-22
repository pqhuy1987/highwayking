//
//  TGTruck.m
//  TGDriving
//
//  Created by Charles Magahern on 10/21/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGTruck.h"
#import "CCDrawingPrimitives.h"
#import "Congratulations.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"

#import "TGPenaltyDot.h"
#import "TGHighScoresController.h"

@implementation TGTruck
@synthesize velocity;
@synthesize firstRawPathNode, curRawPathNode, firstDrivingPathNode, curDrivingPathNode;
@synthesize stopped, crashed, locked, arrivingSpot, tasks, goal, goalComplete;
@synthesize numberOfOriginalTasks, warning;
@synthesize opacity;

int _filterCount = 10;

#pragma mark -
#pragma mark Initialization

- (id)init {
	if ( (self = [super init]) ) {
		CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"truck_orange.png"];
		if (texture) {
			CGRect rect = CGRectZero;
			rect.size = texture.contentSize;
			self.texture = texture;
			self.textureRect = rect;
		}
		
		self.tasks = [[NSMutableArray alloc] init];
		[self populateTasks];
		[self updateTasks];
		
		self.goalComplete = NO;

		
		[self schedule:@selector(update) interval:0.02];
		
		anchor1 = ccp(self.textureRect.size.width / 2, self.textureRect.size.height / 8 + 20);
		anchor1 = [self convertToWorldSpace:anchor1];
		anchor2 = CGPointZero;
		
		[self setAnchorPoint:ccp(0.5, 0.9)];
		
		velocity = ccp(0.0, 1.0);
		self.firstRawPathNode = NULL;
		self.firstDrivingPathNode = NULL;
		self.curRawPathNode = NULL;
		self.curDrivingPathNode = NULL;
		
		selectSprite = [[CCSprite alloc] initWithFile:@"select-graphic.png"];
		selectSprite.position = ccp(self.textureRect.size.width / 2, self.textureRect.size.height / 2);
		
		numberOfOriginalTasks = 0;
		
		self.stopped = NO;
        self.crashed = NO;
		enteredScreen = NO;
		offroading = NO;
		
		//[[SimpleAudioEngine sharedEngine] preloadEffect:@"bell_gasstation.aiff"];
	}
	
	return self;
}

- (void)setGoal:(TGTruckGoal *)_goal {
	goal = _goal;
	
	NSString *truckPath;
	switch (_goal.goalType) {
		case TGTruckGoalTypeBlue:
			truckPath = @"truck_blue.png";
			break;
		case TGTruckGoalTypeOrange:
			truckPath = @"truck_orange.png";
			break;
		default:
			truckPath = @"red_truck.png";
			break;
	}
	
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:truckPath];
	
	[self setTexture:texture];
}


#pragma mark -

-(void) populateTasks {
	//[self addTask:TGTaskFood];
}

-(void) addTask:(TGTaskType)type {
	TGTask *task = [[TGTask alloc] initWithTGTaskType:type];
	[self.tasks addObject:task];
    [task release];
    
	[self updateTasks];
	
	numberOfOriginalTasks += 1;
}

-(void) removeTask:(TGTaskType)type {
	for (TGTask *task in self.tasks) {
		if ([task taskType] == type) {
			[self.tasks removeObject:task];
			break;
		}
	}
	
	[self updateTasks];
}

-(BOOL) taskExists:(TGTaskType)type {
	for (TGTask *task in self.tasks) {
		if ([task taskType] == type) {
			return YES;
		}
	}
	
	return NO;
}

-(void) updateTasks {
	for (CCSprite *s in [self children]) {
		if ([[s class] isSubclassOfClass:[TGTaskIcon class]]) {
			[s removeFromParentAndCleanup:YES];
		}
	}
	
	int between = self.textureRect.size.height / [self.tasks count];
	int space = between;
	for (TGTask *task in self.tasks) {
		NSString *iconPath;
		switch ([task taskType]) {
			case TGTaskFood:
				iconPath = @"food-small.png";
				break;
            case TGTaskFuel:
                iconPath = @"fuel-small.png";
                break;
			default:
				iconPath = @"fire.png";
				break;
		}
		
		if ([self.tasks count] == 1) {
			space = self.textureRect.size.height / 2;
		}
		
		
		TGTaskIcon *icon = [[TGTaskIcon alloc] initWithFile:iconPath];
		[icon setPosition:ccp(self.textureRect.size.width / 2, space)];
		[icon setScale:0.7];
		if ([self.tasks count] > 1) {
			[icon setScale:0.5];
		}
		
		space -= icon.textureRect.size.height * icon.scale;
		
		[self addChild:icon];
	}
}


#pragma mark Accessors

- (void)setStopped:(BOOL)s {
	if (s == YES) {
		[self stopTruck];
	} else {
		[self resumeTruck];
	}
}

-(void) setPosition:(CGPoint)pos {
	[super setPosition:pos];
	// Check if second anchor point is uninitialized
	if (CGPointEqualToPoint(anchor2, CGPointZero)) {
        if (abs(self.velocity.x) != abs(self.velocity.y)) {
            if (self.velocity.x > 0)
                [self setRotation:90];
            else if (self.velocity.y > 0)
                [self setRotation:0];
            else if (self.velocity.x < 0)
                [self setRotation:-90];
            else if (self.velocity.y < 0)
                [self setRotation:180];
        } else {
            if (self.velocity.x > 0 && self.velocity.y > 0)
                [self setRotation:45];
            else if (self.velocity.x < 0 && self.velocity.y < 0)
                [self setRotation:-135];
            else if (self.velocity.x < 0 && self.velocity.y > 0)
                [self setRotation:-45];
            else if (self.velocity.x > 0 && self.velocity.y < 0)
                [self setRotation:135];
        }

		anchor1 = ccp(self.textureRect.size.width / 2, self.textureRect.size.height / 6);
		anchor2 = ccp(self.textureRect.size.width / 2, -5 * self.velocity.y);
		anchor1 = [self convertToWorldSpace:anchor1];
		anchor2 = [self convertToWorldSpace:anchor2];
	}
}

- (void)setFirstRawPathNode:(PointNode *)p {
	firstRawPathNode = p;
	self.curRawPathNode = p;
}

- (void)setFirstDrivingPathNode:(PointNode *)p {
	firstDrivingPathNode = p;
	self.curDrivingPathNode = p;
}

- (void)setOpacity:(GLubyte)o {
	[super setOpacity:o];
	for (CCSprite *sprite in [self children])
		sprite.opacity = o;
}

- (CGPoint)centerPoint {
	CGSize content = self.contentSize;
	
	CGPoint centerPoint = CGPointMake(content.width / 2, content.height / 2);
	return centerPoint;
}

- (CGPoint)tailPoint {
    CGSize content = self.contentSize;
    CGPoint tail = CGPointMake(content.width / 2.0, 5.0);
    return [self convertToWorldSpace:tail];
}

- (CGRect)collidingRect {
	const int scaleConstant = 15;
	CGRect realBounds = [self textureRect];
	CGRect fauxBounds = CGRectMake(realBounds.origin.x + (scaleConstant / 2), realBounds.origin.y + (scaleConstant / 2), realBounds.size.width - scaleConstant, realBounds.size.height - scaleConstant);
	
	return fauxBounds;
}

- (CGPoint *)cornerPoints {
    CGRect trect = [self collidingRect];
    CGPoint *pts = (CGPoint *) malloc(4 * sizeof(CGPoint));
    
    pts[0] = trect.origin;
    pts[1] = ccp(trect.origin.x + trect.size.width, trect.origin.y);
    pts[2] = ccp(trect.origin.x + trect.size.width, trect.origin.y + trect.size.height);
    pts[3] = ccp(trect.origin.x, trect.origin.y + trect.size.height);

    for (int i = 0; i < 4; i++)
        pts[i] = [self convertToWorldSpace:pts[i]];
    
    return pts;
}

#pragma mark -


#pragma mark Drawing

- (void)draw {
	[super draw];
    
    if ([[GameLayer sharedGame] debug_showAnchorPoints]) {
        glColor4ub(0, 0, 255, 255);
        glPointSize(5.0);
        ccDrawPoint([self convertToNodeSpace:anchor1]); // Anchor1 = blieu
        glColor4ub(0, 255, 0, 255);
        ccDrawPoint([self convertToNodeSpace:anchor2]); // Anchor2 = griin
        glColor4ub(255, 0, 0, 255); // Tail = read
        ccDrawPoint([self convertToNodeSpace:[self tailPoint]]);
    }
    
    if ([[GameLayer sharedGame] debug_showCollisionRects]) {
        glColor4ub(255, 0, 0, 255);
        CGRect trect = [self collidingRect];
        CGPoint tpts[] = {
            trect.origin,
            ccp(trect.origin.x + trect.size.width, trect.origin.y),
            ccp(trect.origin.x + trect.size.width, trect.origin.y + trect.size.height),
            ccp(trect.origin.x, trect.origin.y + trect.size.height)
        };
        
        for (int i = 0; i < 4; i++)
            ccDrawLine(tpts[i], tpts[(i != 3 ? i + 1 : 0)]);
    }
}

#pragma mark -


#pragma mark Actions

- (void)resumeTruck {
	stopped = NO;
	offroading = NO;
}

- (void)stopTruck {
	stopped = YES;
	if (cloud) {
		[cloud stopSystem];
	}
}

-(void) truckHasRunOffScreen {
    const int penaltyAmount = 15;
	if (![self goalComplete]) {
		TGPenaltyDot *penalty = [[TGPenaltyDot alloc] initWithPenaltyAmount:penaltyAmount truckLocation:self.position];
		[[GameLayer sharedGame] addChild:penalty];
        
        int curScore = [[GameLayer sharedGame] score];
        [[GameLayer sharedGame] setScore:curScore - penaltyAmount];
        
		
		//[[GameLayer sharedGame] truckFinished:self];
        [[[GameLayer sharedGame] currentLevel] removeTruck:self];
	}
}

-(void) truckHasReachedGoal {
	Congratulations *gratz = [[Congratulations alloc] init];
	
    CGRect goalRect = [goal collidingRect];
    gratz.position = ccp(goalRect.origin.x + goalRect.size.width / 2.0, goalRect.origin.y);
    gratz.angle = goal.rotation;
	switch ([[self goal] goalType]) {
		case TGTruckGoalTypeBlue:
			break;
		case TGTruckGoalTypeOrange:
			gratz.startColor = ccc4FFromccc4B(ccc4(255, 130, 0, 255));
			gratz.endColor = ccc4FFromccc4B(ccc4(200, 130, 0, 0));
			break;
		default:
			break;
	}
	
	[[GameLayer sharedGame] addChild:gratz];
	[[GameLayer sharedGame] truckFinished:self];
	
	[self setGoalComplete:YES];
	
	[[TGHighScoresController sharedHighScoresController] truckReachedGoal];
}

- (void)fadeSelection {
	[selectSprite runAction:[CCSequence actions:
							 [CCFadeOut actionWithDuration:0.2],
							 [CCCallFunc actionWithTarget:selectSprite selector:@selector(removeFromParentAndCleanup:)],
							 nil]];
}

- (void)animateSelection {
	if (![[self children] containsObject:selectSprite]) {
		selectSprite.opacity = 0;
		selectSprite.scale = 2.0;
		[self addChild:selectSprite];
		[selectSprite runAction:[CCFadeIn actionWithDuration:0.2]];
		[selectSprite runAction:[CCScaleTo actionWithDuration:0.2 scale:1.0]];
		[selectSprite runAction:[CCSequence actions:
								 [CCDelayTime actionWithDuration:0.2],
								 [CCCallFunc actionWithTarget:self selector:@selector(fadeSelection)],
								 nil]];
	}
}

- (void)truckReachedDestinationSafely {
	[self unschedule:@selector(update)];
	[self stopTruck];
	
	[self clearDrivingPathPoints];
	[self runAction:[CCSequence actions:
					 [CCFadeOut actionWithDuration:0.3],
					 [CCCallFunc actionWithTarget:self selector:@selector(removeFromParentAndCleanup:)],
					 nil]];
}

- (void)countdownEnded {
	if (self.locked == YES)
		[[SimpleAudioEngine sharedEngine] playEffect:@"bell_gasstation.aiff"];
	
	self.locked = NO;
	countdownTimer = nil;
	arrivingSpot = nil;
}

- (void)truckParked {
	if (self.arrivingSpot != NULL && countdownTimer == nil) {
		[self stopTruck];
		self.locked = YES;
		
		[self clearRawPathPoints];
		[self clearDrivingPathPoints];
		
		[self removeTask:[arrivingSpot taskType]];
		
		countdownTimer = [[TGProgressTimer alloc] initWithStartingTime:5];
		countdownTimer.delegate = self;
		countdownTimer.position = ccp(self.textureRect.size.width / 2.0, self.textureRect.size.height / 2.0);
		countdownTimer.position = [self convertToWorldSpace:countdownTimer.position];
		[[[[GameLayer sharedGame] currentLevel] upperLayer] addChild:countdownTimer];
		//[countdownNode startCountdown];
		
		[[TGHighScoresController sharedHighScoresController] truckParked];
	}
}

#pragma mark -


#pragma mark Update

- (void)update {
	if (self.stopped) return;
	
	[self updatePositionAndOrientation];
	[self checkParkingStatus];
	[self checkGoalStatus];
	
	if (cloud) {
		CGPoint pos = self.position;
		pos.y -= 45;
		
		[cloud runAction:[CCMoveTo actionWithDuration:0.1 position:anchor2]];
		cloud.angle = self.rotation - 90;
	}
}

-(void) updatePositionAndOrientation {
	// Update rear axle position
	if (ccpDistance(anchor1, anchor2) > self.textureRect.size.height - 20) {
		CGPoint difference = ccpSub(anchor2, anchor1);
		
		double stepX = difference.x / 2;
		double stepY = difference.y / 2;
		
		anchor2.x = anchor2.x - stepX;
		anchor2.y = anchor2.y - stepY;
	}
	
	// Get total number of points 
	long count = [self currentPathSize];
	
	if (count > self.textureRect.size.height || !self.firstDrivingPathNode) {
		CGFloat rot = atan2((anchor2.y - anchor1.y), (anchor2.x - anchor1.x)) * (180/M_PI);
		
		//[self runAction:[CCRotateTo actionWithDuration:0.1 angle:rot*(-1) - 90.0]];
        [self setRotation:-rot-90.0];
	}
	if (self.curDrivingPathNode) {
        CGPoint distVect = ccpSub(self.curDrivingPathNode->point, anchor1);
		anchor1 = ccp(anchor1.x + (distVect.x / 2), anchor1.y + (distVect.y / 2));
		
		self.position = anchor1;
		
		// If our multiplier is greater than 1, we need to iterate multiple times through the
		// path array.
		if ([[GameLayer sharedGame] speedMultiplier] > 1) {
			for (int x = 0; x < ([[GameLayer sharedGame] speedMultiplier]) && self.curDrivingPathNode != NULL; x++)
				self.curDrivingPathNode = self.curDrivingPathNode->next;
		} else {
			self.curDrivingPathNode = self.curDrivingPathNode->next;
		}
	} else if (self.firstDrivingPathNode) {
		PointNode *back = self.firstDrivingPathNode->prev;
		int x = 0;
		while (back != NULL && x < 30) {
			back = back->prev;
			x++;
		}
		
		CGPoint vector = ccpSub(self.firstDrivingPathNode->prev->point, back->point);
		CGFloat distance = ccpDistance(self.firstDrivingPathNode->prev->point, back->point);
		
		distance = (distance == 0 ? 1 : distance);
		
		self.velocity = ccp(vector.x / distance, vector.y / distance);
		self.firstDrivingPathNode = NULL;
	}
	
	if (!enteredScreen) {
		CGRect screen = [[UIScreen mainScreen] bounds];
		CGRect transTruck = [self boundingBox];
		// If we went off screen
		if (CGRectContainsRect(screen, transTruck)) {
			enteredScreen = YES;
		}
	}
	
	if (!self.firstDrivingPathNode) {
		int multiplier = [[GameLayer sharedGame] speedMultiplier];
		self.position = ccp(self.position.x + (self.velocity.x * multiplier), self.position.y + (self.velocity.y * multiplier));
		anchor1 = self.position;
	}
}

-(void) checkGoalStatus {
	// Win?
	if (![self goalComplete]) {
        CGRect goalRect = self.goal.collidingRect;
        if (CGRectContainsPoint(goalRect, [self tailPoint])) {
            [self truckHasReachedGoal];
        }
	}
	
    // Fudge the screen rectangle a little so that the truck has a little bit more room
    // to leave the screen before we decide that it has.
    const float scrn_finagle = 20.0;
	CGRect screen = [[UIScreen mainScreen] bounds];
    screen = CGRectMake(screen.origin.x - scrn_finagle, screen.origin.y - scrn_finagle, screen.size.width + scrn_finagle*2, screen.size.height + scrn_finagle*2);
	CGRect transTruck = [self boundingBox];
	// If we went off screen
	if (enteredScreen && !CGRectIntersectsRect(screen, transTruck)) {
		[self truckHasRunOffScreen];
	}
}

- (void) checkParkingStatus {
	if (arrivingSpot != nil) {
		CGPoint center = CGPointMake(arrivingSpot.position.x + (arrivingSpot.collidingRect.size.width / 2), arrivingSpot.position.y + (arrivingSpot.collidingRect.size.height / 2) - 15);
		
		if (self.firstDrivingPathNode != NULL && self.firstDrivingPathNode->prev->point.y > arrivingSpot.position.y) {
			center.y += 15;
		}
		
		CGPoint currentCenter = [self convertToWorldSpace:[self centerPoint]];
		float distanceFromSpot = ccpDistance(currentCenter, center);
		if (distanceFromSpot < 10) {
			[self truckParked];
		}
	}
	
	// CountdownTimer now gets added to the upperLayer in the level.
	//if (countdownTimer != NULL)
		//[countdownTimer setRotation:-self.rotation];
}

- (void)checkBoundsWithStreetZones:(NSMutableArray *)zones {
	for (NSValue *zoneValue in zones) {
		CGRect *zone = malloc(sizeof(CGRect));
		[zoneValue getValue:zone];
		
		CGRect truckRect = [self collidingRect];
		truckRect.origin = [self convertToWorldSpace:truckRect.origin];
		if (!CGRectContainsRect(*zone, truckRect)) {
			if (!offroading && !self.stopped) {
				if (!cloud) {
					cloud = [[TGDustParticles alloc] init];
					[[self parent] addChild:cloud];
				} else {
					[cloud resetSystem];
				}

				cloud.position = self.position;
				cloud.angle = self.rotation;

				offroading = YES;
			}
		} else {
			offroading = NO;
			if (cloud) {
				[cloud stopSystem];
			}
			
			break;
		}

	}
}

- (BOOL)isTruckOnScreen {
	CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect transTruck = [self boundingBox];
    return CGRectContainsRect(screen, transTruck);
}

#pragma mark -


#pragma mark Helper Methods

- (void)clearDrivingPathPoints {
	for (PointNode *cur = self.firstDrivingPathNode; cur != NULL;) {
		PointNode *next = cur->next;
		free(cur);
		cur = next;
	}
	
	_filterCount = 10;
	self.firstDrivingPathNode = NULL;
}

- (void)clearRawPathPoints {
	for (PointNode *cur = self.firstRawPathNode; cur != NULL;) {
		PointNode *next = cur->next;
		free(cur);
		cur = next;
	}
	self.firstRawPathNode = NULL;
}

- (size_t)currentPathSize {
	size_t len = 0;
	for (PointNode *cur = self.firstDrivingPathNode; cur != NULL; cur = cur->next, len++);
	return len;
}

- (void)addDrivingPoint:(CGPoint)point {
	if (!self.firstDrivingPathNode) {
		PointNode *new = (PointNode *) malloc(sizeof(PointNode));
		new->prev = new;
		new->next = NULL;
		new->point = anchor1;
		
		self.firstDrivingPathNode = new;
	} else {
		PointNode *last = self.firstDrivingPathNode->prev;
		PointNode *new = (PointNode *) malloc(sizeof(PointNode));
		
		new->point = point;
		new->prev = last;
		new->next = NULL;
		last->next = new;
		self.firstDrivingPathNode->prev = new;
	}
}

- (void)addInterpolatedPoint:(CGPoint)point {
	PointNode *first = self.firstDrivingPathNode;

	if (!first) {
		[self addDrivingPoint:point];
	} else {
		CGFloat d = ccpDistance(first->prev->point, point);
		
		if (d >= 1) {
			CGPoint ptDifference = ccpSub(first->prev->point, point);
			int numPoints = floorf(d);
			
			double stepX = ptDifference.x / numPoints;
			double stepY = ptDifference.y / numPoints;
			double pX = first->prev->point.x - stepX;
			double pY = first->prev->point.y - stepY;
			
			for (int x = 0; x < numPoints; x++) {
				[self addDrivingPoint:ccp(pX, pY)];
				
				pX -= stepX;
				pY -= stepY;
			}
			
			[self addDrivingPoint:point];
		}
	}
}

- (void)addFilteredPoint:(CGPoint)point {
    if (_filterCount >= 20) {
        if (_filterCount % 3 == 0) {
            [self addInterpolatedPoint:point];
        }
    } else {
        [self addInterpolatedPoint:point];
    }
    
    _filterCount++;
}

- (void)addRawPoint:(CGPoint)point {
	if (!self.firstRawPathNode) {
		PointNode *new = (PointNode *) malloc(sizeof(PointNode));
		new->prev = new;
		new->next = NULL;
		new->point = anchor1;
		
		self.firstRawPathNode = new;
	} else {
		PointNode *last = self.firstRawPathNode->prev;
		PointNode *new = (PointNode *) malloc(sizeof(PointNode));
		
		new->point = point;
		new->prev = last;
		new->next = NULL;
		last->next = new;
		self.firstRawPathNode->prev = new;
	}
}

- (void)removeFromParentAndCleanup:(BOOL)cleanup {
	if (cloud) {
		[cloud removeFromParentAndCleanup:YES];
	}
	
	[super removeFromParentAndCleanup:cleanup];
}

#pragma mark -

#pragma mark Checking Collisions

BOOL lineIntersect(CGPoint a1, CGPoint a2, CGPoint b1, CGPoint b2) {
    float ua_t = (b2.x - b1.x) * (a1.y - b1.y) - (b2.y - b1.y) * (a1.x - b1.x);
    float ub_t = (a2.x - a1.x) * (a1.y - b1.y) - (a2.y - a1.y) * (a1.x - b1.x);
    float u_b = (b2.y - b1.y) * (a2.x - a1.x) - (b2.x - b1.x) * (a2.y - a1.y);
    
    if (u_b != 0) {
        float ua = ua_t / u_b;
        float ub = ub_t / u_b;
        
        if (0 <= ua && ua <= 1 && 0 <= ub && ub <= 1)
            return YES;
        else
            return NO;
    } else {
        return NO;
    }
}

- (BOOL)collidesWithNode:(CCNode<TGColliding> *)collidee {
    CGPoint *tpts = [self cornerPoints];
    CGPoint *cpts;
    if ([collidee isKindOfClass:[TGTruck class]]) {
        cpts = [(TGTruck *)collidee cornerPoints];
    } else {
        CGRect crect = [collidee collidingRect];
        cpts = (CGPoint *) malloc(4 * sizeof(CGPoint));
        cpts[0] = crect.origin;
        cpts[1] = ccp(crect.origin.x + crect.size.width, crect.origin.y);
        cpts[2] = ccp(crect.origin.x + crect.size.width, crect.origin.y + crect.size.height);
        cpts[3] = ccp(crect.origin.x, crect.origin.y + crect.size.height);
    }
    
    BOOL collided = NO;
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            collided |= lineIntersect(tpts[i], tpts[(i != 3 ? i + 1 : 0)], cpts[j], cpts[(j != 3 ? j + 1 : 0)]);
        }
    }
    
    free(cpts);
    
    return collided;
}

#pragma mark -

#pragma mark TGColliding Delegate Methods

static BOOL crashSoundPlaying = NO;

- (void)crashedShowGameOver {
    int score = [[GameLayer sharedGame] score];
    if (![[GameLayer sharedGame] gameIsOver]) {
        if ([[GameLayer sharedGame] gameType] == TGGameTypeCareer)
            [[GameLayer sharedGame] gameOverWithTitle:@"Crashed!" message:@"Be careful of oncoming traffic and obstacles." type:TGGameOverFailed];
        else if ([[GameLayer sharedGame] gameType] == TGGameTypeEndless)
            [[GameLayer sharedGame] gameOverWithTitle:[NSString stringWithFormat:@"Score: %d", score]
                                              message:(score >= 1000 ? @"Nice Score! Keep it up!" : (score >= 500 ? @"Not bad. Keep trying for a higher score." : @"Really? That's the best you could do?"))
                                                 type:TGGameOverFailedEndless];
    }
    crashSoundPlaying = NO;
}

- (void)collidedWith:(id)collidee {
    if (![self crashed]) {
        [self stopTruck];
		
		
		if ([collidee class] == [TGTruck class]) {
			CCParticleExplosion *explosion = [[CCParticleExplosion alloc] initWithTotalParticles:140];
			explosion.texture = [[CCTextureCache sharedTextureCache] addImage: @"smokeParticle.png"];
			explosion.life = 7;
			explosion.speed = 10;
			
			CGPoint closest = CGPointZero;
			
			TGTruck *truck2 = (TGTruck*)collidee;
			[truck2 stopTruck];
			
			CGPoint *t1Points = [self cornerPoints];
			CGPoint *t2Points = [truck2 cornerPoints];
			
			int closestDistance = 900;
			closest = t1Points[0];
			for (int i = 0; i < 4; i++) {
				for (int j = 0; j < 4; j++) {
					if (!CGPointEqualToPoint(t1Points[i], t2Points[j]) && ccpDistance(t1Points[i], t2Points[j]) < closestDistance) {
						closest = ccpMidpoint(t1Points[i], t2Points[j]);
						closestDistance = ccpDistance(t1Points[i], t2Points[j]);
					}
				}
			}
			
			[explosion setPosition:closest];
			[((TGTruck *)collidee) setCrashed:YES];
			[[[[GameLayer sharedGame] currentLevel] layer] addChild:explosion];
		}
		
		
        [self setCrashed:YES];
        
        if (!crashSoundPlaying) {
            crashSoundPlaying = YES;
            [[SimpleAudioEngine sharedEngine] playEffect:[[NSBundle mainBundle] pathForResource:@"crash" ofType:@"aif"]];
        }
        
        const float fadeSpeed = 0.2f;
        CCSequence *seq = [CCSequence actions:
                            [CCFadeOut actionWithDuration:fadeSpeed],
                            [CCFadeIn actionWithDuration:fadeSpeed],
                            [CCFadeOut actionWithDuration:fadeSpeed],
                            [CCFadeIn actionWithDuration:fadeSpeed],
                            [CCFadeOut actionWithDuration:fadeSpeed],
                            [CCFadeIn actionWithDuration:fadeSpeed],
						    [CCFadeOut actionWithDuration:fadeSpeed],
						    [CCFadeIn actionWithDuration:fadeSpeed], nil];
        [self runAction:seq];
        
        for (TGTruck *t in [[[GameLayer sharedGame] currentLevel] trucks]) {
            [t stopTruck];
        }
        
		[[TGHighScoresController sharedHighScoresController] truckCrashed];
		[[[GameLayer sharedGame] currentLevel] gameHasEndedWithGameOverType:TGGameOverFailed];
        [self performSelector:@selector(crashedShowGameOver) withObject:nil afterDelay:1.6];
    }
}

#pragma mark -

- (void)dealloc {
	if (cloud) {
		[cloud removeFromParentAndCleanup:YES];
	}
	
	[super dealloc];
}

@end
