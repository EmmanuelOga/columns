local matchesNeeded = 50
local bombs = {"lr", "ud", "14", "23"}

return {
  number = 11,
  name = "Long matches needed",
  message = "This time only matches of length 4 or more will be accepted. Good luck! Match " .. matchesNeeded .. " to proceed.",

  timer = true,
  countDownSpeed = 12, -- only used if timer is true. Controls the speed of the timer.

  newColumn = function(column)
    probability(column, { 1/10, "normal", function(n) column[n] = gems.wild() end })
    probability(column, {
      1/10, "any",    function(n) column[n].bomb = bombs[math.random(#bombs)] end,
      1/10, "normal", function(n) column[3] = gems.burn() end,
      1/10, "normal", function(n) column[3] = gems.obstacle() end,
    })

    return column
  end,

  boardMap = function()
    return [[
      | . . . . . . . . F |
      | . . . . . . . . F |
      | . . . . . . . . F |
      | . . . . . . . . F |
      | . . . . . . . . F |
      | F . . . . . . . . |
      | F . . . . . . . . |
      | F . . . . . . . . |
      | F . . . . . . . F |
      | . . . . . . . . F |
      | . . . . . . . . F |
      | . . . . . . . . F |
      | F . . . . . . . F |
      | F . . . . . . . . |
      | F . . . . . . . . |
      | F . . . . . . . . |
    ]], {
    }
  end,

  music= "music",
  background= "interference",

  vert = 4,
  horz = 4,
  upDiag = 4,
  downDiag = 4,

  checkObjectives = function(game)
    return game.scores.levelMatches >= matchesNeeded
  end
}
