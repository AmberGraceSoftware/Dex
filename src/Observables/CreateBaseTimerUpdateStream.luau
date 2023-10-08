--!strict
local RunService = game:GetService("RunService")
local Types = require(script.Parent.Parent.Types)
type State<T> = Types.State<T>
type Observable<T> = Types.Observable<T>
type StopwatchProps = Types.StopwatchProps

local function CreateBaseTimerUpdateStream(playState: State<{
    playing: boolean,
    startClockTime: number,
    resumeAtTime: number,
}>, props: StopwatchProps?)
    local duration = (if props then props.duration else nil) or math.huge
    return function(notifyUpdate: () -> ())
        local heartbeatConn = nil
        local function playStateChanged(current: typeof(playState:Current()))
            if current.playing then
                if not heartbeatConn then
                    heartbeatConn = RunService.Heartbeat:Connect(function()
                        local elapsed = os.clock() - current.startClockTime
                        if elapsed > duration then
                            playState:Set({
                                playing = false,
                                startClockTime = 0,
                                resumeAtTime = 0,
                            })
                        end
                        notifyUpdate()
                    end)
                end
            else
                if heartbeatConn then
                    heartbeatConn:Disconnect()
                end
            end
            notifyUpdate()
        end

        local unsubscribes = {}

        -- Update play state via reactive time controls in props
        if props then
            if props.isPlaying then
                if typeof(props.isPlaying) == "boolean" then
                    if props.isPlaying == true then
                        playState:Set({
                            playing = true,
                            resumeAtTime = 0,
                            startClockTime = os.clock()
                        })
                    end
                else
                    table.insert(
                        unsubscribes,
                        props.isPlaying:Subscribe(
                            function(isPlaying)
                                if playState:Current().playing == isPlaying then
                                    return
                                end
                                if isPlaying then
                                    playState:Set({
                                        playing = true,
                                        resumeAtTime = 0,
                                        startClockTime = os.clock()
                                    })
                                else
                                    playState:Set({
                                        playing = false,
                                        startClockTime = 0,
                                        resumeAtTime = 0,
                                    })
                                end
                            end
                        )
                    )
                end
            end

            if props.playOnChange then
                table.insert(
                    unsubscribes,
                    props.playOnChange:Subscribe(
                        function()
                            playState:Set({
                                playing = true,
                                resumeAtTime = 0,
                                startClockTime = os.clock()
                            })
                        end
                    )
                )
            end
        end
        table.insert(unsubscribes, playState:Subscribe(playStateChanged, true))

        return function()
            for _, unsubscribe in unsubscribes do
                unsubscribe()
            end
            if heartbeatConn then
                heartbeatConn:Disconnect()
            end
        end
    end
end
return CreateBaseTimerUpdateStream