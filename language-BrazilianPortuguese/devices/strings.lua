function Merge(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
end

local EnergyDoorStrings =
{
    energydoor = L"Porta de Escudo",
    energydoorTip2 = L"Abre para permitir disparos e reflete lasers enquanto fechada",
    energydoorTip3 = L"Consome energia enquanto o campo está ativo",
}

-- Forts versions/mod configurations have used the material strings through
-- the Device table, while some setups expose a dedicated Material table.
-- Populate both when available.
if Device then
    Merge(Device, EnergyDoorStrings)
end

if Material then
    Merge(Material, EnergyDoorStrings)
end
