local matchesNeeded = 50
local bombs = {"lr", "ud", "14", "23"}

return {
  number = 10,
  name = "Non diagonals Disabled",
  message = "Ok, for a change, now diagonals are the only matches enabled. Make sure you destroy " .. matchesNeeded .. " to proceed.",

  timer = true,
  countDownSpeed = 12, -- only used if timer is true. Controls the speed of the timer.

  newColumn = function(column)
    probability(column, { 1/10, "normal", function(n) column[n] = gems.wild() end })
    probability(column, {
      1/10, "any",    function(n) column[n].bomb = bombs[math.random(#bombs)] end,
      1/10, "normal", function(n) column[3] = gems.burn() end,
    })

    return column
  end,

  boardMap = function()
    return [[
      | F . . . . . . . F |
      | . F . . . . . F . |
      | . . F . . . F . . |
      | . . . F . F . . . |
      | . . . . F . . . . |
    ]], {
    }
  end,

  music= "classic2",
  background= "interference",

  vert = false,
  horz = false,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return game.scores.levelMatches >= matchesNeeded
  end
}
