//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Algorithms
import XCTest
import XCTestExtensions


extension ViewsTests {
    @MainActor
    func testSimpleMarkdownView() throws {
        let app = XCUIApplication()
        app.launch()

        app.open(target: "SpeziViews")

        XCTAssert(app.buttons["Markdown View (Simple)"].waitForExistence(timeout: 2))
        app.buttons["Markdown View (Simple)"].tap()
        
        XCTAssert(app.staticTexts["This is a markdown example."].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["This is a markdown example taking 2 seconds to load."].waitForExistence(timeout: 5))
    }
    
    
    @MainActor
    func testAdvancedMarkdownView() async throws { // swiftlint:disable:this function_body_length
        let app = XCUIApplication()
        app.launch()
        app.open(target: "SpeziViews")

        XCTAssert(app.buttons["Markdown View (Advanced)"].waitForExistence(timeout: 2))
        app.buttons["Markdown View (Advanced)"].tap()
        
        XCTAssert(app.navigationBars.staticTexts["Welcome to the Spezi Ecosystem"].waitForExistence(timeout: 2))
        XCTAssert(app.navigationBars.staticTexts["Jun 22, 2025 at 5:41 AM"].waitForExistence(timeout: 2))
        
        func assertTextExists(_ text: String, line: UInt = #line) {
            XCTAssert(app.staticTexts[text].waitForExistence(timeout: 1), line: line)
        }
        
        assertTextExists("Welcome to the Spezi Ecosystem")
        assertTextExists("This article aims to provide you with a broad overview of Spezi.")
        XCTAssert(app.otherElements["ayooooooo"].waitForExistence(timeout: 2))
        assertTextExists("Our Modules")
        assertTextExists("Spezi is architected to be a highly modular system, allowing your application to ...")
        
        do {
            var xCoords: [CGFloat] = []
            let image = app.otherElements["ayooooooo"].images.firstMatch
            XCTAssert(image.exists)
            for _ in 0..<300 {
                xCoords.append(image.frame.center.x)
                try await Task.sleep(for: .seconds(0.2))
            }
            
            func postprocess(_ xCoords: [CGFloat]) -> [CGFloat] {
                var processed = xCoords
                for (idx, (xPos1, xPos2)) in xCoords.adjacentPairs().enumerated().reversed() {
                    if xPos1 == xPos2 { // swiftlint:disable:this for_where
                        processed.remove(at: idx)
                    }
                }
                return processed == xCoords ? processed : postprocess(processed)
            }
            
            xCoords = postprocess(xCoords)
        
            enum Direction {
                case left, right
                
                init(_ x1: CGFloat, _ x2: CGFloat) { // swiftlint:disable:this identifier_name
                    XCTAssert(x1 < x2 || x1 > x2, "\(x1) vs \(x2)")
                    self = x1 < x2 ? .right : .left
                }
            }
            
            let runs = try xCoords
                .reduce(into: [[CGFloat]]()) { runs, xPos in
                    if var run = runs.last {
                        precondition(!run.isEmpty)
                        if run.count >= 2 {
                            let segDirection = Direction(run[run.endIndex - 2], try XCTUnwrap(run.last))
                            let newDirection = Direction(try XCTUnwrap(run.last), xPos)
                            if newDirection == segDirection {
                                run.append(xPos)
                                runs[runs.endIndex - 1] = run
                            } else {
                                runs.append([xPos])
                            }
                        } else {
                            run.append(xPos)
                            runs[runs.endIndex - 1] = run
                        }
                    } else {
                        runs = [[xPos]]
                    }
                }
                .map { run -> (direction: Direction, run: [CGFloat]) in
                    (Direction(run[0], run[1]), run)
                }
            
            XCTAssert(
                runs.adjacentPairs().allSatisfy { $0.direction != $1.direction },
                "Found 2 adjacent runs w/ same direction"
            )
            
            for (dir, run) in runs.dropFirst().dropLast() { // skip first and last run, since they're probably gonna be partial
                XCTAssertGreaterThanOrEqual(
                    run.count,
                    7,
                    "Direction changed unexpectedly early. runs: \(runs)"
                )
                let roughMinExpected: CGFloat = 58
                let roughMaxExpected: CGFloat = 387
                switch dir {
                case .right:
                    XCTAssertEqual(try XCTUnwrap(run.first), roughMinExpected, accuracy: 20)
                    XCTAssertEqual(try XCTUnwrap(run.last), roughMaxExpected, accuracy: 20)
                case .left:
                    XCTAssertEqual(try XCTUnwrap(run.first), roughMaxExpected, accuracy: 20)
                    XCTAssertEqual(try XCTUnwrap(run.last), roughMinExpected, accuracy: 20)
                }
            }
        }
    }
}


extension CGRect {
    var center: CGPoint {
        CGPoint(
            x: minX + 0.5 * width,
            y: minY + 0.5 * height
        )
    }
}

extension CGPoint {
    var shortDebugDescription: String {
        let formatStyle = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(2))
        return "(x: \(x.formatted(formatStyle)); y: \(y.formatted(formatStyle))"
    }
}
