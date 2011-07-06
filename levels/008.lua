local matchesNeeded = 200
local bombs = {"lr", "ud", "14", "23"}

return {
  number = 8,
  name = "Arrow Match Galore",
  message = "Quick! match " .. matchesNeeded .. " to proceed. You'll have a couple arrow matches to help you do it.",

  timer = true,
  countDownSpeed = 12, -- only used if timer is true. Controls the speed of the timer.

  newColumn = function(column)
    probability(column, { 1/10, "normal", function(n) column[n] = gems.wild() end })
    probability(column, {
      1/6, "any",    function(n) column[n].bomb = bombs[math.random(#bombs)] end,
      1/10, "normal", function(n) column[3] = gems.burn() end,
    })

    return column
  end,

  boardMap = function()
    return [[
      | . . . . . . . . . |
      | . . . . . . . . . |
      | F . . . . . . . . |
      | . F . . . . . . . |
      | . . F . . . . . . |
      | . . . F . . . . . |
      | . . . . F . . . . |
      | . . . . . F . . . |
      | . . . . . . F . . |
      | . . . . . . . F . |
      | . . . . . . . . F |
    ]], {
    }
  end,

  music= "classic2",
  background= "interference",

  vert = 3,
  horz = 3,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return game.scores.levelMatches >= matchesNeeded
  end
}
