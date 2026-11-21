import 'package:material_ui/material_ui.dart';

// --- Legal Text Constants ---

const String privacyPolicyText = '''
Privacy Policy for DevPulse

Effective date: November 14, 2026

At DevPulse, accessible from com.hamza.devpulse, one of our main priorities is the privacy of our visitors. This Privacy Policy document contains types of information that is collected and recorded by DevPulse and how we use it.

If you have additional questions or require more information about our Privacy Policy, do not hesitate to contact us.

Information We Collect
DevPulse may collect usage data, device information, and interaction metrics to improve application performance and user experience. If integrated with third-party services like Google Mobile Ads, standard advertising identifiers and diagnostic data may be collected in accordance with their respective privacy policies.

How We Use Your Information
We use the information we collect in various ways, including to:
- Provide, operate, and maintain our application
- Improve, personalize, and expand our application
- Understand and analyze how you use our application
- Develop new products, services, features, and functionality

Third-Party Privacy Policies
DevPulse's Privacy Policy does not apply to other advertisers or websites. Thus, we are advising you to consult the respective Privacy Policies of these third-party ad servers for more detailed information.

Consent
By using our app, you hereby consent to our Privacy Policy and agree to its terms.
''';

const String termsConditionsText = '''
Terms and Conditions

Effective date: November 14, 2026

Welcome to DevPulse!

These terms and conditions outline the rules and regulations for the use of DevPulse's Application.

By accessing this app we assume you accept these terms and conditions. Do not continue to use DevPulse if you do not agree to all of the terms and conditions stated on this page.

License
Unless otherwise stated, DevPulse and/or its licensors own the intellectual property rights for all material on DevPulse. All intellectual property rights are reserved. You may access this from DevPulse for your own personal use subjected to restrictions set in these terms and conditions.

You must not:
- Republish material from DevPulse
- Sell, rent, or sub-license material from DevPulse
- Reproduce, duplicate or copy material from DevPulse
- Redistribute content from DevPulse

Disclaimer
To the maximum extent permitted by applicable law, we exclude all representations, warranties, and conditions relating to our app and the use of this app. Nothing in this disclaimer will:
- limit or exclude our or your liability for death or personal injury;
- limit or exclude our or your liability for fraud or fraudulent misrepresentation;
- limit any of our or your liabilities in any way that is not permitted under applicable law; or
- exclude any of our or your liabilities that may not be excluded under applicable law.
''';

// --- Legal Screen Widget ---

class LegalScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 15.0,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}