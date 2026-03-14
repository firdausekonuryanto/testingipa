class ApiRoutes {
  //auth api routes
  static const login = '/login';
  static const sendResetLink = '/auth/send-reset-link';
  static const resetPassword = '/auth/reset-password';
  static const logout = '/auth/logout';
  static const authme = '/auth/me';
  static const updateprofilepicture = '/auth/profile/picture';
  static const updateprofileaccount = '/auth/profile/account';
  static const updateprofile = '/auth/profile';

  //attendance
  static const attendance = '/attendance';
  static const attendanceMontly = '/attendance/montly';
  static const clockin = '$attendance/clock-in';
  static const clockout = '$attendance/clock-out';
  static const attendanceToday = '$attendance/today';
  static String attendanceNotes(int id) => '$attendance/$id/notes';
  static String attendanceByDate(String id) => '$attendanceMontly/$id';

  //assignment
  static const assignment = '/assignment';
  static String assignmentById(int id) => '$assignment/$id';
  static String assignmentTask(int id) => '$assignment/$id/task';

  //customer
  static const customer = '/customer';
  static const customerFormData = '${customer}/form-data';
  static const customerStore = '${customer}/store';
  static const customerOnlyStore = '${customer}/store-only-customer';
  static String customerById(int id) => '$customer/$id';

  //dynamic-forms
  static const dynamicForms = '/dynamic-forms';
  static const dynamicFormsResponses = '${dynamicForms}/responses';
  static String dynamicFormsById(int id) => '$dynamicForms/$id';
  static String dynamicFormsCreate(int id) => '$dynamicForms/$id/create';
  static String dynamicFormsEditById(int id) => '$dynamicForms/$id/edit';
  static String dynamicFormsDelete(int id) => '$dynamicForms/$id/delete';
  static const dynamicFormsEdit = '$dynamicForms/edit';

  //KPI-Score
  static const kpiScore = '/kpi-scores';
  static String kpiScoreById(int id) => '$kpiScore/$id';

  //leave
  static const leave = '/leave';
  static const leaveCreate = '${leave}/req-leave';

  //master
  static const master = '/master';
  static const masterProduct = '${master}/product';
  static const masterCustomer = '${master}/customer';

  //product-subscription
  static const productSubscription = '/product-subscription';

  //salary
  static const salary = '/salary';
  static String salaryById(int id) => '$salary/$id';

  //task
  static const task = '/task';
  static String taskById(int id) => '$task/$id';
  static String taskReport(int id) => '$task/$id/report';
  static String taskReports(int id) => '$task/$id/reports';
  static String taskOverdueReason() => '$task/reason';

  //work-schedule
  static const workSchedule = '/work-schedule';
  static const workScheduleEmployee = '${workSchedule}/employee';
  static const workScheduleInsert = '${workSchedule}/insert-update';
  static String workScheduleEmployeeById(int id) =>
      '$workSchedule/employee/$id';

  // shift-templates
  static const shiftTemplate = '/shift-templates';
  static String shiftTemplateMine(int id) => '$shiftTemplate/$id/my-shifts';

  //work-product
  static const workProduct = '/work-product';
  static const workProductFormData = '${workProduct}/form-data';
  static const workProductStore = '${workProduct}/store';
  static String workProductById(int id) => '$workProduct/$id';

  //app version
  static const appVersion = '/app-version';

  //app Notifications
  static const notifications = '/notifications';
  static String notificationsRead(int id) => '$notifications/$id/read';
}
