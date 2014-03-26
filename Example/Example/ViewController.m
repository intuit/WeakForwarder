//
//  ViewController.m
//  Example
//
//  Created by Jeff Shulman on 3/26/14.
//	Copyright (c) 2014 Intuit Inc
//
//	Permission is hereby granted, free of charge, to any person obtaining
//	a copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//
//	The above copyright notice and this permission notice shall be
//	included in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//	WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "iOSWeakForwarder.h"
#import "ViewController.h"
#import "SecondViewController.h"

@interface ViewController ()

@property (nonatomic, strong) DummyClass* dummy;

@end

@implementation ViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if ( self ) {
		_dummy = [[DummyClass alloc] init];
	}
	
	return self;
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"After viewDidAppear");
		
		// Note after we pop back to this view controller the system will have dealloc'ed the
		// second view controller leaving our unsuspecting dummy class with a deallocated
		// delegate but not a nil reference since it was unsafe_unretained.
		//
		// So without using iOSWeakForwarder this next line would cause a crash.
		[self.dummy doLogMessage:@"viewDidAppear"];
	});
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	SecondViewController* vc = [segue destinationViewController];
	
	// Instead of setting dummy's delegate directly to vc (the second view controller) we will set it to
	// the weak forwarder which will create a NSProxy object that will stick around as long as "dummy"
	// does but will automatically, due to a true weak reference, nil out the forwarded to object (vc here.)
	self.dummy.delegate = [iOSWeakForwarder forwardTo:vc associatedWith:self.dummy];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"After prepareForSegue");
		[self.dummy doLogMessage:@"from prepareForSegue"];
	});
}

@end
