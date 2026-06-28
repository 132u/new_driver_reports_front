class EmailValidator {
  static const forbiddenDomains = {
        "gmail.com",
        "googlemail.com",
        "outlook.com",
        "hotmail.com",
        "live.com",
        "msn.com",
        "yahoo.com",
        "icloud.com",
        "me.com",
        "mac.com",
        "proton.me",
        "protonmail.com",
        "tuta.com",
        "tutanota.com",
        "aol.com",
        "mail.com",
        "gmx.com",
        "gmx.de",
        "gmx.net",
        "zoho.com",
        "fastmail.com",
        "hey.com",
        "runbox.com",
        "posteo.de",
        "mailfence.com",
        "startmail.com",
        "migadu.com",
        "hushmail.com",
  };

  static bool IsRussianEmail(String email) {
    final parts = email.toLowerCase().trim().split('@');

    if (parts.length != 2) return false;

    return !forbiddenDomains.contains(parts[1]);
  }
}