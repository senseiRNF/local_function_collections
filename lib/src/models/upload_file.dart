import 'dart:io';
import 'package:dio/dio.dart';

class UploadFile {
  /// Name of your file parameter, the default value is 'files'.
  final String fileParameterName;

  /// List of file that you want to upload (uses `dart:io File`).
  final List<File> files;

  /// Raw MultipartFile list, useful for Flutter Web or memory-based uploads.
  final List<MultipartFile> rawFiles;

  /// If your file parameter is written with indexed array keys like `file[0]`,
  /// set to true.
  final bool isArrayKeyMethod;

  /// If your API endpoint expects a single file value instead of a list,
  /// set to true.
  final bool isSingleFile;

  const UploadFile({
    this.files = const [],
    this.rawFiles = const [],
    this.fileParameterName = "files",
    this.isArrayKeyMethod = false,
    this.isSingleFile = false,
  });

  /// Factory constructor to create an [UploadFile] from byte arrays.
  /// Ideal for Flutter Web and in-memory files.
  factory UploadFile.fromBytes({
    required List<List<int>> bytesList,
    List<String>? fileNames,
    String fileParameterName = "files",
    bool isArrayKeyMethod = false,
    bool isSingleFile = false,
  }) {
    final List<MultipartFile> multipartList = [];
    for (int i = 0; i < bytesList.length; i++) {
      final name = (fileNames != null && i < fileNames.length)
          ? fileNames[i]
          : 'file_$i';
      multipartList.add(MultipartFile.fromBytes(bytesList[i], filename: name));
    }

    return UploadFile(
      files: const [],
      rawFiles: multipartList,
      fileParameterName: fileParameterName,
      isArrayKeyMethod: isArrayKeyMethod,
      isSingleFile: isSingleFile,
    );
  }

  /// Factory constructor to create an [UploadFile] directly from [MultipartFile] items.
  factory UploadFile.fromMultipartFiles({
    required List<MultipartFile> multipartFiles,
    String fileParameterName = "files",
    bool isArrayKeyMethod = false,
    bool isSingleFile = false,
  }) {
    return UploadFile(
      files: const [],
      rawFiles: multipartFiles,
      fileParameterName: fileParameterName,
      isArrayKeyMethod: isArrayKeyMethod,
      isSingleFile: isSingleFile,
    );
  }
}
