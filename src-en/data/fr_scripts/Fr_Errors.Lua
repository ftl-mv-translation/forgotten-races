if not mods or not mods.inferno then
    error("Couldn't find Inferno Core! Make sure it's above both forgotten races files but below the multiverse files in the Slipstream load order")
end

if not mods or not mods.trc then
    error("Couldn't find The Renegade Collection (TRC)! Make sure it's above both forgotten races files and Inferno Core but below other multiverse files in the Slipstream load order")
end