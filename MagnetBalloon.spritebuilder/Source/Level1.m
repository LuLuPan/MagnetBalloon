//
//  Level1.m
//  MagnetBalloon
//
//  Created by Luning Pan on 7/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Level1.h"

//default speed of balloon in Level1
static const CGFloat scrollSpeed = 80.f;

@implementation Level1 {
    CCSprite *_balloon;
    CCPhysicsNode *_physicsNode;
    // loop desert and background scene
    CCNode *_desert1;
    CCNode *_desert2;
    NSArray *_deserts;
    CCNode *_westbg1;
    CCNode *_westbg2;
    NSArray *_westbgs;
}

- (void)didLoadFromCCB {
    _deserts = @[_desert1, _desert2];
    _westbgs = @[_westbg1, _westbg2];
}

- (void)onEnter {
    [super onEnter];
}

- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    self.userInteractionEnabled = YES;
}

- (void)update:(CCTime)delta {
    // update balloon position
    //_balloon.position = ccp(_balloon.position.x + delta * scrollSpeed, _balloon.position.y);
 
    // update physics nodes position to create camera	
    _physicsNode.position = ccp(_physicsNode.position.x - (scrollSpeed *delta), _physicsNode.position.y);


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
        CCLOG(@"Desert1: %f, %f", _desert1.position.x, _desert1.position.y);
    }

}

@end
