# CIDR Facts module

*Define facts by network zone.*

This module allows you to define attributes of many network zones and combine them into a single fact for each server.

It is very common for custom facts to be determined based on the network zone that a machine is in. However creating a new custom fact for each attribute that can be determined by IP address can be extremely tedious and the logic can become extremely complex, especially if your network is not straightforward. *i.e. If 10.36.x.x is production, with the exception of 10.36.12.x, which is UAT*

## How it works

This module works by reading json files from the `lib/facter/cidr.d` directory. These files are added to a custom module and are distributed to each node using pluginsync. Each JSON file contains a hash of the following structure:

```json
{
  "CIDR": {
    "some_fact": "some_value"
  }
}
```

The data from all `.json` files is merged and the facts that apply to a given node are returned. If a node is part of multiple CIDR ranges that define the same fact, the most specific (smallest) range will take precedence. Here is a real life example:

```json
{
  "10.23.0.0/16": {
    "datacenter": "kyabram"
  },
  "10.23.18.0/24": {
    "zone": "DMZ",
    "owner": "Dylan"
  },
  "10.23.18.192/26": {
    "zone": "SUPER-DMZ",
    "compliance_level": "excruciating"
  }
}
```

Given the above data, a node with the IP `10.23.18.212` would have the following facts:

```json
{
  "datacenter": "kyabram",
  "owner": "Dylan",
  "zone": "SUPER-DMZ",
  "compliance_level": "excruciating"
}
```
