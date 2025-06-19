# REVERSER (FOR KUBERNETES BASED REMOTE POD WORKSPACE)

` 
    A Reverse TCP for SSH to Pods directly Based on Source IP for cluster internal networking
    Can also be used for Layer 3 (OSI) / Layer 2 (TCP/IP) Load Balancing based on a particular CIDR
`

## HOW TO BUILD

* If you are a nix user use the nix derivation provided here to get native inputs needed for static executable
* Then do ` dune build --profile=release `
* strip ./_build/default/bin/main.exe && cp ./_build/default/bin/main.exe /to/your/system/path
* Make sure the reverser.toml is present in the reverser directory of your user home directory
* Example config is given here