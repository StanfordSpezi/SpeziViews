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
        
        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS

        XCTAssert(app.buttons["Markdown View (Advanced)"].waitForExistence(timeout: 2))
        app.buttons["Markdown View (Advanced)"].tap()
        
        XCTAssert(app.navigationBars.staticTexts["Welcome to the Spezi Ecosystem"].waitForExistence(timeout: 2))
        XCTAssert(app.navigationBars.staticTexts["Jun 22, 2025 at 05:41 AM"].waitForExistence(timeout: 2))
        
        func assertTextExists(_ text: String, line: UInt = #line) {
            XCTAssert(app.staticTexts[text].waitForExistence(timeout: 1), line: line)
        }
        
        assertTextExists("Welcome to the Spezi Ecosystem")
        assertTextExists("This article aims to provide you with a broad overview of Spezi.")
        XCTAssert(app.otherElements["ayooooooo"].waitForExistence(timeout: 2))
        assertTextExists("Our Modules")
        assertTextExists("Spezi is architected to be a highly modular system, allowing your application to ...")
        
        do {
            var frames: [CGRect] = []
            let image = app.otherElements["ayooooooo"].images.firstMatch
            XCTAssert(image.exists)
            for _ in 0..<150 {
                frames.append(image.frame)
                try await Task.sleep(for: .seconds(0.1))
            }
            
            func postprocess(_ frames: [CGRect]) -> [CGRect] {
                var processed = frames
                for (idx, (frame1, frame2)) in frames.adjacentPairs().enumerated().reversed() {
                    if frame1 == frame2 { // swiftlint:disable:this for_where
                        processed.remove(at: idx)
                    }
                }
                return processed == frames ? processed : postprocess(processed)
            }
            
            frames = postprocess(frames)
        
            enum Direction {
                case left, right
                
                init(_ point1: CGPoint, _ point2: CGPoint) {
                    XCTAssert(point1.x < point2.x || point1.x > point2.x, "\(point1.x) vs \(point2.x)")
                    self = point1.x < point2.x ? .right : .left
                }
            }
            
            let runs = try frames
                .reduce(into: [[CGRect]]()) { runs, frame in
                    if var run = runs.last {
                        precondition(!run.isEmpty)
                        if run.count >= 2 {
                            let segDirection = Direction(run[run.endIndex - 2].center, try XCTUnwrap(run.last).center)
                            let newDirection = Direction(try XCTUnwrap(run.last).center, frame.center)
                            if newDirection == segDirection {
                                run.append(frame)
                                runs[runs.endIndex - 1] = run
                            } else {
                                runs.append([frame])
                            }
                        } else {
                            run.append(frame)
                            runs[runs.endIndex - 1] = run
                        }
                    } else {
                        runs = [[frame]]
                    }
                }
                .map { run -> (direction: Direction, run: [CGRect]) in
                    (Direction(run[0].center, run[1].center), run)
                }
            
            XCTAssert(
                runs.adjacentPairs().allSatisfy { $0.direction != $1.direction },
                "Found 2 adjacent runs w/ same direction"
            )
            
            for (dir, run) in runs.dropFirst().dropLast() { // skip first and last run, since they're probably gonna be partial
                XCTAssertGreaterThanOrEqual(
                    run.count,
                    10,
                    "Direction changed unexpectedly early. runs: \(runs)"
                )
                let roughMinExpected: CGFloat = 58
                let roughMaxExpected: CGFloat = 387
                switch dir {
                case .right:
                    XCTAssertEqual(try XCTUnwrap(run.first).center.x, roughMinExpected, accuracy: 10)
                    XCTAssertEqual(try XCTUnwrap(run.last).center.x, roughMaxExpected, accuracy: 10)
                case .left:
                    XCTAssertEqual(try XCTUnwrap(run.first).center.x, roughMaxExpected, accuracy: 10)
                    XCTAssertEqual(try XCTUnwrap(run.last).center.x, roughMinExpected, accuracy: 10)
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
