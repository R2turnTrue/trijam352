--
-- rdtk
-- modern LDTK loader for Love2D
--
-- Copyright (c) 2025 R2turnTrue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local json = rawget(_G, "json") or require((...):gsub("[^/.\\]+$", "json"))
LdtkFile = Object:extend()
LdtkLevel = Object:extend()
LdtkLayer = Object:extend()

---------------------- LdtkFile

---Load LDTK File.
---@param self table
---@param path any
function LdtkFile:new(path)
    self.path = path
    local contents, size = love.filesystem.read(path)
    assert(contents, "Failed to read LDtk file: " .. path)
    self.data = json.decode(contents)
end

---Get levels
---@param self table
---@return table
function LdtkFile:getLevels()
    local levels = {}
    for i, levelData in ipairs(self.data.levels) do
        table.insert(levels, LdtkLevel(self, i))
    end
    return levels
end

---------------------- LdtkLevel

---Load level
---@param self table
---@param ldtkfile table
---@param levelindex table
function LdtkLevel:new(ldtkfile, levelindex)
    self.index = levelindex
    self.file = ldtkfile
    self.width = ldtkfile.data.levels[levelindex].pxWid
    self.height = ldtkfile.data.levels[levelindex].pxHei
    self.offset_x = ldtkfile.data.levels[levelindex].worldX
    self.offset_y = ldtkfile.data.levels[levelindex].worldY
    self.data = ldtkfile.data.levels[levelindex]
end

---Get layers in level
---@param self table
---@return table
function LdtkLevel:getLayers()
    local layers = {}
    for i, layerData in ipairs(self.data.layerInstances) do
        table.insert(layers, LdtkLayer(self, i))
    end
    return layers
end

---------------------- LdtkLayer

---Load layer
---@param self table
---@param ldtklevel table
---@param layerindex table
function LdtkLayer:new(ldtklevel, layerindex)
    self.level = ldtklevel
    self.data = ldtklevel.data.layerInstances[layerindex]
end

---Get tiles in layer
---@param self table
---@return table
function LdtkLayer:getTiles()
    local tiles = {}

    for i, tileInstance in ipairs(self.data.gridTiles) do
        table.insert(tiles, {
            x = tileInstance.px[1],
            y = tileInstance.px[2],
            srcX = tileInstance.src[1],
            srcY = tileInstance.src[2],
            width = tileInstance.width,
            height = tileInstance.height
        })
    end

    return tiles
end