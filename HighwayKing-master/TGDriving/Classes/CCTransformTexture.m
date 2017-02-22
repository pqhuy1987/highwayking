///
//	@see TTexture.h for full info
///

#import "CCTransformTexture.h"

@implementation CCTransformTexture
@synthesize textureTransform = textureTransform_;
@synthesize sprite = sprite_;
- (void) initTextureTransform
{
	if(!textureTransform_)
		textureTransform_ = malloc(sizeof(TextureTransform));
	self.textureTransform->scale.x = 1.f;
	self.textureTransform->scale.y = 1.f;
	self.textureTransform->anchorPoint.x = 0.5f;
	self.textureTransform->anchorPoint.y = 0.5f;
	self.textureTransform->rotation = 0.f;
	self.textureTransform->position = CGPointZero;
	self.textureTransform->params.minFilter = GL_LINEAR;
	self.textureTransform->params.magFilter = GL_LINEAR;
	self.textureTransform->params.wrapS = GL_REPEAT;
	self.textureTransform->params.wrapT = GL_REPEAT;
}

- (id) init 
{
	return [self initWithFile:nil];
}

+ (id) transformWithFile:(NSString*) filename
{
	return [[[self alloc] initWithFile:filename] autorelease];
}

- (id) initWithFile:(NSString*) filename
{
	return [self initWithSprite:[CCSprite spriteWithFile:filename]];
}

+(id)transformWithSprite:(CCSprite*)aSprite
{
	return [[[self alloc]initWithSprite:aSprite]autorelease];
}

-(id)initWithSprite:(CCSprite*)aSprite
{
	if((self = [super init] )) {
		sprite_ = [aSprite retain];
		[self initTextureTransform];
	}
	return self;
}

- (void) dealloc
{
	if(textureTransform_){
		free(textureTransform_);
	}
	[sprite_ release];
	[super dealloc];
}

- (void) draw
{
	if(!sprite_) return;
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	//glDisableClientState(GL_COLOR_ARRAY);
		
	//	transform the texture matrix
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();
	glTranslatef(textureTransform_->position.x, textureTransform_->position.y, 0.f);
	glTranslatef(textureTransform_->anchorPoint.x*sprite_.texture.maxS, 
				 textureTransform_->anchorPoint.y*sprite_.texture.maxT, 0.f);
	glRotatef(textureTransform_->rotation, 0.f, 0.f, 1.f);
	glScalef(textureTransform_->scale.x, textureTransform_->scale.y, 1.f);
	glTranslatef(-textureTransform_->anchorPoint.x*sprite_.texture.maxS, 
				 -textureTransform_->anchorPoint.y*sprite_.texture.maxT, 0.f);
	
	//	render texture
	glMatrixMode(GL_MODELVIEW);
	glBindTexture(GL_TEXTURE_2D, [sprite_.texture name]);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, textureTransform_->params.minFilter);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, textureTransform_->params.magFilter);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, textureTransform_->params.wrapT);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, textureTransform_->params.wrapS);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, textureTransform_->params.wrapT);
	[sprite_ visit];
	
	//	restore texture matrix
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();
	
	//	back to render
	glMatrixMode(GL_MODELVIEW);
}

@end

#pragma mark -
#pragma mark TTexture Actions
#pragma mark -
@implementation CCTextureMoveTo

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	startPosition = [self.target textureTransform]->position;
	delta = ccpSub( endPosition, startPosition );
}

-(void) update: (ccTime) t
{	
	[self.target textureTransform]->position = ccp( (startPosition.x + delta.x * t ), (startPosition.y + delta.y * t ) );
}

@end

@implementation CCTextureMoveBy

- (id) initWithDuration: (ccTime) t position: (CGPoint) p
{
	if( !(self=[super initWithDuration: t]) )
		return nil;
	
	delta = p;
	return self;
}

- (id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: delta];
	return copy;
}

- (void) startWithTarget:(CCNode *)aTarget
{
	CGPoint dTmp = delta;
	[super startWithTarget:aTarget];
	delta = dTmp;
}

- (CCActionInterval*) reverse
{
	return [[self class] actionWithDuration: self.duration position: ccp( -delta.x, -delta.y)];
}

@end

@implementation CCTextureRotateTo
+(id) actionWithDuration: (ccTime) t angle:(float) a
{	
	return [[[self alloc] initWithDuration:t angle:a ] autorelease];
}

-(id) initWithDuration: (ccTime) t angle:(float) a
{
	if( (self=[super initWithDuration: t]) ) {	
		angle = a;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] angle: angle];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	
	startAngle = [self.target textureTransform]->rotation;
	if (startAngle > 0)
		startAngle = fmodf(startAngle, 360.0f);
	else
		startAngle = fmodf(startAngle, -360.0f);
	
	angle -= startAngle;
	if (angle > 180)
		angle = -360 + angle;
	if (angle < -180)
		angle = 360 + angle;
}
-(void) update: (ccTime) t
{
	[self.target textureTransform]->rotation = startAngle + angle * t;
}
@end

@implementation CCTextureRotateBy

- (void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	startAngle = [self.target textureTransform]->rotation;
}

- (void) update: (ccTime) t
{
	[self.target textureTransform]->rotation = startAngle + angle * t;
}

- (CCActionInterval*) reverse
{
	return [[self class] actionWithDuration: self.duration angle: -angle];
}
@end

@implementation CCTextureScaleTo

- (void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	startScaleX = [self.target textureTransform]->scale.x;
	startScaleY = [self.target textureTransform]->scale.y;
	deltaX = endScaleX - startScaleX;
	deltaY = endScaleY - startScaleY;
}

- (void) update: (ccTime) t
{
	[self.target textureTransform]->scale.x = (startScaleX + deltaX * t );
	[self.target textureTransform]->scale.y = (startScaleY + deltaY * t );
}

@end

@implementation CCTextureScaleBy

- (void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	deltaX = startScaleX * endScaleX - startScaleX;
	deltaY = startScaleY * endScaleY - startScaleY;
}

- (CCActionInterval*) reverse
{
	return [[self class] actionWithDuration: self.duration scaleX: 1/endScaleX scaleY:1/endScaleY];
}
@end
