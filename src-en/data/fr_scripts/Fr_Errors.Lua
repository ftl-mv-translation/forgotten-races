if not mods or not mods.inferno then
    error("Couldn't find Inferno-Core! Make sure it's above both Forgotten Races files, but below the Multiverse files, in Slipstream's load order!")
end

if not mods or not mods.trc then
    error("Couldn't find The Renegade Collection (TRC)! Make sure it's above both Forgotten Races files and Inferno-Core, but below other Multiverse files, in Slipstream's load order!")
end