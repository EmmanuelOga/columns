local bombs = "udlr1234"

return {
  number = "endless",
  name = "Endless Mode",
  message = "Match as many gems as you can!",

  timer = true,
  countDownSpeed = 5,

  newColumn = function(column)
    probability(column, {
      1/10, "normal", function(n) column[n] = gems.wild() end,
      1/10, "any",    function(n) column[3] = gems.burn() end,
      1/10, "normal", function(n)
        local b = math.random(#bombs)
        column[n].bomb = string.sub(bombs, b, b)
      end,
      1/10, "normal", function(n) column[n].stays = math.random(5) end,
    })

    return column
  end,

  music= "trance",
  background= "drops",

  vert = 3,
  horz = 3,
  upDiag = 3,
  downDiag = 3,

  checkObjectives = function(game)
    return false -- never!
  end
}
