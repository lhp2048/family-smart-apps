# family-bot-app

家庭智能中心 Flutter 客户端；本地工程目录名为 `family_smart_center`，**GitHub 仓库名为 `family-bot-app`**。

数据来自 [family_smart_datacenter](../family_smart_datacenter/)（默认 `:18025`）；设置里配置服务器地址与 API KEY 即可接入。

## 家庭服务端口

| 服务 | 端口 |
|------|------|
| AI 服务 `family_smart_center_server` | 18024 |
| 数据中心 `family_smart_datacenter` | 18025 |
| **本 App Web 静态站** | **18027** |

## 接入 Datacenter

1. 确保 datacenter 已启动并可访问 `GET /api/v1/members`
2. App **设置** → 服务器：`http://<host>:18025`（仅站点根，不含 `/api/v1`）
3. **API KEY**：无鉴权环境留空；有鉴权时填 `X-API-Key`（写操作可用 Sync Key，见设置）
4. 保存并校验通过后，各页面从 datacenter 在线读数据

## Web 只读发布（macOS）

Web 端自动只读（`kIsWeb`）：仅展示数据，不可勾选作业、不可切换心愿。移动端保留写能力。

```bash
cd family_smart_center
chmod +x scripts/build_web_mac.sh scripts/serve_web_mac.sh
./scripts/build_web_mac.sh
./scripts/serve_web_mac.sh
```

浏览器打开 `http://127.0.0.1:18027`（局域网用 Mac IP）。Safari 可「添加到程序坞」作为 PWA。

**运行时依赖**：已构建的 `build/web/` + Python 3 托管静态站；真实数据还需 datacenter `:18025` 同时运行。

## 开发

```bash
flutter pub get
dart run tool/generate_build_stamp.dart
flutter run -d chrome    # Web
flutter run              # 移动端
```

## 契约

业务 API 见项目根目录 [后台API需求说明.md](../后台API需求说明.md)；写接口见 datacenter `POST /api/v1/sync/*`。
