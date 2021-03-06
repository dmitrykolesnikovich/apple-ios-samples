/*
     File: BatStatViewController.m
 Abstract: Receives battery status change notifications. Queries the battery status and presents it in a UITableView. Enables and disables battery status updates.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "BatStatViewController.h"

@interface BatStatViewController ()

- (IBAction)switchAction:(id)sender;

@end

@implementation BatStatViewController

#pragma mark - Battery notifications

- (void)updateBatteryLevel
{
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (batteryLevel < 0.0) {
        // -1.0 means battery state is UIDeviceBatteryStateUnknown
        self.levelLabel.text = NSLocalizedString(@"Unknown", @"");
    }
    else {
        static NSNumberFormatter *numberFormatter = nil;
        if (numberFormatter == nil) {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
            [numberFormatter setMaximumFractionDigits:1];
        }
        
        NSNumber *levelObj = [NSNumber numberWithFloat:batteryLevel];
        self.levelLabel.text = [numberFormatter stringFromNumber:levelObj];
    }
}

- (void)updateBatteryState
{
    NSArray *batteryStateCells = @[self.unknownCell, self.unpluggedCell, self.chargingCell, self.fullCell];
    
    UIDeviceBatteryState currentState = [UIDevice currentDevice].batteryState;
    
    for (int i = 0; i < [batteryStateCells count]; i++) {
        UITableViewCell *cell = (UITableViewCell *) batteryStateCells[i];
        
        if (i + UIDeviceBatteryStateUnknown == currentState) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (void)batteryLevelChanged:(NSNotification *)notification
{
    [self updateBatteryLevel];
}

- (void)batteryStateChanged:(NSNotification *)notification
{
    [self updateBatteryLevel];
    [self updateBatteryState];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Register for battery level and state change notifications.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryLevelChanged:)
												 name:UIDeviceBatteryLevelDidChangeNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryStateChanged:)
												 name:UIDeviceBatteryStateDidChangeNotification object:nil];
    
    [self switchAction:self.monitorSwitch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Switch action handler

- (IBAction)switchAction:(id)sender
{
    if ([sender isOn]) {
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
		// The UI will be updated as a result of the first UIDeviceBatteryStateDidChangeNotification notification.
        // Note that enabling monitoring only triggers a UIDeviceBatteryStateDidChangeNotification;
        // a UIDeviceBatteryLevelDidChangeNotification is not sent.
    }
    else {
        [UIDevice currentDevice].batteryMonitoringEnabled = NO;
		
        [self batteryStateChanged:nil];
    }
}


@end
