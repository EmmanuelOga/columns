local matchesNeeded = 50

return {
  number = 1,
  name = "Beginning!",
  message = "Welcome!\nMatch at least 3 colors in any direction to destroy the gems. Complete "..
    matchesNeeded.." gems to clear this level.",

  timer = false,
  countDownSpeed = 10, -- only used if timer is true. Controls the speed of the timer.

  newColumn = function(column)
    return column
  end,

  music= "trance",
  background= "drops",

  vert = 3,
  horz = 3,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return game.scores.levelMatches >= matchesNeeded
  end
}
