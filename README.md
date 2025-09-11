# Adonis-AntiCheat-Bypass
A simple &amp; undetected bypass for the Adonis "Anti" & "Anti-Cheat" module.

# Required Functions
The following UNC & sUNC functions are required:

1. filtergc: For retrieving adonis-related closures from the garbage collector
2. hookfunction: For detouring adonis-related closures
3. getrenv: Optional - to let us guarantee we hook the experiences debug.info function, and not one that the executor may have overriden

# Required Globals
These globals are not provided and must be reimplemented by you:

1. LocalClient: The local player of the game
2. REnv: The roblox environment
3. Hooks: A hooking module that wraps around hookfunction()

# How The Detections Work

Adonis is an admin script that experience developers can use freely, that also comes packed with optional code designed to curb cheating. The 2 modules "Anti" and "Anti Cheat" are responsible for this, and serve 2 different yet similar purposes:

1. The **Anti** module appears to be an **anti exploit** module, targeting executors or poor scripts directly.
2. The **Anti Cheat** module appears to be just that, an **anti cheat**, checking for speed hacks, noclip, anti-idle, and more, *locally*.

Both of these modules will rely on the same function to report detections to the server, called **Detected**. It is an anonymous function that is defined inside the **Anti** module:

<img width="1599" height="310" alt="Detected Function Code" src="https://github.com/user-attachments/assets/f534575a-9ea8-4273-b351-32065462c414" />


When called, it will call the network **Send** function to let the server know about the detection. Half a second after reporting the detection, it will check if the caller wanted to kick you or crash your game.

Adonis will also protect it's Detected function using **debug.info**. It will first cache all information about the **Detected** function on startup (like source identifier, line number, argument count, etc). It will then continuously call **debug.info** and compare the results with the 1st cached result.

This works because the **Detected** function is a *lua closure*. Depending on how your executor performs hooking, the function itself will likely have to be modified in some way to make it jump to the desired detour (which might be a wrapped *c closure* automatically on some executors) when called. Whether this detection is effective or not will depend on your executor and their method of hooking lua closures. When Adonis detects any change with the functions info, it will crash itself:

<img width="881" height="308" alt="Hook Detection Code" src="https://github.com/user-attachments/assets/408bfa5b-549e-4038-adf6-daf4fbefa79c" />


# Bypassing

In order to bypass this, we must first find the "Detected" function. We can do that by scanning the garbage collector using **filtergc**, which will find the **Detected** function based on the input given to it.

We see it has 2 easy strings, " - On Xbox" and " - On mobile". Strings like these are **constants**, they will never change, so we will give these constants to **filtergc**. They should be unique enough and we will only get 1 result back.

You can also pass in the SHA-384 hash of the **Detected** function, however, this is considerably slower. In order to find a function by its hash, the executor must first hash every single function it finds to compare it with the input hash. This means your executor must perform *x* hashes where `x = gc function count`, which can be super slow or fast, completely depending on the experience Adonis is being used in.

Even though the executor is likely hashing on the C++ side, when hashing such large quantities, you will notice your game freezing for several seconds. You may find an example of how your executor hashes functions [by clicking here.](https://rubis.app/view/?scrap=mwDweOS6zirsPJtc&type=cpp)

After we find the **Detected** function, we must first cache & hook the **debug.info** function to bypass hook checks. To do so, we can call **debug.info** on the **Detected** function, store all the results into locals, and then create a detour for **debug.info**. We check if the input is **Detected**, which means a caller would like information about the **Detected** function, and if so we return the previously cached locals. Otherwise, we call the original **debug.info** function.

Now that **debug.info** is hooked, we can simply detour **Detected** and make it yield infinitely when called (or just return instantly). Once done, you will no longer be detected by Adonis.

⚠️ If you choose to return instantly, you should make sure to return "true", as you can see below the hook-check related code will also check if **Detected** returns a non-truthy value.
<img width="881" height="308" alt="Hook Detection Code" src="https://github.com/user-attachments/assets/408bfa5b-549e-4038-adf6-daf4fbefa79c" />

You can find a proof of concept bypass [by clicking here.](https://github.com/GetRioToday/Adonis-AntiCheat-Bypass/blob/main/Bypass.lua)

# Why It's Effective

Adonis has many, many, detections in both it's **Anti** and **Anti-Cheat** module. Instead of targeting each detection, we can simply target the code responsible for the consequences & snitching.

This means that by blocking the **Detected** function, all the Adonis detections will still be running & working, it just cannot do anything about it, nor can it tell anyone about it.
