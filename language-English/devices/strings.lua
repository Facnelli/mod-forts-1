function Merge(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
end

local EnergyDoorStrings =
{
    energydoor = L"Shield Door",
    energydoorTip2 = L"Opens for friendly weapons and reflects lasers while closed",
    energydoorTip3 = L"Consumes energy while the field is active",
}

if Device then
    Merge(Device, EnergyDoorStrings)
end

if Material then
    Merge(Material, EnergyDoorStrings)
end
