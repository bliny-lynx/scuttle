local fennel = require("fennel")
table.insert(package.loaders or package.searchers, fennel.searcher)

local game = require "strap"