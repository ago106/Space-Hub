local Event = "31.10"

function checkDate(eventStr)
    if eventStr == "none" then return false end
    
    local day, month = eventStr:match("(%d+)%.(%d+)")
    local current = os.date("*t")
    
    local eventTime = os.time{year=current.year, month=month, day=day}
    local novemberFirst = os.time{year=current.year, month=11, day=1}
    
    return os.time() >= eventTime and os.time() < novemberFirst
end

return Event ~= "none" and checkDate(Event)
