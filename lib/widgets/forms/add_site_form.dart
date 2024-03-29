import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocode/geocode.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/helpers/decoration_library.dart';
import 'package:teamshare/helpers/location_helper.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/drawer_screens/map_screen.dart';
import 'package:teamshare/widgets/form_title.dart';

class AddSiteForm extends StatefulWidget {
  @override
  _AddSiteFormState createState() => _AddSiteFormState();
}

class _AddSiteFormState extends State<AddSiteForm> {
  String _previewImageUrl;
  Address _selectedAddress;

  bool _uploading = false;
  Site _newSite = Site(name: "", address: Address(0, 0));

  final _siteForm = GlobalKey<FormState>();
  StreamSubscription<List<Instrument>> subscription;

  final _controllerAddressText = TextEditingController();

  Future<void> _getCurrentLocation() async {
    try {
      final locData = await Location().getLocation();

      _showPreview(locData.latitude, locData.longitude);
    } on Exception catch (_) {
      return;
    }
  }

  Future<void> _showPreview(double lat, double lng) async {
    geo.GeoCode geoCode = geo.GeoCode();

    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
      lat: lat,
      lng: lng,
    );
    var address = await geoCode.reverseGeocoding(latitude: lat, longitude: lng);

    _selectedAddress = Address(lat, lng,
        area: address.region,
        city: address.city,
        country: address.countryName,
        street: address.streetAddress,
        houseNumber: address.streetNumber.toString());
    _newSite.address = _selectedAddress;
    setState(() {
      _previewImageUrl = staticMapImageUrl;
      _controllerAddressText.text = _selectedAddress.toString();
    });
  }

  Future<void> _selectOnMap() async {
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => StreamProvider<List<Site>>(
          create: (context) => FirebaseFirestoreProvider.getSites(),
          initialData: [],
          child: MapScreen(
            initialLocation: null,
            isSelecting: true,
          ),
        ),
      ),
    );
    if (selectedLocation == null)
      return;
    else {
      _showPreview(selectedLocation.latitude, selectedLocation.longitude);
    }
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: DecorationLibrary.inputDecoration("Site Name", context),
      keyboardType: TextInputType.text,
      validator: (value) => (value.trim().isEmpty) ? "Not a valid name" : null,
      onSaved: (val) {
        _newSite.name = val;
      },
    );
  }

  Widget _buildAddressField() {
    return TextField(
      decoration:
          DecorationLibrary.inputDecoration("Selected Address", context),
      controller: _controllerAddressText,
      enabled: false,
      maxLines: 2,
    );
  }

  @override
  void dispose() {
    if (subscription != null) subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(border: Border.all(width: 5)),
        padding: EdgeInsets.only(
            left: 5,
            right: 5,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Form(
          key: _siteForm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FormTitle(title: 'Add Site'),
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _previewImageUrl == null
                                  ? Icon(Icons.location_off_sharp)
                                  : Image.network(
                                      _previewImageUrl,
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Icon(Icons.location_on),
                                tooltip: 'Current Location',
                                onPressed: _getCurrentLocation,
                              ),
                              IconButton(
                                icon: Icon(Icons.map),
                                tooltip: 'Select On Map',
                                onPressed: _selectOnMap,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(flex: 2, child: _buildNameField()),
                            Spacer(),
                            Expanded(flex: 3, child: _buildAddressField())
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: _uploading
                    ? CircularProgressIndicator()
                    : OutlinedButton(
                        onPressed: _addSite,
                        child: Text(
                          'Add New Site',
                        ),
                        style: outlinedButtonStyle,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSite() async {
    {
      FormState formState = _siteForm.currentState;
      if (formState != null &&
          formState.validate() &&
          _selectedAddress != null) {
        formState.save();
        setState(() {
          _uploading = true;
        });
        //send to server
        try {
          await FirebaseFirestoreCloudFunctions.uploadSite(
                  _newSite, Operation.CREATE)
              .then((_) async => {
                    Navigator.of(context).pop(),
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Site Added Successfully!'),
                      ),
                    ),
                  });
        } catch (error) {
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: Text('Error!'),
                    content: Text('Operation failed\n' + error.toString()),
                    actions: <Widget>[
                      TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: Text('Ok'),
                      ),
                    ],
                  ));
        } finally {
          setState(() {
            _newSite = Site(name: "", address: Address(0, 0));

            _uploading = false;
          });
        }
      }
    }
  }
}
