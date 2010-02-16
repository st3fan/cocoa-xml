// XMLDigesterTest.m

#import "XMLDigesterTest.h"
#import "XMLDigester.h"

#import "Person.h"

@implementation XMLDigesterTest

/**
 * Test if we can load the test XML.
 */
 
- (void) testLoadTestXML
{
	NSString* path = [[NSBundle bundleForClass: [self class]] pathForResource:@"XMLDigesterTest" ofType:@"xml"];
	STAssertNotNil(path, @"Cannot find path to XMLDigesterTest.xml");
} 

/**
 * Test if the CreateObjectRule works. Parsing the test XML should result in a single NSMutableArray object.
 */
 
- (void) testCreateObjectRuleWithJustTheTopLevelObject
{
	NSString* path = [[NSBundle bundleForClass: [self class]] pathForResource:@"XMLDigesterTest" ofType:@"xml"];
	STAssertNotNil(path, @"Cannot find path to XMLDigesterTest.xml");

	NSData* xml = [NSData dataWithContentsOfFile: path];
	STAssertNotNil(xml, @"Cannot load XML data");

    XMLDigester* digester = [XMLDigester digesterWithData: xml];
	STAssertNotNil(digester, @"Cannot create XMLDigester instance");
	
	[digester addRule: [XMLDigesterObjectCreateRule objectCreateRuleWithDigester: digester class: [NSMutableArray class]]
		forPattern: @"people"];
	
	NSMutableArray* people = [digester digest];
	STAssertNotNil(people, @"Digester returned nil object");
	
	STAssertTrue([people isKindOfClass: [NSMutableArray class]], @"Top level digester object is not an NSMutableArray");
	STAssertTrue([people count] == 0, @"Returned object should be zero");
}

/**
 * Test if the CreateObjectRule works. Parsing the test XML should result in a top-level NSMutableArray with four
 * Person instances.
 */

- (void) testCreateObjectRule
{
	NSString* path = [[NSBundle bundleForClass: [self class]] pathForResource:@"XMLDigesterTest" ofType:@"xml"];
	STAssertNotNil(path, @"Cannot find path to XMLDigesterTest.xml");

	NSData* xml = [NSData dataWithContentsOfFile: path];
	STAssertNotNil(xml, @"Cannot load XML data");

    XMLDigester* digester = [XMLDigester digesterWithData: xml];
	STAssertNotNil(digester, @"Cannot create XMLDigester instance");
	
	[digester addRule:
		[XMLDigesterObjectCreateRule objectCreateRuleWithDigester: digester class: [NSMutableArray class]]
			forPattern: @"people"];

	[digester addRule:
		[XMLDigesterObjectCreateRule objectCreateRuleWithDigester: digester class: [Person class]]
			forPattern: @"people/person"];

	[digester addRule:
		[XMLDigesterSetNextRule setNextRuleWithDigester: digester selector: @selector(addObject:)]
			forPattern: @"people/person"];
	
	NSMutableArray* people = [digester digest];
	STAssertNotNil(people, @"Digester returned nil object");
	
	STAssertTrue([people isKindOfClass: [NSMutableArray class]], @"Top level digester object is not an NSMutableArray");
	STAssertTrue([people count] == 4, @"Returned object should be zero");
	STAssertTrue([[people objectAtIndex: 0] isKindOfClass: [Person class]], @"Object at index 0 should be a Person");
	STAssertTrue([[people objectAtIndex: 1] isKindOfClass: [Person class]], @"Object at index 0 should be a Person");
	STAssertTrue([[people objectAtIndex: 2] isKindOfClass: [Person class]], @"Object at index 0 should be a Person");
	STAssertTrue([[people objectAtIndex: 3] isKindOfClass: [Person class]], @"Object at index 0 should be a Person");
}

/**
 * Test if the CreateObjectRule works. Parsing the test XML should result in a top-level NSMutableArray with four
 * Person instances. The instances should have their name set.
 */

- (void) testSetPropertyRule
{
	NSString* path = [[NSBundle bundleForClass: [self class]] pathForResource:@"XMLDigesterTest" ofType:@"xml"];
	STAssertNotNil(path, @"Cannot find path to XMLDigesterTest.xml");

	NSData* xml = [NSData dataWithContentsOfFile: path];
	STAssertNotNil(xml, @"Cannot load XML data");

	//

    XMLDigester* digester = [XMLDigester digesterWithData: xml];
	STAssertNotNil(digester, @"Cannot create XMLDigester instance");
	
	[digester addRule:
		[XMLDigesterObjectCreateRule objectCreateRuleWithDigester: digester class: [NSMutableArray class]]
			forPattern: @"people"];

	[digester addRule:
		[XMLDigesterObjectCreateRule objectCreateRuleWithDigester: digester class: [Person class]]
			forPattern: @"people/person"];

	[digester addRule:
		[XMLDigesterSetPropertyRule setPropertyRuleWithDigester: digester]
			forPattern: @"people/person/name"];

	[digester addRule:
		[XMLDigesterSetPropertyRule setPropertyRuleWithDigester: digester name: @"cityOfBirth"]
			forPattern: @"people/person/city-of-birth"];

	[digester addRule:
		[XMLDigesterSetPropertyRule setPropertyRuleWithDigester: digester]
			forPattern: @"people/person/luckyNumber"];

	[digester addRule:
		[XMLDigesterSetNextRule setNextRuleWithDigester: digester selector: @selector(addObject:)]
			forPattern: @"people/person"];
	
	NSMutableArray* people = [digester digest];
	STAssertNotNil(people, @"Digester returned nil object");
	
	//
	
	STAssertTrue([people isKindOfClass: [NSMutableArray class]], @"Top level digester object is not an NSMutableArray");
	STAssertTrue([people count] == 4, @"Returned object should be zero");

	NSString* names[4] = { @"Ringo Starr", @"George Harrison", @"John Lennon", @"Paul McCartney" };

	for (NSUInteger i = 0; i < 4; i++)
	{
		Person* person = [people objectAtIndex: i];
		STAssertTrue([person isKindOfClass: [Person class]], @"Object at index %d should be a Person", i);
		STAssertTrue([[person name] isEqualToString: names[i]], @"Object at index %d does not have correct name", i);
		NSLog(@"===> %@", [person cityOfBirth]);
		STAssertTrue([[person cityOfBirth] isEqualToString: @"Liverpool"], @"Object at index %d does not have correct cityOfBirth", i);
		STAssertTrue([person.luckyNumber intValue] == (i+1) * 10, @"Object at index %d does not have correct luckyNumber", i);
	}
}

@end