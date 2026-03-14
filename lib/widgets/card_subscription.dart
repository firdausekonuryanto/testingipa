import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internusa_group/utils/helper/globalhelper.dart';
import 'package:internusa_group/utils/theme.dart';

class CardSubscription extends StatelessWidget {
  final String? name;
  final String? address;
  final String? phone;
  final String productSN;
  final String subscriptionPackage;
  final String terminationReason;
  final String createdAt;
  final Color colors;

  const CardSubscription({
    super.key,
    required this.name,
    required this.address,
    required this.phone,
    required this.productSN,
    required this.subscriptionPackage,
    required this.terminationReason,
    required this.createdAt,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      shadowColor: Colors.blueGrey.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colors.withValues(alpha: 0.9),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name ?? 'Tidak diketahui',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.myLightYellow
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(thickness: 1, color: AppColors.textSecondary),
            _buildInfoRow(context,
                icon: Icons.home, label: "Alamat", value: address ?? '-'),
            _buildInfoRow(context,
                icon: Icons.phone, label: "Telepon", value: phone ?? '-'),
            _buildInfoRow(context,
                icon: Icons.router, label: "Produk & SN", value: productSN),
            _buildInfoRow(context,
                icon: Icons.wifi,
                label: "Paket Langganan",
                value: subscriptionPackage),
            _buildInfoRow(context,
                icon: Icons.cancel,
                label: "Alasan Putus",
                value: terminationReason),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Dibuat: ${formatDate(createdAt, "d MMMM yyyy HH:mm:ss")}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.myLightGreen
                      : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 20,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textLight
                  : Colors.blueGrey[700]),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textLight
                    : Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : '—',
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textLight
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
