struct Puzzel<SudokuType: SudokuTypeProtocol> {
    
    let string: String
    let solutionString: String
    let board: SudokuBoard<SudokuType>
    let solution: SudokuBoard<SudokuType>
    
    init(_ string: String, solution: String) {
        self.string = string
        self.solutionString = solution
        self.board = SudokuBoard<SudokuType>(string)
        self.solution = SudokuBoard<SudokuType>(solutionString)
    }

}

enum TestData9 {
        
    static let hard1 = Puzzel<Sudoku9>(
        ".9....5....189..24......7.9..4.82...8...6...3...35.2..5.9......74..251....2....7.",
        solution: "497236581651897324283541769934182657825769413176354298519673842748925136362418975")
    static let hard1NiceDescription = """
               +-----+-----+-----+
               |  9  |     |5    |
               |    1|8 9  |  2 4|
               |     |     |7   9|
               +-----+-----+-----+
               |    4|  8 2|     |
               |8    |  6  |    3|
               |     |3 5  |2    |
               +-----+-----+-----+
               |5   9|     |     |
               |7 4  |  2 5|1    |
               |    2|     |  7  |
               +-----+-----+-----+

               """
    
    // https://puzzling.stackexchange.com/questions/252/how-do-i-solve-the-worlds-hardest-sudoku
    // http://sw-amt.ws/sudoku/worlds-hardest-sudoku/xx-world-hardest-sudoku.html
    static let hard2 = Puzzel<Sudoku9>(
        "8..........36......7..9.2...5...7.......457.....1...3...1....68..85...1..9....4..",
        solution: "812753649943682175675491283154237896369845721287169534521974368438526917796318452"
    )
    
    static let hardToBruteForce = Puzzel<Sudoku9>(
        "..............3.85..1.2.......5.7.....4...1...9.......5......73..2.1........4...9",
        solution: "987654321246173985351928746128537694634892157795461832519286473472319568863745219"
    )
    
    static let constraintPropagationSolvable = Puzzel<Sudoku9>(
        "9.4286....581...69..1..382418..9.74.7634..2.....7356.859.861...3.7.2..86.1..7.952",
        solution: "934286571258147369671953824185692743763418295429735618592861437347529186816374952")
    
    static let empty = SudokuBoard9(".................................................................................")
    static let multipleSolutions = SudokuBoard9(".9....5....189..24......7.9..4.82...8...6...3...35.2..5.9......74..251....2......")
    static let invalid = SudokuBoard9("........6.....3.........6.................6........7......9..6.............6....2")
    static let filled = SudokuBoard9("739561842468237951251498673517349286943826715826715394675182439194673528382954167")

