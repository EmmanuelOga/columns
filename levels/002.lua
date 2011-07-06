local matchesNeeded = 100

local firstTime = true

return {
  number = 2,
  name = "Let there be wildcards",
  message = "Use the wildcard to match any color in any direction. Complete " .. matchesNeeded .. " to proceed.",

  timer = false,
  countDownSpeed = 10, -- only used if timer is true. Controls the speed of the timer.

  newColumn = function(column)
    if firstTime then column[2] = gems.wild(); firstTime = false end
    probability(column, {1/15, "normal", function(n) column[n] = gems.wild() end})
    return column
  end,

  music= "4u",
  background= "checkers",

  vert = 3,
  horz = 3,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return game.scores.levelMatches >= matchesNeeded
  end
}
