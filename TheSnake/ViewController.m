//
//  ViewController.m
//  TheSnake
//
//  Created by JiangXuanke on 2018/10/10.
//  Copyright © 2018年 JiangXuanke. All rights reserved.
//

#import "ViewController.h"
#import "SelfMadeButton.h"

@interface locationItem : NSObject

@property (nonatomic, assign) CGFloat X;
@property (nonatomic, assign) CGFloat Y;

@end
@implementation locationItem

@end

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *snakeArray;
@property (nonatomic, strong) NSMutableArray *snakeViewArray;
@property (nonatomic, strong) locationItem *foodItem;
@property (nonatomic, strong) locationItem *thePreviousFoodItem;
@property (nonatomic, strong) locationItem *theNewHead;
@property (nonatomic, strong) UIView *mainScreen;
@property (nonatomic, assign) NSInteger direction;// 1:上（默认） 2:右 3:下 4:左
@property (nonatomic, assign) NSInteger totalScore;
@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIView *foodView;
@property (nonatomic, strong) UIView *theEatenFood;
@property (nonatomic, assign) NSInteger ifFoodEaten;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewWidth = (double)(self.view.frame.size.width * 0.05f);
    self.viewHeight = (double)(self.view.frame.size.width * 0.05f);
    [self buildView];
    //  pan 和 swipe 有什么区别呢？
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleTheGesture:)];
    [gestureRecognizer setMinimumNumberOfTouches:1];
    // what is the maximum number normally?? Or just leave this here?
    [self.view addGestureRecognizer:gestureRecognizer];
    [self initSnake];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Views
