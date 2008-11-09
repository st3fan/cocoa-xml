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

#import "XMLParser.h"

void StartElementHandler(void* userData, const XML_Char* name, const XML_Char** atts)
{
   XMLParser* parser = (XMLParser*) userData;

   NSMutableDictionary* attributes = [NSDictionary dictionary];
   if (*atts != NULL) {
      attributes = [NSMutableDictionary dictionary];
      while (*atts != NULL) {
         NSString* attributeName = [NSString stringWithCString: *atts++ encoding: NSUTF8StringEncoding];
         NSString* attributeValue = [NSString stringWithCString: *atts++ encoding: NSUTF8StringEncoding];
         [attributes setObject: attributeValue forKey: attributeName];
      }
   } else {
      attributes = [NSDictionary dictionary];
   }

   [[parser delegate] parser: parser didStartElement: [NSString stringWithCString: name encoding: NSUTF8StringEncoding]
      attributes: attributes];
}

void EndElementHandler(void* userData, const XML_Char* name)
{
   XMLParser* parser = (XMLParser*) userData;
   [[parser delegate] parser: parser didEndElement: [NSString stringWithCString: name encoding: NSUTF8StringEncoding]];
}

void CharacterDataHandler(void *userData, const XML_Char *data, int length)
{
   XMLParser* parser = (XMLParser*) userData;
   [[parser delegate] parser: parser foundCharacters: [[[NSString alloc] initWithBytes: data length: length
      encoding: NSUTF8StringEncoding] autorelease]];
}

@implementation XMLParser

- (id) initWithDelegate: (id) delegate
{
   if ((self = [super init]) != nil) {
      delegate_ = [delegate retain];
      parser_ = XML_ParserCreate(NULL);
      XML_SetUserData(parser_, self);
      if ([delegate respondsToSelector: @selector(parser:didStartElement:attributes:)]) {
         XML_SetStartElementHandler(parser_, StartElementHandler);
      }
      if ([delegate respondsToSelector: @selector(parser:didEndElement:)]) {
         XML_SetEndElementHandler(parser_, EndElementHandler);
      }
      if ([delegate respondsToSelector: @selector(parser:foundCharacters:)]) {
         XML_SetCharacterDataHandler(parser_, CharacterDataHandler);
      }
   }
   return self;
}

- (void) dealloc
{
   XML_ParserFree(parser_);
   [delegate_ release];
   [super dealloc];
}

+ (id) parserWithDelegate: (id) delegate
{
   return [[[self alloc] initWithDelegate: delegate] autorelease];
}

- (void) parseData: (NSData*) data
{
   enum XML_Status status = XML_Parse(parser_, [data bytes], [data length], 1);
}

- (void) parsePartialData: (NSData*) data
{
   enum XML_Status status = XML_Parse(parser_, [data bytes], [data length], 0);
}

- (void) parseFinalData: (NSData*) data
{
   enum XML_Status status = XML_Parse(parser_, [data bytes], [data length], 1);
}

- (id) delegate
{
   return delegate_;
}

@end