    // Borrowed from https://github.com/attractivechaos/plb/blob/master/sudoku/sudoku.txt
    static let perfTestSuite: [Puzzel<Sudoku9>] = [
        Puzzel<Sudoku9>("..............3.85..1.2.......5.7.....4...1...9.......5......73..2.1........4...9",
            solution: "987654321246173985351928746128537694634892157795461832519286473472319568863745219"),
        Puzzel<Sudoku9>(".......12........3..23..4....18....5.6..7.8.......9.....85.....9...4.5..47...6...",
            solution: "839465712146782953752391486391824675564173829287659341628537194913248567475916238"),
        Puzzel<Sudoku9>(".2..5.7..4..1....68....3...2....8..3.4..2.5.....6...1...2.9.....9......57.4...9..",
            solution: "123456789457189236869273154271548693346921578985637412512394867698712345734865921"),
        Puzzel<Sudoku9>("........3..1..56...9..4..7......9.5.7.......8.5.4.2....8..2..9...35..1..6........",
            solution: "562987413471235689398146275236819754714653928859472361187324596923568147645791832"),
        Puzzel<Sudoku9>("12.3....435....1....4........54..2..6...7.........8.9...31..5.......9.7.....6...8",
            solution: "126395784359847162874621953985416237631972845247538691763184529418259376592763418"),
        Puzzel<Sudoku9>("1.......2.9.4...5...6...7...5.9.3.......7.......85..4.7.....6...3...9.8...2.....1",
            solution: "174385962293467158586192734451923876928674315367851249719548623635219487842736591"),
        Puzzel<Sudoku9>(".......39.....1..5..3.5.8....8.9...6.7...2...1..4.......9.8..5..2....6..4..7.....",
            solution: "751846239892371465643259871238197546974562318165438927319684752527913684486725193"),
        Puzzel<Sudoku9>("12.3.....4.....3....3.5......42..5......8...9.6...5.7...15..2......9..6......7..8",
            solution: "125374896479618325683952714714269583532781649968435172891546237257893461346127958"),
        Puzzel<Sudoku9>("..3..6.8....1..2......7...4..9..8.6..3..4...1.7.2.....3....5.....5...6..98.....5.",
            solution: "123456789457189236896372514249518367538647921671293845364925178715834692982761453"),
        Puzzel<Sudoku9>("1.......9..67...2..8....4......75.3...5..2....6.3......9....8..6...4...1..25...6.",
            solution: "123456789456789123789123456214975638375862914968314275591637842637248591842591367"),
        Puzzel<Sudoku9>("..9...4...7.3...2.8...6...71..8....6....1..7.....56...3....5..1.4.....9...2...7..",
            solution: "239187465675394128814562937123879546456213879798456312367945281541728693982631754"),
        Puzzel<Sudoku9>("....9..5..1.....3...23..7....45...7.8.....2.......64...9..1.....8..6......54....7",
            solution: "743892156518647932962351748624589371879134265351276489496715823287963514135428697"),
        Puzzel<Sudoku9>("4...3.......6..8..........1....5..9..8....6...7.2........1.27..5.3....4.9........",
            solution: "468931527751624839392578461134756298289413675675289314846192753513867942927345186"),
        Puzzel<Sudoku9>("7.8...3.....2.1...5.........4.....263...8.......1...9..9.6....4....7.5...........",
            solution: "728946315934251678516738249147593826369482157852167493293615784481379562675824931"),
        Puzzel<Sudoku9>("3.7.4...........918........4.....7.....16.......25..........38..9....5...2.6.....",
            solution: "317849265245736891869512473456398712732164958981257634174925386693481527528673149"),
        Puzzel<Sudoku9>("........8..3...4...9..2..6.....79.......612...6.5.2.7...8...5...1.....2.4.5.....3",
            solution: "621943758783615492594728361142879635357461289869532174238197546916354827475286913"),
        Puzzel<Sudoku9>(".......1.4.........2...........5.4.7..8...3....1.9....3..4..2...5.1........8.6...",
            solution: "693784512487512936125963874932651487568247391741398625319475268856129743274836159"),
        Puzzel<Sudoku9>(".......12....35......6...7.7.....3.....4..8..1...........12.....8.....4..5....6..",
            solution: "673894512912735486845612973798261354526473891134589267469128735287356149351947628"),
        Puzzel<Sudoku9>("1.......2.9.4...5...6...7...5.3.4.......6........58.4...2...6...3...9.8.7.......1",
            solution: "174835962293476158586192734957324816428961375361758249812547693635219487749683521"),
        Puzzel<Sudoku9>(".....1.2.3...4.5.....6....7..2.....1.8..9..3.4.....8..5....2....9..3.4....67.....",
            solution: "869571324327849516145623987952368741681497235473215869514982673798136452236754198")
    ]
    
}

// Borrowed from https://www.sudoku-puzzles-online.com/hexadoku/print-hexadoku.php

enum TestData16 {
    
    static let easy1 = Puzzel<Sudoku16>("B.78.5E.3..AD.C0..4..7...C.FA..2A..........437....5...9F.......8.4..B8...E.793....E37C....FDB..49F.7..5D.3....8.5..D.F3.24A8C.0..8......B....0D5..D......8..F.E...A.9.F..67...BC...C.AB....E724.7A.9.B1...5..63.D.CEF.7.A....8......E.A..D..5....63509C..B..E...", solution: "B97815E4326ADFC00E4137D68C9FAB52ADF6C28B0514379E3C52A09FD7EB1468C46AB8215E0793FD82E37C0A69FDB5149F074E5DC3B12A8651BD6F3924A8CE07E89F2147BAC360D547DB536C1820F9EA23A09DFE467581BC651C8AB09FDE72437A89DB12E05C463FDBCEF475A13608291024E6A3FD895C7BF63509C87B42EDA1")
    
    static let medium1 = Puzzel<Sudoku16>(".....5..6.F.B.4...49.EA.83..D.....E680D..B...F......1....D4A.836...8.17..423..AD....0..EDA.......E52D64..1.9.C0.......2...B..9E.....EDB1.8C.5......E3.......7.29...........73.CF6....F..5..D.B......5..F...2..1E8..0........C2...56A..0.3.14.7...31.9...F.7.0.5.", solution: "D8A1C53967FEB042F249BEA6830CD17537E680D42B51AF9C0BC512F79D4AE83690B8F17CE42365AD1C3F098EDA6524B7AE52D64B7189FC0346D7A325CFB019E87923EDB148CF5A6051FE34C806AB7D29BD846A5012973ECF6A0C7F925E3D4B81C47B586FA0D2931E8F904713B5E6C2DAE56A2C0D391487FB231D9BEAFC780654")
    