- (void)buildView {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    SelfMadeButton *up  = [[SelfMadeButton alloc] init];
    SelfMadeButton *down = [[SelfMadeButton alloc] init];
    SelfMadeButton *left = [[SelfMadeButton alloc] init];
    SelfMadeButton *right = [[SelfMadeButton alloc] init];
    _mainScreen = [[UIView alloc] init];
    [self.view addSubview:up];
    [self.view addSubview:down];
    [self.view addSubview:left];
    [self.view addSubview:right];
    [self.view addSubview:self.mainScreen];
    
    [up setTitle:@"^" forState:UIControlStateNormal];
    [down setTitle:@"V" forState:UIControlStateNormal];
    [left setTitle:@"<" forState:UIControlStateNormal];
    [right setTitle:@">" forState:UIControlStateNormal];
    
    [up mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.mas_height).multipliedBy(0.1);
        make.height.equalTo(up.mas_width);
        make.bottom.equalTo(down.mas_top).offset((-0.5) * self.viewHeight);
        make.centerX.equalTo(down.mas_centerX);
    }];
    [down mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(up.mas_width);
        make.height.equalTo(up.mas_width);
        make.bottom.equalTo(self.view.mas_bottom).offset((-1) * self.viewHeight);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [left mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(up.mas_width);
        make.height.equalTo(up.mas_width);
        make.centerY.equalTo(down.mas_centerY);
        make.right.equalTo(down.mas_left).offset((-0.5) * self.viewHeight);
    }];
    [right mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(up.mas_width);
        make.height.equalTo(up.mas_width);
        make.centerY.equalTo(down.mas_centerY);
        make.left.equalTo(down.mas_right).offset(self.viewHeight * (0.5));
    }];
    [self.mainScreen setBackgroundColor:[UIColor whiteColor]];
    [self.mainScreen.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.mainScreen.layer setBorderWidth:3];
    [self.mainScreen.layer setCornerRadius:5];
    [self.mainScreen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.8f);
        make.height.mas_equalTo(self.mainScreen.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(2 * self.viewHeight);
    }];
    [up addTarget:self
           action:@selector(goUp:) forControlEvents:UIControlEventTouchUpInside];
    [down addTarget:self
             action:@selector(goDown:) forControlEvents:UIControlEventTouchUpInside];
    [left addTarget:self
             action:@selector(goLeft:) forControlEvents:UIControlEventTouchUpInside];
    [right addTarget:self
              action:@selector(goRight:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - button Related
- (void)goUp:(UIButton *)sender {
    self.direction = 0;
}

- (void)goDown:(UIButton *)sender {
    self.direction = 2;
}

- (void)goLeft:(UIButton *)sender {
    self.direction = 3;
}

- (void)goRight:(UIButton *)sender {
    self.direction = 1;
}

#pragma mark - snake Related
- (void)initSnake {
    _direction = 0;
    _ifFoodEaten = 0;
    _totalScore = 0;
    self.theNewHead = nil;
    locationItem *head = [[locationItem alloc] init];
    locationItem *tail = [[locationItem alloc] init];
    head.X = 0;
    tail.X = 0;
    head.Y = self.viewHeight * 10;
    tail.Y = self.viewHeight * 11;
    UIView *headView = [[UIView alloc] init];
    UIView *tailView = [[UIView alloc] init];
    [headView setBackgroundColor:[UIColor grayColor]];
    [tailView setBackgroundColor:[UIColor grayColor]];
    
    _snakeArray  = [[NSMutableArray alloc] initWithObjects:head, tail, nil];
    _snakeViewArray = [[NSMutableArray alloc] initWithObjects:headView, tailView, nil];
    [self buildTheSnake];
    [self buildTheFood];
    [self addTimer];
}

- (void)buildTheSnake {
    for (NSInteger count = 0 ; count < self.snakeArray.count ; count++) {
        [self.snakeViewArray addObject:[[UIView alloc] init]];
    }
    
    for (NSInteger count = 0 ; count < self.snakeArray.count ; count++) {
        [self.mainScreen addSubview:[self.snakeViewArray objectAtIndex:count]];
        locationItem *item = [self.snakeArray objectAtIndex:count];
        [[self.snakeViewArray objectAtIndex:count] setBackgroundColor:[UIColor grayColor]];
        [[self.snakeViewArray objectAtIndex:count] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.offset(self.viewWidth);
            make.height.offset(self.viewHeight);
            make.left.equalTo(self.mainScreen.mas_left).offset(item.X);
            make.top.equalTo(self.mainScreen.mas_top).offset(item.Y);
        }];
    }
}

- (void)moveTheSnake { // 移动的时候其实后面的一格都是在复制前面的一格，只有第一格受到方向的影响
    locationItem *theHead = [[locationItem alloc] init];
    _theNewHead = [[locationItem alloc] init];
    theHead = [self.snakeArray objectAtIndex:0];
    self.theNewHead.X = theHead.X;
    self.theNewHead.Y = theHead.Y;
    switch (self.direction) {
        case 0:
            self.theNewHead.Y = theHead.Y - self.viewHeight;
            break;
        case 1:
            self.theNewHead.X = theHead.X + self.viewWidth;
            break;
        case 2:
            self.theNewHead.Y = theHead.Y + self.viewHeight;
            break;
        case 3:
            self.theNewHead.X = theHead.X - self.viewWidth;
            break;
        default:
            NSLog(@"direction取值错误:%ld",(long)self.direction);
            break;
    };
    
    if ([self touchTheWall] || [self touchTheBody]) { // 碰到了墙 || 碰到了身体
        [self closeTimer];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"死翘翘～～" message:[NSString stringWithFormat:@"总分数：%ld", (long)self.totalScore] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"重新开始" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self initSnake];
        }];
        [self presentViewController:alertController animated:YES completion:nil];
        [alertController addAction:cancel];
    } else {
        locationItem *theTail = [[locationItem alloc] init];
        theTail = [self.snakeArray objectAtIndex:self.snakeArray.count - 1];
        if (self.thePreviousFoodItem.X == theTail.X && self.thePreviousFoodItem.Y == theTail.Y)  {
            NSLog(@"goooooooot yyaaaaaaa");
            [self.theEatenFood setBackgroundColor:[UIColor clearColor]];
            [self.theEatenFood removeFromSuperview];
            self.thePreviousFoodItem = nil;
            self.ifFoodEaten -= 1;
            UIView *addtional = [[UIView alloc] init];
            [addtional setBackgroundColor:[UIColor clearColor]];
            [self.snakeViewArray addObject:addtional];
            [self.mainScreen addSubview:[self.snakeViewArray objectAtIndex:self.snakeArray.count - 1]];
            //     [self.snakeArray removeObjectAtIndex:self.snakeArray.count - 1];
        } else {
            [self.snakeArray removeObjectAtIndex:self.snakeArray.count - 1];
        }
        
        if ([self gotTheFood]) {
            self.totalScore += 1;
            self.ifFoodEaten += 1;
            [self.foodView removeFromSuperview];
            [self.snakeArray insertObject:self.theNewHead atIndex:0];
            for (NSInteger count = 0; count < self.snakeArray.count ; count++) {
                [[self.snakeViewArray objectAtIndex:count] removeFromSuperview];
            }
            [self.snakeViewArray removeAllObjects];
            _thePreviousFoodItem = [[locationItem alloc] init];
            self.thePreviousFoodItem.X = self.foodItem.X;
            self.thePreviousFoodItem.Y = self.foodItem.Y;
            
            [self buildTheSnake];
            [self buildTheFood];
        } else {
            
            //  在这个特定的状态下，这个时候应该只减去两个就好了
            [self.snakeArray insertObject:self.theNewHead atIndex:0];
            for (NSInteger count = 0; count < self.snakeArray.count ; count++) {
                [[self.snakeViewArray objectAtIndex:count] removeFromSuperview];
            }
            
            [self.snakeViewArray removeAllObjects];
            [self buildTheSnake];
        }
        
        if (self.ifFoodEaten) {
            [self buildTheEatenFood];
        }
    }
}

