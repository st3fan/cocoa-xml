// digester.m

#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

#import "XMLDigester.h"

@interface Bar : NSObject {
   @private
      NSString* isbn_;
      NSString* title_;
}

@property(retain) NSString* isbn;
@property(retain) NSString* title;

@end

@implementation Bar

@synthesize isbn = isbn_;
@synthesize title = title_;

@end

@interface Foo : NSObject {
   @private
      NSString* name_;
      NSMutableArray* bars_;
}

@property(retain) NSString* name;
@property(retain) NSMutableArray* bars;

- (void) addBar: (Bar*) bar;

@end

@implementation Foo

@synthesize name = name_;
@synthesize bars = bars_;

- (id) init
{
   if ((self = [super init]) != nil) {
      self.bars = [NSMutableArray array];
   }
   return self;
}

- (void) addBar: (Bar*) bar
{
   [self.bars addObject: bar];
}

@end

//

int main(int argc, char** argv)
{
   NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
   {
      char buffer[1024 * 32];
      size_t n = read(STDIN_FILENO, buffer, sizeof(buffer));
      
      XMLDigester* digester = [XMLDigester digester];
      
      [digester addRule: [XMLDigesterObjectCreateRule objectCreateRuleWithDigester: digester class: [Foo class]] forPattern: @"foo"];
      [digester addRule: [XMLDigesterSetPropertiesRule setPropertiesRuleWithDigester: digester] forPattern: @"foo"];
      [digester addRule: [XMLDigesterObjectCreateRule objectCreateRuleWithDigester: digester class: [Bar class]] forPattern: @"foo/bar"];
      [digester addRule: [XMLDigesterSetPropertiesRule setPropertiesRuleWithDigester: digester] forPattern: @"foo/bar"];
      [digester addRule: [XMLDigesterSetNextRule setNextRuleWithDigester: digester selector: @selector(addBar:)] forPattern: @"foo/bar"];
      
      Foo* foo = [digester parseData: [NSData dataWithBytes: buffer length: n]];
      NSLog(@"Foo = %@", foo);
      NSLog(@"Foo.name = %@", foo.name);
      NSLog(@"Foo.bars = %@", foo.bars);
   }
   [pool release];
   
   return 0;
}
