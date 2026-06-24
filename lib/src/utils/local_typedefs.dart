import 'package:dio/dio.dart';

typedef HttpErrorHandler = void Function(DioException exception, StackTrace stackTrace);

enum RequestType { get, post, put, delete }