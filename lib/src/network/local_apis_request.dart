import 'package:dio/dio.dart';

import 'package:local_function_collections/src/models/upload_file.dart';
import 'package:local_function_collections/src/utils/local_typedefs.dart';

class LocalAPIsRequest {
  static final Dio _dio = Dio(
    BaseOptions(
      sendTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ),
  );

  /// Interceptors
  ///
  /// This function will adding a list of Interceptors to the Dio instance.
  /// It is recommended to call this function once (e.g., during app initialization)
  /// to avoid duplicate interceptors.
  static void addInterceptors(List<Interceptor> interceptors) {
    _dio.interceptors.addAll(interceptors);
  }

  /// Submit Request
  ///
  /// This function will handle a network request using Dio
  ///
  /// Parameters:
  /// * Request Type (Required): Determine request type for submitting request (GET, POST, PUT or DELETE).
  /// * APIs URL (Required): URL required to reach APIs address.
  /// * Header Request (Optional): Header that set for request.
  /// * Parameters (Optional): Query parameters that will be carried when reaching the API endpoint.
  /// * Body Data (Optional): A map of data that will be carried in the request body.
  /// * Connection Timeout in Second (Optional): Timeout set in second, to determined how long request could try reach the APIs address before it's declared as timeout.
  /// * Receive Timeout in Second (Optional): Timeout set in second, to determined how long response could received before it's declared as timeout.
  /// * Use Preserve Header Case (Optional): An option that used as parameter for determined if header need to be keep on sensitve case or not.
  /// * Cancel Token (Optional): If this request runs in the background and needs to handle cancellation, this parameter must be declared. If the request is cancelled, [errorHandler] will be automatically bypassed to prevent UI race conditions.
  /// * Error Handler (Optional): Handling an error request and carried DioException and StackTrace result value. This will NOT be triggered if the request is cancelled using [cancelToken].
  /// * Upload File (Optional): An option that used when you want to upload a file, this parameter will using UploadFile class.
  /// * With Credentials (Optional): An option for web platforms to include credentials (such as cookies or authorization headers) in cross-site requests.
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
    bool withCredentials = false,
  }) async {
    final Options requestOption = Options(
      headers: headerRequest,
      preserveHeaderCase: usePreserveHeaderCase,
      sendTimeout: connectionTimeoutInSecond != null ?
      Duration(
        seconds: connectionTimeoutInSecond,
      ) : _dio.options.sendTimeout,
      receiveTimeout: receiveTimeoutInSecond != null ?
      Duration(
        seconds: receiveTimeoutInSecond,
      ) : _dio.options.receiveTimeout,
      extra: {
        'withCredentials': withCredentials,
      },
    );

    Response? response;

    try {
      dynamic requestData = bodyData;

      if (requestType == RequestType.post && files != null && files.files.isNotEmpty) {
        requestData = _buildFormData(files, bodyData);
      }

      switch (requestType) {
        case RequestType.get:
          response = await _dio.get(
            apisURL,
            options: requestOption,
            queryParameters: parameters,
            data: bodyData,
            cancelToken: cancelToken,
          );
          break;
        case RequestType.post:
          response = await _dio.post(
            apisURL,
            options: requestOption,
            queryParameters: parameters,
            data: requestData,
            cancelToken: cancelToken,
          );
          break;
        case RequestType.put:
          response = await _dio.put(
            apisURL,
            options: requestOption,
            queryParameters: parameters,
            data: bodyData,
            cancelToken: cancelToken,
          );
          break;
        case RequestType.delete:
          response = await _dio.delete(
            apisURL,
            options: requestOption,
            queryParameters: parameters,
            data: bodyData,
            cancelToken: cancelToken,
          );
          break;
      }
    } on DioException catch(err, stackTrace) {
      if (err.type == DioExceptionType.cancel) return err.response;

      if (errorHandler != null) {
        errorHandler(err, stackTrace);
      }

      response = err.response;
    } catch(e) {
      rethrow;
    }

    return response;
  }

  static FormData _buildFormData(UploadFile files, Map<String, dynamic>? bodyData) {
    final mergedData = Map<String, dynamic>.from(bodyData ?? {});

    if (files.isArrayKeyMethod) {
      mergedData.addEntries(
        files.files.asMap().entries.map((entry) => MapEntry(
          "${files.fileParameterName}[${entry.key}]",
          MultipartFile.fromFileSync(entry.value.path),
        )),
      );
    } else {
      mergedData[files.fileParameterName] = files.files
          .map((file) => MultipartFile.fromFileSync(file.path))
          .toList();
    }

    return FormData.fromMap(mergedData);
  }
}