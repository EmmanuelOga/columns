local matchesNeeded = 100

return {
  number = 5,
  name = "Arrow Match!",
  message = "Match arrow blocks to destroy the whole line in the direction the arrow goes. Destroy the selected gems to clear the level.",

  timer = false,
  countDownSpeed = 15, -- only used if timer is true. Controls the speed of the timer.

  newColumn = function(column)
    probability(column, {
      1/10, "normal", function(n) column[n] = gems.wild() end,
    })
    return column
  end,

  boardMap = function()
    return [[
      | F F F . . . F F F |
      | F C F . . . F D F |
      | F F F . . . F F F |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . F F F . F F F |
      | . . F G F . F E F |
      | . . F F F . F F F |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | . . . . . . . . . |
      | F F F . . . F 5 F |
      | F B F . . . F A F |
      | F F F . . . F F F |
    ]], {
      A = {"normal", {color=1, selected=true, bomb="l"}},
      B = {"normal", {color=2, selected=true, bomb="u"}},
      C = {"normal", {color=3, selected=true, bomb="r"}},
      D = {"normal", {color=4, selected=true, bomb="d"}},
      E = {"normal", {color=5, selected=true, bomb="l"}},
      G = {"normal", {color=6, selected=true}},
    }
  end,

  music= "economic",
  background= "interference",

  vert = 3,
  horz = 3,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return game.board.selectedCount() == 0
  end
}
