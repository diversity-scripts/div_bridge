## 🚀 Overview
A high-performance, standardized dependency library designed to unify the FiveM development ecosystem. By bridging the gap between major frameworks (ESX, QBCore), inventory systems (ox, QS, Core) and other resources, it provides a consistent API that allows developers to write code once and deploy it anywhere.

## 🌟 Features
- **Framework Agnostic:** Seamlessly auto-detects ESX or QBCore environments on startup with zero configuration required.
- **Inventory Integration:** Out-of-the-box support for ox_inventory, qs-inventory, and native framework systems.
- **Optimized Performance:** Built on a Singleton Pattern to minimize memory overhead and eliminate redundant logic across your resources.
- **Smart Notifications:** Automatically routes alerts through ox_lib (if available) or other supported resource, falling back to native GTA V notifications otherwise.

## 🛠️ Installation
1. Download the latest release of `div_bridge` resource.
2. Extract the folder into your server's `resources` directory.
3. Add the following line to your server.cfg. **It is crucial that this starts BEFORE any script that depends on it.**
```
ensure ox_lib       # If you use it
ensure es_extended  # OR ensure qb-core
ensure div_bridge   # <--- MUST LOAD HERE
ensure [my_scripts]
```

## Supported Frameworks
- [ESX](https://github.com/esx-framework/esx_core)
- [QBCore](https://github.com/qbcore-framework/qb-core)
- [Qbox](https://github.com/Qbox-project/qbx_core)
- [ox_core](https://github.com/CommunityOx/ox_core)
- [TMC](https://store.tmc.bj/category/frameworks)

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
> All framework integrated inventories are also supported.

## Database Resources
- [oxmysql](https://github.com/CommunityOx/oxmysql)
- [mysql-async](https://github.com/brouznouf/fivem-mysql-async)
- ghmattimysql

## Supported Interaction Systems (External)
- [ox_target](https://github.com/CommunityOx/ox_target)
- [qb-target](https://github.com/qbcore-framework/qb-target)
- [qtarget](https://github.com/overextended/qtarget?tab=readme-ov-file) (deprecated)
- [bt-target](https://github.com/brentN5/bt-target) (deprecated)

## Interaction Systems (Internal)
- 3D text
- GTA V native hint

## Notification Systems
- [ox_lib](https://github.com/CommunityOx/ox_lib)
- codem-notification
- okokNotify
- mythic_notify
- 17mov_Hud
> All framework integrated notification systems are also supported.

## 📄 Licensing & Usage
This library is a dedicated dependency for all our resources.
- **Permissions:** You are encouraged to view and modify the code to suit your server's specific requirements.
- **Restrictions:** You may not claim this code as your own, redistribute it, or resell it as a standalone product.

## ⤴️ Pull Requests
We welcome community contributions! If you are a developer looking to enhance `div_bridge`, whether by optimizing existing logic or adding support for a custom framework or inventory system - we’d love to see your work.
- **Fork** the repository.
- **Commit** your changes with clear, descriptive notes.
- **Submit** a **Pull Request**.

Our team will review all submissions and merge those that provide significant value to the community.
