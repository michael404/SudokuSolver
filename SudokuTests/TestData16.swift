// Borrowed from https://www.sudoku-puzzles-online.com/hexadoku/print-hexadoku.php

enum TestData16 {
    
    enum Empty {
    
        static let board = SudokuBoard16(String(repeating: ".", count: 256))
        
    }
    
    enum Easy1 {
        
        static let string = "B.78.5E.3..AD.C0..4..7...C.FA..2A..........437....5...9F.......8.4..B8...E.793....E37C....FDB..49F.7..5D.3....8.5..D.F3.24A8C.0..8......B....0D5..D......8..F.E...A.9.F..67...BC...C.AB....E724.7A.9.B1...5..63.D.CEF.7.A....8......E.A..D..5....63509C..B..E..."
    
        static let board = SudokuBoard16(string)
        
        static let solutionString = "B97815E4326ADFC00E4137D68C9FAB52ADF6C28B0514379E3C52A09FD7EB1468C46AB8215E0793FD82E37C0A69FDB5149F074E5DC3B12A8651BD6F3924A8CE07E89F2147BAC360D547DB536C1820F9EA23A09DFE467581BC651C8AB09FDE72437A89DB12E05C463FDBCEF475A13608291024E6A3FD895C7BF63509C87B42EDA1"
        
        static let solution = SudokuBoard16(solutionString)
    
    }
    
    enum Medium1 {
        
        static let string = ".....5..6.F.B.4...49.EA.83..D.....E680D..B...F......1....D4A.836...8.17..423..AD....0..EDA.......E52D64..1.9.C0.......2...B..9E.....EDB1.8C.5......E3.......7.29...........73.CF6....F..5..D.B......5..F...2..1E8..0........C2...56A..0.3.14.7...31.9...F.7.0.5."
    
        static let board = SudokuBoard16(string)
        
        static let solutionString = "D8A1C53967FEB042F249BEA6830CD17537E680D42B51AF9C0BC512F79D4AE83690B8F17CE42365AD1C3F098EDA6524B7AE52D64B7189FC0346D7A325CFB019E87923EDB148CF5A6051FE34C806AB7D29BD846A5012973ECF6A0C7F925E3D4B81C47B586FA0D2931E8F904713B5E6C2DAE56A2C0D391487FB231D9BEAFC780654"
        
        static let solution = SudokuBoard16(solutionString)
        
    }
    
    enum Hard1 {
        
        static let string = "E.........8..6.1..9...3F.C....85.61.5B...9.3..C..3..2...6.....A.D......B..2...13.8.A.641.....79E0...F.8.9.7.A.5..........1C..0..........A...3.6..0.5.4..1E.....C.C.73.0........F9E3.B.A.....7..0...C9.7.8..F...2A2...5.8...7DE..3.E....4..D.1....15...D.C..E.9.8"
    
        static let board = SudokuBoard16(string)
        
        static let solutionString = "E5DF4A9C708B26312A90673FDCE1B48586145BED29A30FC7C37B281064F5EDA9D96E705B4F2AC813B82AC6413D50F79E04C1F38E9B76A25D57F3D92AE1C8604B1B82EDF9A70C3564F0A584671E329BDC6C473102B59D8AEF9E3DBCA5F86471204D0C9E768A1F53B2A2B915C80347DEF63FE802B456D91C7A7156AFD3C2BE4908"
        
        static let solution = SudokuBoard16(solutionString)
    
    }
    
    enum MultipleSolutions {
        
        static let string = "..........8..6.1..9...3F......85.61.5B...9.3..C..3..2...6.....A.D......B..2...13.8.A.641.....79E0...F.8.9.7.A.5..........1C..0..........A...3.6..0.5.4..1E.....C.C.73.0........F9E3.B.A.....7..0...C..7.8..F...2A2...5.8...7DE..3.E....4..D.1....15...D.C..E.9.."
    
        static let board = SudokuBoard16(string)
    
    }
    
    enum Invalid {
        
        static let string = "BB78.5E.3..AD.C0..4..7...C.FA..2A..........437....5...9F.......8.4..B8...E.793....E37C....FDB..49F.7..5D.3....8.5..D.F3.24A8C.0..8......B....0D5..D......8..F.E...A.9.F..67...BC...C.AB....E724.7A.9.B1...5..63.D.CEF.7.A....8......E.A..D..5....63509C..B..E..."
        
        static let board = SudokuBoard16(string)
        
    }
    
}
