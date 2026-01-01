class ApiUrls {

  static const String baseUrl = "http://15.206.9.70:8080/api";


  //Property services URLs
  static const String updateUserProfile = "$baseUrl/user/update";
  static const String verifyOtp = "$baseUrl/user/verifyOtp";
  static const String resendOtp = "$baseUrl/user/resend-otp";
  static const String userSignup = "$baseUrl/user/signup";
  static const String userlogin = "$baseUrl/user/login";
  static const String userlogout = "$baseUrl/user/logout";

  //Tools services URLs

  static const String emiCalculator = "$baseUrl/tools/homeloancalculator";
  static const String calculateAffordability  = "$baseUrl/tools/calculateAffordability";


  //Property services URLs

  static const String propertySearch = "$baseUrl/property/search";
  static const String post_property = "$baseUrl/property/add";
  static const String update_property = "$baseUrl/property/update";

  static const String post_MarkFavProperty = "$baseUrl/user/{userId}/favourite/4";
  static const String get_FavProperty_list = "$baseUrl/user/{userId}/favourites";

  //Document legal services URLs
  static const String getlegalVendors_list=  "$baseUrl/providers/search";
//Bank APIs URLs

  static const String getBanks_list="$baseUrl/banks";
  static const String getBanksInterestRates_list="$baseUrl/banks/{bankId}/interest_rates";
  static const String applyloan=  "$baseUrl/loan_inquiries";

//Enum APIs URLs
  static const String getMasterEnums=  "$baseUrl/api/master/allenums";

  static const String getMasterValues=  "$baseUrl/master/getMasterValues?type=1&status=ACTIVE";
}
