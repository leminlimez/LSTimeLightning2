#import <Foundation/Foundation.h>
#import "LSTRootListController.h"

@implementation LSTRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

@end
