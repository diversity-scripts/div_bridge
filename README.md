## 🚀 Overview
A high-performance, standardized dependency library designed to unify the FiveM development ecosystem. By bridging the gap between major frameworks (ESX, QBCore), inventory systems (ox, QS, Core) and other resources, it provides a consistent API that allows developers to write code once and deploy it anywhere.

## 🌟 Features
- **Framework Agnostic:** Seamlessly auto-detects frameworks (e.g.: ESX, QBCore) environments on startup with zero configuration required.
- **Inventory Integration:** Out-of-the-box support for inventories (e.g.: ox_inventory, qb-inventory), and native framework systems.
- **Optimized Performance:** Built on a Singleton Pattern to minimize memory overhead and eliminate redundant logic across your resources.
- **Smart Notifications:** Automatically routes alerts through supported resources, falling back to native GTA V notifications otherwise.

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
| Resource | Author / Maintainer | Price |
| :--- | :--- | :--- |
| [**ESX**](https://github.com/esx-framework/esx_core) | [@ESX](https://github.com/esx-framework) | `Free` |
| [**QBCore**](https://github.com/qbcore-framework/qb-core) | [@QBCore](https://github.com/qbcore-framework) | `Free` |
| [**Qbox**](https://github.com/Qbox-project/qbx_core) | [@Qbox Project](https://github.com/Qbox-project) | `Free` |
| [**ox_core**](https://github.com/CommunityOx/ox_core) | [@CommunityOx](https://github.com/CommunityOx) | `Free` |
| [**ND_Core**](https://github.com/ND-Framework/ND_Core) | [@ND Framework](https://github.com/ND-Framework) | `Free` |
| [**TMC**](https://store.tmc.bj/category/frameworks) | [@The Modding Collective](https://store.tmc.bj) | `Paid` |

## Supported Inventories
| Resource | Author / Maintainer | Compatibility | Price |
| :--- | :--- | :--- | :--- |
| [**ox_inventory**](https://github.com/CommunityOx/ox_inventory) | [@CommunityOx](https://github.com/CommunityOx) | `ESX / QB / ox_core / ND_Core` | `Free` |
| [**qs-inventory**](https://www.quasar-store.com/scripts/advancedinventory) | [@Quasar](https://www.quasar-store.com) | `ESX / QB / Qbox` | `Paid` |
| [**origen_inventory**](https://www.origennetwork.store/package/5881161) | [@Origen Network](https://www.origennetwork.store) | `ESX / QB` | `Paid` |
| [**tgiann-inventory**](https://tgiann.com/package/6273000) | [@Tgiann](https://www.tgiann.com) | `ESX / QB` | `Paid` |
| [**codem-inventory**](https://codem.tebex.io/package/5900973) | [@CodeM](https://codem.tebex.io) | `ESX / QB` | `Paid` |
| [**core_inventory**](https://core.tebex.io/package/5123274) | [@Core](https://core.tebex.io) | `ESX` | `Paid` |
| [**ps-inventory**](https://github.com/Project-Sloth/ps-inventory) | [@Project Sloth](https://github.com/Project-Sloth) | `QB` | `Free` |
| [**ak47_inventory**](https://menanak47.tebex.io/package/6436604) | [@MenanAK47](https://menanak47.tebex.io) | `ESX / QB` | `Paid` |
| [**chezza_inventory**](https://chezza.tebex.io/package/4770357) | [@Chezza Studios](https://chezza.tebex.io) | `ESX` | `Paid` |
> [!TIP]
> All framework-integrated inventories are also supported.

## Database Resources
| Resource | Author / Maintainer | Compatibility | Price |
| :--- | :--- | :--- | :--- |
| [**oxmysql**](https://github.com/CommunityOx/oxmysql) | [@CommunityOx](https://github.com/CommunityOx) | `Standalone` | `Free` |
| [**mysql-async**](https://github.com/brouznouf/fivem-mysql-async) | [@brouznouf](https://github.com/brouznouf) | `Standalone` | `Free` |
| [**ghmattimysql**](https://github.com/FrazzIe/ghmattimysql) | [@FrazzIe](https://github.com/FrazzIe) | `Standalone` | `Free` |

## Interaction Systems (External)
| Resource | Author / Maintainer | Compatibility | Price |
| :--- | :--- | :--- | :--- |
| [**ox_target**](https://github.com/CommunityOx/ox_target) | [@CommunityOx](https://github.com/CommunityOx) | `Standalone` | `Free` |
| [**qb-target**](https://github.com/qbcore-framework/qb-target) | [@QBCore](https://github.com/qbcore-framework) | `Standalone` | `Free` |
| [**core_focus**](https://www.c8re.store/package/6986459) | [@Core](https://core.tebex.io) | `ESX / QB` | `Paid` |

## Interaction Systems (Internal)
- **3D Text**: World-space coordinate text.
- **GTA V Native Hint**: Standard top-left help notifications.

## Notification Systems
| Resource | Author / Maintainer | Compatibility | Price |
| :--- | :--- | :--- | :--- |
| [**ox_lib**](https://github.com/CommunityOx/ox_lib) | [@CommunityOx](https://github.com/CommunityOx) | `Standalone` | `Free` |
| [**okokNotify**](https://okok.tebex.io/package/4724993) | [@okok Scripts](https://okok.tebex.io) | `Standalone` | `Paid` |
| [**mythic_notify**](https://github.com/JayMontana36/mythic_notify) | [@JayMontana36](https://github.com/JayMontana36) | `Standalone` | `Free` |
| [**pNotify**](https://github.com/Nick78111/pNotify) | [@Nick78111](https://github.com/Nick78111) | `Standalone` | `Free` |
| [**17mov_Hud**](https://17movement.net/scripts/6020650) | [@17 Movement](https://17movement.net) | `Standalone` | `Paid` |
| [**codem-notification**](https://codem.tebex.io/package/5399171) | [@CodeM](https://codem.tebex.io) | `Standalone` | `Paid` |
> [!TIP]
> All framework-integrated notification systems are also supported.

## TextUI Systems
| Resource | Author / Maintainer | Compatibility | Price |
| :--- | :--- | :--- | :--- |
| [**ox_lib**](https://github.com/CommunityOx/ox_lib) | [@CommunityOx](https://github.com/CommunityOx) | `Standalone` | `Free` |
| [**jg-textui**](https://github.com/jgscripts/jg-textui) | [@jgscripts](https://github.com/jgscripts) | `Standalone` | `Free` |
| [**okokTextUI**](https://okok.tebex.io/package/6024831) | [@okok Scripts](https://okok.tebex.io) | `Standalone` | `Paid` |
| [**cd_drawtextui**](https://github.com/dsheedes/cd_drawtextui) | [@dsheedes](https://github.com/dsheedes) | `Standalone` | `Free` |
| [**codem-textui**](https://codem.tebex.io/package/5984937) | [@CodeM](https://codem.tebex.io) | `Standalone` | `Paid` |
| [**brutal_textui**](https://store.brutalscripts.com/product/6411668) | [@Brutal Scripts](https://store.brutalscripts.com) | `Standalone` | `Paid` |
> [!TIP]
> All framework-integrated textui systems are also supported.

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
