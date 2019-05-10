/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKDataSourceConfiguration.h"
#import "CKDataSourceConfigurationInternal.h"

#import "CKEqualityHashHelpers.h"
#import "CKGlobalConfig.h"
#import "CKMacros.h"

static auto nilProvider(id<NSObject>, id<NSObject>) -> CKComponent * { return nil; }

@implementation CKDataSourceConfiguration
{
  CKSizeRange _sizeRange;
  std::unordered_set<CKComponentPredicate> _componentPredicates;
  std::unordered_set<CKComponentControllerPredicate> _componentControllerPredicates;
  CKDataSourceSplitChangesetOptions _splitChangesetOptions;
  CKComponentProviderBlock _componentProviderBlock;
  // These are preserved only for the purposes of equality checking
  Class _componentProviderClass;
}

- (instancetype)initWithComponentProvider:(Class<CKComponentProvider>)componentProvider
                                  context:(id<NSObject>)context
                                sizeRange:(const CKSizeRange &)sizeRange
{
  return [self initWithComponentProvider:componentProvider
                                 context:context
                               sizeRange:sizeRange
                   splitChangesetOptions:{}
                     componentPredicates:{}
           componentControllerPredicates:{}
                       analyticsListener:nil];
}

- (instancetype)initWithComponentProviderFunc:(CKComponentProviderFunc)componentProvider
                                      context:(id<NSObject>)context
                                    sizeRange:(const CKSizeRange &)sizeRange
{
  return [self initWithComponentProviderFunc:componentProvider
                                     context:context
                                   sizeRange:sizeRange
                       splitChangesetOptions:{}
                         componentPredicates:{}
               componentControllerPredicates:{}
                           analyticsListener:nil];
}

- (instancetype)initWithComponentProvider:(Class<CKComponentProvider>)componentProvider
                                  context:(id<NSObject>)context
                                sizeRange:(const CKSizeRange &)sizeRange
                    splitChangesetOptions:(const CKDataSourceSplitChangesetOptions &)splitChangesetOptions
                      componentPredicates:(const std::unordered_set<CKComponentPredicate> &)componentPredicates
            componentControllerPredicates:(const std::unordered_set<CKComponentControllerPredicate> &)componentControllerPredicates
                        analyticsListener:(id<CKAnalyticsListener>)analyticsListener
{
  return [self initWithComponentProvider:componentProvider
                                 context:context
                               sizeRange:sizeRange
                   splitChangesetOptions:splitChangesetOptions
                     componentPredicates:componentPredicates
           componentControllerPredicates:componentControllerPredicates
                       analyticsListener:analyticsListener
shouldInvalidateControllerBetweenComponentGenerations:CKReadGlobalConfig().shouldInvalidateControllerBetweenComponentGenerationsInDataSource];
}

- (instancetype)initWithComponentProviderFunc:(CKComponentProviderFunc)componentProvider
                                      context:(id<NSObject>)context
                                    sizeRange:(const CKSizeRange &)sizeRange
                        splitChangesetOptions:(const CKDataSourceSplitChangesetOptions &)splitChangesetOptions
                          componentPredicates:(const std::unordered_set<CKComponentPredicate> &)componentPredicates
                componentControllerPredicates:(const std::unordered_set<CKComponentControllerPredicate> &)componentControllerPredicates
                            analyticsListener:(id<CKAnalyticsListener>)analyticsListener
{
  return [self initWithComponentProviderFunc:componentProvider
                                     context:context
                                   sizeRange:sizeRange
                       splitChangesetOptions:splitChangesetOptions
                         componentPredicates:componentPredicates
               componentControllerPredicates:componentControllerPredicates
                           analyticsListener:analyticsListener
shouldInvalidateControllerBetweenComponentGenerations:CKReadGlobalConfig().shouldInvalidateControllerBetweenComponentGenerationsInDataSource];
}

- (instancetype)initWithComponentProviderFunc:(CKComponentProviderFunc)componentProvider
                                      context:(id<NSObject>)context
                                    sizeRange:(const CKSizeRange &)sizeRange
                        splitChangesetOptions:(const CKDataSourceSplitChangesetOptions &)splitChangesetOptions
                          componentPredicates:(const std::unordered_set<CKComponentPredicate> &)componentPredicates
                componentControllerPredicates:(const std::unordered_set<CKComponentControllerPredicate> &)componentControllerPredicates
                            analyticsListener:(id<CKAnalyticsListener>)analyticsListener
shouldInvalidateControllerBetweenComponentGenerations:(BOOL)shouldInvalidateControllerBetweenComponentGenerations
{
  componentProvider = componentProvider ?: nilProvider;

  return [self initWithComponentProviderClass:Nil
                       componentProviderBlock:^(id<NSObject> m, id<NSObject> c){ return componentProvider(m, c); }
                                      context:context
                                    sizeRange:sizeRange
                        splitChangesetOptions:splitChangesetOptions
                          componentPredicates:componentPredicates
                componentControllerPredicates:componentControllerPredicates
                            analyticsListener:analyticsListener
shouldInvalidateControllerBetweenComponentGenerations:shouldInvalidateControllerBetweenComponentGenerations];
}

