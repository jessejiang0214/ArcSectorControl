//
//  JJvvArcsectorControl.m
//  testdraw
//
//  Created by jesse on 8/4/14.
//  Copyright (c) 2014 pptv. All rights reserved.
//

#import "JJvvArcsectorControl.h"
#import "JJvvMath.h"
#import <CoreText/CoreText.h>

#define sectorringRadius 75.0
#define sectorlineWidth 1
#define markerlineWidth 3
#define markerRadius 10.0
#define markerIconStringFontSize 15.0
#define currentValueFontSize 20.0
#define scaleMarkFontSzie 10

#define IS_OS_LOWER_7    ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)

typedef struct{
    CGPoint BcontrolPoint;
    CGPoint UcontrolPoint;
    //CGFloat radius;
    
    
    CGPoint BLPoint;
    CGPoint BRPoint;
    
    //For the first sector
    CGPoint OptBLPoint;
    CGPoint OptBRPoint;
    bool HasOptPoint;
    
    CGPoint ULPoint;
    CGPoint URPoint;
    
    CGPoint MarkerCenter;
    CGFloat MarkerRadius;
    
    CGPoint CurrentValueCenter;
    
    CGPoint * ScaleMarkCenters;
    CGFloat * ScaleMarkAngle;
    int ScaleMarkNumber;
    
} JJvvSectorDrawingInformation;

@implementation JJvvArcsectorControl{
    NSMutableArray *sectorsArray;
    JJvvArcsectorSector *trackingSector;
    JJvvSectorDrawingInformation trackingSectorDrawInf;
    
}

#pragma mark - Sectors manipulations

- (void)addSector:(JJvvArcsectorSector *)sector{
    [sectorsArray addObject:sector];
    [self setNeedsDisplay];
}

- (void)removeSector:(JJvvArcsectorSector *)sector{
    [sectorsArray removeObject:sector];
    [self setNeedsDisplay];
}

- (void)removeAllSectors{
    [sectorsArray removeAllObjects];
    [self setNeedsDisplay];
}

- (NSArray *)sectors{
    return sectorsArray;
}



#pragma mark - Initializators

- (instancetype)init{
    if(self = [super init]){
        [self setupDefaultConfigurations];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        [self setupDefaultConfigurations];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setupDefaultConfigurations];
    }
    return self;
}

- (void) setupDefaultConfigurations{
    sectorsArray = [NSMutableArray new];
    self.backgroundColor = [UIColor clearColor];
}

-(void)drawRect:(CGRect)rect
{
    if(trackingSector!=nil)
    {
        [self drawSector:trackingSector atPosition:trackingSector.tag];
        return;
    }
    for(int i = 0; i < sectorsArray.count; i++){
        JJvvArcsectorSector *sector = sectorsArray[i];
        [self drawSector:sector atPosition:i];
        
    }
}


- (void)drawSector:(JJvvArcsectorSector *)sector atPosition:(NSUInteger)position{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    JJvvSectorDrawingInformation drawInf = [self sectorToDrawInf:sector position: position];
    
    //draw sector ring
    CGContextMoveToPoint(context, drawInf.BLPoint.x, drawInf.BLPoint.y);
    CGContextAddQuadCurveToPoint(context, drawInf.BcontrolPoint.x, drawInf.BcontrolPoint.y,
                                 drawInf.BRPoint.x, drawInf.BRPoint.y);
    if(drawInf.HasOptPoint)
    {
        CGContextAddLineToPoint(context, drawInf.OptBRPoint.x, drawInf.OptBRPoint.y);
        
    }
    CGContextAddLineToPoint(context, drawInf.URPoint.x, drawInf.URPoint.y);
    CGContextAddQuadCurveToPoint(context, drawInf.UcontrolPoint.x, drawInf.UcontrolPoint.y,
                                 drawInf.ULPoint.x, drawInf.ULPoint.y);
    
    if(drawInf.HasOptPoint)
    {
        CGContextAddLineToPoint(context, drawInf.OptBLPoint.x, drawInf.OptBLPoint.y);
    }
    CGContextAddLineToPoint(context, drawInf.BLPoint.x, drawInf.BLPoint.y);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor);
    CGContextFillPath(context);
    
    
    // draw line
    CGContextMoveToPoint(context, drawInf.BLPoint.x, drawInf.BLPoint.y);
    CGContextAddQuadCurveToPoint(context, drawInf.BcontrolPoint.x, drawInf.BcontrolPoint.y,
                                 drawInf.BRPoint.x, drawInf.BRPoint.y);
    CGContextSetLineWidth(context, sectorlineWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokePath(context);
    
    // draw current value string
    [self drawString:[NSString stringWithFormat:@"%.0f",sector.currentValue]
            withFont:[UIFont boldSystemFontOfSize:currentValueFontSize]
               color:[UIColor whiteColor]
          withCenter:drawInf.CurrentValueCenter
               angle:0
             context:context];
    
    // draw scale value
    for(int i = 0;i<drawInf.ScaleMarkNumber;i++)
    {
        [self drawString:sector.scalemarkValue[i]
                withFont:[UIFont boldSystemFontOfSize:scaleMarkFontSzie]
                   color:[UIColor whiteColor]
              withCenter:drawInf.ScaleMarkCenters[i]
                   angle:90
                context:context];
    }
    
    // draw marker
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, markerlineWidth);
    CGContextAddArc(context, drawInf.MarkerCenter.x, drawInf.MarkerCenter.y,
                    drawInf.MarkerRadius, 0.0, 6.28, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    // draw marker icon
    [self drawString:sector.iconString
            withFont:[UIFont boldSystemFontOfSize:markerIconStringFontSize]
               color:[UIColor whiteColor]
          withCenter:drawInf.MarkerCenter
               angle:0
             context:context];
    

    free(drawInf.ScaleMarkCenters);
    //free(drawinf.ScaleMarkAngle);
}

