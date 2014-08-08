//
//  Level1.m
//  MagnetBalloon
//
//  Created by Luning Pan on 7/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Level1.h"
#import "Magnet.h"
#import "Ore.h"
//default speed of balloon in Level1
static const CGFloat fg_scrollSpeed = 120.f;
static const CGFloat init_scrollSpeed = 40.f;
static CGFloat bg_scrollSpeed = 50.f;
static CGFloat cur_scrollSpeed = 50.f;
static const CGFloat scrollSpeedMax = 200.f;
static const NSInteger speedScoreInterval = 20;
static const CGFloat speedInterval = 10.0f;
static NSInteger preSpeedLevel = 0;
// protected number of badguy
static const NSInteger protectionLimit = 5;

// distance between each ore bars
static const CGFloat firstOrePosition = 200.f;
static const CGFloat minDistanceBetweenOres = 90.f;
static const CGFloat maxDistanceBetweenOres = 150.f;
static BOOL firstRound = TRUE;

// enum for object type
typedef NS_ENUM(NSInteger, ObjType) {
    OreN,
    OreS,
    BadguyN,
    BadguyS,
    ProtectionRed,
    ProtectionBlue,
    ObjNum
};

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
    
    Magnet *_balloon_magnet;
    
    // ore bars
    NSMutableArray *_ores;
    NSMutableArray *_objs_ctrl;
    
    NSInteger _score;
    
    CCLabelTTF *_scoreText;
    
    CCButton *_restartButton;
    CCButton *_pauseButton;
    BOOL _gameOver;
    BOOL _paused;
    // be protected from badguy
    BOOL _protected;
    NSInteger _protectedCount;
    
    CCParticleSystem *_protectCircle;
    CCNode *over;
    
    CCNode *_instruct1;
    CCNode *_instruct2;
    CCNode *_instruct3;
    CCNode *_instruct4;
    CCNode *_instruct5;
}

- (void)didLoadFromCCB {
    _deserts = @[_desert1, _desert2];
    _westbgs = @[_westbg1, _westbg2];

    bg_scrollSpeed = init_scrollSpeed;
    _physicsNode.collisionDelegate = self;
    
    _balloon.physicsBody.collisionType = @"balloon";
    _balloon.physicsBody.sensor = YES;
    
    _ores = [NSMutableArray array];
    _objs_ctrl = [NSMutableArray array];
    // initial objects on the screen
    [self spawnNewOre];
    [self spawnNewOre];
    [self spawnNewOre];
    [self spawnNewOre];
    [self spawnNewOre];
    [self spawnNewOre];
    
    _paused = FALSE;
    _gameOver = NO;
    _protected = FALSE;
    _protectedCount = 0;
    _restartButton.visible = NO;
    if (firstRound == FALSE) {
        [_instruct1 removeFromParent];
        [_instruct2 removeFromParent];
        [_instruct3 removeFromParent];
        [_instruct4 removeFromParent];
        [_instruct5 removeFromParent];
    }
}

- (void)onEnter {
    [super onEnter];
}

- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    self.userInteractionEnabled = YES;
    // only show instructions for the first game round
    if (firstRound) {
        
        [NSThread sleepForTimeInterval:3];
        firstRound = FALSE;
        [_instruct1 removeFromParent];
        [_instruct2 removeFromParent];
        [_instruct3 removeFromParent];
        [_instruct4 removeFromParent];
        [_instruct5 removeFromParent];
    }
}

#pragma mark - CCPhysicsCollisionDelegate

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair balloon:(CCNode *)balloon ore:(CCNode *)ore {    
    Ore* object = [_objs_ctrl objectAtIndex:0];
    if (object.isOre || object.isProtection) {
        // check if could get current ore to gain a point
        if (object.pole_n == _balloon_magnet.pole_n) {
            _score++;
            CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"disappear"];
            // make the particle effect clean itself up, once it is completed
            explosion.autoRemoveOnFinish = TRUE;
            // place the particle effect on the seals position
            explosion.position = object.position;
            // add the particle effect to the same node the seal is on
            [object.parent addChild:explosion];
            [ore removeFromParent];
            
            // get a protection circle?
            if (object.isProtection && !_protected) {
                _protected = TRUE;
                _protectCircle = (CCParticleSystem *)[CCBReader load:@"ProtectCircle"];
                _protectCircle.duration = -1;
                // place the particle effect on the seals position
                _protectCircle.position = _balloon.position;
                // add the particle effect to the same node the seal is on
                [_balloon.parent addChild:_protectCircle];
            }
        }
    } else {
        // check if current pole to opposite bady guy
        if (object.pole_n == _balloon_magnet.pole_n) {
            // avoid bady guy successfully
            _score += 2;
        } else {
            // trap by bad guy, restart
            if (!_protected)
                [self gameOver];
            else
                _protectedCount++;
        }
    }
    
    [_objs_ctrl removeObjectAtIndex:0];
    
    _scoreText.string = [NSString stringWithFormat:@"%d", _score];

    // accelerate speed to increase difficulty
    NSInteger speedLevel = _score / speedScoreInterval;
    if (speedLevel >= 1 && speedLevel > preSpeedLevel && bg_scrollSpeed <= scrollSpeedMax) {
        bg_scrollSpeed += speedInterval;
        preSpeedLevel++;
    }
    
    return YES;
}

