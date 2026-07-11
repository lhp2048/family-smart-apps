/// Optional callback while pdf.js loads a PDF from HTTP URL (Web only).
typedef PdfjsUrlLoadProgressCallback = void Function(int loaded, int total);

/// Per-open progress scope — supports concurrent PDF URL loads on Web.
///
/// [start] registers a callback and hands off a session id to the next
/// [pdfjsGetDocument] call (sync handoff). Progress events dispatch only
/// to the session id captured in that task's `onProgress` closure.
class PdfjsUrlLoadProgressScope {
  PdfjsUrlLoadProgressScope._(this.sessionId);

  final int sessionId;

  static int _nextId = 0;
  static final Map<int, PdfjsUrlLoadProgressCallback> _sessions = {};
  static int? _handoffSessionId;

  /// Registers [callback] and prepares handoff for the next URL open.
  static PdfjsUrlLoadProgressScope start(
    PdfjsUrlLoadProgressCallback? callback,
  ) {
    if (callback == null) {
      return PdfjsUrlLoadProgressScope._(-1);
    }
    final id = ++_nextId;
    _sessions[id] = callback;
    _handoffSessionId = id;
    return PdfjsUrlLoadProgressScope._(id);
  }

  /// Removes this session when the open future completes.
  void end() {
    if (sessionId >= 0) {
      _sessions.remove(sessionId);
    }
  }

  /// Consumed synchronously by [pdfjsGetDocument] when creating the load task.
  static int consumeHandoffSessionId() {
    final id = _handoffSessionId ?? -1;
    _handoffSessionId = null;
    return id;
  }

  static void dispatch(int sessionId, int loaded, int total) {
    _sessions[sessionId]?.call(loaded, total);
  }
}