- (JJvvSectorDrawingInformation) sectorToDrawInf:(JJvvArcsectorSector *)sector position:(NSInteger)position{
    JJvvSectorDrawingInformation drawInf;
    float xoffsite = 0.15;
    
    // sector position
    CGPoint fistControlPoint = CGPointMake(self.frame.size.width/2,
                                           self.frame.size.height - self.frame.size.width/2);
    
    
    if(position == 0)
    {
        drawInf.BLPoint = CGPointMake(self.frame.size.width *xoffsite , self.frame.size.height);
        drawInf.BRPoint = CGPointMake(self.frame.size.width *(1-xoffsite) , self.frame.size.height);
        drawInf.ULPoint = CGPointMake(0 , self.frame.size.height -sectorringRadius);
        drawInf.URPoint = CGPointMake(self.frame.size.width , self.frame.size.height -sectorringRadius);
        
        drawInf.HasOptPoint = true;
        drawInf.OptBLPoint = CGPointMake(0,self.frame.size.height);
        drawInf.OptBRPoint = CGPointMake(self.frame.size.width,self.frame.size.height);
        
        drawInf.BcontrolPoint = fistControlPoint;
        drawInf.UcontrolPoint = CGPointMake(fistControlPoint.x , fistControlPoint.y - sectorringRadius);
        
    }else{
        
        drawInf.BLPoint = CGPointMake(0 , self.frame.size.height - position*sectorringRadius);
        drawInf.BRPoint = CGPointMake(self.frame.size.width  ,  self.frame.size.height - position*sectorringRadius);
        drawInf.ULPoint = CGPointMake(0 , self.frame.size.height - (1+position)*sectorringRadius);
        drawInf.URPoint = CGPointMake(self.frame.size.width , self.frame.size.height- (1+position)*sectorringRadius);
        
        drawInf.HasOptPoint = false;
        drawInf.BcontrolPoint = CGPointMake(fistControlPoint.x , fistControlPoint.y -  position*sectorringRadius);
        drawInf.UcontrolPoint = CGPointMake(fistControlPoint.x , fistControlPoint.y - (1+position)*sectorringRadius);
    }
    

    // marker position
    CGFloat x = drawInf.BLPoint.x + (drawInf.BRPoint.x - drawInf.BLPoint.x)*(sector.currentValue-sector.minValue)/(sector.maxValue-sector.minValue);
    CGPoint crossOnCurve = PointOnBezierFromx(drawInf.BLPoint,drawInf.BcontrolPoint,drawInf.BRPoint,x);
    drawInf.MarkerCenter = crossOnCurve;
    drawInf.MarkerRadius = markerRadius;
    
    // Current value string position
    drawInf.CurrentValueCenter =PointOnBezierFromx(drawInf.BLPoint,drawInf.BcontrolPoint,drawInf.BRPoint,self.frame.size.width/2);
    drawInf.CurrentValueCenter.y -=sectorringRadius/2;
    
    drawInf.ScaleMarkNumber = sector.scalemarkNumber;
    CGFloat scaleX= (drawInf.BRPoint.x - drawInf.BLPoint.x- 2*markerRadius)/(drawInf.ScaleMarkNumber -1);
    drawInf.ScaleMarkCenters = malloc(sizeof(CGPoint)*drawInf.ScaleMarkNumber);
    for(int i = 0;i<drawInf.ScaleMarkNumber; i++)
    {
        x = drawInf.BLPoint.x + markerRadius + i*scaleX;
        crossOnCurve = PointOnBezierFromx(drawInf.BLPoint,drawInf.BcontrolPoint,drawInf.BRPoint,x);
        crossOnCurve.y -= markerRadius;
        drawInf.ScaleMarkCenters[i]=crossOnCurve;
    }
    
    return drawInf;
}

