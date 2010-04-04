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
#import "XMLDigesterRule.h"

/**
 * Rule implementation that calls a method on the (top-1) (parent) object, passing the top
 * object (child) as an argument. It is commonly used to establish parent-child relationships.
 *
 * Example usage
 *
 *  Assume the following XML:
 *
 *    <people>
 *      <person></person>
 *      <person></person>
 *    </people>
 *
 *  The following digester configuration will parse the names into Name entities and add use
 *  this rule to add them to a top level names array:
 *
 *    // This rule will create the top level object on the stack, a mutable array
 *    [digester addRule: [XMLDigesterObjectCreateRule objectCreateRuleWithDigester: digester
 *      class: [NSMutableArray class]] forPattern: @"people"];
 *
 *    // This rule will create a new Person instance and put it on the stack
 *    [digester addRule: [XMLDigesterObjectCreateRule objectCreateRuleWithDigester: digester
 *      class: [Person class]] forPattern: @"people/person"];
 *
 *    // This rule will call the addObject: method on the top level object
 *    [digester addRule: [XMLDigesterSetNextRule setNextRuleWithDigester: digester
 *      selector: @selector(addObject:)] forPattern: @"people/person"];
 */

@class XMLDigester;

@interface XMLDigesterSetNextRule : XMLDigesterRule {
   @private
      SEL selector_;
}
- (id) initWithSelector: (SEL) selector;
+ (id) setNextRuleWithSelector: (SEL) selector;
@end
