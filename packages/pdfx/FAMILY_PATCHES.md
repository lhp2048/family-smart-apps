# family-smart-apps pdfx fork 说明

基于上游 [pdfx 2.9.2](https://pub.dev/packages/pdfx)，通过 `pubspec.yaml` 的 `dependency_overrides` 指向 `packages/pdfx`。

## 为何 fork

上游 Web 端 `PdfDocument.openFile()` 未实现（抛 `UnimplementedError`），无法让 pdf.js 对 HTTP URL 做 Range 流式加载。家庭 App Web 阅读器需直接打开 mediacenter `public_url`，跳过 Dio 整包下载。

## 改动文件（升级时需 merge）

| 文件 | 改动 |
|------|------|
| `lib/src/renderer/web/platform.dart` | 实现 `openFile` → `pdfjsGetDocument(url)` + `_documents.register` |
| `lib/src/renderer/web/pdfjs.dart` | URL 经 `familyPdfJsGetDocumentUrl`：`disableRange: false`, **`disableStream: true`**, `disableAutoFetch: true` |
| `lib/src/renderer/web/url_load_progress.dart` | **新增** — `PdfjsUrlLoadProgressScope` 按 session 隔离并发 URL 加载进度 |
| `lib/src/viewer/simple/pdf_controller.dart` | 非 Exception 错误保留 `error.toString()`，不再显示 `Unknown error` |
| `lib/src/viewer/pinch/pdf_controller_pinch.dart` | 同上 |
| `lib/pdfx.dart` | export `url_load_progress.dart` |

## 升级步骤

1. 将上游 pdfx 新版本解压/复制到 `packages/pdfx`（或 diff 合并）
2. 按上表重新应用 patch
3. `flutter pub get` + `dart analyze lib/features/ebook`
4. Web 打开 PDF：Network 应见 **206 Partial Content**（多条小请求，而非一条撑满文件大小的 200）；首屏应早于 100% 进度出现

## mediacenter 依赖

`app/main.py` CORS 须 `expose_headers` 包含 `Accept-Ranges`, `Content-Length`, `Content-Range`，否则浏览器跨域时 pdf.js 无法检测 Range 支持，会退化为整包下载。

## 相关 App 代码

- `lib/features/ebook/data/pdf_document_open.dart` — 统一 `openFile` / `openData`，`PdfjsUrlLoadProgressScope` 管理进度
- `lib/features/ebook/data/pdf_streaming_mode.dart` — Web 启用 URL 流式
