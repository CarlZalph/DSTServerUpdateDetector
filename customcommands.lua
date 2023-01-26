local SHUTDOWN_SIGNAL = "<Shutting Down>"

if TheShard:IsMaster()
then
    local CHECK_FREQUENCY = 300
    local CHECK_URL = "https://s3.amazonaws.com/dstbuilds/builds.json"
    local CHECK_VERSION = tonumber(APP_VERSION)

    local UPDATE_TICKS_COUNT = 61
    local SHUTDOWN_MESSAGES = {
        [60] = "A game update has been detected.\nThe server will save and update in 60 seconds.",
        [30] = "A game update has been detected.\nThe server will save and update in 30 seconds.",
        [15] = "A game update has been detected.\nThe server will save and update in 15 seconds.",
        [10] = "A game update has been detected.\nThe server will save and update in 10 seconds.",
        [5] = "A game update has been detected.\nThe server will save and update in 5 seconds.",
        [4] = "The server will save and update in 4 seconds.",
        [3] = "The server will save and update in 3 seconds.",
        [2] = "The server will save and update in 2 seconds.",
        [1] = "The server will save and update in 1 second.",
    }


    local DoNothing = function() end
    local Tick = DoNothing

    local StartUpdatingServer = function()
        local TicksUpating = UPDATE_TICKS_COUNT
        Tick = function()
            TicksUpating = TicksUpating - 1
            if TicksUpating > 0
            then
                local msg = SHUTDOWN_MESSAGES[TicksUpating]
                if msg
                then
                    c_announce(msg)
                end
            else
                Tick = DoNothing
                c_announce(SHUTDOWN_SIGNAL)
                c_shutdown(true)
            end
        end
    end

    local IsNewVersion = function(response)
        local success, response_json = pcall(function()
            return json.decode(response)
        end)

        if not success or not response_json or not response_json.release or response_json.release[1] == nil
        then
            return false
        end

        local latest_version = -2
        for _, v in ipairs(response_json.release)
        do
            local version = tonumber(v)
            if version > latest_version
            then
                latest_version = version
            end
        end

        if CHECK_VERSION >= latest_version
        then
            return false
        end

        return true
    end

    local CheckForUpdate = function()
        TheSim:QueryServer(CHECK_URL, function(response, success, httpcode)
            if success and httpcode == 200 and #response > 1
            then
                if IsNewVersion(response)
                then
                    StartUpdatingServer()
                end
            end
        end, "GET")
    end


    local TicksToCheckForUpdate = CHECK_FREQUENCY
    Tick = function()
        TicksToCheckForUpdate = TicksToCheckForUpdate - 1
        if TicksToCheckForUpdate <= 0
        then
            TicksToCheckForUpdate = CHECK_FREQUENCY
            CheckForUpdate()
        end
    end


    local GetTime = os.time
    local oldTime = GetTime()
    local ShouldTick = function()
        local newTime = GetTime()
        if newTime > oldTime
        then
            oldTime = newTime
            return true
        end
        return false
    end

    local HandleRPCQueue_old = HandleRPCQueue
    HandleRPCQueue = function(...)
        if ShouldTick()
        then
            Tick()
        end
        return HandleRPCQueue_old(...)
    end
else
    local Networking_Announcement_old = Networking_Announcement
    Networking_Announcement = function(msg, ...)
        if msg == SHUTDOWN_SIGNAL
        then
            c_shutdown(true)
        end
        return Networking_Announcement_old(msg, ...)
    end
end