    static let hard1 = Puzzel<Sudoku16>("E.........8..6.1..9...3F.C....85.61.5B...9.3..C..3..2...6.....A.D......B..2...13.8.A.641.....79E0...F.8.9.7.A.5..........1C..0..........A...3.6..0.5.4..1E.....C.C.73.0........F9E3.B.A.....7..0...C9.7.8..F...2A2...5.8...7DE..3.E....4..D.1....15...D.C..E.9.8", solution: "E5DF4A9C708B26312A90673FDCE1B48586145BED29A30FC7C37B281064F5EDA9D96E705B4F2AC813B82AC6413D50F79E04C1F38E9B76A25D57F3D92AE1C8604B1B82EDF9A70C3564F0A584671E329BDC6C473102B59D8AEF9E3DBCA5F86471204D0C9E768A1F53B2A2B915C80347DEF63FE802B456D91C7A7156AFD3C2BE4908")

    
    static let empty = SudokuBoard16(String(repeating: ".", count: 256))
    static let multipleSolutions = SudokuBoard16("..........8..6.1..9...3F......85.61.5B...9.3..C..3..2...6.....A.D......B..2...13.8.A.641.....79E0...F.8.9.7.A.5..........1C..0..........A...3.6..0.5.4..1E.....C.C.73.0........F9E3.B.A.....7..0...C..7.8..F...2A2...5.8...7DE..3.E....4..D.1....15...D.C..E.9..")
    static let invalid = SudokuBoard16("BB78.5E.3..AD.C0..4..7...C.FA..2A..........437....5...9F.......8.4..B8...E.793....E37C....FDB..49F.7..5D.3....8.5..D.F3.24A8C.0..8......B....0D5..D......8..F.E...A.9.F..67...BC...C.AB....E724.7A.9.B1...5..63.D.CEF.7.A....8......E.A..D..5....63509C..B..E...")
    
}

enum TestData25 {
    
    static var puzzel1 = Puzzel<Sudoku25>("Q..M.PW.U..I.Y...BVN.A..XG.F.P..Q..R....T...H.CD..W...CHT....K..D.I...M....KE.JX..MA..LO.U.W.Q..G.I.....O.D..V...BAL.U...Q...L..SQAEV.W..Y....N....XJ.UXW.DS..I.LF..KRQ.JAPHYG...Y....UG.OX..H.V...F....PI......OKT..C.U.GB....R...N.FTX....U.I..YM..Q.S.......U.WP....N.Y...E.SA..TBPWLQ..V.G.M...U..D....O.V..G.C.....HQ..O........S.A......D.OEK..C..J.Y.W..O.R..A.Y.D...C.BS..JI......NW...Q.MD..Y...OXIFGT.H...RYM...J.KL...D..XW....J..MI.F.XU..O.W...RK..SY..O.Y.PBD.E..A.J....C..HN.FIG.OV..CPBQ..E......MDA.MH..J..C.......TX.Y.RQ.S..KDA.NHW.....TVP..I...E.IN...XO..B.R.H.C.EU..KJ....BO....F.S.AUEH.JWQ...XM...FV..TK...C...R.DS..PA.", solution: "QDRMHPWOUFCISYGKJBVNEATLXGUFBPLKQNIRJVXMTEASHOCDYWWASLCHTGJEQKPFDXIRYOMVNUBKEVJXBYMARNLOTUDWCQFSGHIPNYTIOCDXSVHEWBALMUGPRQFKJLTGSQAEVHWBPYMRIDNFCUOXJKUXWVDSBCIMLFNEKRQOJAPHYGTMRYABDQUGPOXJWHSVKETFLINCPIEHJNFYOKTSDCQUXGBLAMWRVOKNCFTXRLJAUGIVPYMHWQESBDDQCKIUJWPOVTXNLYGHREBSAMFTBPWLQSKVHGYMRJFUIADNXECOYVJXGFCEBNIAHQSMOWLKDTUPRSHAUNMRIXDFOEKBQCTPJVYLWGFOMREGALYTDWUPCNBSXVJIKQHBCLNWKHJQUMDRVYASPOXIFGTEHPUERYMSTAJCKLFGNDIBXWVOQAJDQMIGFEXUHTONWLVCRKPBSYVSOTYWPBDLEGIAXJFQKMCURHNXFIGKOVNRCPBQSWEHYTULJMDAEMHPUJLACGKVBDIOTXNYWRQFSCGKDARNHWSXQLJTVPFMIYBOEUINQYSXODMBWRFHPCAEUGTKJVLRLBOTVIPFYSNAUEHKJWQGDCXMJWXFVEUTKQYMCGOBRLDSHNPAI")
    
}
