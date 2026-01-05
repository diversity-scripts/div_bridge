# div_lib
This is a standardized dependency library designed to bridge the gap between resources, frameworks (ESX, QBCore) and inventory systems (Ox, QS, Core). It also simplifies and adds additional helper functions to make creating of new scripts as easy and quick as possible.

## 🌟 Features
- **Framework Agnostic:** Auto-detects ESX and QBCore on startup.
- **Inventory Integration:** Built-in support for Ox Inventory, QS Inventory, and default framework inventories.
- **Performance:** Utilizes a singleton pattern to reduce memory usage and code duplication across scripts.
- **Unified Notifications:** Automatically routes notifications through Ox Lib (if available) or native framework notifications.

## 🛠️ Installation
1. Download the div_lib resource.
2. Extract the folder into your server's resources directory.
3. Add the following line to your server.cfg. **It is crucial that this starts BEFORE any script that depends on it.**
```
ensure ox_lib   # If you use it
ensure qb-core  # OR ensure qb-core
ensure div_lib  # <--- MUST LOAD HERE
ensure [my_scripts]
```

## Supported Frameworks
- [ESX](https://github.com/esx-framework/esx_core)
- [QBCore](https://github.com/qbcore-framework/qb-core)
- [Qbox](https://github.com/Qbox-project/qbx_core)
- [Ox Core](https://github.com/CommunityOx/ox_core)
- vRP
- TMC

## Supported Inventories
- [ox_inventory](https://github.com/CommunityOx/ox_inventory)
- [tgiann-inventory](https://tgiann.com/package/6273000)
- ak47_inventory
- codem-inventory
- core_inventory
- ps-inventory
- [qs-inventory](https://www.quasar-store.com/scripts/advancedinventory)
- origen_inventory
- chezza
> All framework integrated inventories also are supported.

## Supported Interaction Systems (External)
- [ox_target](https://github.com/CommunityOx/ox_target)
- qtarget
- qb-target

## Interaction Systems (Internal)
- 3D text
- GTA V native hint

## Notification Systems
- [ox_lib](https://github.com/CommunityOx/ox_lib)
- codem-notification
- okokNotify
- mythic_notify
- 17mov_Hud
> All framework integrated notification systems also are supported.

## Database Resources
- [oxmysql](https://github.com/CommunityOx/oxmysql)
- [mysql-async](https://github.com/brouznouf/fivem-mysql-async)
- ghmattimysql

## 📄 License
This library is provided as a dependency for my paid/free resources. You are free to view and edit the code for your server's needs, but you may not claim it as your own or resell it.

## ⤴️ Pull Requests
If you're a developer and wish to improve upon div_lib or add an integration to your own custom framework, inventory, or another kind of resource. Feel free to commit pull requests. We will review them and merge if we deem the changes as valuable.
