/*
 * (C) Copyright 2008, Stefan Arentz, Arentz Consulting.
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "XMLDigester.h"

@implementation XMLDigester

- (id) init
{
   if ((self = [super init]) != nil) {
      parser_ = [[XMLParser parserWithDelegate: self] retain];
      rulesByPath_ = [[NSMutableDictionary dictionary] retain];
      stack_ = [[NSMutableArray array] retain];
      path_ = [[NSMutableArray array] retain];
   }
   return self;
}

- (void) dealloc
{
   [path_ release];
   [stack_ release];
   [rulesByPath_ release];
   [object_ release];
   [super dealloc];
}

+ (id) digester
{
   return [[[self alloc] init] autorelease];
}

- (NSArray*) stack
{
   return stack_;
}

- (void) pushObject: (id) object
{
   if (object_ == nil) {
      object_ = [object retain];
   }
   [stack_ addObject: object];
}

- (id) popObject
{
   id object = nil;
   if ([stack_ count] > 0) {
      object = [stack_ lastObject];
      [stack_ removeLastObject];
   }
   return object;
}

- (id) peekObject
{
   id object = nil;
   if ([stack_ count] > 0) {
      object = [stack_ lastObject];
   }
   return object;
}

- (id) peekObjectAtIndex: (NSUInteger) index
{
   id object = nil;
   if ([stack_ count] > 0) { // TODO Do a better check
      object = [stack_ objectAtIndex: [stack_ count] - 1 - index];
   }
   return object;
}

- (void) addRule: (XMLDigesterRule*) rule forPattern: (NSString*) pattern;
{
   NSArray* path = [pattern componentsSeparatedByString: @"/"];
   
   NSMutableArray* rules = [rulesByPath_ objectForKey: path];
   if (rules == nil) {
      rules = [NSMutableArray array];
      [rulesByPath_ setObject: rules forKey: path];
   }
   
   [rules addObject: rule];
}

- (id) parseData: (NSData*) data
{
   [parser_ parseData: data];
   return object_;
}

- (void) parsePartialData: (NSData*) data
{
   [parser_ parsePartialData: data];
}

- (id) parseFinalData: (NSData*) data
{
   [parser_ parseFinalData: data];
   return object_;
}

- (void) parser: (XMLParser*) parser didStartElement: (NSString*) element attributes: (NSDictionary*) attributes
{
   [path_ addObject: element];

   NSArray* rules = [rulesByPath_ objectForKey: path_];
   if (rules != nil) {
      for (XMLDigesterRule* rule in rules) {
         [rule didStartElement: element attributes: attributes];
      }
   }
}

- (void) parser: (XMLParser*) parser didEndElement: (NSString*) element
{
   NSArray* rules = [rulesByPath_ objectForKey: path_];
   if (rules != nil) {
      for (XMLDigesterRule* rule in [rules reverseObjectEnumerator]) {
         [rule didEndElement: element];
      }
   }

   [path_ removeLastObject];
}

@end