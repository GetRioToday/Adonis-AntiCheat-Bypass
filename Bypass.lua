local function BypassAdonis()
	local Query = {
		--Hash = "605A34235509ABBB6946D10B499B526AC72774E441C3F9BAE4B63D321C6E759347D864CE879B39864743C0EEAC444FFF";
		Constants = {" - On Xbox", " - On mobile", "_"}
		IgnoreExecutor = true
	}

	local Detected = filtergc("function", Query, true)
	if not Detected then
		return LocalClient:Kick("Adonis anticheat bypass failed to activate, please contact support.")
	end

	local iDetour = Hooks.new(REnv.debug.info)
	local dDetour = Hooks.new(Detected)

	local a, b, c, d, e, f = debug.info(Detected, "slanf")
	local Detour = function(...)
		local Args = {...}
		if Args[1] == Detected and Args[2] == "slanf" then
			return a, b, c, d, e, f
		end

		return iDetour:Original(...)
	end

	iDetour:SetDetour(Detour)
	dDetour:SetDetour(function() return task.wait(9e10) end)
	iDetour:Enable()
	dDetour:Enable()
end
