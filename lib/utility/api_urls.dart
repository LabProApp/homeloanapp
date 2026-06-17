import '../config/app_config.dart';

class ApiUrls {
  static const String baseUrl = AppConfig.apiBaseUrl;

  static const String uploadDocuments = "$baseUrl/documents/uploadDocuments";
  static const String downloadDocuments = "$baseUrl/documents";

  // User APIs
  static const String updateUserProfile = "$baseUrl/user/update";
  static const String verifyOtp = "$baseUrl/user/verifyOtp";
  static const String resendOtp = "$baseUrl/user/resend-otp";
  static const String userSignup = "$baseUrl/user/signup";
  static const String userlogin = "$baseUrl/user/login";
  static const String userlogout = "$baseUrl/user/logout";
  static const String resetPassword = "$baseUrl/user/reset-password";

  // Plan change requests
  static const String planRequests = "$baseUrl/plan-requests";
  static const String myPlanRequests = "$baseUrl/plan-requests/me";
  static String cancelPlanRequest(int id) => "$baseUrl/plan-requests/$id/cancel";
  static String approvePlanRequest(int id) => "$baseUrl/plan-requests/$id/approve";
  static String rejectPlanRequest(int id) => "$baseUrl/plan-requests/$id/reject";

  // Admin
  static const String adminStats = "$baseUrl/admin/stats";
  static const String adminUsers = "$baseUrl/admin/users";
  static String adminChangeUserPlan(int userId) => "$baseUrl/user/$userId/plan";

  static String userProfileById(String userId) =>
      "$baseUrl/user/profile/$userId";

  // Leads APIs
  static const String searchLeads = "$baseUrl/leads/search";
  static const String postBrokerLeads = "$baseUrl/leads";
  static const String updateBrokerLeads = "$baseUrl/leads/{leadId}";
  static const String updateLeadStatus = "$baseUrl/leads/{leadId}/status";
  static const String scheduleLeadFollowUp = "$baseUrl/leads/{leadId}/followup";

  static String propertyLeadsSummary(int propertyId) =>
      "$baseUrl/leads/property/$propertyId/summary";

  // Tools APIs
  static const String emiCalculator = "$baseUrl/tools/homeloancalculator";
  static const String calculateAffordability =
      "$baseUrl/tools/calculateAffordability";
  static const String state_list =
      "$baseUrl/master/getMasterValues?type=STATE";

  static String master_child_list(int stateId) =>
      "$baseUrl/master/$stateId/cities";

  // Property APIs
  static const String propertySearch = "$baseUrl/property/advancedsearch";
  static String propertyById(int id) => "$baseUrl/property/$id";
  static const String post_property = "$baseUrl/property/add";
  static const String update_property = "$baseUrl/property/update";
  static const String delete_property = "$baseUrl/property/delete";

  static const String post_MarkFavProperty =
      "$baseUrl/user/{userId}/favourite/{propertyId}";
  static const String get_FavProperty_list = "$baseUrl/user/{userId}/favourites";

  // Legal APIs
  static const String getlegalVendors_list = "$baseUrl/providers/search";
  static const String legalInquiry = "$baseUrl/inquiries/add";

  // Bank APIs
  static const String getBanks_list = "$baseUrl/banks";
  static const String getBanksInterestRates_list =
      "$baseUrl/banks/{bankId}/interest_rates";
  static const String applyloan = "$baseUrl/loan_inquiries";

  // Master / Enum APIs
  static const String getMasterEnums = "$baseUrl/api/master/allenums";
  static const String getMasterValues =
      "$baseUrl/master/getMasterValues?type=1&status=ACTIVE";

  // App version check (public endpoint — no auth)
  static const String versionCheck = "$baseUrl/version/check";
}
