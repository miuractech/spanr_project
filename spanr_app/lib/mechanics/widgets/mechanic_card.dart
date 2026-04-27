import 'package:flutter/material.dart';
import '../models/mechanic_company.dart';
import '../../core/theme/app_theme.dart';

class MechanicCard extends StatelessWidget {
  final MechanicCompany mechanic;
  final VoidCallback? onTap;

  const MechanicCard({
    super.key,
    required this.mechanic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular profile image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundGrey,
                      shape: BoxShape.circle,
                    ),
                    child: mechanic.logo != null
                        ? ClipOval(
                            child: Image.network(
                              mechanic.logo!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholder(context),
                            ),
                          )
                        : _buildPlaceholder(context),
                  ),
                  const SizedBox(width: 16),
                  
                  // Company details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mechanic.companyName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: AppTheme.darkGrey,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Rating and Distance
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: mechanic.rating != null && mechanic.rating! > 0
                                  ? Colors.amber
                                  : AppTheme.mediumGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              mechanic.displayRating,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (mechanic.distanceKm != null) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppTheme.mediumGrey,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                mechanic.displayDistance,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.mediumGrey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Address
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppTheme.mediumGrey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${mechanic.addressLine1}, ${mechanic.city}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.mediumGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Contact info
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: AppTheme.mediumGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    mechanic.phone,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.mediumGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Icon(
      Icons.person,
      size: 30,
      color: AppTheme.lightGrey,
    );
  }
}

