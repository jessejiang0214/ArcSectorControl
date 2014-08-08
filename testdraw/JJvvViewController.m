//
//  JJvvViewController.m
//  testdraw
//
//  Created by jesse on 8/4/14.
//  Copyright (c) 2014 pptv. All rights reserved.
//

#import "JJvvViewController.h"

@interface JJvvViewController ()

@end

@implementation JJvvViewController
{
    UIImage * localImage;
    CIContext * context;
    CIFilter * brightnessFilter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMultisectorControl];
    [self setupImageControl];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupImageControl{

    localImage = [UIImage imageNamed:@"testPicture.jpg"];
    self.OutputImage.image = localImage;
    CGImageRef inputCGImage =localImage.CGImage;
    CIImage * inputImage = [CIImage imageWithCGImage:inputCGImage];
    context = [CIContext contextWithOptions:nil];
    brightnessFilter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:@"inputImage",inputImage, nil];
    CGImageRelease(inputCGImage);
}

- (void)setupMultisectorControl{
    [self.arcsectorControl addTarget:self action:@selector(arcsectorValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    JJvvArcsectorSector *sector1 = [JJvvArcsectorSector sectorWithValue:-1 maxValue:1];
    sector1.currentValue = 0;
    sector1.iconString = @"☼";
    sector1.scalemarkNumber = 5;
    sector1.scalemarkValue=[NSArray arrayWithObjects:@"-1",@"-0.5",@"0",@"0.5",@"1",nil];
    JJvvArcsectorSector *sector2 = [JJvvArcsectorSector sectorWithValue:20.0];
    sector2.currentValue = 0;
    sector2.iconString = @"☯";
    sector2.scalemarkNumber = 2;
    sector2.scalemarkValue=[NSArray arrayWithObjects:@"0",@"100",nil];
    JJvvArcsectorSector *sector3 = [JJvvArcsectorSector sectorWithValue:100.0];
    sector3.currentValue = 0;
    sector3.iconString = @"S";
    sector3.scalemarkNumber = 4;
    sector3.scalemarkValue=[NSArray arrayWithObjects:@"0",@"33",@"66",@"100",nil];
    sector1.tag = 0;
    sector2.tag = 1;
    sector3.tag = 2;
    
    [self.arcsectorControl addSector:sector1];
    [self.arcsectorControl addSector:sector2];
    [self.arcsectorControl addSector:sector3];
}

- (void)arcsectorValueChanged:(id)sender{
    
    NSMutableArray *sectorValus =[NSMutableArray arrayWithCapacity:[self.arcsectorControl.sectors count]];
    for(int i =0 ;i<[self.arcsectorControl.sectors count];i++)
    {
        JJvvArcsectorSector * sector =[self.arcsectorControl.sectors objectAtIndex:i];
        [sectorValus addObject:[NSNumber numberWithDouble:sector.currentValue]];
        sector = nil;
    }
    [brightnessFilter setValue:[NSNumber numberWithDouble:[[sectorValus objectAtIndex:0] doubleValue]] forKey:@"inputBrightness"];
    CIImage * outputImage = [brightnessFilter outputImage];
    CGImageRef outputCGImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    [self.OutputImage setImage:[UIImage imageWithCGImage:outputCGImage]];
    CGImageRelease(outputCGImage);

}

@end
