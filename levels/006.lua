local matchesNeeded = 100
local firstBurn = true

return {
  number = 6,
  name = "Gem Destroyers",
  message = "Gem Destroyers will clear every gem of the color where they lay on (if the gems are not selected). You'll need to clear the selected gems to proceed.",

  timer = false,
  countDownSpeed = 15, -- only used if timer is true. Controls the speed of the timer.

  newColumn = function(column)
    if firstBurn then firstBurn = false; column[3] = gems.burn() end
    probability(column, {
      1/10, "normal", function(n) column[n] = gems.wild() end,
      1/10, "normal", function(n) column[3] = gems.burn() end,
    })
    return column
  end,

  boardMap = function()
    return [[
      | 4 5 6 1 2 3 4 5 6 |
      | 1 2 3 4 5 6 1 2 3 |
      | 4 5 6 1 2 3 4 5 6 |
      | A 2 3 4 A 5 6 1 A |
    ]], {
      A = {"normal", {color=1, selected=true}},
    }
  end,

  music= "lum",
  background= "interference",

  vert = 3,
  horz = 3,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return game.board.selectedCount() == 0
  end
}
