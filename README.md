# DSTServerUpdateDetector
An update detecting routine that can be seamlessly copy-pasted into customcommands.lua files anywhere.

The idea of this is to be self-contained to the process to make the game quit after notifying players on the server about its intention.
A watchdog script should be used to handle the OS-specific aspect of seeing that the server instances have quit and then use their platform, such as Steam, to try to update the game binaries before launching the server processes up again.

I am providing it here to help the community dedicated server administrators keep their servers up to date and am licensing it under MIT in the hopes it will be useful.

# customcommands.lua
Inside of the server's cluster folder is the following layout for a typical DST server with the customcommands.lua file placed where the game reads it:
```
cluster/
  Master/
    server.ini
    worldgenoverride.lua
    customcommands.lua
  Caves/
    server.ini
    worldgenoverride.lua
    customcommands.lua
  cluster.ini
  cluster_token.txt
