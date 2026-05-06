import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/admin_service.dart';
import '../../../models/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Future<void> _updateStatus(OrderStatus s) async {
    await AdminService.instance.updateOrderStatus(widget.orderId, s);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${_statusLabel(s)}', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: AdminService.instance.getAllOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final orders = snapshot.data ?? [];
        final order = orders.firstWhere(
          (o) => o.id == widget.orderId,
          orElse: () => orders.length > 0 ? orders.first : OrderModel(id: 'err', userId: '', userName: '', items: [], totalAmount: 0, status: OrderStatus.pending, createdAt: DateTime.now(), deliveryAddress: ''),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 130,
                pinned: true,
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.whiteSurface,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFB71C1C), AppColors.primaryRed],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order #${order.id.length > 5 ? order.id.substring(0, 5).toUpperCase() : order.id}',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.whiteSurface)),
                        _StatusBadge(status: order.status),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _sectionCard('Customer Info', [
                      _infoRow(Icons.person_rounded, order.userName),
                      _infoRow(Icons.location_on_rounded, order.deliveryAddress),
                    ]),
                    const SizedBox(height: 12),
                    _sectionCard('Order Items', [
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Text(item['emoji'] ?? '🍔', style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(item['name'] ?? 'Item',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13, color: AppColors.textPrimary)),
                              ),
                              Text('${item['quantity']}×',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(width: 6),
                              Text('₹${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _sectionCard('Price Breakdown', [
                      _priceRow('Subtotal', order.totalAmount / 1.05),
                      _priceRow('Tax (GST 5%)', order.totalAmount - (order.totalAmount / 1.05)),
                      const Divider(),
                      _priceRow('Total Amount', order.totalAmount, bold: true),
                    ]),
                    const SizedBox(height: 12),
                    _buildStatusDropdown(order),
                    const SizedBox(height: 12),
                    _buildActionButtons(context, order),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderModel order) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(OrderStatus.delivered),
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: Text('Deliver', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: AppColors.whiteSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _updateStatus(OrderStatus.cancelled),
              icon: const Icon(Icons.cancel_rounded, size: 18),
              label: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryRed,
                side: const BorderSide(color: AppColors.primaryRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.whiteSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text('₹${value.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  color: bold ? AppColors.primaryRed : AppColors.textPrimary)),
        ],
      ),
    );
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  Widget _buildStatusDropdown(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.whiteSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OrderStatus>(
          isExpanded: true,
          value: order.status,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryRed),
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
          items: OrderStatus.values
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(_statusLabel(s)),
                  ))
              .toList(),
          onChanged: (s) {
            if (s != null) _updateStatus(s);
          },
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color fg; String label;
    switch (status) {
      case OrderStatus.pending:    fg = AppColors.primaryOrange; label = 'Pending';
      case OrderStatus.preparing:  fg = Colors.blue;             label = 'Preparing';
      case OrderStatus.outForDelivery: fg = Colors.indigo;       label = 'On Way';
      case OrderStatus.delivered:  fg = AppColors.successGreen;  label = 'Delivered';
      case OrderStatus.cancelled:  fg = AppColors.primaryRed;    label = 'Cancelled';
    }
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.whiteSurface.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}
