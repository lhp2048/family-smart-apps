# family-bot-app

家庭智能中心 Flutter 客户端；本地工程目录名为 `family_smart_center`，**GitHub 仓库名为 `family-bot-app`**。

数据来自 [family_smart_datacenter](../family_smart_datacenter/)（默认 `:18025`）；设置里配置服务器地址与 API KEY 即可接入。

## 家庭服务端口

| 服务 | 端口 |
|------|------|
| Web 门户 `family_smart_center_web` | 18024（宣传 + 管理 + 安装升级） |
| 数据中心 `family_smart_datacenter` | 18025 |
| **本 App Web 部署**（Mac zip 解压） | **18027** |

## 接入 Datacenter

1. 确保 datacenter 已启动并可访问 `GET /api/v1/members`
2. App **设置** → 服务器：`http://<host>:18025`（仅站点根，不含 `/api/v1`）
3. **API KEY**：无鉴权环境留空；有鉴权时填 `X-API-Key`（写操作可用 Sync Key，见设置）
4. 保存并校验通过后，各页面从 datacenter 在线读数据

## 本 App 独立 Web 打包与部署（:18027）

Windows 一键构建并打包：

```bat
cd family_smart_apps
scripts\build_and_pack.bat
```

Mac / Linux：

```bash
cd family_smart_apps
chmod +x scripts/*.sh
./scripts/build_and_pack.sh
```

本地 Web 开发：

```bat
scripts\dev.bat
```

```bash
./scripts/dev.sh
```

输出：
- 构建：`family_smart_apps/build/web/`
- zip：`family_smart_apps/dist_out/family_smart_apps_web.zip`

解压后安装（三端通用）：

```bat
install.bat
```

```bash
./install.sh
# 或 ./service.sh install|start|stop|restart|status|uninstall
```

Mac 从 zip 升级：

```bash
./scripts/update_service_mac.sh ~/Downloads/family_smart_apps_web.zip ~/family_smart_apps_web
```

浏览器：`http://127.0.0.1:18027`

Web 构建已禁用 Service Worker（`--pwa-strategy=none`），并内置 SW/Cache 自动清理（保留 Local Storage）。Mac 升级后打开页面即可，**首次可能自动刷新一次**；之后普通刷新即可，不会清掉服务器地址等本地设置。

## 开发

```bash
flutter pub get
dart run tool/generate_build_stamp.dart
flutter run -d chrome    # Web
flutter run              # 移动端
```

## 契约

业务 API 见项目根目录 [后台API需求说明.md](../后台API需求说明.md)；写接口见 datacenter `POST /api/v1/sync/*`。
