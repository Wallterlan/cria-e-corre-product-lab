-- Stable identifiers: existing recipes keep their parts across catalog updates.
local C={}
C.order={
    body={"Torradeira","Gelatina","Cunha","Bípede","Esqueleto","Blindado"},
    movement={"Pernas","Rodas","Esteiras","Molas","Triciclo","Articuladas"},
    power={"Torrada","Grito","Arpão","Chamas","Alavanca","Martelo"},
    engine={"Econômico","Equilibrado","Turbo","Servo","Híbrido"},
    tank={"Compacto","Reserva","Duplo"},
}
C.parts={
    body={
        Esqueleto={mass=8,steady=.55,stun=1.15,description="Ultraleve: ganha velocidade, mas sofre 15% mais tempo de atordoamento."},
        Blindado={mass=28,steady=.95,stun=.6,locked=true,description="Projeto de 3 fragmentos. Resiste ao atordoamento; exige peças leves para respeitar 60 kg."},
        Torradeira={mass=26,steady=.9,stun=.7,description="Pesada: atordoamento 30% menor. Mantém 90% da velocidade nas chamas."},
        Gelatina={mass=10,steady=.6,description="Corpo leve. Rápido, mas mantém só 60% da velocidade nas chamas."},
        Cunha={mass=10,steady=.6,description="Chassi baixo e largo. Leve; perde velocidade ao disparar chamas."},
        ["Bípede"]={mass=18,steady=.75,stun=.9,description="Estrutura intermediária: atordoamento 10% menor."},
    },
    movement={
        Triciclo={mass=5,factor=.92,speed=.65,acceleration=8,turn=2.6,description="Leve e econômico. Acelera devagar e perde velocidade ao fazer curvas fechadas."},
        Articuladas={mass=10,factor=1.16,speed=-.2,acceleration=20,turn=8,impulse=1.2,description="Mudanças rápidas de direção e arrancada +20%; consome mais ao andar."},
        Pernas={mass=8,factor=1.1,speed=0,impulse=1.24,description="Arrancada de +24%. Custa 3 de combustível; Turbo custa 5."},
        Rodas={mass=6,factor=1,speed=.5,description="Mais velocidade e menor consumo. Sem salto livre."},
        Esteiras={mass=12,factor=1.2,speed=-.5,description="Pesadas. Armadilhas reduzem só 15% da velocidade."},
        Molas={mass=8,factor=1.15,speed=0,jumpDistance=24,jumpWindup=.2,jumpSeconds=.55,description="Salto de até 24 studs. Custa 4; Turbo custa 6. Sem atacar durante o impulso."},
    },
    power={
        Torrada={mass=4,cost=4,description="Projétil que derruba. Custa 4 de combustível."},
        Grito={mass=6,cost=6,description="Cone de impacto. Custa 6 de combustível."},
        ["Arpão"]={mass=8,cost=5,description="Puxa e derruba; cobertura bloqueia. Custa 5."},
        Chamas={mass=10,cost=6,description="Toque para disparar; toque de novo para parar. 3 de combustível/s, até 2 s."},
        Alavanca={mass=6,cost=4,description="Golpe frontal curto. Prepara em 0,5 s; custa 4."},
        Martelo={mass=9,cost=6,description="Impacto lento, maior alcance. Prepara em 0,85 s; custa 6."},
    },
    engine={
        ["Híbrido"]={mass=5,factor=.9,speed=-.4,idle=.06,locked=true,description="Projeto de 3 fragmentos. Menor consumo parado; velocidade intermediária."},
        ["Econômico"]={mass=3,factor=.82,speed=-1,description="Consome menos ao mover, com menor velocidade."},
        Equilibrado={mass=4,factor=1,speed=0,description="Velocidade e consumo intermediários."},
        Turbo={mass=6,factor=1.22,speed=1.2,description="Mais rápido; impulso custa duas unidades extras."},
        Servo={mass=5,factor=1.08,speed=0,locked=true,description="Captura prepara 25% mais rápido e custa 2. Projeto: 3 fragmentos."},
    },
    tank={
        Duplo={mass=14,capacity=140,description="140 de combustível. Peso alto limita armas e carrocerias."},
        Compacto={mass=4,capacity=100,description="100 de combustível. Menor peso."},
        Reserva={mass=8,capacity=120,description="120 de combustível. Pesa mais e reduz velocidade."},
    },
}
C.default={body="Torradeira",movement="Pernas",power="Torrada",engine="Econômico",tank="Compacto"}
function C.normalize(value)
    if type(value)~="table" then return nil end
    local out={}
    for key,parts in pairs(C.parts) do
        local id=value[key] or ((key=="engine" or key=="tank") and C.default[key])
        if type(id)~="string" or not parts[id] then return nil end
        out[key]=id
    end
    return out
end
function C.owned(recipe,data)
    for key,id in pairs(recipe) do
        local part=C.parts[key] and C.parts[key][id]
        if not part or (part.locked and not (data and data.unlocked and data.unlocked[id])) then return false end
    end
    return true
end
return C
