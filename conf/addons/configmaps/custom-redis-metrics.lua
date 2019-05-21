-- Based on https://github.com/soveran/rediscan.lua by GitHub user Soveran.

-- Base queue name:
local base_queue_name = "predict"
local queues = {}
queues[#queues+1] = base_queue_name
local queue_regex = "processing-" .. base_queue_name .. ":*"

-- Gather the names of all queues.
local keys = nil
local done = false
local cursor = "0"
repeat
       local result = redis.call("SCAN", cursor, "MATCH", "processing-predict:*", "COUNT", 1000)

       cursor = result[1]
       keys   = result[2]

       for i, key in ipairs(keys) do
               queues[#queues+1] = key
       end

       if cursor == "0" then
               done = true
       end
until done

-- Separately tally the zip and image keys between all queues.
local zip_keys = 0
local image_keys = 0
for _,queue in ipairs(queues) do
       local results = redis.call("LRANGE", queue, 0, -1)
       for _,key in ipairs(results) do
               if string.find(key,"^.+\.zip.+$") then
                       zip_keys = zip_keys + 1
               else
                       image_keys = image_keys + 1
               end
       end
end

-- Format output
local results = {}
table.insert(results, "image_keys")
table.insert(results, tostring(image_keys))
table.insert(results, "zip_keys")
table.insert(results, tostring(zip_keys))

return results
