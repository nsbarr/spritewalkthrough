//
//  SpaceshipScene.m
//  SpriteWalkthrough
//
//  Created by Nicholas Barr on 9/8/13.
//  Copyright (c) 2013 Nicholas Barr. All rights reserved.
//

#import "SpaceshipScene.h"
#import "GoodbyeScene.h"


@interface SpaceshipScene () <SKPhysicsContactDelegate>
@property BOOL contentCreated;
@property BOOL amiDone;
@property BOOL isShieldEnabled;
@end


CGFloat _shieldpercentage = 100.00f;
CGFloat _healthpercentage = 100.00f;

static const uint32_t rockCategory        =  0x1 << 0;
static const uint32_t shipCategory        =  0x1 << 1;
static const uint32_t shieldCategory      =  0x1 << 2;


@implementation SpaceshipScene
- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        _isShieldEnabled = FALSE;
        _healthpercentage = 100;
        _shieldpercentage = 100;
        self.contentCreated = YES;
        

    }
   
    self.physicsWorld.contactDelegate = self;

}


//Introduce the nodes
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //load explosions
        SKTextureAtlas *explosionAtlas = [SKTextureAtlas atlasNamed:@"Explosion"];
        NSArray *textureNames = [explosionAtlas textureNames];
        _explosionTextures = [NSMutableArray new];
        for (NSString *name in textureNames) {
            SKTexture *texture = [explosionAtlas textureNamed:name];
            [_explosionTextures insertObject:texture atIndex:0];
        }
    }
        return self;

}

- (SKSpriteNode *)outerSpace
{
    SKSpriteNode *space = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(4000,4000)];
    space.name = @"space";
    space.zPosition = -5;
    return space;
}


- (SKSpriteNode *)newShield
{
 SKSpriteNode *shield = [SKSpriteNode spriteNodeWithImageNamed:@"Shield.png"];
    shield.name = @"shield";
    shield.size = CGSizeMake(264,264);
    shield.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:shield.size.width/2];
    // [spaceship addChild:shield];
    shield.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:132];
    shield.physicsBody.dynamic = NO;
    shield.physicsBody.categoryBitMask = shieldCategory;
    shield.physicsBody.contactTestBitMask = 0;
    shield.physicsBody.collisionBitMask = rockCategory;
    shield.physicsBody.usesPreciseCollisionDetection = YES;
    SKAction *fadeOut = [SKAction fadeOutWithDuration: 0.2];
    SKAction *fadeIn = [SKAction fadeInWithDuration: 0.2];
    SKAction *pulse = [SKAction sequence:@[fadeOut,fadeIn]];
    SKAction *pulseForever = [SKAction repeatActionForever:pulse];
    [shield runAction: pulseForever];

    return shield;
}


- (SKLabelNode *)newEnergyMeter
{
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    scoreLabel.name = @"energymeter";
    scoreLabel.fontSize = 40;
    scoreLabel.position = CGPointMake(50,50);
    scoreLabel.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:0.3];
    scoreLabel.text = [NSString stringWithFormat:@"%02.0f", _shieldpercentage];
    return scoreLabel;
    
}

- (SKLabelNode *)newHealthMeter
{
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    scoreLabel.name = @"healthmeter";
    scoreLabel.fontSize = 40;
    scoreLabel.position = CGPointMake(718,50);
    scoreLabel.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:0.3];
    scoreLabel.text = [NSString stringWithFormat:@"%02.0f", _healthpercentage];
    return scoreLabel;
    
}



- (SKSpriteNode *)newSpaceship
{
    SKSpriteNode *hull = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship.png"];
    hull.name = @"spaceship";
    hull.size = CGSizeMake(64,64);
    hull.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:24];
    hull.physicsBody.dynamic = NO;
    hull.physicsBody.categoryBitMask = shipCategory;
  //  hull.physicsBody.contactTestBitMask = rockCategory;
    hull.physicsBody.collisionBitMask = 0;
   // SKSpriteNode *shield = [self newShield];
   // [hull addChild:shield];
    return hull;
}


//Define touch behavior

- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event
{
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    SKNode *space = [self childNodeWithName:@"space"];
    SKNode *shield = [self childNodeWithName:@"shield"];

    UITouch *touch = [touches anyObject];
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    
    if (![nodes containsObject:spaceship]) {
        CGPoint pointToMove = [touch locationInNode: space];
        SKAction *teleport = [SKAction sequence:@[
                                                      [SKAction waitForDuration:0],
                                                      [SKAction moveTo:pointToMove duration:1.0]]];
            [spaceship runAction: [SKAction repeatAction: teleport count:(1)]];
        [shield runAction: [SKAction repeatAction: teleport count:(1)]];

    }
    else if (_shieldpercentage > 0) {
        SKSpriteNode *shield = [self newShield];
                _isShieldEnabled = TRUE;
        [self addChild: shield];
        shield.position = spaceship.position;
    }
    else {
        _isShieldEnabled = FALSE;
        SKNode *shield = [self childNodeWithName:@"shield"];
        [shield removeFromParent];
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    SKNode *space = [self childNodeWithName:@"space"];
    SKNode *shield = [self childNodeWithName:@"shield"];

    UITouch *touch = [touches anyObject];
    CGPoint pointToMove = [touch locationInNode: space];
    
    SKAction *teleport = [SKAction sequence:@[
                                              [SKAction waitForDuration:0],
                                              [SKAction moveTo:pointToMove duration:1.0]]];
    
    [spaceship runAction: [SKAction repeatAction: teleport count:(1)]];
    [shield runAction: [SKAction repeatAction: teleport count:(1)]];

    
    if(_shieldpercentage <= 0){
          [spaceship removeAllChildren];
    }
}

-(void)moveShield
{
    SKNode *shield = [self childNodeWithName:@"shield"];
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    shield.position = spaceship.position;
}

- (void)touchesEnded:(NSSet *) touches withEvent:(UIEvent *)event {
    _isShieldEnabled = FALSE;
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    //spaceship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:24];
    //spaceship.physicsBody.dynamic = NO;
    SKNode *shield = [self childNodeWithName:@"shield"];
    [shield removeFromParent];
    [spaceship removeAllChildren];
    
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _isShieldEnabled = FALSE;
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    //spaceship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:24];
    //spaceship.physicsBody.dynamic = NO;
    [spaceship removeAllChildren];
    SKNode *shield = [self childNodeWithName:@"shield"];
    [shield removeFromParent];
}

static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}


