import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../addresses_provider.dart';

class AddressSelector extends StatelessWidget {
  final bool locationEnabled;
  final VoidCallback onAddressManage;

  const AddressSelector({
    super.key,
    required this.locationEnabled,
    required this.onAddressManage,
  });

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressesProvider>();
    final selectedAddress = addressProvider.selectedAddress;

    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onAddressManage,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                locationEnabled
                    ? Icons.location_on
                    : Icons.location_off,
                color: locationEnabled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationEnabled
                          ? 'Deliver to'
                          : 'Location Disabled',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    if (selectedAddress != null)
                      Text(
                        '${selectedAddress.label} - ${selectedAddress.addressLine1}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Select an address',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}

