-- Function to calculate the modular exponentiation (a^b mod m)
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

-- Function to generate a random prime number in a given range
function generate_random_prime(lower_bound, upper_bound)
  while true do
    local num = math.random(lower_bound, upper_bound)
    if is_prime(num, 5) then
      return num
    end
  end
end

-- Function to check if a number is prime using the Miller-Rabin primality test
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

    for i = 1, k do
      local a = math.random(2, n - 2)
      local x = mod_exp(a, d, n)
      if x == 1 or x == n - 1 then
        -- Continue to the next iteration of the loop
      else
        local prime = true
        for r = 1, math.floor(math.log(n - 1) / math.log(2)) - 1 do
          x = mod_exp(x, 2, n)
          if x == n - 1 then
            prime = true
            break
          else
            prime = false
          end
        end
        if not prime then
          return false
        end
      end
    end
    return true
  end
end

-- Function to perform Diffie-Hellman key exchange
function diffie_hellman()
  -- Step 1: Choose large prime p and primitive root g
  local p = generate_random_prime(500, 1000)
  local g = 2

  -- Open a Rednet modem on the left side
  rednet.open("left")

  -- Step 2: Listener waits for the client to send the public key
  print("Waiting for client to send public key...")
  local senderId, message = rednet.receive("diffie_hellman")
  if not message or not message.public_key then
    print("Timeout or invalid response. Exiting.")
    rednet.close("left")
    return
  end

  -- Extract the sender's ID and public key from the message
  local sender_public_key = message.public_key

  -- Step 3: Listener generates a private key
  local private_key_a = math.random(2, p - 2)
  local public_key_a = mod_exp(g, private_key_a, p)

  -- Step 4: Listener sends its public key to the client
  rednet.send(senderId, { public_key = public_key_a }, "diffie_hellman")

  -- Step 5: Listener calculates the shared secret
  local shared_secret_a = mod_exp(sender_public_key, private_key_a, p)

  -- The shared secret is printed
  print("Shared Secret:", shared_secret_a)

  -- Close the Rednet modem
  rednet.close("left")
end

-- Run the Diffie-Hellman key exchange
diffie_hellman()
