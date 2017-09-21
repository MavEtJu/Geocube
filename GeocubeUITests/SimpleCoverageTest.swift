//
//  SimpleCoverageTest.swift
//  GeocubeUITests
//
//  Created by Tim Learmont on 9/20/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

import XCTest

class SimpleCoverageTest: XCTestCase {
    typealias ScreenTest = (screenName:String, hasLocalMenu:Bool)
    typealias CommandTest = (command:String, swipeUpFrom: String?, screens:[ScreenTest])

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func coverageTestHelper(tests coverageTests: [CommandTest]) {
        let app = XCUIApplication()
        
        // XXX These tests should be re-written using Accessibility IDs so they don't depend on language.
        let menuIconGlobalDefaultButton = app.buttons["menu icon   global   default"]
        let localMenuButton = app.buttons["menu icon   local   default"]
        
        
        let tablesQuery = app.tables
        
        for (command, swipeUpFrom, screens) in coverageTests {
            menuIconGlobalDefaultButton.tap()
            if let swipeUpCommand = swipeUpFrom {
                tablesQuery.staticTexts[swipeUpCommand].swipeUp()
            }
            let currentCommandElement = tablesQuery.staticTexts[command]
            if currentCommandElement.exists {
                currentCommandElement.tap()
                
                if let (lastScreen, _) = screens.last {
                    // Select the last screen
                    app.buttons[lastScreen].tap()
                }
                // Now, go through all the screens and make sure that they work.
                for (screenName, hasLocalMenu) in screens {
                    app.buttons[screenName].tap()
                    if hasLocalMenu != localMenuButton.exists {
                        // It either is supposed to have a local menu and doesn't or vice versa.
                        // Show an appropriate message.
                        if hasLocalMenu {
                            XCTFail("\(command)/\(screenName) should have a local menu but doesn't")
                        } else {
                            XCTFail("\(command)/\(screenName) should not have a local menu, but does")
                        }
                    } else if localMenuButton.exists {
                        // Try tapping it and then making it go away.
                        localMenuButton.tap()
                        // Now, make the local menu go away.
                        menuIconGlobalDefaultButton.tap()
                        
                    }
                }
                
            } else {
                XCTFail("Could not find global menu item \(command)")
            }
        }
        
    }

    /// Test the expected items in the UI once a user has initialized the app.
    func testCoverageExpected() {
        let coverageTests:[CommandTest] = [
            ("Navigate", nil, [("Compass", false), ("Target", true), ("Map", true)]),
            ("Waypoints", nil, [("Filters", true), ("List", true), ("Map", true)]),
            ("Keep Track", nil, [("Car", true), ("Tracks", true), ("Map", true), ("Beeper", false)]),
            ("Notes + Logs", nil, [("Saved", true), ("Personal", false), ("Field", false), ("Images", false)]),
            ("Groups", nil, [("User Groups", true), ("System Groups", false)]),
            ("Lists", nil, [("Highlight", true), ("DNF", true), ("In Progress", true)]),
            ("Queries", nil, [("Geocaching.com Website", true), ("GCA", true)]),
            ("Trackables", nil, [("Inventory", true), ("Mine", true), ("List", false)]),
            ("Locationless", nil, [("All", true), ("Planned", true), ("Map", true)]),
            ("Files", nil, [("Local Files", true), ("KML", false), ("File Browser", false)]),
            ("Statistics", nil, [("Statistics", true)]),
            ("Browser", nil, [("User", true), ("Queries", false), ("Browser", true)]),
            ("Tools", nil, [("GNSS", true), ("ROT13", false)]),
            ("Settings", nil, [("Accounts", true), ("Settings", true), ("Colours", true), ("Log", true)]),
            ("Help", "Settings", [("About", false), ("Help", true), ("Notices", true)])
            ]
            
       
        coverageTestHelper(tests: coverageTests)
 
    }
    
    // Test that the "Initialize Notices alert goes away.
    func testInitializeNoticesGoesAway() {
        let app = XCUIApplication()
        
        // XXX These tests should be re-written using Accessibility IDs so they don't depend on language.
        let menuIconGlobalDefaultButton = app.buttons["menu icon   global   default"]
        menuIconGlobalDefaultButton.tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Statistics"].swipeUp()
        tablesQuery.staticTexts["Help"].tap()
        
        // Go to the notices page.
        app.buttons["Notices"].tap()
        if app.alerts["Initialize notices"].exists {
            XCTFail("Clear notices and run test again.")
            return
        }
        // Switch to another page.
        app.buttons["About"].tap()
        
        // Now, go back to the notices page, and ensure that the notices alert doesn't recur
        app.buttons["Notices"].tap()
        if app.alerts["Initialize notices"].exists {
            XCTFail("Error: notices shouldn't be requested again!")
        }

    }
    // Test the developer stuff that might be removed from the shipping version.
    func testCoverageDeveloper() {
         let developerTests:[CommandTest] = [
            ("Developer", "Trackables", [ ("Images", false), ("DB", true)])
        ]
        
        coverageTestHelper(tests: developerTests)
        
    }
}