- (void) drawString:(NSString *)s withFont:(UIFont *)font color:(UIColor *)color withCenter:(CGPoint)center angle:(double)angle context:(CGContextRef)context{
    CGSize size = [s sizeWithFont:font];
    CGFloat x = center.x - (size.width / 2);
    CGFloat y = center.y - (size.height / 2);
    CGRect textRect = CGRectMake(x, y, size.width, size.height);
//    if(angle == 0)  fix me
//    {
        if(IS_OS_LOWER_7){
            [color set];
            [s drawInRect:textRect withFont:font];
        }else{
            NSMutableDictionary *attr = [NSMutableDictionary new];
            attr[NSFontAttributeName] = font;
            attr[NSForegroundColorAttributeName] = color;
            [s drawInRect:textRect withAttributes:attr];
        }
//    }else{   //fix me the text laber shoule has angle with tangential direction
//        CGMutablePathRef path = CGPathCreateMutable();
//        CGAffineTransform t = CGAffineTransformMakeRotation(angle);
//        CGPathAddRect(path, NULL, textRect);
//        NSAttributedString *attstring = [[NSAttributedString alloc] initWithString:s];
//        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attstring);
//        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attstring length]), path, NULL);
//        CTFrameDraw(frame, context);
//    }
}

#pragma mark - Events manipulator

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPoint = [touch locationInView:self];
    
    for(NSUInteger i = 0; i < sectorsArray.count; i++){
        JJvvArcsectorSector *sector = sectorsArray[i];
        NSUInteger position = i;
        
        JJvvSectorDrawingInformation drawInf =[self sectorToDrawInf:sector position:position];
        
        if([self touchInBezierWithPoint:touchPoint
                                 LPoint:drawInf.ULPoint CtlPoint:drawInf.UcontrolPoint RPoint:drawInf.URPoint])
        {
            //NSLog(@"Touch in the %d sector lower", i);
            if(![self touchInBezierWithPoint:touchPoint
                                      LPoint:drawInf.BLPoint CtlPoint:drawInf.BcontrolPoint RPoint:drawInf.BRPoint])
            {
                //NSLog(@"Touch in the %d sector uper", i);
                trackingSector = sector;
                trackingSectorDrawInf = drawInf;
                return YES;
            }
        }
        
    }
    NSLog(@"Touch Failed");
    return NO;
}

- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPoint = [touch locationInView:self];
    double newValue = trackingSector.minValue + (touchPoint.x-trackingSectorDrawInf.BLPoint.x)/
    (trackingSectorDrawInf.BRPoint.x - trackingSectorDrawInf.BLPoint.x)*
    (trackingSector.maxValue - trackingSector.minValue);
    
    
    newValue = newValue<trackingSector.minValue?trackingSector.minValue:newValue;    
    newValue = newValue>trackingSector.maxValue?trackingSector.maxValue:newValue;
    trackingSector.CurrentValue = newValue;
    
    [self valueChangedNotification];
    [self setNeedsDisplay];
    return YES;
}

- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    free(trackingSectorDrawInf.ScaleMarkCenters);
    trackingSector = nil;
    [self setNeedsDisplay];
}

- (BOOL) touchInBezierWithPoint:(CGPoint)touchPoint LPoint:(CGPoint)LPoint CtlPoint:(CGPoint)CtlPoint RPoint:(CGPoint)RPoint{
    
    CGPoint crossPoint = BezierCrossLine(LPoint,CtlPoint,RPoint,touchPoint,
                                         CGPointMake(self.frame.size.width /2 , self.frame.size.height));
    
    if(!(crossPoint.x==0&&crossPoint.y==0))
    {
        if(crossPoint.y < touchPoint.y)
            return YES;
    }
    return NO;
}

- (void) valueChangedNotification{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


@end




@implementation JJvvArcsectorSector

- (instancetype)init{
    if(self = [super init]){
        self.minValue = 0.0;
        self.maxValue = 100.0;
        self.CurrentValue = 0.0;
        self.tag = 0;
    }
    return self;
}

+ (instancetype) sector{
    return [[JJvvArcsectorSector alloc] init];
}

+ (instancetype) sectorWithValue:(double)maxValue{
    JJvvArcsectorSector *sector = [self sector];
    sector.maxValue = maxValue;
    return sector;
}

+ (instancetype) sectorWithValue:(double)minValue maxValue:(double)maxValue{
    JJvvArcsectorSector *sector = [self sectorWithValue:maxValue];
    sector.minValue = minValue;
    return sector;
}

@end
