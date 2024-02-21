if fs.exists("tmp") then
    fs.delete("tmp")
end

math.randomSeed(os.time())

shell.run("wget", "https://raw.githubusercontent.com/Yabastar/ACS/main/gen.lua", "tmp")
local genTable = loadfile("tmp")()
fs.delete("tmp")

local p = genTable[1]
local g = genTable[2]

term.clear()
term.setCursorPos(1,1)
print("ACS Client CLI\n")

local function is_prime(n, k)
    if n <= 1 or n == 4 then
        return false
    elseif n <= 3 then
        return true
    else
        local d = n - 1
        while d % 2 == 0 do
            d = d / 2
        end

        local isComposite = false
        for i = 1, k do
            local a = math.random(2, n - 2)
            local x = mod_exp(a, d, n)
            if x == 1 or x == n - 1 then
                isComposite = false
            else
                local r = 1
                while r <= math.floor(math.log(n - 1) / math.log(2)) - 1 and x ~= n - 1 do
                    x = mod_exp(x, 2, n)
                    r = r + 1
                end
                if x ~= n - 1 then
                    isComposite = true
                    break
                end
            end
        end

        return not isComposite
    end
end

local function find_primitive_root(p)
    for g = 2, p - 1 do
        local isRoot = true
        for i = 1, p - 2 do
            if mod_exp(g, i, p) == 1 then
                isRoot = false
                break
            end
        end
        if isRoot then
            return g
        end
    end
end

local function prompt()
    io.write(tostring(os.getComputerID()) .. " > ")
    return (function() local words = {}; for word in io.read():gmatch("%S+") do table.insert(words, word) end; return words end)()
end

local host = 0

while true do
    local userprompt = prompt()
    if userprompt[1] == "set" then
        if userprompt[2] == "host" then
            host = tonumber(userprompt[3])
        end
        if userprompt[2] == "prime" then
            if is_prime(userprompt[3], 5) == true then
                p = tonumber(userprompt[3])
                g = find_primitive_root(p)
            else
                print("\n"..userprompt[3].." is not prime")
            end
        end

rednet.send(host, genTable, "handshake")

local a = math.random(2,1000)

rednet.send(host, (g^a%p), "s1")

local b = tonumber(rednet.receive("s2"))

local s = b^a%p -- this is the key we have finally shared

function encrypt(message, key)
    local encrypted = {}
    for i = 1, #message do
        local charCode = string.byte(message, i)
        local keyChar = string.byte(key, (i - 1) % #key + 1)
        local encryptedChar = bit32.bxor(charCode, keyChar)
        table.insert(encrypted, string.char(encryptedChar))
    end
    return table.concat(encrypted)
end

function decrypt(encryptedMessage, key)
    return encrypt(encryptedMessage, key) -- XOR based encryption is its own inverse
end
