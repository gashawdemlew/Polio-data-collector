import 'package:flutter/material.dart';

void main() {
  runApp(CascadeDropdown1());
}

class CascadeDropdown1 extends StatelessWidget {
  const CascadeDropdown1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Cascade Dropdown Example')),
        body: CascadeDropdown(),
      ),
    );
  }
}

class CascadeDropdown extends StatefulWidget {
  const CascadeDropdown({super.key});

  @override
  _CascadeDropdownState createState() => _CascadeDropdownState();
}

class _CascadeDropdownState extends State<CascadeDropdown> {
  String? _selectedRegion;
  String? _selectedZone;
  String? _selectedWoreda;
  Map<String, Map<String, List<String>>> locationData = {
    'Amhara': {
      'North Gonder': ['Debark', 'Dabat'],
      'East Gojam': [
        'Bahirdar',
        'Debremarkos',
        'Enarj Enawga',
        'Mota',
        'Dejen'
      ],
      'South Wollo': ['Dessie', 'Kombolcha', 'Bati', 'Debre Tabor'],
      'North Shewa': ['Debre Berhan', 'Ankober', 'Wuchale', 'Ginchi'],
    },
    'Oromia': {
      'West Arsi Zone': [
        'Shashemene',
        'Arsi Negele',
        'Kofele',
        'Asella',
        'Robe'
      ],
      'East Shewa Zone': ['Adama', 'Bishoftu', 'Mojo', 'Zeway', 'Dera'],
      'Jimma Zone': ['Jimma', 'Agaro', 'Limu Kosa', 'Sekoru', 'Gumii'],
      'Bale Zone': ['Robe', 'Ginnir', 'Goba', 'Delo Mena', 'Sinana'],
      'West Wollega': ['Nekemte', 'Gimbi', 'Dambi Dolo', 'Dembi Dolo', 'Gutin'],
    },
    'Tigray': {
      'North Tigray': ['Shire', 'Axum', 'Adwa', 'Adi Remets', 'Zalambessa'],
      'Central Tigray': ['Mekelle', 'Adigrat', 'Quiha', 'Wukro', 'Hawzien'],
      'Western Tigray': [
        'Humera',
        'Sheraro',
        'Dansha',
        'Adi Gudem',
        'May Tsebri'
      ],
    },
    'Somali': {
      'Siti Zone': ['Shinile', 'Erer', 'Aysha', 'Jijiga', 'Kebri Beyah'],
      'Jarar Zone': ['Degehabur', 'Kebri Dehar', 'Gode', 'Fik', 'Galadi'],
      'Afder Zone': ['Dolo Odo', 'Kelafo', 'Mustahil', 'Filtu', 'Liben'],
    },
    'Afar': {
      'Zone 1': ['Dubti', 'Ereb Ber', 'Awash', 'Asaita', 'Chifra'],
      'Zone 5': ['Ewa', 'Yalo', 'Mille', 'Chifra', 'Afdera'],
      'Zone 4': ['Semera', 'Afrera', 'Dalol', 'Berahle', 'Hamedela'],
    },
    'Benishangul-Gumuz': {
      'Assosa Zone': ['Assosa', 'Bambasi', 'Kurmuk', 'Menge', 'Chagni'],
      'Metekel Zone': ['Pawe', 'Guba', 'Galgalla', 'Bure', 'Shehedi'],
      'Kamashi Zone': ['Asosa', 'Guba Koricha', 'Dibate', 'Beyeda', 'Mandura'],
    },
    'Southern Nations, Nationalities, and Peoples': {
      'Sidama Zone': [
        'Hawassa',
        'Yirgalem',
        'Wendo Genet',
        'Dilla',
        'Aleta Wendo'
      ],
      'Wolaita Zone': ['Sodo', 'Boditi', 'Areka', 'Wolaita Sodo', 'Sawla'],
      'Gurage Zone': ['Butajira', 'Welkite', 'Silti', 'Endegagn', 'Cheha'],
    },
    'Gambela': {
      'Agnewak Zone': ['Gambela', 'Itang', 'Abobo', 'Gog', 'Jor'],
      'Nuer Zone': ['Matar', 'Jikawo', 'Akobo', 'Lare', 'Wanthowa'],
      'Mezhenger Zone': ['Gilo', 'Abobo', 'Gambella', 'Dimma', 'Gog woreda'],
    },
    'Harari': {
      'Harari Region': [
        'Harar',
        'Dire Dawa',
        'Asebe Teferi',
        'Jijiga',
        'Tuliguled'
      ],
      'Dire Dawa Special Zone': [
        'Dire Dawa',
        'Dhagaxbuur',
        'Deder',
        'Gursum',
        'Lebu'
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          DropdownButton<String>(
            hint: const Text('Select Region'),
            value: _selectedRegion,
            items: locationData.keys.map((String region) {
              return DropdownMenuItem<String>(
                value: region,
                child: Text(region),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedRegion = newValue;
                _selectedZone = null; // Reset the zone dropdown
                _selectedWoreda = null; // Reset the woreda dropdown
              });
            },
          ),
          if (_selectedRegion != null)
            DropdownButton<String>(
              hint: const Text('Select Zone'),
              value: _selectedZone,
              items: locationData[_selectedRegion!]!.keys.map((String zone) {
                return DropdownMenuItem<String>(
                  value: zone,
                  child: Text(zone),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedZone = newValue;
                  _selectedWoreda = null; // Reset the woreda dropdown
                });
              },
            ),
          if (_selectedZone != null)
            DropdownButton<String>(
              hint: const Text('Select Woreda'),
              value: _selectedWoreda,
              items: locationData[_selectedRegion!]![_selectedZone!]!
                  .map((String woreda) {
                return DropdownMenuItem<String>(
                  value: woreda,
                  child: Text(woreda),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedWoreda = newValue;
                });
              },
            ),
        ],
      ),
    );
  }
}
