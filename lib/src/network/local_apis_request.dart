import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import 'package:local_function_collections/src/models/upload_file.dart';
import 'package:local_function_collections/src/utils/local_typedefs.dart';

class LocalAPIsRequest {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  /// Direct access to the underlying [Dio] instance.
  static Dio get dio => _dio;

  /// Setup Certificate Pinning
  ///
  /// Enables SSL/TLS certificate pinning using SHA-256 fingerprints to protect
  /// against Man-In-The-Middle (MITM) attacks.
  ///
  /// Parameters:
  /// * [allowedSHAFingerprints] (Required): SHA-256 fingerprints of valid leaf certificates.
  ///   Colons and spaces are automatically stripped and normalized to lowercase.
  /// * [allowedHosts] (Optional): List of allowed hostnames (e.g. `['api.example.com']`).
  ///   If supplied, certificates will only be accepted when connecting to these hosts.
  static void setupCertificatePinning(
    List<String> allowedSHAFingerprints, {
    List<String>? allowedHosts,
  }) {
    if (kIsWeb) return;

    if (_dio.httpClientAdapter is IOHttpClientAdapter) {
      final cleanAllowedPins = allowedSHAFingerprints
          .map((pin) => pin.replaceAll(':', '').replaceAll(' ', '').toLowerCase())
          .toSet();

      final hostSet = allowedHosts?.map((h) => h.toLowerCase()).toSet();

      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final HttpClient client = HttpClient(
          context: SecurityContext(withTrustedRoots: false),
        );

        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          if (hostSet != null && !hostSet.contains(host.toLowerCase())) {
            assert(() {
              debugPrint('⚠️ [LocalAPIsRequest] Host "$host" is not in allowedHosts: $hostSet');
              return true;
            }());
            return false;
          }

          final Uint8List certBytes = cert.der;
          final Digest sha256Digest = sha256.convert(certBytes);
          final serverFingerprint = sha256Digest.toString().toLowerCase();

          if (cleanAllowedPins.contains(serverFingerprint)) {
            return true;
          }

          assert(() {
            debugPrint('⚠️ [LocalAPIsRequest] Certificate Pinning Mismatch!');
            debugPrint('Expected one of: $cleanAllowedPins');
            debugPrint('Received server fingerprint: $serverFingerprint');
            return true;
          }());

          return false;
        };

        return client;
      };
    }
  }

  /// Adds a list of Interceptors to the Dio instance.
  static void addInterceptors(List<Interceptor> interceptors) {
    _dio.interceptors.addAll(interceptors);
  }

  /// Clears all interceptors from the Dio instance.
  static void clearInterceptors() {
    _dio.interceptors.clear();
  }

  /// Submit Request
  ///
  /// Handles a network request using Dio.
  ///
  /// Parameters:
  /// * [requestType] (Required): GET, POST, PUT, PATCH, or DELETE.
  /// * [apisURL] (Required): Target API endpoint URL.
  /// * [headerRequest] (Optional): HTTP headers map.
  /// * [parameters] (Optional): Query parameters.
  /// * [bodyData] (Optional): Request body data.
  /// * [connectionTimeoutInSecond] (Optional): Timeout in seconds to establish connection.
  /// * [sendTimeoutInSecond] (Optional): Timeout in seconds for sending request payload.
  /// * [receiveTimeoutInSecond] (Optional): Timeout in seconds for receiving response data.
  /// * [usePreserveHeaderCase] (Optional): Preserve original header casing.
  /// * [cancelToken] (Optional): Dio CancelToken for cancelling the request.
  /// * [errorHandler] (Optional): Custom error handler callback.
  /// * [files] (Optional): [UploadFile] for multipart file uploads (supports POST, PUT, and PATCH).
  /// * [withCredentials] (Optional): Enable credentials flag for web requests.
  /// * [responseType] (Optional): Customize Dio response format (JSON, bytes, plain, stream).
  /// * [contentType] (Optional): Custom Content-Type header.
  static Future<Response<T>?> submitRequest<T>({
    required RequestType requestType,
    required String apisURL,
    Map<String, dynamic>? headerRequest,
    Map<String, dynamic>? parameters,
    dynamic bodyData,
    int? connectionTimeoutInSecond,
    int? sendTimeoutInSecond,
    int? receiveTimeoutInSecond,
    bool? usePreserveHeaderCase,
    CancelToken? cancelToken,
    HttpErrorHandler? errorHandler,
    UploadFile? files,
    bool withCredentials = false,
    ResponseType? responseType,
    String? contentType,
  }) async {
    final Options requestOption = Options(
      headers: headerRequest,
      preserveHeaderCase: usePreserveHeaderCase,
      connectTimeout: connectionTimeoutInSecond != null
          ? Duration(seconds: connectionTimeoutInSecond)
          : _dio.options.connectTimeout,
      sendTimeout: sendTimeoutInSecond != null
          ? Duration(seconds: sendTimeoutInSecond)
          : (connectionTimeoutInSecond != null
              ? Duration(seconds: connectionTimeoutInSecond)
              : _dio.options.sendTimeout),
      receiveTimeout: receiveTimeoutInSecond != null
          ? Duration(seconds: receiveTimeoutInSecond)
          : _dio.options.receiveTimeout,
      extra: {
        'withCredentials': withCredentials,
      },
      responseType: responseType,
      contentType: contentType,
    );

    Response<T>? response;

    try {
      dynamic requestData = bodyData;

      final bool hasFiles = files != null &&
          (files.files.isNotEmpty || files.rawFiles.isNotEmpty);

      final bool canHaveFiles = requestType == RequestType.post ||
          requestType == RequestType.put ||
          requestType == RequestType.patch;

      if (canHaveFiles && hasFiles) {
        requestData = _buildFormData(
          files,
          bodyData is Map<String, dynamic> ? bodyData : null,
        );
      }

      switch (requestType) {
        case RequestType.get:
          response = await _dio.get<T>(
            apisURL,
            options: requestOption,
            queryParameters: parameters,
            cancelToken: cancelToken,
          );
          break;
        case RequestType.post:
          response = await _dio.post<T>(
            apisURL,
            options: requestOption,
            queryParameters: parameters,
            data: requestData,
            cancelToken: cancelToken,
          );
          break;
        case RequestType.put:
          response = await _dio.put<T>(
            apisURL,
            options: requestOption,
            queryParameters: parameters,
            data: requestData,
            cancelToken: cancelToken,
          );
          break;
        case RequestType.patch:
          response = await _dio.patch<T>(
            apisURL,
            options: requestOption,
            queryParameters: parameters,
            data: requestData,
            cancelToken: cancelToken,
          );
          break;
        case RequestType.delete:
          response = await _dio.delete<T>(
            apisURL,
            options: requestOption,
            queryParameters: parameters,
            data: bodyData,
            cancelToken: cancelToken,
          );
          break;
      }
    } on DioException catch (err, stackTrace) {
      if (err.type == DioExceptionType.cancel) {
        return err.response as Response<T>?;
      }

      if (errorHandler != null) {
        errorHandler(err, stackTrace);
      }

      response = err.response as Response<T>?;
    } catch (e) {
      rethrow;
    }

    return response;
  }

  static FormData _buildFormData(
    UploadFile files,
    Map<String, dynamic>? bodyData,
  ) {
    final mergedData = Map<String, dynamic>.from(bodyData ?? {});
    final List<MultipartFile> allMultipartFiles = [];

    if (files.rawFiles.isNotEmpty) {
      allMultipartFiles.addAll(files.rawFiles);
    }

    if (!kIsWeb && files.files.isNotEmpty) {
      for (final file in files.files) {
        allMultipartFiles.add(MultipartFile.fromFileSync(file.path));
      }
    }

    if (files.isSingleFile && allMultipartFiles.isNotEmpty) {
      mergedData[files.fileParameterName] = allMultipartFiles.first;
    } else if (files.isArrayKeyMethod) {
      mergedData.addEntries(
        allMultipartFiles.asMap().entries.map((entry) => MapEntry(
          "${files.fileParameterName}[${entry.key}]",
          entry.value,
        )),
      );
    } else {
      mergedData[files.fileParameterName] = allMultipartFiles;
    }

    return FormData.fromMap(mergedData);
  }
}
