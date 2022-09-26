---
sidebar_position: 1
---

# Getting Started

All of this is ripped from RbxUtil's documentation because I'm lazy to write an actual intro document.

These Roblox utility modules can be acquired using [Wally](https://wally.run/), a package manager for Roblox.

## Wally Configuration
Once Wally is installed, run `wally init` on your project directory, and then add the various utility modules found here as dependencies. For example, the following could be a `wally.toml` file for a project that includes a few of these modules:
```toml
[package]
name = "your_name/your_project"
version = "0.1.0"
registry = "https://github.com/UpliftGames/wally-index"
realm = "shared"

[dependencies]
Attribute = "notfenv/attribute@^1"
```

To install these dependencies, run `wally install` within your project. Wally will create a Package folder in your directory with the installed dependencies.

## Rojo Configuration
The Package folder created by Wally should be synced into Roblox Studio through your Rojo configuration. For instance, a Rojo configuration might have the following entry to sync the Packages folder into ReplicatedStorage:
```json
{
	"name": "rbx-util-example",
	"tree": {
		"$className": "DataModel",
		"ReplicatedStorage": {
			"$className": "ReplicatedStorage",
			"Packages": {
				"$path": "Packages"
			}
		}
	}
}
```

## Usage Example
The installed dependencies can now be used in scripts, such as the following:
```lua
-- Reference folder with packages:
local Packages = game:GetService("ReplicatedStorage").Packages

-- Require the utility modules:
local Attribute = require(Packages.Attribute)

-- Use the modules:
local attribute = Attribute.new(object)
attribute.AttributeChanged:Connect(function(name, value)
    print(name, value)
end)
attribute:Set("Test", true)
```