- (void)addRock
{
    SKSpriteNode *rock = [SKSpriteNode spriteNodeWithImageNamed:@"Asteroid.png"];
    rock.size = CGSizeMake(8,8);
    rock.position = CGPointMake(skRand(0, self.size.width), self.size.height-50);
    rock.name = @"rock";
    rock.physicsBody.categoryBitMask = rockCategory;
    rock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rock.size];
    rock.physicsBody.usesPreciseCollisionDetection = YES;
    rock.physicsBody.collisionBitMask = shieldCategory | rockCategory;
    rock.physicsBody.contactTestBitMask = shipCategory;
    //rock.physicsBody.collisionBitMask = 1;
    [self addChild:rock];
   // if (_isShieldEnabled){
   //     _shieldpercentage = _shieldpercentage - 1;
   //     if(_shieldpercentage < 0){
   //         _shieldpercentage = 0;
   //     }
   // }
}

- (void)rock:(SKSpriteNode *)rock didCollideWithShip:(SKSpriteNode *)ship {
   // NSLog(@"ShipHitRock");
    [rock removeFromParent];
}


- (void)didBeginContact:(SKPhysicsContact *)contact
    {
      //  NSLog(@"contact");
        // rock < ship < shield
        
        if (contact.bodyA.categoryBitMask == contact.bodyB.categoryBitMask){
            NSLog(@"rockonrock");
        }
        else if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            NSLog(@"a smaller than b");
            //add explosion
            SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[_explosionTextures objectAtIndex:0]];
            explosion.zPosition = 1;
            explosion.scale = 0.2;
            explosion.position = contact.bodyA.node.position;
            [self addChild:explosion];
            SKAction *explosionAction = [SKAction animateWithTextures:_explosionTextures timePerFrame:0.07];
            SKAction *remove = [SKAction removeFromParent];
            [explosion runAction:[SKAction sequence:@[explosionAction,remove]]];
                // take damage
            _healthpercentage = _healthpercentage - 5;

        }
        else
        {
            NSLog(@"a larger than b");
            //add explosion
            SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[_explosionTextures objectAtIndex:0]];
            explosion.zPosition = 1;
            explosion.scale = 0.2;
            explosion.position = contact.bodyA.node.position;
            [self addChild:explosion];
            SKAction *explosionAction = [SKAction animateWithTextures:_explosionTextures timePerFrame:0.07];
            SKAction *remove = [SKAction removeFromParent];
            [explosion runAction:[SKAction sequence:@[explosionAction,remove]]];
                // take damage
            _healthpercentage = _healthpercentage - 5;
            if (_healthpercentage == 0){
                SKScene *goodbyeScene  = [[GoodbyeScene alloc] initWithSize:self.size];
                SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
                [self.view presentScene:goodbyeScene transition:doors];
            }
        }
    





        
        
        

        SKPhysicsBody *firstBody, *secondBody;
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        }
        else
        {
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        
        // 2
        if ((firstBody.categoryBitMask & shipCategory) != 0 &&
            (secondBody.categoryBitMask & rockCategory) != 0)
        {
            [self rock:(SKSpriteNode *) secondBody.node didCollideWithShip:(SKSpriteNode *) firstBody.node];
        
                  }
      }

- (void)createSceneContents
{
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    SKSpriteNode *spaceship = [self newSpaceship];
    SKSpriteNode *space = [self outerSpace];
    SKLabelNode *energy = [self newEnergyMeter];
    SKLabelNode *health = [self newHealthMeter];
    spaceship.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-150);
    [self addChild:space];
    [self addChild:spaceship];
    [self addChild:energy];
    [self addChild:health];
    //if (_isShieldEnabled == FALSE){
    //    shield.hidden = YES;
    //    }
 
    
    SKAction *makeRocks = [SKAction sequence: @[
                                                [SKAction performSelector:@selector(addRock) onTarget:self],
                                                [SKAction waitForDuration:0.10 withRange:0.15]
                                                ]];
    [self runAction: [SKAction repeatActionForever:makeRocks]];
}

-(void)update:(CFTimeInterval)currentTime
{
    [self enumerateChildNodesWithName:@"energymeter" usingBlock:^(SKNode *node, BOOL *stop) {
            [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"healthmeter" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    if (_isShieldEnabled){
        _shieldpercentage = _shieldpercentage - 0.1;
        if(_shieldpercentage < 0){
            _shieldpercentage = 0;
    [self enumerateChildNodesWithName:@"shield" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
        }
    }

}
    


-(void)didSimulatePhysics
{
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    scoreLabel.text = [NSString stringWithFormat:@"%f", _shieldpercentage];
    [self addChild:self.newEnergyMeter];
    
    SKLabelNode *health = [self newHealthMeter];
    health.text = [NSString stringWithFormat:@"%f", _healthpercentage];
    [self addChild:self.newHealthMeter];



    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0)
            [node removeFromParent];
    }];
}
@end