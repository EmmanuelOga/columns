return {
  number = 13,
  name = "Path",
  message = "Remove the selected gem to proceed.",
  timer = false,
  countDownSpeed = 10, -- only used if timer is true. Controls the speed of the timer.

  boardMap = function()
    return [[
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . F . . . . . . . |
      | . . F . . . . . . |
      | . . . F . . . . . |
      | . . . . F . . . . |
      | F . . . . F . . . |
      | . F . . . . F . . |
      | . . F . . . . F . |
      | . . . F . . . . F |
      | . . . . F . . . . |
      | . . . . . F . . . |
      | . . . . . F . . . |
      | . . . . . F . . A |
    ]], {
      A = {"normal", {color=1, selected=true}},
    }
  end,

  newColumn = function(column)
    probability(column, {
      1/10, "normal", function(n) column[n] = gems.wild() end,
      1/10, "normal", function(n) column[3] = gems.burn() end,
    })

    return column
  end,

  music= "economic",
  background= "drops",

  vert = 3,
  horz = 3,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return game.board.selectedCount() == 0
  end
}
