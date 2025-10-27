local Event = "31.10"

local d,m = Event:match("(%d+)%.(%d+)")
return os.time() <= os.time{year=os.date("*t").year, month=m, day=d}
