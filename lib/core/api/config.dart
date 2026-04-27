import 'dart:convert';

class ApiConfig {
  static const String apiBaseUrl = 'https://api.ggleap.com/production';

  static const String betaApiBaseUrl = 'https://api.ggleap.com/beta';

  static const String apiKey =
      'Cp0ePFW9UqV9pUdf+hqhr5+NPuaEyUrqF90wC7DKZ3t5bmVrXf3jG5BnBeTveSZY9yzrtE/n3ChjwcwGTqOOAvdCixckPWKsoFfV1Lx/QmyB+UP1qh04ohLjOuHzqIRu';

  static void printCurl({
    required String method,
    required Uri url,
    Map<String, String>? headers,
    Object? body,
  }) {
    // String curl = "curl --request ${method.toUpperCase()} \\\n  '$url'";

    // Add headers to cURL command
    // headers?.forEach((key, value) {
    //   curl += " \\\n  --header '$key: $value'";
    // });

    // Add body if it exists
    if (body != null) {
      String bodyString;
      if (body is Map || body is List) {
        bodyString = jsonEncode(body);
      } else {
        bodyString = body.toString();
      }
      // Escape single quotes in the body to prevent breaking the cURL command
      bodyString = bodyString.replaceAll("'", "'\\''");
      // curl += " \\\n  --data '$bodyString'";
    }
  }
}
