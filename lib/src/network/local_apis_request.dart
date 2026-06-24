import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:local_function_collections/src/models/upload_file.dart';
import 'package:local_function_collections/src/utils/local_typedefs.dart';

class LocalAPIsRequest {
  static final Dio _dio = Dio();

  /// Submit Request
  ///
  /// This function will handle a network request using Dio
  ///
  /// Parameters:
  /// * Request Type (Required): Determine request type for submitting request (GET, POST, PUT or DELETE).
  /// * APIs URL (Required): URL required to reach APIs address.
  /// * Header Request (Optional): Header that set for request.
  /// * Parameters (Required): Query Parameter that will be carried when reaching APIs address.
  /// * Body Data (Required): Map of data that will be carried when reaching APIs address.
  /// * Connection Timeout in Second (Optional): Timeout set in second, to determined how long request could try reach the APIs address before it's declared as timeout.
  /// * Receive Timeout in Second (Optional): Timeout set in second, to determined how long response could received before it's declared as timeout.
  /// * Use Preserve Header Case (Optional): An option that used as parameter for determined if header need to be keep on sensitve case or not.
  /// * Cancel Token (Optional): If this request runs in the background and needs to handle cancellation, this parameter must be declared. If the request is cancelled, [errorHandler] and [onFinish] will be automatically bypassed to prevent UI race conditions.
  /// * Error Handler (Optional): Handling an error request and carried DioException and StackTrace result value. This will NOT be triggered if the request is cancelled using [cancelToken].
  /// * Upload File (Optional): An option that used when you want to upload a file, this parameter will using UploadFile class.
  /// * On Start (Optional): Callback function triggered immediately right before the API request is executed. Usually utilized to trigger loading state or spinner in UI.
  /// * On Finish (Optional): Callback function triggered when the API request has completely finished. This will NOT be triggered if the request is cancelled using [cancelToken], as the triggering UI is assumed to have been dismissed.
  static Future<Response?> submitRequest({
    required RequestType requestType,
    required String apisURL,
    Map<String, dynamic>? headerRequest,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? bodyData,
    int? connectionTimeoutInSecond,
    int? receiveTimeoutInSecond,
    bool? usePreserveHeaderCase,
    CancelToken? cancelToken,
    HttpErrorHandler? errorHandler,
    UploadFile? files,
    VoidCallback? onStart,
    VoidCallback? onFinish,
  }) async {
    _dio.options = BaseOptions(
      headers: headerRequest,
      preserveHeaderCase: usePreserveHeaderCase,
      connectTimeout: Duration(
        seconds: connectionTimeoutInSecond ?? 30,
      ),
      receiveTimeout: Duration(
        seconds: receiveTimeoutInSecond ?? 30,
      ),
    );

    if (onStart != null) onStart();

    bool isFinishCalled = false;

    try {
      Response? response;
      dynamic requestData = bodyData;

      if (requestType == RequestType.post && files != null && files.files.isNotEmpty) {
        requestData = _buildFormData(files, bodyData);
      }

      switch (requestType) {
        case RequestType.get:
          response = await _dio.get(
            apisURL,
            queryParameters: parameters,
            data: bodyData,
            cancelToken: cancelToken,
          );
          break;
        case RequestType.post:
          response = await _dio.post(
            apisURL,
            queryParameters: parameters,
            data: requestData,
            cancelToken: cancelToken,
          );
          break;
        case RequestType.put:
          response = await _dio.put(
            apisURL,
            queryParameters: parameters,
            data: bodyData,
            cancelToken: cancelToken,
          );
          break;
        case RequestType.delete:
          response = await _dio.delete(
            apisURL,
            queryParameters: parameters,
            data: bodyData,
            cancelToken: cancelToken,
          );
          break;
      }

      return response;
    } on DioException catch(err, stackTrace) {
      if (err.type == DioExceptionType.cancel) return err.response;

      if (onFinish != null) {
        onFinish();
        isFinishCalled = true;
      }

      if (errorHandler != null) {
        errorHandler(err, stackTrace);
      }

      return err.response;
    } catch(e) {
      rethrow;
    } finally {
      if (cancelToken?.isCancelled == true) {
        /// user already cancel this request
      } else {
        if (!isFinishCalled) {
          if (onFinish != null) onFinish();
        }
      }
    }
  }

  static FormData _buildFormData(UploadFile files, Map<String, dynamic>? bodyData) {
    final mergedData = Map<String, dynamic>.from(bodyData ?? {});

    if (files.isArrayKeyMethod) {
      mergedData.addEntries(
        files.files.asMap().entries.map(
              (entry) => MapEntry("${files.fileParameterName}[${entry.key}]", MultipartFile.fromFileSync(entry.value.path)),
        ),
      );
    } else {
      mergedData.addEntries(
        files.files.map((file) => MapEntry(
          files.fileParameterName,
          MultipartFile.fromFileSync(file.path),
        )),
      );
    }

    return FormData.fromMap(mergedData);
  }
}