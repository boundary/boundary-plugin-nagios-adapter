-- [boundary.com] Nagios Plugin Adapter
-- [author] Ivano Picco <ivano.picco@pianobit.com>

-- Common requires.
local utils = require('utils')
local timer = require('timer')
local fs = require('fs')
local json = require('json')
local os = require ('os')
local tools = require ('tools')
 
local success, boundary = pcall(require,'boundary')
if (not success) then
  boundary = nil 
end
 
-- Business requires.
local childProcess = require ('childprocess')
local string = require ('string')
 
-- Default parameters.
local pollInterval = 10000
local source       = nil
 
-- Configuration.
local _parameters = (boundary and boundary.param ) or json.parse(fs.readFileSync('param.json')) or {}
 
_parameters.pollInterval = 
  (_parameters.pollInterval and tonumber(_parameters.pollInterval)>0  and tonumber(_parameters.pollInterval)) or
  pollInterval;
 
_parameters.source =
  (type(_parameters.source) == 'string' and _parameters.source:gsub('%s+', '') ~= '' and _parameters.source ~= nil and _parameters.source) or
  os.hostname()


-- Get current values.
function poll(item)

  childProcess.execFile(item.cmd, item.args , {},
    function ( err, stdout, stderr )
      if (err or #stderr>0) then 
        --print errors to stderr
        utils.debug(err or stderr)
        return
      end

      --parse Nagios output
      --plugin output format: http://nagios.sourceforge.net/docs/3_0/pluginapi.html
      --[[
              TEXT OUTPUT | OPTIONAL PERFDATA
              LONG TEXT LINE 1
              LONG TEXT LINE 2
              ...
              LONG TEXT LINE N | PERFDATA LINE 2
              PERFDATA LINE 3
      --]]

      local perfdata=""
      local longPerfdata = ""
      stdout:gsub("[^\r\n]+", function(line)
        local parse = tools.split(line,'|')
        if (#perfdata==0) then
          perfdata = parse[2]
        else
          if (#longPerfdata == 0) then
            longPerfdata=parse[2]
          else
            longPerfdata=longPerfdata..line
          end
        end
      end)
      perfdata = perfdata..longPerfdata

      --parse performance data
      --performance data format (http://nagios-plugins.org/doc/guidelines.html#AEN200):
      --[[
              'label'=value[UOM];[warn];[crit];[min];[max]
      --]]
      local metrics = tools.split(perfdata,' ')
      for _,metric in ipairs(metrics) do 
        local parts = tools.split(metric,'=')
        local label = string.match(parts[1], "^'?([^=']+)")
        
        local values = tools.split(parts[2],';')
        local value,uom = string.match(values[1],"([%d%.]+)([^%d]*)");

        utils.print(string.upper(item.name.."_"..label..(#uom>0 and "_"..uom or "")), value or 0, item.source)
      end
    end
  )

end

-- Ready, go.
if (#_parameters.items >0 ) then
  for _,item in ipairs(_parameters.items) do 
    item.source = item.source or _parameters.source --default hostname
    item.args = tools.split (item.args or "", " ")
    timer.setInterval(_parameters.pollInterval,poll,item)
  end
else
  utils.debug("Configuration error: no items found")
end
