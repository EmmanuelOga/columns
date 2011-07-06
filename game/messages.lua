local K = require('game.constants')

local function messages()
  local self = { info = {} }

  function self.add(message)
    self.info[#self.info + 1] = message

    -- keep at most the max number of messages
    if #self.info > K.NUM_MESSAGES then table.remove(self.info, 1) end

    return self.info
  end

  return self
end

return messages
