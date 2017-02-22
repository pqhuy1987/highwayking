///
//  CCTransformTexture.h.h
//
//  Created by Lam Hoang Pham on 08/07/09.
//
//
//	QUICK INFO:
//	A Transformable Texture Node has fields that allow a user to position, scale,
//	rotate a texture in a node in the same manner that a CCNode allows
//	transforms on the actual object.
//
//	
//	GOTCHAS AND LIMITATIONS:
//	We have a speed improvement by having the gpu transform the texture for us but
//	this means we have some limitations listed below.
//
//	Texture transformations have a small problem of convention. A transformation
//	will behave differently than a CocosNode transformation.
//
//	To access the transform we have a 'TextureTransform' struct that holds position,
//	scale, rotation, anchorPoint, and wrap.
//
//	Take note:
//	The texture AnchorPoint is flipped from a CocosNode:anchorPoint:
//	0,0 (topleft)		0,1 (topright)
//	0,1 (bottomleft)	1,1 (bottomright)
//
//	Transforms:		Default		Range
//	position		(0,0)		[-inf, inf] 
//		Wraps around at cycles of 1.
//		Moves left for positive values of x, right for negative values of x
//		Moves up for positive values of y,	down for negative values of y
//	scale			(1,1)		[-inf, inf]
//		Shrinks for large values, Grows for small values, flips on negative
//	rotation
//		Counterclockwise for positive values and clockwise for negative
//
//	Texture transforms are opposite of CocosNode transforms and remember that
//	y is flipped. This is due to texture coordinates starting top left and within [0..1]
//
//	Note that if you're repeating a texture it should be a power of 2 so you won't
//	see gaps. Gaps occur for non-powers of 2 because CCTexture2D stores texture data
//	as a power of 2 with gaps at the edges but we have to use the entire texture data.
//
//	Another caveat is that texture rotation transform works best with "square
//	textures" otherwise texture mapping takes place and you'll run into distortions.
//	The texture will stretch the image to map to the texture coordinate.
//
//
//	USAGE:
//	If you ever need to manually adjust the transforms of the transformable texture
//	just access textureTransform->position, textureTransform->scale, etc.
//	The properties are all in the TextureTransform struct.
//
//	REPEAT ANDS CLAMP INFO:
//	By setting textureTransform->params we can change the wrapping of the texture
//	as it transforms. 'textureTransform->params' is in the class due to the limitation that
//	a Texture2D Image can only have one wrap mode but we may want multiple sprites
//	to have different wrapping modes even if they use the same texture image.
//	self.textureTransform->params.wrapS = GL_REPEAT; Repeat horizontally
//	self.textureTransform->params.wrapT = GL_REPEAT; Repeat vertically
//
//	SPRITE ADDITION:
//	CCTransformTexture now holds a sprite so we get get all the benefits of CCSprite
//	and I don't have to duplicate any of those features.
//	Anything you need to change for the Transformable texture like it's color,
//	adding animations, scale, etc; you would do this from sprite.
//		eg) transfromTextureInst.sprite.color = ccBLUE;
//
//	RUNNING ACTIONS ON SPRITE:
//	If you want to run actions on the sprite then remember that sprite is just a
//	property and not a child of CCTransformTexture so you can't run actions normally
//	what I've done is overriden runAction to work
///

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef struct TextureTransform_t {
	CGPoint			position;
	CGPoint			anchorPoint;
	float			rotation;
	CGPoint			scale;
	ccTexParams		params;
} TextureTransform;


@protocol CCTransformTextureProtocol
- (TextureTransform*) textureTransform;
@end

@interface CCTransformTexture : CCNode<CCTransformTextureProtocol> {
	//	We hold a sprite as a component so we can transform it's texture and
	//	because inheriting a CCSprite is kinda hard.
	CCSprite			*sprite_;
	TextureTransform	*textureTransform_;
}
///
//	The sprite holds the texture file that we initialized.
//	Why I return a sprite is that it's such a substantial class in terms of what
//	it can do that I can get all sprite functionality by accessing the sprite.
///
@property (retain) CCSprite *sprite;
///
//	
///
@property (readonly) TextureTransform *textureTransform;

///
//	@param filename is the image filename
//	@returns a CCTransformTexture
///
+(id)transformWithFile:(NSString*)filename;
-(id)initWithFile:(NSString*)filename;
///
//	@param aSprite is the sprite filename
//	@returns a CCTransformTexture
///
+(id)transformWithSprite:(CCSprite*)aSprite;
-(id)initWithSprite:(CCSprite*)aSprite;
@end


#pragma mark -
#pragma mark TTexture Actions
#pragma mark -
@interface CCTextureMoveTo : CCMoveTo<NSCopying>
@end

@interface CCTextureMoveBy : CCTextureMoveTo<NSCopying>
@end

@interface CCTextureRotateTo : CCActionInterval<NSCopying>
{
	float angle;
	float startAngle;
}
+(id)actionWithDuration:(ccTime)duration angle:(float)angle;
-(id)initWithDuration:(ccTime)duration angle:(float)angle;
@end

@interface CCTextureRotateBy : CCRotateBy<NSCopying>
@end

@interface CCTextureScaleTo : CCScaleTo<NSCopying>
@end

@interface CCTextureScaleBy : CCTextureScaleTo<NSCopying>
@end
