#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "rootless.h"

#define MILLIS_PER_CHARGE 1318.359375

@interface SBFLockScreenDateViewController : UIViewController
@property(nonatomic, strong) NSTimer *litt_timer;
@end

@interface _UIStatusBarStringView : UILabel
@property (nonatomic, assign) BOOL litt_isTimeString;
@end

@interface _UIStatusBarTimeItem : NSObject
@property (nonatomic, strong, readwrite) _UIStatusBarStringView *timeView;
@property (nonatomic, strong, readwrite) _UIStatusBarStringView *shortTimeView;
@property (nonatomic, strong, readwrite) _UIStatusBarStringView *pillTimeView;
@end