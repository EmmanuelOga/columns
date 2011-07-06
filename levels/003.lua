local matchesNeeded = 100

local firstTime = true

return {
  number = 3,
  name = "Let there be obstacles",
  message = "Obstacles cannot be matched, they are there just to annoy you! Complete " ..
    matchesNeeded .. " to proceed.",

  timer = false,
  countDownSpeed = 10, -- only used if timer is true. Controls the speed of the timer.

  newColumn = function(column)
    if firstTime then column[2] = gems.obstacle(); firstTime = false end
    probability(column, {
      1/15, "normal", function(n) column[n] = gems.wild() end,
      1/50, "normal", function(n) column[n] = gems.obstacle() end
    })
    return column
  end,

  boardMap = function()
    return [[
      | F . . . . . . . . |
      | F . . . . . . . . |
      | F . . . . . . . . |
      | F . . . . . . . . |
      | F F F . . . . . . |
      | . . . . . . . . . |
      | F F F . . . . . . |
      | F . F . . . . . . |
      | F . F . . . . . . |
      | F F F . . . . . . |
      | . . . . . . . . . |
      | F . F . . . . . . |
      | F . F . . . . . . |
      | F . F . . . . . . |
      | . F . . . . . . . |
      | . . . . . . . . . |
      | F F F . . . . . . |
      | F . . . . . . . . |
      | F F . . . . . . . |
      | F . . . . . . . . |
      | F F F . . . . . . |
    ]], {
      A = {"normal", {color=4, fixed=true}}
    }
  end,

  music= "music",
  background= "interference",

  vert = 3,
  horz = 3,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return game.scores.levelMatches >= matchesNeeded
  end
}
