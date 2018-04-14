//
//  SudokuSolverTestsBacktrack.swift
//  SudokuTests
//
//  Created by Michael Holmgren on 2018-04-04.
//  Copyright © 2018 Michael Holmgren. All rights reserved.
//

import XCTest

class SudokuSolverTestsBacktrack: XCTestCase {

    func testFailingBoard() {
        XCTAssertFalse(TestData.Invalid.board.isValid)
        XCTAssertThrowsError(try TestData.Invalid.board.findFirstSolutionBacktrack())
        XCTAssertThrowsError(try TestData.Invalid.board.findFirstSolutionBacktrack())
    }
    
    func testFindAllSolutions() {
        do {
            let solutions = try! TestData.Hard1.board.findAllSolutionsBacktrack()
            XCTAssertEqual(solutions.count, 1)
            XCTAssertEqual(solutions[0].description, TestData.Hard1.solutionString)
        }
        
        do {
            // Too many solutions both with default and non-default maxSolutions
            XCTAssertThrowsError(try TestData.Empty.board.findAllSolutionsBacktrack())
            XCTAssertThrowsError(try TestData.Empty.board.findAllSolutionsBacktrack(maxSolutions: 50))
        }
        
        do {
            let solutions = try! TestData.MultipleSolutions.board.findAllSolutionsBacktrack()
            XCTAssertEqual(solutions.count, 9)
            for solution in solutions {
                XCTAssertTrue(solution.isValid)
                XCTAssertTrue(solution.isFullyFilled)
            }
        }
    }
    
    func testManySolutions() {
        
        //Should throw
        XCTAssertThrowsError(try TestData.MultipleSolutions.board.findAllSolutionsBacktrack(maxSolutions: 3))
        
        // Should only find 1 solution
        do {
            let solution = try! TestData.Hard1.board.findAllSolutionsBacktrack(maxSolutions: 1)
            XCTAssertEqual(solution.count, 1)
            XCTAssertTrue(solution[0].isValid)
            XCTAssertTrue(solution[0].isFullyFilled)
            XCTAssertEqual(solution[0].description, TestData.Hard1.solutionString)
        }
        
    }
    
    func testNumberOfSolutions() {
        XCTAssertEqual(TestData.Hard1.board.numberOfSolutionsBacktrack(), .one)
        XCTAssertEqual(TestData.Hard2.board.numberOfSolutionsBacktrack(), .one)
        XCTAssertEqual(TestData.MultipleSolutions.board.numberOfSolutionsBacktrack(), .multiple)
        XCTAssertEqual(TestData.Invalid.board.numberOfSolutionsBacktrack(), .none)
    }
    
    func testRandomFullyFilledBoard() {
        let board = SudokuBoard.randomFullyFilledBoardBacktrack()
        XCTAssertTrue(board.isValid)
        XCTAssertTrue(board.isFullyFilled)
        XCTAssertEqual(board.clues, 81)
        
        
        // Two random filled boards should (usually) not be equal
        XCTAssertNotEqual(board, SudokuBoard.randomFullyFilledBoardBacktrack())
    }
    
    func testRandomStartingBoard() {
        do {
            let board = SudokuBoard.randomStartingBoardBacktrack()
            XCTAssertTrue(board.isValid)
            XCTAssertFalse(board.isFullyFilled)
        }
        
        do {
            let board = SudokuBoard.randomStartingBoardBacktrack()
            XCTAssertTrue(board.isValid)
            XCTAssertFalse(board.isFullyFilled)
            XCTAssert(board.clues <= 40) // Maximum that should be possible
            XCTAssert(board.clues >= 17) // inimum that should be possible
        }
        
        // Two random starting boards should (usually) not be equal
        XCTAssertNotEqual(SudokuBoard.randomStartingBoardBacktrack(), SudokuBoard.randomStartingBoardBacktrack())
    }

}
