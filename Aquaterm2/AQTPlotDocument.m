//
//  AQTDocument.m
//  Aquaterm2
//
//  Created by Per Persson on 13-08-09.
//  Copyright (c) 2013 Aquaterm. All rights reserved.
//

#import "AQTPlotDocument.h"
#import "AQTPlotView.h"

@implementation AQTPlotDocument

- (id)init
{
    self = [super init];
    if (self) {
        // FIXME: Size argument
        _model = [[AQTModel alloc] initWithCanvasSize:NSMakeSize(100,100)];
    }
    return self;
}

- (void)awakeFromNib
{
    // NSLog(@"%@#%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"AQTPlotDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    //  NSLog(@"%@#%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    [self.window setContentSize:_model.canvasSize];
    [self.window setContentAspectRatio:_model.canvasSize];
    [self.window setTitle:_model.title];
    
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSData *data = nil;
    @try {
        data = [NSKeyedArchiver archivedDataWithRootObject:_model];
    }
    @catch (NSException *exception) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil];
        }
    }
    
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    @try {
        _model = (AQTModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        _model.bounds = NSZeroRect; // Trigger bounds computation and caching.
    }
    @catch (NSException *exception) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil];
        }
        _model = nil;
    }

    return (_model != nil);
}

- (AQTModel *)model
{
    return _model;
}

#pragma mark ==== AQTRendering methods ====
- (void)setModel:(bycopy AQTModel *)aModel
{
    _model = aModel;
    
    [self showWindows];
}

#pragma mark ==== Helpers ====

- (BOOL)putOnPasteboard:(id)object
{
    if (!object && ![object conformsToProtocol:@protocol(NSPasteboardWriting)]) {
        return NO;
    }
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    return [pasteboard writeObjects:@[object]];
}

- (NSWindow *)window
{
    return [self.windowControllers[0] window];
}

- (NSView *)contentView
{
    return [self.window contentView];
}


- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings
                                           error:(NSError **)outError
{
    NSPrintOperation *po = nil;
    
    @try {
        po = [NSPrintOperation printOperationWithView:self.contentView];
    }
    @catch (NSException *exception) {
        if (outError) {
            *outError = [NSError errorWithDomain:@"Foo" code:42 userInfo:nil];
        }
    }
    
    return po;
}


#pragma mark ==== Action methods ====

- (void)copy:(id)sender
{
    NSView *canvasView = self.contentView;
    NSRect viewBounds = canvasView.bounds;
    
    NSData* theData = [canvasView dataWithPDFInsideRect:viewBounds];
    NSPDFImageRep* pdfRep = [NSPDFImageRep imageRepWithData:theData];
    NSImage* pdfImage = [[NSImage alloc] initWithSize:viewBounds.size];
    [pdfImage addRepresentation:pdfRep];
    
    [self putOnPasteboard:pdfImage];
}


@end
