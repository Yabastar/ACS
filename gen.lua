-- calculate the modular exponentiation (a^b mod m)
function mod_exp(a, b, m)
    if b == 0 then
        return 1
    end
    local result = 1
    a = a % m
    while b > 0 do
        if b % 2 == 1 then
            result = (result * a) % m
        end
        b = math.floor(b / 2)
        a = (a * a) % m
    end
    return result
end

-- check if a number is prime using the Miller-Rabin primality test
function is_prime(n, k)
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

-- generate a random prime number in a given range
function generate_random_prime(lower_bound, upper_bound)
    while true do
        local num = math.random(lower_bound, upper_bound)
        if is_prime(num, 5) then
            return num
        end
    end
end

-- find a primitive root modulo p
function find_primitive_root(p)
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

local lower_bound = 100
local upper_bound = 1000
local random_prime = generate_random_prime(lower_bound, upper_bound)
local primitive_root = find_primitive_root(random_prime)

return {random_prime, primitive_root}
