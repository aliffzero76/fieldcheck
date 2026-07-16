import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

enum LocationFieldStatus { idle, loading, success, error }

/// "Get Location" button + result box, per wireframe screen 2.
/// Shows a loading state while fetching, then lat/lng/accuracy or an
/// error message — never leaves the UI stuck or crashes on denial.
class LocationField extends StatefulWidget {
  final ValueChanged<Position?> onLocationFetched;
  final bool showRequiredError;

  const LocationField({
    super.key,
    required this.onLocationFetched,
    this.showRequiredError = false,
  });

  @override
  State<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {
  LocationFieldStatus _status = LocationFieldStatus.idle;
  Position? _position;
  String? _errorMessage;

  Future<void> _fetchLocation() async {
    setState(() => _status = LocationFieldStatus.loading);

    final result = await LocationService.getCurrentLocation();

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _position = result.position;
        _status = LocationFieldStatus.success;
      });
      widget.onLocationFetched(result.position);
    } else {
      setState(() {
        _errorMessage = result.error;
        _status = LocationFieldStatus.error;
      });
      widget.onLocationFetched(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _status == LocationFieldStatus.loading
                    ? null
                    : _fetchLocation,
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Get Location'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const _RequiredTag(),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.showRequiredError && _position == null
                  ? Colors.red
                  : Colors.grey.shade300,
            ),
          ),
          child: _buildContent(),
        ),
        if (widget.showRequiredError && _position == null)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Location is required',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_status) {
      case LocationFieldStatus.loading:
        return const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('fetching…'),
          ],
        );
      case LocationFieldStatus.success:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Latitude', _position!.latitude.toStringAsFixed(6)),
            _row('Longitude', _position!.longitude.toStringAsFixed(6)),
            _row('Accuracy', '${_position!.accuracy.toStringAsFixed(1)} m'),
          ],
        );
      case LocationFieldStatus.error:
        return Text(
          _errorMessage ?? 'Something went wrong.',
          style: const TextStyle(color: Colors.red),
        );
      case LocationFieldStatus.idle:
        return Text(
          'No location fetched yet.',
          style: TextStyle(color: Colors.grey.shade500),
        );
    }
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RequiredTag extends StatelessWidget {
  const _RequiredTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'required',
        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
      ),
    );
  }
}
