-- Writes all lines from the file input to the file output except those starting with prefix
-- Doesn't close the output file, but returns the file object
local function do_filter_prefix(input, output, prefix)
	local f = io.open(output, 'w+')
	local l = prefix:len()

	for line in io.lines(input) do
		if line:sub(1, l) ~= prefix then
			f:write(line, '\n')
		end
	end

	return f
end


local function escape_args(ret, arg0, ...)
	if not arg0 then
		return ret
	end

	return escape_args(ret .. "'" .. string.gsub(arg0, "'", "'\\''") .. "' ", ...)
end


local os = os
local string = string
local tonumber = tonumber

local nixio = require 'nixio'
local sysconfig = require 'gluon.sysconfig'
local uci = require('luci.model.uci').cursor()

module 'gluon.util'

function exec(...)
	return os.execute(escape_args('', ...))
end

-- Removes all lines starting with a prefix from a file, optionally adding a new one
function replace_prefix(file, prefix, add)
	local tmp = file .. '.tmp'
	local f = do_filter_prefix(file, tmp, prefix)
	if add then
		f:write(add)
	end
	f:close()
	os.rename(tmp, file)
end

function lock(file)
	exec('lock', file)
end

function unlock(file)
	exec('lock', '-u', file)
end

function node_id()
  return string.gsub(sysconfig.primary_mac, ':', '')
end

-- Wrapper for generate_mac; if wan_mac_static is set, use 2014.3-method for WAN MAC
function generate_mac(f, i)
  local wan_mac_static = uci:get_first('gluon-node-info','system','wan_mac_static') and 1 or 0
  local hostname = uci:get_first("system", "system", "hostname")

  if f==1 and i==0 then
    if wlan_max_static then
      return(generate_mac_2014_3(f, i))
    end
    -- Hardcoded for now, FIXME
    if string.match(hostname, 'HolidayInnExpress') then
      return(generate_mac_2014_3(f, i))
    end
  end
  -- fall through

  return(generate_mac_2014_4(f, i))
end

-- Generates a (hopefully) unique MAC address
-- The first parameter defines the function and the second
-- parameter an ID to add to the MAC address
-- Functions and IDs defined so far:
-- (1, 0): WAN (for mesh-on-WAN)
-- (1, 1): LAN (for mesh-on-LAN)
-- (2, n): client interface for the n'th radio
-- (3, n): adhoc interface for n'th radio
-- (4, 0): mesh VPN
function generate_mac_2014_4(f, i)
  local m1, m2, m3, m4, m5, m6 = string.match(sysconfig.primary_mac, '(%x%x):(%x%x):(%x%x):(%x%x):(%x%x):(%x%x)')
  m1 = nixio.bit.bor(tonumber(m1, 16), 0x02)
  m2 = (tonumber(m2, 16)+f) % 0x100
  m3 = (tonumber(m3, 16)+i) % 0x100

  return string.format('%02x:%02x:%02x:%s:%s:%s', m1, m2, m3, m4, m5, m6)
end

-- fix up duplicate mac addresses
function generate_mac_2014_3(f, i)
  local m1, m2, m3, m4, m5, m6 = string.match(sysconfig.primary_mac, '(%x%x):(%x%x):(%x%x):(%x%x):(%x%x):(%x%x)')
  m1 = nixio.bit.bor(tonumber(m1, 16), 0x02)
  m4 = (tonumber(m4, 16)+1) % 0x100
  m6 = (tonumber(m6, 16)+1) % 0x100

  return string.format('%02x:%s:%s:%02x:%s:%02x', m1, m2, m3, m4, m5, m6)
 end
