import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:http/http.dart' as http;

const _kTimeout = Duration(seconds: 15);
const _kMaxRetries = 3;
const _kTag = 'API';
const _kBodyPreviewLimit = 4000;
const _kSep = '─────────────────────────────────────────────────────────────────';

/// Centralized HTTP wrapper — 15 s timeout, up to 3 retries on transient errors.
///
/// Retry is triggered by: [SocketException], [TimeoutException], and
/// HTTP 503. Permanent client errors (4xx, etc.) are never retried.
///
/// Call [setToken] after login / on app start to attach the JWT to every request.
/// Call [setToken] with null on logout to clear it.
class ApiClient {
  const ApiClient._();

  static String? _token;

  /// Called once when any authenticated request receives a 401 or 403.
  /// Wire this up in main.dart to clear prefs and redirect to login.
  static void Function()? onUnauthorized;

  /// Store or clear the JWT. Call after login, after auto-login from prefs, and on logout.
  static void setToken(String? token) => _token = token;

  // ── GET ────────────────────────────────────────────────────────────────────

  static Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
    bool authenticated = true,
  }) =>
      _send('GET', uri, () => http.get(uri, headers: _headers(headers, authenticated)));

  // ── POST ───────────────────────────────────────────────────────────────────

  static Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    bool authenticated = true,
  }) =>
      _send(
        'POST',
        uri,
        () => http.post(uri, headers: _headers(headers, authenticated), body: body),
        requestBody: body,
      );

  // ── PUT ────────────────────────────────────────────────────────────────────

  static Future<http.Response> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    bool authenticated = true,
  }) =>
      _send(
        'PUT',
        uri,
        () => http.put(uri, headers: _headers(headers, authenticated), body: body),
        requestBody: body,
      );

  // ── DELETE ─────────────────────────────────────────────────────────────────

  static Future<http.Response> delete(
    Uri uri, {
    Map<String, String>? headers,
    bool authenticated = true,
  }) =>
      _send('DELETE', uri, () => http.delete(uri, headers: _headers(headers, authenticated)));

  // ── PATCH ──────────────────────────────────────────────────────────────────

  static Future<http.Response> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    bool authenticated = true,
  }) =>
      _send(
        'PATCH',
        uri,
        () => http.patch(uri, headers: _headers(headers, authenticated), body: body),
        requestBody: body,
      );

  // ── Multipart (no retry — streams can't be replayed) ─────────────────────

  static Future<http.StreamedResponse> sendMultipart(
    http.MultipartRequest request,
  ) async {
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    final fileNames = request.files.map((f) => f.filename ?? f.field).join(', ');
    dev.log(
      '$_kSep\n'
      '→ ${request.method} ${request.url}\n'
      '   auth   : ${_token != null ? "Bearer [present]" : "none"}\n'
      '   files  : $fileNames',
      name: _kTag,
    );
    final sw = Stopwatch()..start();
    try {
      final response = await request.send().timeout(_kTimeout);
      sw.stop();
      dev.log(
        '← ${request.method} ${response.statusCode}  ${sw.elapsedMilliseconds}ms\n'
        '   url    : ${request.url}',
        name: _kTag,
      );
      return response;
    } on SocketException catch (e) {
      sw.stop();
      dev.log('✗ NO INTERNET (${sw.elapsedMilliseconds}ms): $e', name: _kTag);
      throw const NetworkException('No internet connection');
    } on TimeoutException catch (e) {
      sw.stop();
      dev.log('✗ UPLOAD TIMEOUT (${sw.elapsedMilliseconds}ms): $e', name: _kTag);
      throw const NetworkException('Upload timed out. Please try again.');
    }
  }

  // ── Core retry loop ────────────────────────────────────────────────────────

  static Future<http.Response> _send(
    String method,
    Uri uri,
    Future<http.Response> Function() attempt, {
    Object? requestBody,
  }) async {
    // ── Request ───────────────────────────────────────────────────────────────
    final bodyLine = requestBody != null
        ? '\n   body   : ${_truncate(requestBody.toString(), _kBodyPreviewLimit)}'
        : '';
    dev.log(
      '$_kSep\n'
      '→ $method $uri\n'
      '   auth   : ${_token != null ? "Bearer [present]" : "none"}'
      '$bodyLine',
      name: _kTag,
    );

    int tries = 0;

    while (true) {
      tries++;
      final sw = Stopwatch()..start();

      try {
        final response = await attempt().timeout(_kTimeout);
        sw.stop();

        // ── Response ──────────────────────────────────────────────────────────
        dev.log(
          '← $method ${response.statusCode}  ${sw.elapsedMilliseconds}ms\n'
          '   url    : $uri\n'
          '   body   : ${_truncate(response.body, _kBodyPreviewLimit)}',
          name: _kTag,
        );

        if (response.statusCode == 503 && tries < _kMaxRetries) {
          dev.log('⚠ 503 — retry $tries/$_kMaxRetries after backoff', name: _kTag);
          await _backoff(tries);
          continue;
        }

        if ((response.statusCode == 401 || response.statusCode == 403) &&
            _token != null) {
          dev.log('⚠ ${response.statusCode} Unauthorized — clearing session', name: _kTag);
          onUnauthorized?.call();
        }

        return response;
      } on SocketException catch (e) {
        sw.stop();
        dev.log(
          '✗ NO INTERNET [$tries/$_kMaxRetries] ${sw.elapsedMilliseconds}ms\n   $e',
          name: _kTag,
        );
        if (tries >= _kMaxRetries) {
          throw const NetworkException('No internet connection. Please check your network.');
        }
        await _backoff(tries);
      } on TimeoutException catch (e) {
        sw.stop();
        dev.log(
          '✗ TIMEOUT [$tries/$_kMaxRetries] ${sw.elapsedMilliseconds}ms\n   $e',
          name: _kTag,
        );
        if (tries >= _kMaxRetries) {
          throw const NetworkException('Request timed out. Please try again.');
        }
        await _backoff(tries);
      } on HandshakeException catch (e) {
        sw.stop();
        dev.log('✗ SSL/TLS ${sw.elapsedMilliseconds}ms\n   $e', name: _kTag);
        throw NetworkException('Secure connection failed: ${e.message}');
      }
    }
  }

  static Future<void> _backoff(int attempt) =>
      Future.delayed(Duration(milliseconds: 500 * attempt));

  static Map<String, String> _headers(Map<String, String>? extra, bool authenticated) => {
        'Content-Type': 'application/json',
        if (authenticated && _token != null) 'Authorization': 'Bearer $_token',
        ...?extra,
      };

  static String _truncate(String s, int limit) =>
      s.length <= limit ? s : '${s.substring(0, limit)}… (+${s.length - limit} chars)';
}

/// Thrown for any network-level failure (no connectivity, timeout, SSL).
/// Screens catch this to show the full-page [NetworkErrorScreen].
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => message;
}
