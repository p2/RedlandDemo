//
//  CHViewController.m
//  RedlandDemo
//
//  Created by Pascal Pfiffner on 12/2/12.
//  Copyright (c) 2012 CHIP. All rights reserved.
//

#import "CHViewController.h"
#import "CHAppDelegate.h"
#import <Redland-ObjC.h>


@interface CHViewController ()

@property (nonatomic, strong) NSURL *currentURL;
@property (strong, nonatomic) RedlandStorage *storage;

@end


@implementation CHViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// iOS 7 layout
	if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
		self.edgesForExtendedLayout = UIRectEdgeAll;
	}
	
	// our RDF+XML file
	_urlField.text = [APP_DELEGATE.defaultURL absoluteString];
}


- (IBAction)download:(id)sender
{
	[_urlField resignFirstResponder];
	
	// get the URL
	NSString *urlString = _urlField.text;
	if ([urlString length] > 0) {
		_output.text = @"Loading...";
		
		// load the RDF+XML
		// this is a very bad way and only for the purpose of this demo, if I see your app doing this you'll get a one-star rating! ;)
		self.currentURL = [NSURL URLWithString:urlString];
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
		dispatch_async(queue, ^{
			NSString *loaded = [[NSString alloc] initWithContentsOfURL:_currentURL encoding:NSUTF8StringEncoding error:nil];
			
			dispatch_sync(dispatch_get_main_queue(), ^{
				[self parseRDFXML:loaded];
			});
		});
	}
	
	// No URL
	else {
		_output.text = @"No URL given";
		
		// for testing purposes, let's use the bundled file
		NSString *path = [[NSBundle mainBundle] pathForResource:@"vcard" ofType:@"xml"];
		self.currentURL = APP_DELEGATE.defaultURL;
		NSString *rdf = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
		[self parseRDFXML:rdf];
	}
}


- (void)parseRDFXML:(NSString *)rdfXML
{
	if ([rdfXML length] > 0) {
		
		// if we want to store stuff locally, we use a SQLite storage object
		if (!_storage) {
			NSString *localStore = APP_DELEGATE.localSQLiteStoragePath;
			if (localStore) {
				NSString *options = [[NSFileManager defaultManager] fileExistsAtPath:localStore] ? @"new='no'" : @"new='yes'";
				self.storage = [[RedlandStorage alloc] initWithFactoryName:@"sqlite" identifier:localStore options:options];
			}
			
			// no local storage, but we still need to provide a storage object
			else {
				self.storage = [RedlandStorage new];
			}
		}
		NSAssert(_storage, @"Must have a `storage` object");
		
		// instantiate a parser
		RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
		RedlandURI *uri = [RedlandURI URIWithURL:_currentURL];
		RedlandModel *model = [RedlandModel modelWithStorage:_storage];
		
		// parse
		@try {
			_output.text = @"Parsing...";
			[parser parseString:rdfXML intoModel:model withBaseURI:uri];
		}
		@catch (NSException *exception) {
			_output.text = [NSString stringWithFormat:@"Failed to parse RDF: %@", [exception reason]];
			return;
		}
		
		// the card is the main node we got from the URL
		RedlandNode *card = [RedlandNode nodeWithURIString:[_currentURL absoluteString]];
		
		// extract nickname
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2006/vcard/ns#nickname"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:card predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		NSString *nickname = [rslt.object isLiteral] ? [rslt.object literalValue] : @"Unknown";
		
		// extract the email address
		predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2006/vcard/ns#email"];
		statement = [RedlandStatement statementWithSubject:card predicate:predicate object:nil];
		query = [model enumeratorOfStatementsLike:statement];
		
		rslt = [query nextObject];
		NSString *email = [rslt.object URIValue] ? [[rslt.object URIValue] stringValue] : @"unknown email";
		
		// show in output
		_output.text = [NSString stringWithFormat:@"Nickname: %@\nEmail: %@", nickname, email];
	}
	else {
		_output.text = @"No RDF+XML received";
	}
}


@end
