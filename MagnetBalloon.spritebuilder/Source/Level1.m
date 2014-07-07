//
//  Level1.m
//  MagnetBalloon
//
//  Created by Luning Pan on 7/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Level1.h"
#import "Magnet.h"
//default speed of balloon in Level1
static const CGFloat fg_scrollSpeed = 120.f;
static const CGFloat bg_scrollSpeed = 60.f;

@implementation Level1 {
    CCSprite *_balloon;
    CCNode *_ore_bar;
    CCPhysicsNode *_physicsNode;
    // loop desert and background scene
    CCNode *_desert1;
    CCNode *_desert2;
    NSArray *_deserts;
    CCNode *_westbg1;
    CCNode *_westbg2;
    NSArray *_westbgs;
    
    Magnet *_balloon_magnet;
    CCLabelTTF *_scoreText;
}

- (void)didLoadFromCCB {
    _deserts = @[_desert1, _desert2];
    _westbgs = @[_westbg1, _westbg2];
    
    _balloon.physicsBody.collisionType = @"balloon";
    _balloon.physicsBody.sensor = YES;
    //_balloon_magnet = [[Magnet alloc] initMagnet];
}

- (void)onEnter {
    [super onEnter];
}

- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    self.userInteractionEnabled = YES;
    _physicsNode.debugDraw = TRUE;
}

#pragma mark - CCPhysicsCollisionDelegate

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair balloon:(CCNode *)balloon ore:(CCNode *)ore {
    [ore removeFromParent];
    CCLOG(@"collision!");
    return YES;
}

- (void)update:(CCTime)delta {
    // update balloon position
    //_balloon.position = ccp(_balloon.position.x + delta * fg_scrollSpeed, _balloon.position.y);
    //_balloon_magnet.position = ccp(_balloon_magnet.position.x + delta * fg_scrollSpeed, _balloon_magnet.position.y);
    _ore_bar.position = ccp(_ore_bar.position.x + delta * fg_scrollSpeed, _ore_bar.position.y);
    // update physics nodes position to create camera	
    _physicsNode.position = ccp(_physicsNode.position.x - (bg_scrollSpeed *delta), _physicsNode.position.y);

    _scoreText.string = [NSString stringWithFormat:@"%d", _physicsNode.position.x];
    // loop the western background scene
    for (CCNode *westbg in _westbgs) {
        // get the world position of the ground
        CGPoint bgWorldPosition = [_physicsNode convertToWorldSpace:westbg.position];
        // get the screen position of the ground
        CGPoint bgScreenPosition = [self convertToNodeSpace:bgWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (bgScreenPosition.x <= (-1 * westbg.contentSize.width)) {
            westbg.position = ccp(westbg.position.x + 2 * westbg.contentSize.width, westbg.position.y);
        }
    }
    
    // loop the desert
    for (CCNode *desert in _deserts) {
        // get the world position of the ground
        CGPoint desertWorldPosition = [_physicsNode convertToWorldSpace:desert.position];
        // get the screen position of the ground
        CGPoint desertScreenPosition = [self convertToNodeSpace:desertWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (desertScreenPosition.x <= (-1 * desert.contentSize.width)) {
            desert.position = ccp(desert.position.x + 2 * desert.contentSize.width, desert.position.y);
        }
    }
    
    [_balloon_magnet.physicsBody applyAngularImpulse:0.f];
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // Rotate Magnet Pole
    _balloon_magnet.rotationalSkewX = _balloon_magnet.pole_n ? 180.f : 0.f;
    _balloon_magnet.rotationalSkewY = _balloon_magnet.pole_n ? 180.f : 0.f;
    _balloon_magnet.pole_n = _balloon_magnet.pole_n ? FALSE : TRUE;
    
    CCLOG(@"Magnet Pole: %d", _balloon_magnet.pole_n);
}

@end
