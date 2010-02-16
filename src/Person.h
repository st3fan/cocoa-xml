// Person.h

#import <Foundation/Foundation.h>

@interface Person : NSObject {
  @private
    NSString* name_;
	NSString* cityOfBirth_;
	NSNumber* luckyNumber_;
}

@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSString* cityOfBirth;
@property (nonatomic,retain) NSNumber* luckyNumber;

@end