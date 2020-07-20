local computer=require"computer"
local component=require"component"
local soundlib={}
local sounds={}
local function tcheck(x,t)
  return type(x)==t
end
local smt={}
function smt:play()
  self.playing=true
end
function smt:pause()
  self.playing=false
end
function smt:rewind()
  self.rawpoint=0
end
function smt:stop()
  self.playing=false
  self.rawpoint=0
end
function smt:setVolume(n)
  self.volume=tcheck(n,"number") and math.max(0,math.min(n,10))
end
function smt:getVolume(n)
  return self.volume
end
function smt:getDuration()
  return self.duration*self.delay/1000
end
function smt:seek()
  return self.rawpoint*self.delay/1000
end
function smt:set(rawpos,wave,freq,vol)
  if not(tcheck(rawpos,"number") and tcheck(wave,"string") and tcheck(freq,"number") and tcheck(vol,"number")) then
    error("invalid args",-2)
  end
  if not(self.samples[wave]) or not(self.samples[wave][math.floor(rawpos)]) then
    error("out of range",-2)
  end
  self.samples[wave][math.floor(rawpos)][1],self.samples[wave][math.floor(rawpos)][2]=freq,vol
  return true
end
function smt:get(rawpos,wave,freq,vol)
  if not(tcheck(rawpos,"number") and tcheck(wave,"string") and tcheck(freq,"number") and tcheck(vol,"number")) then
    error("invalid args",-2)
  end
  if not(self.samples[wave]) or not(self.samples[wave][math.floor(rawpos)]) then
    error("out of range",-2)
  end
  local sample=self.samples[wave][math.floor(rawpos)]
  return sample[1],sample[2]
end
function smt:getCurrentSample()
  return self.rawpos
end
function smt:getSampleCount()
  return self.duration
end
function smt:setSeek(pos)
  --if pos*1000 > self.duration*self.delay or pos < 0 then
  --  error("out of range",-2)
  --end
  self.rawpoint=math.min(self.duration*self.delay,math.max(0,pos*1000))
end
function smt:isPlaying()
  return self.playing
end
function smt:setLooping(bool)
  self.rep=not not bool
end
function smt:isLooping()
  return self.rep
end
function smt:destroy()
  for k,v in pairs(sounds) do
    if v==self then
      sounds[k]=nil
      break
    end
  end
end
function smt:isDestroyed()
  for k,v in pairs(sounds) do
    if v==self then
      return false
    end
  end
  return true
end
local s=false
local prevaddress=false
local inited=false
local function middle(numbers)
  local supernumber=0
  local numbercount=0
  for k,v in ipairs(numbers) do
    supernumber=supernumber+v.num*v.power
    numbercount=numbercount+v.power
  end
  return supernumber/numbercount
end
function soundlib.init()
  if not (inited) and component.isAvailable("sound") then
    inited=true
    s=component.sound
    prevaddress=s.address
    return true
  end
  return false
end
function soundlib.getSoundsCount()
  local n=0
  for k,v in pairs(sounds) do
    n=n+1
  end
  return n
end
function soundlib.deinit()
  if inited then
    inited=false
    s=false
    for k,v in pairs(sounds) do
      sounds[k]=nil
    end
    prevaddress=false
    return true
  end
  return false
end
function soundlib.isInited()
  return inited
end
function soundlib.reinit()
  soundlib.deinit()
  return soundlib.init()
end
--[[ Формат объекта звука:
sound={repeat=булиан,playing=булиан,rawpoint=0,duration=кол-во_сэмплов,delay=длительность_сэмплов_в_мс,samples={["тип_волны"]={{freq=частота,vol=громкость}}}}
]]
function soundlib.newSound(size,delay)
  if not(tcheck(size,"number") and tcheck(delay,"number")) then
    error("invalid args",-2)
  end
  delay=math.max(1,math.min(delay*1000,100000))
  local sound={rep=false,volume=1,prevproc=computer.uptime(),playing=false,rawpoint=0,duration=size,delay=delay}
  sound.samples={square={},sine={},noise={},triangle={}}
  for n=0,size-1 do
    sound.samples.square[n]={0,0}
  end
  for n=0,size-1 do
    sound.samples.sine[n]={0,0}
  end
  for n=0,size-1 do
    sound.samples.noise[n]={0,0}
  end
  for n=0,size-1 do
    sound.samples.triangle[n]={0,0}
  end
  setmetatable(sound,{__index=smt,__newindex=function()end,__metatable={}}) -- _metatable - защита от "хакеров", от которых может рухнуть вся система звуков
  table.insert(sounds,sound)
  return sound
end
function soundlib.process(times) -- Запускать как можно чаще
  local ok=false
  if inited and component.isAvailable("sound") then
    s=component.sound
    if s.address ~= prevaddress then
      soundlib.reinit()
    end
    local modes={square={modeid=1,ch=1},noise={modeid=-1,ch=2},sine={modeid=2,ch=3},triangle={modeid=3,ch=4}}
    for k,v in pairs(sounds) do xpcall(function()
      for mname,mdata in pairs(modes) do
        if v.samples[mname] and v.playing then
          if (not v.samples[mname][math.floor(v.rawpoint)]) or v.rawpoint > v.duration then
            if v.rep then
              v.rawpoint=0
            else
              v.rawpoint=0 v.playing=false
            end
          end
          if v.playing then
            local sample=v.samples[mname][math.floor(v.rawpoint)]
            if sample[1] and sample[2] and sample[2] > 0 and sample[1] > 0 then
              mdata.volume=(mdata.volume or 0)+sample[2]*v.volume
              mdata.freqs=mdata.freqs or {}
              table.insert(mdata.freqs,{num=math.max(0,math.min(sample[1],20000)),power=math.floor(sample[2]*v.volume*100)})
            else
              --print("No playing sounds")
            end
            v.prevproc=v.prevproc or computer.uptime()
            local tm=computer.uptime()-v.prevproc
            v.rawpoint=v.rawpoint+tm*1000*v.delay
            --print(v.rawpoint)
            v.prevproc=computer.uptime()
          end
        end
      end
    end,function(err) print("Sound system errored in sound processing: "..err) end) end
    local sounders=0
    for mname,mdata in pairs(modes) do
      if mdata.freqs and mdata.volume then
        sounders=sounders+1
      end
    end
    for mname,mdata in pairs(modes) do xpcall(function()
      if mdata.freqs and mdata.volume then
        local freq=middle(mdata.freqs)
        s.setWave(mdata.ch,mdata.modeid)
        s.setFrequency(mdata.ch,freq)
        s.open(mdata.ch)
        s.delay(times/sounders)
        s.setVolume(mdata.ch,mdata.volume)
        s.close(mdata.ch)
        while not s.process() do end
        --print(mdata.ch,mdata.volume,freq,require("serialization").serialize(mdata.freqs))
      end
    end,function(err) print("Sound system errored in sound sending: "..err) end) end
    ok=true
  else
    ok=false
  end
  if not component.isAvailable("sound") then
    soundlib.deinit()
  else
    soundlib.init()
  end
  return ok
end
return soundlib