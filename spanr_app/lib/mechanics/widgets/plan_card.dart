import 'package:flutter/material.dart';
import '../models/plan_model.dart';
import 'plan_details_dialog.dart';

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
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: isInCart ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isInCart
            ? BorderSide(color: primary, width: 2)
            : BorderSide(color: Colors.grey.shade200, width: 1),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (plan.badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  plan.badge!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 3),
                            Text(
                              plan.durationDisplay,
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 3),
                            Text(
                              plan.locationType == 'in_premise' ? 'In Premise' : 'Shed',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${plan.basePrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                      ),
                      Text(
                        '+${plan.tax.toStringAsFixed(0)}% tax',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),

              if (plan.fuelTypes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: plan.fuelTypes.map((fuel) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        fuel.toUpperCase(),
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 10,
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
                        Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
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
                      '+${plan.features.length - 3} more features',
                      style: TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],

              if (plan.warranty != null || plan.guarantee != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (plan.warranty != null) ...[
                      Icon(Icons.verified_user, size: 13, color: Colors.orange.shade700),
                      const SizedBox(width: 3),
                      Text(
                        plan.warranty!,
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (plan.warranty != null && plan.guarantee != null) const SizedBox(width: 10),
                    if (plan.guarantee != null) ...[
                      Icon(Icons.shield, size: 13, color: Colors.green.shade700),
                      const SizedBox(width: 3),
                      Text(
                        plan.guarantee!,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 13, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to view details',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
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
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: isInCart ? onRemove : onAdd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isInCart ? Colors.grey.shade100 : primary,
          borderRadius: BorderRadius.circular(20),
          border: isInCart ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isInCart ? Icons.check : Icons.add,
              size: 14,
              color: isInCart ? Colors.grey.shade700 : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              isInCart ? 'Added' : 'Add',
              style: TextStyle(
                color: isInCart ? Colors.grey.shade700 : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
