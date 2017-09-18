//
// XMLReader.h
//

// Obtained from http://troybrant.net/blog/2010/09/simple-xml-to-nsdictionary-converter/

#import <Foundation/Foundation.h>

@interface XMLReader : NSObject <NSXMLParserDelegate>

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;

@end
