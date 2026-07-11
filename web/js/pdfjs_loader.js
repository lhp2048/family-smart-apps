(function () {
  var PDFJS_VERSION = '4.6.82';
  var CDN = 'https://cdn.jsdelivr.net/npm/pdfjs-dist@' + PDFJS_VERSION;
  var LOCAL_BASE = 'vendor/pdfjs-dist';
  var SCRIPT_SELECTOR = 'script[data-family-pdfjs="1"]';
  var loadPromise = null;
  var activeBase = CDN;

  if (!globalThis.pdfRenderOptions) {
    globalThis.pdfRenderOptions = {
      cMapUrl: CDN + '/cmaps/',
      cMapPacked: true,
    };
  }
  if (!globalThis.pdfjsLib) {
    globalThis.pdfjsLib = { GlobalWorkerOptions: {} };
  }

  function isRealPdfJsReady() {
    return !!(
      globalThis.pdfjsLib &&
      typeof globalThis.pdfjsLib.getDocument === 'function'
    );
  }

  function configurePdfJs(base) {
    activeBase = base;
    var pdfjsLib = globalThis.pdfjsLib;
    if (!pdfjsLib || typeof pdfjsLib.getDocument !== 'function') {
      throw new Error('pdfjsLib missing after pdf.min.mjs load');
    }
    pdfjsLib.GlobalWorkerOptions.workerSrc = base + '/build/pdf.worker.mjs';
    globalThis.pdfRenderOptions = {
      cMapUrl: CDN + '/cmaps/',
      cMapPacked: true,
    };
  }

  function injectPdfScript(src, base) {
    return new Promise(function (resolve, reject) {
      function finish() {
        try {
          configurePdfJs(base);
          resolve();
        } catch (err) {
          reject(err);
        }
      }

      var existing = document.querySelector(SCRIPT_SELECTOR);
      if (existing) {
        if (isRealPdfJsReady()) {
          finish();
          return;
        }
        existing.addEventListener('load', finish, { once: true });
        existing.addEventListener(
          'error',
          function () {
            reject(new Error('Failed to load pdf.min.mjs'));
          },
          { once: true }
        );
        return;
      }

      var script = document.createElement('script');
      script.type = 'module';
      script.src = src;
      script.dataset.familyPdfjs = '1';
      script.onload = finish;
      script.onerror = function () {
        reject(new Error('Failed to load pdf.min.mjs: ' + src));
      };
      document.head.appendChild(script);
    });
  }

  function loadRealPdfJs() {
    if (isRealPdfJsReady()) {
      return Promise.resolve();
    }
    if (loadPromise) {
      return loadPromise;
    }

    loadPromise = injectPdfScript(CDN + '/build/pdf.min.mjs', CDN)
      .catch(function () {
        var stale = document.querySelector(SCRIPT_SELECTOR);
        if (stale) {
          stale.remove();
        }
        return injectPdfScript(LOCAL_BASE + '/build/pdf.min.mjs', LOCAL_BASE);
      })
      .catch(function (err) {
        loadPromise = null;
        throw err;
      });

    return loadPromise;
  }

  window.ensureFamilyPdfJs = loadRealPdfJs;

  /**
   * Open PDF from HTTP(S) URL with Range + disableAutoFetch (no full-file prefetch).
   * Called from Dart pdfx fork — options must be plain JS objects for pdf.js 4.x.
   */
  window.familyPdfJsGetDocumentUrl = function (url, password, onProgressFn) {
    return loadRealPdfJs().then(function () {
      var pdfjsLib = globalThis.pdfjsLib;
      var opts = globalThis.pdfRenderOptions || {};
      var task = pdfjsLib.getDocument({
        url: url,
        password: password || undefined,
        cMapUrl: opts.cMapUrl || activeBase + '/cmaps/',
        cMapPacked: opts.cMapPacked !== false,
        // disableStream MUST be true for multi-request Range (206).
        // false = one HTTP 200 that streams the entire file (what Network tab showed).
        disableRange: false,
        disableStream: true,
        disableAutoFetch: true,
        withCredentials: false,
        rangeChunkSize: 262144,
      });
      if (typeof onProgressFn === 'function') {
        task.onProgress = function (p) {
          onProgressFn(p.loaded, p.total || 0);
        };
      }
      return task.promise;
    });
  };
})();
