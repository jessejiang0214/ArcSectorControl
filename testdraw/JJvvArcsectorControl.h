//
//  JJvvArcsectorControl.h
//  testdraw
//
//  Created by jesse on 8/4/14.
//  Copyright (c) 2014 pptv. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JJvvArcsectorSector : NSObject


@property (nonatomic, readwrite) double minValue;
@property (nonatomic, readwrite) double maxValue;

@property (nonatomic, readwrite) double currentValue;
@property (nonatomic, readwrite) NSString *iconString;

@property (nonatomic, readwrite) int scalemarkNumber;
@property (nonatomic, readwrite) NSArray *scalemarkValue;

@property (nonatomic, readwrite) NSInteger tag;

- (instancetype) init;

+ (instancetype) sector;
+ (instancetype) sectorWithValue:(double)maxValue;
+ (instancetype) sectorWithValue:(double)minValue maxValue:(double)maxValue;


@end


@interface JJvvArcsectorControl : UIControl

@property (strong, nonatomic, readonly) NSArray *sectors;

- (void)addSector:(JJvvArcsectorSector *)sector;
- (void)removeSector:(JJvvArcsectorSector *)sector;
- (void)removeAllSectors;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@end


