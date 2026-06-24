import 'dart:io';

class UploadFile {
  /// Name of your file parameter, the default value is 'files'.
  final String fileParameterName;
  /// List of file that you want to upload.
  final List<File> files;
  /// If your file parameter written like
  /// `file[0]`
  /// set to true.
  final bool isArrayKeyMethod;

  const UploadFile({
    required this.files,
    this.fileParameterName = "files",
    this.isArrayKeyMethod = false,
  });
}