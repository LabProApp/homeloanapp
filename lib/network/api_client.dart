import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:http/http.dart' as http;

const _kTimeout = Duration(seconds: 15);
const _kMaxRetries = 3;
const _tag = 'ApiClient';

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
      _send(() => http.get(uri, headers: _defaultHeaders(headers)));

  // ── POST ───────────────────────────────────────────────────────────────────

  static Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send(() => http.post(uri, headers: _defaultHeaders(headers), body: body));

  // ── PUT ────────────────────────────────────────────────────────────────────

  static Future<http.Response> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send(() => http.put(uri, headers: _defaultHeaders(headers), body: body));

  // ── PATCH ──────────────────────────────────────────────────────────────────

  static Future<http.Response> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send(
          () => http.patch(uri, headers: _defaultHeaders(headers), body: body));

  // ── Multipart (no retry — streams can't be replayed) ─────────────────────

  static Future<http.StreamedResponse> sendMultipart(
    http.MultipartRequest request,
  ) async {
    try {
      return await request.send().timeout(_kTimeout);
    } on SocketException {
      developer.log('No internet connection', name: _tag);
      throw const NetworkException('No internet connection');
    } on TimeoutException {
      developer.log('Upload timed out', name: _tag);
      throw const NetworkException('Upload timed out. Please try again.');
    }
  }

  // ── Core retry loop ────────────────────────────────────────────────────────

  static Future<http.Response> _send(
    Future<http.Response> Function() attempt,
  ) async {
    int tries = 0;

    while (true) {
      tries++;
      try {
        final response = await attempt().timeout(_kTimeout);

        if (response.statusCode == 503 && tries < _kMaxRetries) {
          developer.log(
            'Server unavailable — retry $tries/$_kMaxRetries',
            name: _tag,
          );
          await _backoff(tries);
          continue;
        }

        return response;
      } on SocketException catch (e) {
        developer.log('No internet ($tries/$_kMaxRetries): $e', name: _tag);
        if (tries >= _kMaxRetries) {
          throw const NetworkException('No internet connection. Please check your network.');
        }
        await _backoff(tries);
      } on TimeoutException catch (e) {
        developer.log('Timeout ($tries/$_kMaxRetries): $e', name: _tag);
        if (tries >= _kMaxRetries) {
          throw const NetworkException('Request timed out. Please try again.');
        }
        await _backoff(tries);
      } on HandshakeException catch (e) {
        developer.log('SSL/TLS error: $e', name: _tag);
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
}

/// Thrown for any network-level failure (no connectivity, timeout, SSL).
/// Screens catch this to show the full-page [NetworkErrorScreen].
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => message;
}
