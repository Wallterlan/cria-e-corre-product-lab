local B=require("./RobotBalance")
local C=require("./Catalog")
local checks,validCount,invalidCount=0,0,0
local function check(value,label) assert(value,label); checks+=1 end
for _,body in ipairs(C.order.body) do
    for _,movement in ipairs(C.order.movement) do
        for _,power in ipairs(C.order.power) do
            for engine in pairs(B.engines) do
                for tank in pairs(B.tanks) do
                    local s=B.stats({body=body,movement=movement,power=power,engine=engine,tank=tank})
                    check(s.speed>=25.5 and s.speed<=31.5 and s.valid==(s.mass<=60),"weight limit and movement bounds")
                    if s.valid then
                        validCount+=1
                        check(s.speed<24*1.4,"survivor speed pickup outruns every base build")
                        if movement=="Molas" then
                            local burst=s.jumpDistance+(1.4-s.jumpWindup-s.jumpSeconds)*s.speed*s.impulseFactor
                            check(burst>s.speed*1.4 and burst<s.speed*1.4+8,"spring gains useful bounded distance over ordinary movement")
                        end
                    else invalidCount+=1 end
                    local fuel=s.capacity
                    for _=1,1500 do fuel=B.drain(fuel,s,.1,true) end
                    local once=B.drain(s.capacity,s,150,true)
                    check(math.abs(fuel-once)<.000001,"consumption independent of tick rate")
                    local bad,accepted=B.spend(.5,2)
                    check(bad==.5 and not accepted,"insufficient fixed action has no charge")
                    local zero,valid=B.spend(2,2)
                    check(zero==0 and valid,"exact fuel use reaches zero")
                end
            end
        end
    end
end
local a=B.stats({body="Gelatina",movement="Pernas",power="Torrada"})
local b=B.stats({body="Torradeira",movement="Pernas",power="Torrada"})
check(a.speed>b.speed and a.movement<b.movement,"lighter body faster and cheaper")
check(B.drain(1,a,100,false)==0,"idle can cause dry out")
local flame=B.stats({body="Torradeira",movement="Pernas",power="Chamas",engine="Turbo",tank="Reserva"})
check(flame.mass==58 and flame.powerCost==6 and flame.impulseCost==5,"flame full burst and turbo costs")
local economy=B.stats({body="Gelatina",movement="Rodas",power="Chamas",engine="Econômico",tank="Compacto"})
check(economy.impulseCost==3 and economy.movement<flame.movement,"economy impulse tradeoff")
check(validCount+invalidCount==3240 and validCount>2500 and invalidCount>3,"expanded recipes respect the mass budget")
check(B.stats({body="bad"})==nil,"unknown recipe rejected")
check(b.stunFactor<a.stunFactor,"heavy body trades speed and fuel for shorter interruption")
local legs=B.stats({body="Cunha",movement="Pernas",power="Arpão"})
local wheels=B.stats({body="Cunha",movement="Rodas",power="Arpão"})
check(legs.speed<wheels.speed and legs.movement>wheels.movement and legs.speed*legs.impulseFactor>wheels.speed*wheels.impulseFactor,"legs burst advantage pays weight and movement fuel")
local function budget(tank)
    local s=B.stats({body="Torradeira",movement="Molas",power="Alavanca",engine="Turbo",tank=tank})
    return s.capacity-150*s.idle-105*s.movement-4*s.powerCost-4*s.impulseCost-8-4*s.captureCost
end
check(budget("Compacto")>0 and budget("Compacto")<20 and budget("Reserva")>budget("Compacto")+15,"regular heavy turbo use finishes with limited reserve; larger tank pays its weight")
local aggressive=B.stats({body="Torradeira",movement="Molas",power="Alavanca",engine="Turbo",tank="Compacto"})
check(aggressive.capacity-150*(aggressive.idle+aggressive.movement)-8*aggressive.powerCost-8*aggressive.impulseCost-12<0,"repeated turbo and weapon use can still run dry")
print("Cria & Corre balance: "..checks.." checks passed; "..validCount.." legal recipes")
