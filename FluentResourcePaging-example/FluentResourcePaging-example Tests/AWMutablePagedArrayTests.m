//
// AWMutablePagedArrayTests.m
//
// Copyright (c) 2014 Alek Åström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <XCTest/XCTest.h>
#import "AWMutablePagedArray.h"

@interface AWMutablePagedArrayTests : XCTestCase
@end

const NSUInteger MutablePagedArraySize = 50;
const NSUInteger MutablePagedArrayObjectsPerPage = 6;

@implementation AWMutablePagedArrayTests {
    AWMutablePagedArray *_pagedArray;
    NSMutableArray *_firstPage;
    NSMutableArray *_secondPage;
}

- (void)setUp {
    [super setUp];

    _pagedArray = [[AWMutablePagedArray alloc] initWithCount:MutablePagedArraySize objectsPerPage:MutablePagedArrayObjectsPerPage];
    
    _firstPage = [NSMutableArray array];
    for (NSInteger i = 1; i <= MutablePagedArrayObjectsPerPage; i++) {
        [_firstPage addObject:@(i)];
    }
    [_pagedArray setObjects:_firstPage forPage:1];
    
    _secondPage = [NSMutableArray array];
    for (NSInteger i = MutablePagedArrayObjectsPerPage+1; i <= MutablePagedArrayObjectsPerPage*2; i++) {
        [_secondPage addObject:@(i)];
    }
    [_pagedArray setObjects:_secondPage forPage:2];
    
}
- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSizeIsCorrect {
    XCTAssertEqual(_pagedArray.count, MutablePagedArraySize, @"Paged array has wrong size");
}
- (void)testObjectsPerPageIsCorrect {
    XCTAssertEqual(_pagedArray.objectsPerPage, MutablePagedArrayObjectsPerPage, @"Paged array has wrong objects per page count");
}
- (void)testReturnsRightObject {
    
    XCTAssertEqualObjects(_pagedArray[0], _firstPage[0], @"Returns wrong object!");
}
- (void)testThrowsExceptionWhenSettingPageWithWrongSize {
    
    XCTAssertThrowsSpecificNamed([_pagedArray setObjects:@[@1] forPage:1], NSException, AWMutablePagedArrayObjectsPerPageMismatchException, @"Paged array throws wrong exception");
}
- (void)testDoesNotThrowExceptionWhenSettingLastPageWithOddSize {
    
    NSInteger lastPage = MutablePagedArraySize/MutablePagedArrayObjectsPerPage;
    
    XCTAssertNoThrow([_pagedArray setObjects:@[@(1)] forPage:lastPage], @"Paged array throws exception on last page!");
}
- (void)testFastEnumeration {
    
    NSMutableArray *objects = [NSMutableArray array];
    for (id object in _pagedArray) {
        [objects addObject:object];
    }
    
    NSArray *testObjects = [_firstPage arrayByAddingObjectsFromArray:_secondPage];
    
    XCTAssertEqualObjects(objects, testObjects, @"Fast enumeration outputs wrong objects");
}
- (void)testFastEnumerationUpdatesAfterSettingNewPage {
    
    NSMutableArray *beforeObjects = [NSMutableArray array];
    for (id object in _pagedArray) {
        [beforeObjects addObject:object];
    }
    
    [_pagedArray setObjects:_firstPage forPage:3];
    
    NSMutableArray *afterObjects = [NSMutableArray array];
    for (id object in _pagedArray) {
        [afterObjects addObject:object];
    }
    
    XCTAssertNotEqualObjects(beforeObjects, afterObjects, @"Fast enumeration still returns same objects after setting new page");
}
- (void)testIndexOfObjectReturnsRightIndex {
    
    NSNumber *testNumber = _secondPage[0];
    XCTAssert(([_pagedArray indexOfObject:testNumber] == MutablePagedArrayObjectsPerPage), @"Paged array returned wrong index for object");
}
- (void)testIndexOfObjectReturnsNSNotFoundWhenLookingForAnObjectNotInTheArray {
    
    XCTAssert(([_pagedArray indexOfObject:@(NSNotFound)] == NSNotFound), @"Index returned for an object not present in the array");
}

@end
