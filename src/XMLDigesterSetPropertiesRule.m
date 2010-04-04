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

#import "XMLDigesterSetPropertiesRule.h"
#import "XMLDigester.h"

@implementation XMLDigesterSetPropertiesRule

- (id) initWithMappings: (NSDictionary*) mappings
{
   if ((self = [super init]) != nil) {
		mappings_ = [mappings retain];
   }
   return self;
}

- (void) dealloc
{
	[mappings_ release];
	[super dealloc];
}

+ (id) setPropertiesRuleWithMappings: (NSDictionary*) mappings
{
   return [[[self alloc] initWithMappings: mappings] autorelease];
}

- (void) didStartElement: (NSString*) element attributes: (NSDictionary*) attributes
{
   NSObject* object = [[self digester] peekObject];
   for (NSString* attribute in attributes) {
      if (mappings_ != nil) {
		NSString* key = [mappings_ objectForKey: attribute];
		if (key != nil) {
			[object setValue: [attributes objectForKey: attribute] forKey: key];
		}
	  } else {
		[object setValue: [attributes objectForKey: attribute] forKey: attribute];
	  }
   }
}

@end