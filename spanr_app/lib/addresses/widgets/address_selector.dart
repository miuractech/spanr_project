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
    const orange = Color(0xFFFC8019);

    return GestureDetector(
      onTap: onAddressManage,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: locationEnabled ? orange : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedAddress != null) ...[
                    Row(
                      children: [
                        Text(
                          selectedAddress.label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1C),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down,
                            size: 18, color: Color(0xFF1C1C1C)),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      selectedAddress.addressLine1,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF696969),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else
                    Row(
                      children: [
                        Text(
                          'Select your location',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            size: 18, color: Colors.grey[500]),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
