import 'package:flutter/material.dart';
import '../models/plan_model.dart';
import 'plan_details_dialog.dart';

const _kOrange = Color(0xFFFC8019);
const _kGreen = Color(0xFF267E3E);
const _kHeading = Color(0xFF1C1C1C);
const _kBody = Color(0xFF696969);

class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final String serviceName;
  final List<String>? images;
  final bool isInCart;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;

  const PlanCard({
    super.key,
    required this.plan,
    required this.serviceName,
    this.images,
    required this.isInCart,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => PlanDetailsDialog.show(
          context,
          plan: plan,
          serviceName: serviceName,
          images: images,
          isInCart: isInCart,
          onAddToCart: onAddToCart,
          onRemoveFromCart: onRemoveFromCart,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: Name + Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Expanded(
                        child: Text(
                          plan.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _kHeading,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Price column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${plan.basePrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _kOrange,
                            ),
                          ),
                          Text(
                            '+${plan.tax.toStringAsFixed(0)}% tax',
                            style: TextStyle(color: Colors.grey[500], fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Duration & Location
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: _kBody),
                      const SizedBox(width: 3),
                      Text(
                        plan.durationDisplay,
                        style: const TextStyle(color: _kBody, fontSize: 11),
                      ),
                      Container(
                        width: 3,
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: const BoxDecoration(
                          color: _kBody,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Icon(
                        plan.locationType == 'in_premise'
                            ? Icons.home_outlined
                            : Icons.warehouse_outlined,
                        size: 12,
                        color: _kBody,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        plan.locationType == 'in_premise' ? 'At Doorstep' : 'At Workshop',
                        style: const TextStyle(color: _kBody, fontSize: 11),
                      ),
                    ],
                  ),

                  if (plan.fuelTypes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: plan.fuelTypes.map((fuel) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _kOrange.withValues(alpha: 0.4)),
                            color: _kOrange.withValues(alpha: 0.06),
                          ),
                          child: Text(
                            fuel.toUpperCase(),
                            style: const TextStyle(
                              color: _kOrange,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  if (plan.features.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...plan.features.take(3).map((feature) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 13, color: _kGreen),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                feature,
                                style: const TextStyle(color: _kBody, fontSize: 11, height: 1.3),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (plan.features.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '+${plan.features.length - 3} more',
                          style: const TextStyle(
                            color: _kOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],

                  if (plan.warranty != null || plan.guarantee != null) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (plan.warranty != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user_rounded, size: 12, color: _kOrange.withValues(alpha: 0.85)),
                              const SizedBox(width: 3),
                              Text(
                                plan.warranty!,
                                style: TextStyle(
                                  color: _kOrange.withValues(alpha: 0.85),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        if (plan.guarantee != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shield_rounded, size: 12, color: _kGreen),
                              const SizedBox(width: 3),
                              Text(
                                plan.guarantee!,
                                style: const TextStyle(
                                  color: _kGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 10),

                  // Bottom row: Info + Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 3),
                          Text(
                            'Tap for details',
                            style: TextStyle(color: Colors.grey[400], fontSize: 10),
                          ),
                        ],
                      ),
                      _CartButton(
                        isInCart: isInCart,
                        onAdd: onAddToCart,
                        onRemove: onRemoveFromCart,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Badge - positioned at top right but not overlapping
            if (plan.badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kOrange,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(11),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    plan.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  final bool isInCart;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CartButton({
    required this.isInCart,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isInCart ? onRemove : onAdd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isInCart ? const Color(0xFFF2F2F2) : _kOrange,
          borderRadius: BorderRadius.circular(6),
          border: isInCart
              ? Border.all(color: const Color(0xFFD0D0D0), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isInCart)
              const Icon(Icons.check_rounded, size: 14, color: _kBody)
            else
              const Icon(Icons.add, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              isInCart ? 'Added' : 'Add',
              style: TextStyle(
                color: isInCart ? _kBody : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