- (void)update:(CCTime)delta {
    // update balloon position
    _balloon.position = ccp(_balloon.position.x + delta * bg_scrollSpeed, _balloon.position.y);
    if (_protected) {
        _protectCircle.position = _balloon.position;
        if (_protectedCount >= protectionLimit) {
            _protected = FALSE;
            _protectedCount = 0;
            [_protectCircle removeFromParent];
        }
    }
    
    // update physics nodes position to create camera	
    _physicsNode.position = ccp(_physicsNode.position.x - (bg_scrollSpeed *delta), _physicsNode.position.y);

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
    
    // generate new objects
    NSMutableArray *offScreenObjects = nil;
    for (CCNode *obj in _ores) {
        CGPoint objWorldPosition = [_physicsNode convertToWorldSpace:obj.position];
        CGPoint objScreenPosition = [self convertToNodeSpace:objWorldPosition];
        if (objScreenPosition.x < -obj.contentSize.width) {
            if (!offScreenObjects) {
                offScreenObjects = [NSMutableArray array];
            }
            [offScreenObjects addObject:obj];
        }
    }
    
    for (CCNode *objToRemove in offScreenObjects) {
        [objToRemove removeFromParent];
        [_ores removeObject:objToRemove];
        // for each removed object, add a new one
        [self spawnNewOre];
    }
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // Rotate Magnet Pole
    _balloon_magnet.rotationalSkewX = _balloon_magnet.pole_n ? 180.f : 0.f;
    _balloon_magnet.rotationalSkewY = _balloon_magnet.pole_n ? 180.f : 0.f;
    _balloon_magnet.pole_n = _balloon_magnet.pole_n ? FALSE : TRUE;
}


#pragma mark - Ore Spawning

- (void)spawnNewOre {
    CCNode *previousOre = [_ores lastObject];
    CGFloat previousOreXPosition = previousOre.position.x;
    
    if (!previousOre) {
        // this is the first obstacle
        previousOreXPosition = firstOrePosition;
    }
    
    // generarte object randomly
    Ore *ore = [self generateObj];
    CGFloat distanceBetweenOres = minDistanceBetweenOres +
            arc4random_uniform(maxDistanceBetweenOres - minDistanceBetweenOres);

    ore.position = ccp(previousOreXPosition + distanceBetweenOres, 20);

    [_physicsNode addChild:ore];
    [_ores addObject:ore];
    [_objs_ctrl addObject:ore];
}

#pragma mark - Objects generate randomly

- (Ore *)generateObj {
    Ore *ore = NULL;
    int obj_choose = arc4random_uniform(ObjNum);
    
    // do not show protection under score threshold
    if ((_score < 20 || _protected) && (obj_choose > BadguyS))
        obj_choose -= 2;
    
    // generate objects with different attributes
    switch (obj_choose) {
        case OreN:
            ore = (Ore *)[CCBReader load:@"OreN"];
            ore.pole_n = TRUE;
            ore.isOre = TRUE;
            ore.isProtection = FALSE;
            break;
            
        case OreS:
            ore = (Ore *)[CCBReader load:@"OreS"];
            ore.pole_n = FALSE;
            ore.isOre = TRUE;
            ore.isProtection = FALSE;
            break;
            
        case BadguyN:
            ore = (Ore *)[CCBReader load:@"BadguyN"];
            ore.pole_n = TRUE;
            ore.isOre = FALSE;
            ore.isProtection = FALSE;
            break;
            
        case BadguyS:
            ore = (Ore *)[CCBReader load:@"BadguyS"];
            ore.pole_n = FALSE;
            ore.isOre = FALSE;
            ore.isProtection = FALSE;
            break;
            
        case ProtectionRed:
            ore = (Ore *)[CCBReader load:@"ProtectionRed"];
            ore.pole_n = TRUE;
            ore.isOre = FALSE;
            ore.isProtection = TRUE;
            break;
            
        case ProtectionBlue:
            ore = (Ore *)[CCBReader load:@"ProtectionBlue"];
            ore.pole_n = FALSE;
            ore.isOre = FALSE;
            ore.isProtection = TRUE;
            break;
            
        default:
            ore = NULL;
            break;
    }
    
    return ore;
}

- (void)pause {
    if (_paused == FALSE) {
        cur_scrollSpeed = bg_scrollSpeed;
        bg_scrollSpeed = 0.f;
        _paused = TRUE;
    } else {
        bg_scrollSpeed = cur_scrollSpeed;
        _paused = FALSE;
    }
}

// Trap by bad guy, need to restart game
- (void)gameOver {
    if (!_gameOver) {
        _restartButton.visible = TRUE;
        bg_scrollSpeed = 0.f;
        _gameOver = TRUE;
        
        CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"over"];
        // make the particle effect clean itself up, once it is completed
        explosion.autoRemoveOnFinish = TRUE;
        // place the particle effect on the seals position
        explosion.position = _balloon.position;
        // add the particle effect to the same node the seal is on
        [_balloon.parent addChild:explosion];
        
        over = (CCNode *)[CCBReader loadAsScene:@"GameOver"];
        over.position = ccp(_balloon.position.x + 70.f, 250.f);
        [_physicsNode addChild:over];
    }
}

- (void)restart {
    [over removeFromParent];
    CCScene *scene = [CCBReader loadAsScene:@"Level1"];
    [[CCDirector sharedDirector]replaceScene:scene];
}

@end