- (instancetype)initWithComponentProvider:(Class<CKComponentProvider>)componentProvider
                                  context:(id<NSObject>)context
                                sizeRange:(const CKSizeRange &)sizeRange
                    splitChangesetOptions:(const CKDataSourceSplitChangesetOptions &)splitChangesetOptions
                      componentPredicates:(const std::unordered_set<CKComponentPredicate> &)componentPredicates
            componentControllerPredicates:(const std::unordered_set<CKComponentControllerPredicate> &)componentControllerPredicates
                        analyticsListener:(id<CKAnalyticsListener>)analyticsListener
shouldInvalidateControllerBetweenComponentGenerations:(BOOL)shouldInvalidateControllerBetweenComponentGenerations
{
  auto const pb = ^(id<NSObject> m, id<NSObject> c){ return [componentProvider componentForModel:m context:c]; };
  return [self initWithComponentProviderClass:componentProvider
                       componentProviderBlock:pb
                                      context:context
                                    sizeRange:sizeRange
                        splitChangesetOptions:splitChangesetOptions
                          componentPredicates:componentPredicates
                componentControllerPredicates:componentControllerPredicates
                            analyticsListener:analyticsListener
shouldInvalidateControllerBetweenComponentGenerations:shouldInvalidateControllerBetweenComponentGenerations];
}

- (instancetype)initWithComponentProviderClass:(Class<CKComponentProvider>)componentProviderClass
                        componentProviderBlock:(CKComponentProviderBlock)componentProviderBlock
                                       context:(id<NSObject>)context
                                     sizeRange:(const CKSizeRange &)sizeRange
                         splitChangesetOptions:(const CKDataSourceSplitChangesetOptions &)splitChangesetOptions
                           componentPredicates:(const std::unordered_set<CKComponentPredicate> &)componentPredicates
                 componentControllerPredicates:(const std::unordered_set<CKComponentControllerPredicate> &)componentControllerPredicates
                             analyticsListener:(id<CKAnalyticsListener>)analyticsListener
shouldInvalidateControllerBetweenComponentGenerations:(BOOL)shouldInvalidateControllerBetweenComponentGenerations
{
  if (self = [super init]) {
    _componentProviderClass = componentProviderClass;
    _componentProviderBlock = componentProviderBlock;
    _context = context;
    _sizeRange = sizeRange;
    _componentPredicates = componentPredicates;
    _componentControllerPredicates = componentControllerPredicates;
    _analyticsListener = analyticsListener;
    _splitChangesetOptions = splitChangesetOptions;
    _shouldInvalidateControllerBetweenComponentGenerations = shouldInvalidateControllerBetweenComponentGenerations;
  }
  return self;
}

- (instancetype)copyWithContext:(id<NSObject>)context sizeRange:(const CKSizeRange &)sizeRange
{
  return [[CKDataSourceConfiguration alloc] initWithComponentProviderClass:_componentProviderClass
                                                    componentProviderBlock:_componentProviderBlock
                                                                   context:context
                                                                 sizeRange:sizeRange
                                                     splitChangesetOptions:_splitChangesetOptions
                                                       componentPredicates:_componentPredicates
                                             componentControllerPredicates:_componentControllerPredicates
                                                         analyticsListener:_analyticsListener
                     shouldInvalidateControllerBetweenComponentGenerations:_shouldInvalidateControllerBetweenComponentGenerations];
}

- (const CKDataSourceSplitChangesetOptions &)splitChangesetOptions
{
  return _splitChangesetOptions;
}

- (const std::unordered_set<CKComponentPredicate> &)componentPredicates
{
  return _componentPredicates;
}

- (const std::unordered_set<CKComponentControllerPredicate> &)componentControllerPredicates
{
  return _componentControllerPredicates;
}

- (const CKSizeRange &)sizeRange
{
  return _sizeRange;
}

- (CKComponentProviderBlock)componentProvider
{
  return _componentProviderBlock;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[CKDataSourceConfiguration class]]) {
    return NO;
  } else {
    CKDataSourceConfiguration *obj = (CKDataSourceConfiguration *)object;
    return (_componentProviderClass == obj->_componentProviderClass
            && (_context == obj.context || [_context isEqual:obj.context])
            && _sizeRange == obj.sizeRange);
  }
}

- (BOOL)hasSameComponentProviderAndContextAs:(CKDataSourceConfiguration *)other
{
  if (other == nil) {
    return NO;
  }
  return _componentProviderClass == other->_componentProviderClass && (_context == other.context || [_context isEqual:other.context]);
}

- (NSUInteger)hash
{
  NSUInteger hashes[2] = {
    [_context hash],
    _sizeRange.hash()
  };
  return CKIntegerArrayHash(hashes, CK_ARRAY_COUNT(hashes));
}

@end
