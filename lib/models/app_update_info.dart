class AppUpdateInfo {
  final int latestVersionCode;
  final String latestVersionName;
  final String downloadUrl;
  final String notes;
  final bool isMandatory;
  final int currentVersionCode;

  AppUpdateInfo({
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.downloadUrl,
    required this.notes,
    required this.isMandatory,
    required this.currentVersionCode,
  });
}
