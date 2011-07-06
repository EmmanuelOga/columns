local matchesNeeded = 100

return {
  number = 12,
  name = "One little obstacle",
  message = "Unblock the path and remove all the gems bellow the obstacles to win. Also, complete " ..
    matchesNeeded .. " to clear the level.",

  timer = false,
  countDownSpeed = 10, -- only used if timer is true. Controls the speed of the timer.

  boardMap = function()
    return [[
      | . . . . A . . . . |
      | . F F F . F F F . |
      | . F G F . F G F . |
      | . F E F . F E F . |
      | . F D F . F D F . |
      | F F B C . C B F F |
      | G G C B . B C G G |
      | E E B B . B B E E |
      | D D C C . C C D D |
      | C C D D . D D C C |
    ]], {
      A = {"normal", {color=1, fixed=true, selected=false}},
      B = {"normal", {color=2, selected=true}},
      C = {"normal", {color=3, selected=true}},
      D = {"normal", {color=4, selected=true}},
      E = {"normal", {color=5, selected=true}},
      G = {"normal", {color=6, selected=true}},
    }
  end,

  newColumn = function(column)
    probability(column, {
      1/100, "any", function(n)
        column[1] = gems.normal{color=2}
        column[2] = gems.normal{color=3}
        column[3] = gems.normal{color=4}
      end,
    })

    return column
  end,

  music= "satell",
  background= "drops",

  vert = 3,
  horz = 3,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return game.scores.levelMatches >= matchesNeeded and game.board.selectedCount() == 0
  end
}

