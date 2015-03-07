//
//  ChromeTabAdapter.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "ChromeTabAdapter.h"
#import "runningSBApplication.h"

@implementation ChromeTabAdapter

+(id) initWithApplication:(runningSBApplication *)application andWindow:(ChromeWindow *)window andTab:(ChromeTab *)tab
{
    ChromeTabAdapter *out = [[ChromeTabAdapter alloc] init];
    [out setTab:[tab get]];
    [out setWindow:[window get]];
    out.application = application;
    return out;
}

-(id) executeJavascript:(NSString *) javascript
{
    return [self.tab executeJavascript:javascript];
}

-(NSString *) title
{
    return [self.tab title];
}

-(NSString *) URL
{
    return [self.tab URL];
}

-(BOOL) isEqual:(__autoreleasing id)object
{
    if (object == nil || ![object isKindOfClass:[ChromeTabAdapter class]]) return NO;

    ChromeTabAdapter *other = (ChromeTabAdapter *)object;
    return self.tab.id == other.tab.id;
}

-(NSString *) key
{
    return [NSString stringWithFormat:@"C:%ld:%ld", [self.window index], [self.tab id]];
}

- (void)activateTab{

    @autoreleasepool {
        
        if (![(ChromeApplication *)self.application.sbApplication frontmost]) {
            
            NSArray *appArray = [NSRunningApplication runningApplicationsWithBundleIdentifier:self.application.bundleIdentifier];
            
            NSRunningApplication *app = [appArray firstObject];
            if (!app) {
                return;
            }
            [app activateWithOptions:(NSApplicationActivateIgnoringOtherApps | NSApplicationActivateAllWindows)];
        }
     
        // Грёбаная хурма
        // We must wait while application will become frontmost
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.window.index = 1;
            NSUInteger count = self.window.tabs.count;
            NSUInteger tabId = [self.tab id];
            // find tab by id
            for (NSUInteger index = 0; index < count; index++) {
                if ([(ChromeTab *)self.window.tabs[index] id] == tabId) {
                    
                    self.window.activeTabIndex = index + 1;
                    break;
                }
            }
        });
    }
}

@end
