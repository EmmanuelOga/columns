require "tlua"

local version = "1.0.0"
local archive  = "tlua-" .. version
local sh      = os.execute

local function docs()
  tlua.invoke("clean")
  sh("luadoc -d docs --nomodules columns/*.lua")
end

local function run()
  sh("love .")
end

local function test()
  sh("~/.luarocks/bin/tsc --load=tests/helper.lua tests/*_test.lua")
end

tlua.task("docs", "Run Luadoc for the Tlua project", docs)
tlua.task("run", "Run Game", run)
tlua.task("test", "Run tests", test)
