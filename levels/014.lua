return {
  number = 14,
  name = "Platform",
  message = "Remove the selected gems to proceed.",
  timer = false,
  countDownSpeed = 10, -- only used if timer is true. Controls the speed of the timer.

  boardMap = function()
    return [[
      | . F F F F F F F . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | F . . . . . . . F |
      | A F . . F . . F C |
      | F F F F B F F F F |
    ]], {
      A = {"normal", {color=2, stays = 2, selected=true}},
      B = {"normal", {color=3, stays = 2, selected=true}},
      C = {"normal", {color=4, stays = 2, selected=true}},
    }
  end,

  newColumn = function(column)
    probability(column, {
      1/10, "normal", function(n) column[n] = gems.wild() end,
      1/10, "normal", function(n) column[3] = gems.burn() end,
    })

    return column
  end,

  music= "trance",
  background= "drops",

  vert = 3,
  horz = 3,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return game.board.selectedCount() == 0
  end
}
