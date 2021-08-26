#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Cashier.h"
#import "NOPersistentStore.h"
#import "NSString+MD5Addition.h"

FOUNDATION_EXPORT double CashierVersionNumber;
FOUNDATION_EXPORT const unsigned char CashierVersionString[];

