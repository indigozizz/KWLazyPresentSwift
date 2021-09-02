//
//  UIViewController+LazyPresentDealloc.m
//  KWLazyPresentSwift
//
//  Created by Kawa on 2021/9/5.
//

#import <objc/runtime.h>
#import "UIViewController+LazyPresentDealloc.h"

@implementation UIViewController (LazyPresentDealloc)

#pragma mark - Swizzle Dealloc

+ (void)kw_replaceDealloc {
    //↓ ARC forbids use of 'dealloc' in a @selector ↓
    //Method origin_deallo_method = class_getInstanceMethod([self class], @selector(dealloc));
    //↓ Use NSSelectorFromString instead of @selector ↓
    Method origin_dealloc_method = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
    Method swizzle_dealloc_method = class_getInstanceMethod([self class], @selector(swizzle_dealloc));

    method_exchangeImplementations(origin_dealloc_method, swizzle_dealloc_method);
}

- (void)swizzle_dealloc {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VIEW_CONTROLLER_WILL_DEALLOC" object:self];

    [self swizzle_dealloc];
}

@end
