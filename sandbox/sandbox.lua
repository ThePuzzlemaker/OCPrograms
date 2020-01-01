function copy(a,b)if type(a)~='table'then return a end;if b and b[a]then return b[a]end;local c=b or{}local d=setmetatable({},getmetatable(a))c[a]=d;for e,f in pairs(a)do d[copy(e,c)]=copy(f,c)end;return d end

local filesystem = require("filesystem")
local computer = require("computer")
local component = require("component")
local bit32 = require("bit32")
local unicode = require("unicode")
local coroutine = require("coroutine")
local term = require("term")

local args = {...}
if #args < 1 then
  print("Error: usage: sandbox.lua <path>")
  os.exit(-1) 
end

path = args[1]

if not filesystem.exists(path) then
  print("Error: path does not exist!")
  os.exit(-1)
end
local fsAddr = filesystem.get(path)
if not filesystem.exists(path .. "/bios.lua") then
  print("Error: path/bios.lua does not exist!")
  os.exit(-1)
end
bootAddrBak = computer.getBootAddress()
computer.setBootAddress(fsAddr)
local file = io.open(path .. "/bios.lua")
biosData = file:read("*a")
file:close()

print("Warning: this sandbox does not currently protect against filesystem/component damage. It may also cause problems which may require a restart. Be careful when using. To exit the sandbox, use whatever means of shutdown/reboot the OS has. Press enter to continue.")
local res = term.read()
if res == nil or res == false then
  print("Exiting.")
  os.exit(0)
end
local prebios = {
  _VERSION = _VERSION,
  assert = assert,
  error = error,
  getmetatable = getmetatable,
  ipairs = ipairs,
  load = load,
  next = next,
  pairs = pairs,
  pcall = pcall,
  rawequal = rawequal,
  rawget = rawget,
  rawlen = rawlen,
  rawset = rawset,
  select = select,
  setmetatable = setmetatable,
  tonumber = tonumber,
  tostring = tostring,
  type = type,
  xpcall = xpcall,
  bit32 = {
    arshift = bit32.arshift,
    band = bit32.band,
    bnot = bit32.bnot,
    bor = bit32.bor,
    btest = bit32.btest,
    extract = bit32.extract,
    lrotate = bit32.lrotate,
    lshift = bit32.lshift,
    replace = bit32.replace,
    rrotate = bit32.rrotate,
    rshift = bit32.rshift
  },
  coroutine = {
    create = coroutine.create,
    resume = coroutine.resume,
    running = coroutine.running,
    status = coroutine.status,
    wrap = coroutine.wrap,
    yield = coroutine.yield
  },
  debug = {
    getinfo = debug.getinfo,
    traceback = debug.traceback
  },
  math = {
    abs = math.abs,
    acos = math.acos,
    asin = math.asin,
    atan = math.atan,
    atan2 = math.atan2,
    ceil = math.ceil,
    cos = math.cos,
    cosh = math.cosh,
    deg = math.deg,
    exp = math.exp,
    floor = math.floor,
    fmod = math.fmod,
    frexp = math.frexp,
    huge = math.huge,
    ldexp = math.ldexp,
    log = math.log,
    max = math.max,
    min = math.min,
    modf = math.modf,
    pi = math.pi,
    pow = math.pow,
    rad = math.rad,
    random = math.random,
    randomseed = math.randomseed,
    sin = math.sin,
    sinh = math.sinh,
    sqrt = math.sqrt,
    tan = math.tan,
    tanh = math.tanh
  },
  os = {
    clock = os.clock,
    date = os.date,
    difftime = os.difftime,
    time = os.time
  },
  string = {
    byte = string.byte,
    char = string.char,
    dump = string.dump,
    find = string.find,
    format = string.format,
    gmatch = string.gmatch,
    gsub = string.gsub,
    len = string.len,
    lower = string.lower,
    match = string.match,
    rep = string.rep,
    reverse = string.reverse,
    sub = string.sub,
    upper = string.upper
  },
  table = {
    concat = table.concat,
    insert = table.insert,
    pack = table.pack,
    remove = table.remove,
    sort = table.sort,
    unpack = table.unpack
  },
  checkArg = checkArg,
  component = {
    doc = component.doc,
    fields = component.fields,
    invoke = component.invoke,
    list = component.list,
    methods = component.methods,
    proxy = component.proxy,
    slot = component.slot,
    type = component.type
  },
  computer = {
    address = computer.address,
    addUser = computer.addUser,
    beep = computer.beep,
    energy = computer.energy,
    freeMemory = computer.freeMemory,
    getArchitectures = computer.getArchitectures,
    getArchitecture = computer.getArchitecture,
    getBootAddress = computer.getBootAddress,
    maxEnergy = computer.maxEnergy,
    pullSignal = computer.pullSignal,
    pushSignal = computer.pushSignal,
    removeUser = computer.removeUser,
    setArchitecture = computer.setArchitecture,
    setBootAddress = computer.setBootAddress,
    shutdown = computer.shutdown,
    tmpAddress = computer.tmpAddress,
    totalMemory = computer.totalMemory,
    uptime = computer.uptime,
    users = computer.users
  },
  unicode = {
    char = unicode.char,
    charWidth = unicode.charWidth,
    isWide = unicode.isWide,
    len = unicode.len,
    lower = unicode.lower,
    reverse = unicode.reverse,
    sub = unicode.sub,
    upper = unicode.upper,
    wlen = unicode.wlen,
    wtrunc = unicode.wtrunc
  }
}
prebios._G = prebios
prebios._BD = biosData
prebios._BA = fsAddr
prebios.computer.shutdown = function()
  coroutine.yield(_CO)
end

co = coroutine.create(function()
  load(prebios._BD, "=" .. path .. "/bios.lua", "bt", prebios)()
end)
prebios._CO = co
coroutine.resume(co)
term.clear()
print("Sandbox shut down.")