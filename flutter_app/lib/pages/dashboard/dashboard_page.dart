import 'package:firebase_auth/firebase_auth.dart';
import 'package:flareline/models/spf_tracker_model.dart';
import 'package:flareline/models/user_model.dart';
import 'package:flareline/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';
import '../../services/ble_uv_service.dart';

import 'widgets/uv_index_widget.dart';
import 'widgets/exposure_timer_widget.dart';
import 'widgets/spf_selector_widget.dart';
import 'widgets/recommendation_widget.dart';

class DashboardPage extends LayoutWidget {
  const DashboardPage({super.key});

  double getMED(String skinType) {
  switch (skinType.toLowerCase()) {
    case 'i':
      return 200.0; // in J/m²
    case 'ii':
      return 250.0;
    case 'iii':
      return 300.0;
    case 'iv':
      return 450.0;
    case 'v':
      return 600.0;
    case 'vi':
      return 800.0;
    default:
      return 250.0;
  }
}

  int calculateProtectionTime(double med, double uvIndex, int spf) {
  return ((med / uvIndex) * spf / 1) ~/ 60; // in minutes
}

int calculateSafeExposureTime(double med, double uvIndex) {
  return (med / uvIndex) ~/ 60;
}


  @override
  String breakTabTitle(BuildContext context) {
    return AppLocalizations.of(context)!.dashboard;
  }

  @override
Widget contentDesktopWidget(BuildContext context) {
  final currentUser = FirebaseAuth.instance.currentUser;

  return CommonCard(
    height: 800,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder(
        future: Future.wait([
          FirestoreService().getUser(currentUser!.uid),
          FirestoreService().getSPFTracking(currentUser.uid)
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data![0] as UserModel;
          final List<SpfTrackerModel> spfList = snapshot.data![1];
          final latestSpf = spfList.isNotEmpty
              ? spfList.reduce((a, b) => a.appliedAt.isAfter(b.appliedAt) ? a : b)
              : null;

          final now = DateTime.now();
          final isSpfActive = latestSpf != null && latestSpf.expiresAt.isAfter(now);

          final double uvIndex = user.currentUVIndex;
          final double med = getMED(user.skinType);
          final int protectionTime = isSpfActive
              ? calculateProtectionTime(med, uvIndex, latestSpf!.spfLevel)
              : 0;
          final int safeTime = !isSpfActive ? calculateSafeExposureTime(med, uvIndex) : 0;

          final alertColor = isSpfActive
              ? Colors.green
              : (safeTime <= 5 ? Colors.red : Colors.orange);

          final statusText = isSpfActive
              ? "SPF protection active"
              : "SPF expired or not applied";

          final timeText = isSpfActive
              ? "Protection expires in approx. $protectionTime minutes"
              : "Safe exposure time without SPF: $safeTime minutes";

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Current UV Index", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const UVIndexWidget(),

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: alertColor.withOpacity(0.2),
                    border: Border.all(color: alertColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(statusText, style: TextStyle(fontSize: 18, color: alertColor, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(timeText, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to SPF timer page
                          Navigator.pushNamed(context, "/spfTimer");
                        },
                        child: Text(isSpfActive ? "Update SPF" : "Apply SPF"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text("Exposure Time", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const ExposureTimerWidget(),

                const SizedBox(height: 20),
                const Text("SPF Tracker", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SPFSelectorWidget(),

                const SizedBox(height: 20),
                const RecommendationWidget(),
              ],
            ),
          );
        },
      ),
    ),
  );
}
}