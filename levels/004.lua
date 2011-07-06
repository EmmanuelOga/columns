local matchesNeeded = 200

local firstTime = true

return {
  number = 4,
  name = "Time constraints",
  message = "On some levels you'll be running against the clock. Don't let the timer reach 0! Complete " ..
    matchesNeeded .. " matches to proceed.",

  timer = true,
  countDownSpeed = 15, -- only used if timer is true. Controls the speed of the timer.

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
      | F . . . . . . . F |
      | F F . . . . . F F |
      | F F F . . . F F F |
    ]], {
      A = {"normal", {color=4, fixed=true}}
    }
  end,

  music= "satell",
  background= "interference",

  vert = 3,
  horz = 3,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return game.scores.levelMatches >= matchesNeeded
  end
}
