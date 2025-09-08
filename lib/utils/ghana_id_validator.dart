/// Utility class for validating Ghanaian identification documents
class GhanaIdValidator {
  /// Validates Ghana Card number format (GHA-XXXXXXXX-X)
  /// Standard Ghana Card format: GHA followed by 8 digits, dash, then 1 check digit
  /// Example: GHA-12345678-9
  static bool isValidGhanaCard(String cardNumber) {
    final regex = RegExp(r'^GHA-\d{9}-\d{1}$');
    return regex.hasMatch(cardNumber.toUpperCase().trim());
  }

  /// Validates Ghana Driver's License format
  /// Example: B1234567 or DL-1234567
  static bool isValidDriversLicense(String licenseNumber) {
    final regex = RegExp(r'^([A-Z]{1,2}-?\d{6,8}|DL-?\d{6,8})$');
    return regex.hasMatch(licenseNumber.toUpperCase().trim());
  }

  /// Validates Ghana Voter ID format
  /// Example: 1234567890
  static bool isValidVoterId(String voterId) {
    final regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(voterId.trim());
  }

  /// Validates Ghana Passport number format
  /// Example: G1234567 or P1234567
  static bool isValidPassport(String passportNumber) {
    final regex = RegExp(r'^[GP]\d{7,8}$');
    return regex.hasMatch(passportNumber.toUpperCase().trim());
  }

  /// Validates any Ghana ID based on its type
  static bool validateId(String idNumber, String idType) {
    switch (idType) {
      case 'ghana_card':
        return isValidGhanaCard(idNumber);
      case 'driver_license':
        return isValidDriversLicense(idNumber);
      case 'voter_id':
        return isValidVoterId(idNumber);
      case 'passport':
        return isValidPassport(idNumber);
      default:
        return false;
    }
  }

  /// Gets the display name for an ID type
  static String getDisplayName(String idType) {
    switch (idType) {
      case 'ghana_card':
        return 'Ghana Card';
      case 'driver_license':
        return "Driver's License";
      case 'voter_id':
        return 'Voter ID';
      case 'passport':
        return 'Passport';
      default:
        return 'ID Document';
    }
  }

  /// Gets a list of available ID types with display names
  static List<Map<String, String>> getAvailableIdTypes() {
    return [
      {'value': 'ghana_card', 'display': 'Ghana Card'},
      {'value': 'driver_license', 'display': "Driver's License"},
      {'value': 'voter_id', 'display': 'Voter ID'},
      {'value': 'passport', 'display': 'Passport'},
    ];
  }

  /// Formats an ID number for display
  static String formatIdNumber(String idNumber, String idType) {
    if (idNumber.isEmpty) return idNumber;
    
    switch (idType) {
      case 'ghana_card':
        // Ensure proper formatting: GHA-XXXXXXXX-X (8 digits + 1 check digit)
        final cleaned = idNumber.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
        if (cleaned.startsWith('GHA') && cleaned.length == 12) {
          return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 11)}-${cleaned.substring(11)}';
        }
        return idNumber;
      
      case 'driver_license':
        // Ensure proper formatting with dash if missing
        final cleaned = idNumber.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
        if (cleaned.length >= 2 && RegExp(r'^[A-Z]{2}').hasMatch(cleaned)) {
          return '${cleaned.substring(0, 2)}-${cleaned.substring(2)}';
        }
        return idNumber;
      
      default:
        return idNumber;
    }
  }
}
