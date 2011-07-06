return {
  number = 7,
  name = "Some Persistent Gems...",
  message = "You might need to match the same gem more than once sometimes. Destroy the selected gems to proceed.",

  timer = false,
  countDownSpeed = 15, -- only used if timer is true. Controls the speed of the timer.

  newColumn = function(column)
    probability(column, {
      1/10, "normal", function(n) column[n] = gems.wild() end,
      1/10, "normal", function(n) column[3] = gems.burn() end,
    })
    return column
  end,

  boardMap = function()
    return [[
      | F A F B F C F D F |
      | F F F F F F F F F |
    ]], {
      A = {"normal", {color=1, selected=true, stays=2}},
      B = {"normal", {color=2, selected=true, stays=3}},
      C = {"normal", {color=3, selected=true, stays=4}},
      D = {"normal", {color=4, selected=true, stays=5}},
    }
  end,

  music= "classic1",
  background= "interference",

  vert = 3,
  horz = 3,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return game.board.selectedCount() == 0
  end
}