- (void)buildTheEatenFood {
    _theEatenFood = [[UIView alloc] init];
    [self.mainScreen addSubview:self.theEatenFood];
    [self.theEatenFood setBackgroundColor:[UIColor clearColor]];
    [self.theEatenFood mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(self.viewWidth);
        make.height.offset(self.viewHeight);
        make.top.equalTo(self.mainScreen.mas_top).offset(self.thePreviousFoodItem.Y);
        make.left.equalTo(self.mainScreen.mas_left).offset(self.thePreviousFoodItem.X);
    }];
}

- (BOOL)touchTheWall {// 四面墙壁都要看一下，只看头部就可以了
    if (self.theNewHead.X < 0 || self.theNewHead.X > self.viewWidth * 15) {
        return true;
    }
    if (self.theNewHead.Y < 0 || self.theNewHead.Y > self.viewHeight * 11) {
        return true;
    }
    return false;
}

- (BOOL)touchTheBody {
    for (locationItem *item in self.snakeArray) {
        if (self.theNewHead.X == item.X && self.theNewHead.Y == item.Y) {
            return true;
        }
    }
    return false;
}

- (BOOL)gotTheFood { // 判断一下头部有没有碰到
    if (self.theNewHead.X == self.foodItem.X && self.theNewHead.Y == self.foodItem.Y) {
        return true;
    }
    return false;
}

#pragma mark - food Related
- (void)buildTheFood {
    int location = (arc4random() % (16 * 12 - self.snakeArray.count));
    NSMutableArray *snakePositionInOrder = [[NSMutableArray alloc] init];
    for (locationItem *currentItem in self.snakeArray) {
        int currentItemPosition = currentItem.X / self.viewWidth + 16 * (currentItem.Y / self.viewHeight);
        [snakePositionInOrder addObject:[NSNumber numberWithInt:currentItemPosition]];
    }
    [snakePositionInOrder sortUsingSelector:@selector(compare:)];
    NSLog(@"the position is : %@", snakePositionInOrder);
    for (NSNumber *num in snakePositionInOrder) {
        if (location >= [num intValue]) {
            location ++;
        } else {
            break;
        }
    }
    _foodItem = [[locationItem alloc] init];
    self.foodItem.X = (location % 16) * self.viewWidth;
    self.foodItem.Y = (location / 16) * self.viewHeight;
    _foodView = [[UIView alloc] init];
    [self.mainScreen addSubview:self.foodView];
    [self.foodView setBackgroundColor:[UIColor blueColor]];
    [self.foodView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(self.viewWidth);
        make.height.offset(self.viewHeight);
        make.top.equalTo(self.mainScreen.mas_top).offset(self.foodItem.Y);
        make.left.equalTo(self.mainScreen.mas_left).offset(self.foodItem.X);
    }];
}

#pragma mark - NSTimer
-(void)addTimer
{
    _timer =  [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(moveTheSnake) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)closeTimer
{
    if (self.ifFoodEaten) {
        [self.theEatenFood removeFromSuperview];
    }
    [self.foodView removeFromSuperview];
    for (NSInteger count = 0; count < self.snakeArray.count ; count++) {
        [[self.snakeViewArray objectAtIndex:count] removeFromSuperview];
    }
    [self.snakeViewArray removeAllObjects];
    [self.snakeArray removeAllObjects];
    [self.timer invalidate];
}

- (void)dealloc {
    [self closeTimer];
    self.timer = nil;
}

#pragma mark - recognizer
- (void)handleTheGesture:(UIPanGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint position = [gesture translationInView:self.view];
        NSLog(@"%f, %f ",position.x,position.y);
        NSLog(@"%f, %f",fabs(position.x), fabs(position.y));
        if (fabs(position.x) > fabs(position.y)) {//left and right
            if (position.x > 0) {//right
                
                self.direction = 1;
                
            } else {//left
                self.direction = 3;
            }
        } else {// up and down
            if (position.y > 0) { //down
                self.direction = 2;
            } else {
                self.direction = 0;
            }// up
        }
    }
    
}

@end
