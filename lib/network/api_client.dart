import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:http/http.dart' as http;

const _kTimeout = Duration(seconds: 15);
const _kMaxRetries = 3;
const _kTag = 'ApiClient';
const _kBodyPreviewLimit = 600;

/// Centralized HTTP wrapper — 15 s timeout, up to 3 retries on transient errors.
///
/// Retry is triggered by: [SocketException], [TimeoutException], and
/// HTTP 503. Permanent client errors (4xx, etc.) are never retried.
class ApiClient {
  const ApiClient._();

  // ── GET ────────────────────────────────────────────────────────────────────

  static Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
  }) =>
      _send('GET', uri, () => http.get(uri, headers: _defaultHeaders(headers)));

  // ── POST ───────────────────────────────────────────────────────────────────

  static Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send(
        'POST',
        uri,
        () => http.post(uri, headers: _defaultHeaders(headers), body: body),
        requestBody: body,
      );

  // ── PUT ────────────────────────────────────────────────────────────────────

  static Future<http.Response> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send(
        'PUT',
        uri,
        () => http.put(uri, headers: _defaultHeaders(headers), body: body),
        requestBody: body,
      );

  // ── PATCH ──────────────────────────────────────────────────────────────────

  static Future<http.Response> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send(
        'PATCH',
        uri,
        () => http.patch(uri, headers: _defaultHeaders(headers), body: body),
        requestBody: body,
      );

  // ── Multipart (no retry — streams can't be replayed) ─────────────────────

  static Future<http.StreamedResponse> sendMultipart(
    http.MultipartRequest request,
  ) async {
    final fileNames = request.files.map((f) => f.filename ?? f.field).join(', ');
    dev.log(
      '→ ${request.method} ${request.url}  [multipart | files: $fileNames]',
      name: _kTag,
    );
    final sw = Stopwatch()..start();
    try {
      final response = await request.send().timeout(_kTimeout);
      sw.stop();
      dev.log(
        '← ${request.method} ${request.url}  [${response.statusCode}] ${sw.elapsedMilliseconds}ms',
        name: _kTag,
      );
      return response;
    } on SocketException catch (e) {
      sw.stop();
      dev.log('✗ No internet (${sw.elapsedMilliseconds}ms): $e', name: _kTag);
      throw const NetworkException('No internet connection');
    } on TimeoutException catch (e) {
      sw.stop();
      dev.log('✗ Upload timed out (${sw.elapsedMilliseconds}ms): $e', name: _kTag);
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
    final bodySnippet = requestBody != null
        ? _truncate(requestBody.toString(), 300)
        : null;

    dev.log(
      '→ $method $uri${bodySnippet != null ? '\n  body: $bodySnippet' : ''}',
      name: _kTag,
    );

    int tries = 0;

    while (true) {
      tries++;
      final sw = Stopwatch()..start();

      try {
        final response = await attempt().timeout(_kTimeout);
        sw.stop();

        final preview = _truncate(response.body, _kBodyPreviewLimit);
        dev.log(
          '← $method $uri  [${response.statusCode}] ${sw.elapsedMilliseconds}ms\n'
          '  body: $preview',
          name: _kTag,
        );

        if (response.statusCode == 503 && tries < _kMaxRetries) {
          dev.log(
            '⚠ 503 — retry $tries/$_kMaxRetries after backoff',
            name: _kTag,
          );
          await _backoff(tries);
          continue;
        }

        return response;
      } on SocketException catch (e) {
        sw.stop();
        dev.log(
          '✗ No internet [$tries/$_kMaxRetries] ${sw.elapsedMilliseconds}ms: $e',
          name: _kTag,
        );
        if (tries >= _kMaxRetries) {
          throw const NetworkException('No internet connection. Please check your network.');
        }
        await _backoff(tries);
      } on TimeoutException catch (e) {
        sw.stop();
        dev.log(
          '✗ Timeout [$tries/$_kMaxRetries] ${sw.elapsedMilliseconds}ms: $e',
          name: _kTag,
        );
        if (tries >= _kMaxRetries) {
          throw const NetworkException('Request timed out. Please try again.');
        }
        await _backoff(tries);
      } on HandshakeException catch (e) {
        sw.stop();
        dev.log('✗ SSL/TLS error ${sw.elapsedMilliseconds}ms: $e', name: _kTag);
        throw NetworkException('Secure connection failed: ${e.message}');
      }
    }
  }

  static Future<void> _backoff(int attempt) =>
      Future.delayed(Duration(milliseconds: 500 * attempt));

  static Map<String, String> _defaultHeaders(Map<String, String>? extra) => {
        'Content-Type': 'application/json',
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
