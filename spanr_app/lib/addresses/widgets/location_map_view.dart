import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapView extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final Function(double lat, double lng) onLocationChanged;

  const LocationMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onLocationChanged,
  });

  @override
  State<LocationMapView> createState() => _LocationMapViewState();
}

class _LocationMapViewState extends State<LocationMapView> {
  GoogleMapController? _mapController;
  late LatLng _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(
      widget.latitude ?? 37.7749,
      widget.longitude ?? -122.4194,
    );
    _updateMarker();
  }

  @override
  void didUpdateWidget(LocationMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latitude != oldWidget.latitude ||
        widget.longitude != oldWidget.longitude) {
      if (widget.latitude != null && widget.longitude != null) {
        _currentPosition = LatLng(widget.latitude!, widget.longitude!);
        _updateMarker();
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentPosition),
        );
      }
    }
  }

  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _currentPosition,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _currentPosition = newPosition;
            });
            widget.onLocationChanged(
              newPosition.latitude,
              newPosition.longitude,
            );
          },
        ),
      };
    });
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _currentPosition = position;
      _updateMarker();
    });
    widget.onLocationChanged(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        onTap: _onMapTap,
        markers: _markers,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
