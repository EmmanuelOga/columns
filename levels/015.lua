return {
  number = 15,
  name = "Tower",
  message = "Remove the selected gems to proceed.",
  timer = true,
  countDownSpeed = 5, -- only used if timer is true. Controls the speed of the timer.

  boardMap = function()
    return [[
      | . . . . . . . . . |
      | . F . F . F . F . |
      | . F F F F F F F . |
      | . F F F F F F F . |
      | . . F F F F F . . |
      | . . . A F F . . . |
      | . . . F . F . . . |
      | . . . F F B . . . |
      | . . . F F F . . . |
      | . . . F F F . . . |
      | . . . F F D . . . |
      | . . . F . F . . . |
      | . . . C F F . . . |
      | . . . F F F . . . |
    ]], {
      A = {"normal", {color=1, selected=true}},
      B = {"normal", {color=2, selected=true}},
      C = {"normal", {color=3, selected=true}},
      D = {"normal", {color=4, selected=true}},
      E = {"normal", {color=5, selected=true}},
      G = {"normal", {color=6, selected=true}},
    }
  end,

  newColumn = function(column)
    probability(column, {
      1/10, "normal", function(n) column[n] = gems.wild() end,
      1/10, "normal", function(n) column[3] = gems.burn() end,
    })

    return column
  end,

  music= "lum",
  background= "drops",

  vert = 3,
  horz = 3,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return game.board.selectedCount() == 0
  end
}
