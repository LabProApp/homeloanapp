class ApiUrls {

  static const String baseUrl = "http://15.206.9.70:8080/api";

  static const String uploadDocuments="$baseUrl/documents/uploadDocuments";
  static const String downloadDocuments="$baseUrl/documents";

  //Property services URLs
  static const String updateUserProfile = "$baseUrl/user/update";
  static const String verifyOtp = "$baseUrl/user/verifyOtp";
  static const String resendOtp = "$baseUrl/user/resend-otp";
  static const String userSignup = "$baseUrl/user/signup";
  static const String userlogin = "$baseUrl/user/login";
  static const String userlogout = "$baseUrl/user/logout";

  // Leads APIs
  static const String getBrokerLeads = "$baseUrl/leads/broker/{brokerId}";
  static const String postBrokerLeads = "$baseUrl/leads";
  static const String updateBrokerLeads = "$baseUrl/leads/{leadId}";


  static String userProfileById(String userId) =>
      "$baseUrl/user/profile/$userId";

  static const String resetPassword = "$baseUrl/user/reset-password";
  //Tools services URLs

  static const String emiCalculator = "$baseUrl/tools/homeloancalculator";
  static const String calculateAffordability  = "$baseUrl/tools/calculateAffordability";
  static const String state_list  = "$baseUrl/master/getMasterValues?type=STATE";
  // Dynamic city URL based on state ID
  static String city_list(int stateId) =>
      "$baseUrl/master/$stateId/cities";

  //Property services URLs

  static const String propertySearch = "$baseUrl/property/advancedsearch";
  static const String post_property = "$baseUrl/property/add";
  static const String update_property = "$baseUrl/property/update";



  static const String post_MarkFavProperty = "$baseUrl/user/{userId}/favourite/{propertyId}";
  static const String get_FavProperty_list = "$baseUrl/user/{userId}/favourites";

  //Document legal services URLs
  static const String getlegalVendors_list=  "$baseUrl/providers/search";
  static const String legalInquiry =
      "$baseUrl/inquiries/add";
//Bank APIs URLs

  static const String getBanks_list="$baseUrl/banks";
  static const String getBanksInterestRates_list="$baseUrl/banks/{bankId}/interest_rates";
  static const String applyloan=  "$baseUrl/loan_inquiries";

//Enum APIs URLs
  static const String getMasterEnums=  "$baseUrl/api/master/allenums";

  static const String getMasterValues=  "$baseUrl/master/getMasterValues?type=1&status=ACTIVE";
}
