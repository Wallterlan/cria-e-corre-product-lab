-- Initial playable subset of the modular design. No Roblox services: shared by UI and server.
local Catalog=if script then require(script.Parent.Catalog) else require("./Catalog")
local Balance={engines=Catalog.parts.engine,tanks=Catalog.parts.tank}
function Balance.stats(recipe)
    recipe=Catalog.normalize(recipe); if not recipe then return nil end
    local engine=Balance.engines[recipe.engine]; local tank=Balance.tanks[recipe.tank]
    local body=Catalog.parts.body[recipe.body]; local drive=Catalog.parts.movement[recipe.movement]
    local weapon=Catalog.parts.power[recipe.power]
    local mass=body.mass+drive.mass+weapon.mass+engine.mass+tank.mass
    return {mass=mass,capacity=tank.capacity,idle=engine.idle or .08,
        acceleration=drive.acceleration or 0,
        turn=drive.turn or 0,
        movement=(.08+.002*mass)*drive.factor*engine.factor,
        speed=math.clamp(31.2-.12*(mass-25)+drive.speed+engine.speed,25.5,31.5),
        attackCost=1,captureCost=recipe.engine=="Servo" and 2 or 1,captureWindup=recipe.engine=="Servo" and .75 or 1,
        throwCost=3,impulseCost=(recipe.movement=="Molas" and 4 or 3)+(recipe.engine=="Turbo" and 2 or 0),
        impulseFactor=drive.impulse or 1.15,stunFactor=body.stun or 1,
        jumpDistance=drive.jumpDistance,jumpWindup=drive.jumpWindup,jumpSeconds=drive.jumpSeconds,
        flameSpeed=body.steady,trapFactor=recipe.movement=="Esteiras" and .85 or .65,
        powerCost=weapon.cost,valid=mass<=60}
end
function Balance.estimate(recipe,activity)
    local s=Balance.stats(recipe); if not s then return nil end
    activity=activity or {}; local moving=math.clamp(activity.moving or .7,0,1)
    local actions=math.max(0,activity.powers or 4)*s.powerCost+math.max(0,activity.hits or 6)*s.attackCost+math.max(0,activity.boosts or 3)*s.impulseCost
    actions+=math.max(0,activity.captures or 3)*s.captureCost
    local rate=s.idle+s.movement*moving
    return {seconds=math.floor(math.max(0,s.capacity-actions)/rate),actions=actions,rate=rate,walk=math.floor(s.capacity/(s.idle+s.movement))}
end
function Balance.drain(fuel,stats,seconds,moving)
    return math.max(0,fuel-math.max(0,seconds)*(stats.idle+(moving and stats.movement or 0)))
end
function Balance.spend(fuel,cost)
    if fuel<cost then return fuel,false end
    return math.max(0,fuel-cost),true
end
return Balance
