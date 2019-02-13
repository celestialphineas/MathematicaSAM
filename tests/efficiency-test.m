Print[AbsoluteTiming[MatchQ[#, _List]&/@StringSplit[#, "\t"]&/@ReadList[OpenRead["./0.sam", Method -> {"File", CharacterEncoding -> "UTF8"}], String]][[1]]]
