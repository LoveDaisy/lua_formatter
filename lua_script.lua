local device = {
    MOD_NAME = "device",
    
    backsn = "",
    mac = wifi.sta.getmac(),
    model = "XXYYZZ",
    chipid = tostring(node.chipid()),
    time_zone_shift = 8 * 3600,
    
    target_value = 0,
    schedule_table = {},
    config_file_name = "config.json"
}


function device:init()
    print("device.init()")
    self.backsn = ""
    self.schedule_table = {}
    
    if file.open(self.config_file_name, "r") then
        local config_str = file.read()
        file.close()
        
        local config = {}
        if config_str then
            config = sjson.decode(config_str)
        end
        
        for k, v in pairs(config) do
            if k == "SN" then
                self.backsn = v
            end
            -- TODO other parameters
        end
        print("read sucess")
    end
end


function device:has_sn()
    return #self.backsn > 0
end

function device:on_schedule(param)
    -- FORMAT:
    -- SCHEDULE:0600-2000-1,2,4,7
    -- SCHEDULE:0600-2000
    -- SCHEDULE:ALL
    -- SCHEDULE:NONE
    print("On command SCHEDULE! param: " .. param)
    
    local vals = {}
    for x in string.gmatch(param, "[^-]+") do
        vals[#vals + 1] = x
    end
    
    if vals[1] == "ALL" then
        self.schedule_table = {}
        for wd = 1, 7 do
            self.schedule_table[wd] = {0, 3600 * 24}
        end
        return
    end
    if vals[1] == "NONE" then
        self.schedule_table = {}
    end
    
    local start_hour = tonumber(vals[1]:sub(1, 2))
    local start_minute = tonumber(vals[1]:sub(3, 4))
    local end_hour = tonumber(vals[2]:sub(1, 2))
    local end_minute = tonumber(vals[2]:sub(3, 4))
    
    local week_days = {}
    if #vals == 3 then
        for x in string.gmatch(vals[3], "[^,]+") do
            week_days[#week_days + 1] = tonumber(x)
        end
    else
        week_days = {1, 2, 3, 4, 5, 6, 7}
    end
    for ind, wd in ipairs(week_days) do
        if not self.schedule_table[wd] then
            self.schedule_table[wd] = {start_hour * 3600 + start_minute * 60, end_hour * 3600 + end_minute * 60}
        else
            local len = #self.schedule_table[wd]
            self.schedule_table[wd][len + 1] = start_hour * 3600 + start_minute * 60
            self.schedule_table[wd][len + 2] = end_hour * 3600 + end_minute * 60
        end
    end
end