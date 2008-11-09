// test.m

#import "XMLParser.h"

@interface ParserDelegate : NSObject {
}
@end

@implementation ParserDelegate

- (void) parserDidStartDocument: (NSXMLParser*) parser
{
   NSLog(@"parserDidStartDocument: %@", parser);
}

- (void) parserDidEndDocument: (NSXMLParser*) parser
{
   NSLog(@"parserDidEndDocument: %@", parser);
}

- (void) parser: (NSXMLParser*) parser didStartElement: (NSString*) elementName namespaceURI: (NSString*) namespaceURI
  qualifiedName:(NSString*) qualifiedName attributes: (NSDictionary*) attributes
{
   NSLog(@"parser: %@ didStartElement: %@ namespaceURI: %@ qualifiedName: %@ attributes: %@", parser, elementName, namespaceURI, qualifiedName, attributes);
}

- (void) parser: (NSXMLParser*) parser didEndElement: (NSString*) elementName namespaceURI: (NSString*) namespaceURI
  qualifiedName: (NSString*) qName
{
   NSLog(@"parser: %@ didEndElement: %@ namespaceURI: %@ qualifiedName: %@", parser, elementName, namespaceURI, qName);
}

- (void) parser: (NSXMLParser*) parser foundCharacters: (NSString*) string
{
   NSLog(@"parser: %@ foundCharacters: %@", parser, string);
}

@end

// TODO This is just for testing - move to a real test directory together with xml stanzas

#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

int main(int argc, char** argv)
{
   NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
   {
      char buffer[1024 * 32];
      size_t n;

      n = read(STDIN_FILENO, buffer, sizeof(buffer));

      NSXMLParser* parser = [[NSXMLParser alloc] initWithData: [NSData dataWithBytes: buffer length: n]];
      [parser setDelegate: [ParserDelegate new]];
      [parser setShouldProcessNamespaces: YES];
      [parser parse];
   }
   [pool release];
   
   return 0;
}
