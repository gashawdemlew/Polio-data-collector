import 'dart:async';
import 'dart:convert';

import 'package:camera_app/clinical_history.dart';
import 'package:camera_app/drawer.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/mo/constan.dart';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:location/location.dart' as location;

// import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
// import SharedPreferences from 'my_shared_preferences_package'

import '../../util/color/color.dart';
import '../../util/common/theme_helper.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();

class Patientdemographic extends StatefulWidget {
  const Patientdemographic({super.key});

  // const Patientdemographic({});

  @override
  _PatientdemographicState createState() => _PatientdemographicState();
}

class _PatientdemographicState extends State<Patientdemographic> {
  String? selectedFilePath;
  String? selectedFileName;
  String? _selectedRegion;
  String? _selectedZone;
  String? _selectedWoreda;
  String? _selectedGender;
  LanguageResources? resource12;
  LanguageResources? resource;

  String _selectedLanguage = "English";

  Map<String, Map<String, List<String>>> locationData = {
    "Addis Ababa": {
      "Arada sub-city": [
        "Adwa Dildiy Akebabi",
        "Abacoran Sefer",
        "Ambassador",
        "Amist Kilo",
        "Arat Kilo",
        "Aroge Kera",
        "Atekelet Tera",
        "Bias Meberat",
        "Doro Manekiya",
        "Enqulal Faberika",
        "Eri Bekentu",
        "Gedam Sefer",
        "Giorgis",
        "Habte Giorgis",
        "Piazza",
        "Posta Bet",
        "Ras Mekonnen Deldiy",
        "Sebara Babur",
        "Shola",
        "Somali Tera",
        "Taliyan Sefer",
        "Webe Berha",
        "Yohannes"
      ],
      "Bole Sub-city": [
        "Bole Lemi Industrial Park",
        "Bole Mikael",
        "Gerji",
        "Gewasa",
        "Ghiliffalegn Stream",
        "Kotebe",
        "Kotebe Shet",
        "Rwanda",
        "Tafo Shet",
        "Urael",
        "Woreda 11 Administrative Office",
        "Yeka Bole Bota",
        "Bole Arabsa",
        "Ayat Condominium",
        "Ayat Zone 2",
        "Ayat Zone 3",
        "Ayat Zone 5",
        "BlockLHS",
        "Chefie Condominium",
        "Flintstone Homes Condominium",
        "Jackros Condominium",
        "Natan Feleke Kibret Residence",
        "Noah Real Estate"
      ],
      "Kirkos Sub-city": [
        "Bantyiketu",
        "Beg Tera",
        "Beherawi",
        "Beklo Bet",
        "Bulgariya Sefer",
        "Enderase",
        "Gotera",
        "Kasanchis",
        "Kera",
        "Lancha",
        "Legehar",
        "Menaheriya Kasanchis",
        "Meshualekiya",
        "Meskel Flower",
        "Mexico",
        "Olympia",
        "Riche",
        "Sar Bet",
        "Wollo Sefer"
      ],
      "Lideta": [
        "Little Texas",
        "Abnet Square",
        "Agusta",
        "Berbere Berenda",
        "Ched Tera",
        "Coca",
        "Darmar",
        "Geja Seffer",
        "Golla Mikael",
        "Goma Kuteba",
        "Jos Hansen",
        "Ketena Hulet",
        "Mechare Meda",
        "Microlink Project",
        "Mobil",
        "Molla Maru",
        "Sengatera",
        "Tekle Haymanot",
        "Tor Hayloch"
      ],
      "Yeka Sub-city": [
        "Abado Project 13",
        "Adwa Dildiy Condominium",
        "Ayat Real Estate Development",
        "Balderas Condominium",
        "Signal",
        "Beg Tera",
        "Kara",
        "Kara Alo",
        "Kebena",
        "Kotebe",
        "Megenagna",
        "Sunshine Real Estate",
        "Yedejazmach Alula Irsha"
      ],
      "Addis Ketema Sub-city": [
        "Ammanuel Area",
        "American Gibi",
        "Ched Tera",
        "Doro Tera",
        "Korech Tera",
        "Mesob Tera",
        "Minalesh Tera",
        "Aserasement",
        "Autobus Tera",
        "Bomb Tera",
        "Chid Tera",
        "District 3",
        "Dubai Tera",
        "Ferash Tera",
        "Goma Tera",
        "Hadere Sefer",
        "Kolfe Tiwan",
        "Mentaf Tera",
        "Mesalemiya",
        "Military Tera",
        "Quasmeda",
        "Satin Tera",
        "Sebategna",
        "Sehan Tera",
        "Shanta Tera",
        "Shekla Tera",
        "Shema Tera",
        "Shera Tera",
        "Worik Twra"
      ],
      "Akaky Kaliti Sub-city": [
        "Endorro",
        "Koye",
        "Habitate",
        "Adiss",
        "Akaki Bota",
        "Akaki Beseka",
        "Akaki Kaliti",
        "Kebena",
        "Gelan Bota",
        "Saris",
        "Saris Abo Area",
        "Selbane",
        "Tug Kebena",
        "Tulu Dimitu"
      ],
      "Kolfe Keranio Sub-city": [
        "Kolfe Keranio",
        "Jemo 2",
        "Mickey Ieland Condo Site",
        "Repi Uppe",
        "Asko Area",
        "Asko Bercheko Faberika Area",
        "Atena Tera",
        "Ayer Tena",
        "Gebre Kirstos Bete Kristian",
        "Koshim",
        "Kurtume Stream",
        "Lekwuanda",
        "Lideta Gebriel Bete Kristian",
        "Nefro Neighborhood",
        "Sost Kuter Mazoria (Total)",
        "Zenebework",
        "Asera Sement Mazoria"
      ],
      "Nifas Silk-Lafto Sub-city": [
        "Jemo Michael",
        "Jemo 1",
        "Jemo 3",
        "Repi",
        "SOS Children's Village Addis Ababa",
        "Besrat Gebriel",
        "EECMY Residential Area",
        "Gofa",
        "Gofa Mebrathail",
        "Great Akaki",
        "Gulele Bota",
        "Haile Garment",
        "Hana",
        "Harbu Shet",
        "Irtu Bota",
        "Jemo",
        "Lafto",
        "Lebu",
        "Lebu Mebrathail",
        "Mekanisa",
        "Mekanisa Abo",
        "Menisa",
        "Vatican"
      ],
      "Gullele": ["Gullele Bota", "Yekatit 12 Square"]
    },
    "Amhara": {
      "North Gonder Zone": [
        "Debark",
        "Addi Arkay",
        "Alefa Beyeda",
        "Chilga",
        "Dabat",
        "Debarq",
        "Dembiya",
        "Gondar Town",
        "Gondar Zuria",
        "Jan Amora",
        "Lay Armachiho",
        "Metemma",
        "Mirab Armachiho",
        "Mirab Belessa",
        "Misraq Belessa",
        "Qwara",
        "Tach Armachiho",
        "Takusa",
        "Tegeda",
        "Tselemt",
        "Wegera"
      ],
      "South Gonder Zone": [
        "Debre Tabor Town",
        "Dera",
        "Ebenat",
        "Farta",
        "Fogera",
        "Lay Gayint",
        "Libo Kemekem",
        "Mirab Este",
        "Misraq Este",
        "Simada",
        "Tach Gayint"
      ],
      "East Gojjam Zone": [
        "Aneded",
        "Awabel",
        "Baso Liben",
        "Bibugn",
        "Debay Telatgen",
        "Debre Elias",
        "Debre Markos Town",
        "Dejen",
        "Enarj Enawga",
        "Enbise Sar Midir",
        "Enemay",
        "Goncha",
        "Goncha Siso Enese",
        "Gozamin",
        "Hulet Ej Enese",
        "Machakel",
        "Shebel Berenta",
        "Sinan",
        "Mota keranio"
      ],
      "West Gojjam Zone": [
        "Bahir Dar",
        "Bahir Dar Zuria",
        "Bure",
        "Dega Damot",
        "Debub Achefer",
        "Dembecha",
        "Jabi Tehnan",
        "Finote Selam Town",
        "Kuarit",
        "Mecha",
        "Sekela",
        "Semien Achefer",
        "Wemberma",
        "Yilmana Densa"
      ],
      "South Wollo Zone": [
        "Albuko",
        "Amba Sel",
        "Debre Sina",
        "Dessie Town",
        "Dessie Zuria",
        "Jama",
        "Kalu",
        "Kelela",
        "Kombolcha Town",
        "Kutaber",
        "Legahida",
        "Legambo",
        "Mekdela",
        "Mehal Sayint",
        "Amhara Sayint",
        "Tehuledere",
        "Tenta",
        "Wegde",
        "Were Babu",
        "Were Ilu"
      ],
      "North Wollo Zone": [
        "Weldiya Town",
        "Bugna",
        "Dawunt",
        "Delanta",
        "Gidan",
        "Guba Lafto",
        "Habru",
        "Kobo",
        "Lasta",
        "Meket",
        "Wadla"
      ],
      "Oromia Special Zone": [
        "Kemise Town",
        "Artuma Fursi",
        "Baati",
        "Dawa Chaffa",
        "Dawa Harewa",
        "Jilee Dhummuugaa"
      ],
      "North Shewa Zone": [
        "Debre Birhan Town",
        "Angolalla Tera",
        "Ankober",
        "Antsokiyana Gemza",
        "Asagirt",
        "Basona Werana",
        "Berehet",
        "Efratana Gidim",
        "Ensaro",
        "Gishe",
        "Hagere Mariamna Kesem",
        "Kewet",
        "Minjarna Shenkora",
        "Menz Gera Midir",
        "Menz Keya Gebreal",
        "Menz Lalo Midir",
        "Menz Mam Midir",
        "Merhabete",
        "Mida Woremo",
        "Moretna Jiru",
        "Shenona Wajirat",
        "Termaber"
      ],
      "Wag Hemra Zone": [
        "Abergele",
        "Dehana",
        "Gaz Gibla",
        "Sehala",
        "Sekota Town",
        "Zikuala"
      ],
      "Agew Awi Zone": [
        "Ankesha Guagusa",
        "Banja",
        "Chagni Town",
        "Dangila Town",
        "Guangua",
        "Jawi",
        "Fagita Lekoma",
        "Zigem"
      ]
    },
    'Oromia': {
      'Arsi Zone': [
        'Asella Town',
        'Aminya',
        'Aseko',
        'Bale Gasegar',
        'Batu Dugda',
        'Chole',
        'Digeluna Tijo',
        'Diksis',
        'Dodota',
        'Enkelo Wabe',
        'Gololcha',
        'Guna',
        'Hitosa',
        'Jeju',
        'Limuna Bilbilo',
        'Lude Hitosa',
        'Merti',
        'Munesa',
        'Robe',
        'Seru',
        'Sire',
        'Sherka',
        'Sude',
        'Tena',
        'Tiyo'
      ],
      'West Arsi Zone': [
        'Arsi Negele',
        'Shashamane Town',
        'Adaba',
        'Dodola',
        'Gedeb Asasa',
        'Kofele',
        'Kokosa',
        'Kore',
        'Naannawa Shashamane',
        'Nensebo',
        'Seraro',
        'Shala'
      ],
      'Jimma Zone': [
        'Jimma Town',
        'Agaro Town',
        'Chora Botor',
        'Dedo',
        'Gera',
        'Gomma',
        'Guma' 'Kersa',
        'Limmu Sakka',
        'Limmu Kosa',
        'Mana',
        'Omo Nada',
        'Seka Chekorsa',
        'Setema',
        'Shebe Senbo',
        'Sigmo',
        'Sokoru',
        'Tiro Afeta'
      ],
      'Bale Zone': [
        'Robe Town',
        'Agarfa',
        'Berbere',
        'Dawe Kachen',
        'Dawe Serara',
        'Delo Menna',
        'Dinsho',
        'Gasera',
        'Ginir',
        'Goba',
        'Goba Town',
        'Gololcha',
        'Goro',
        'Guradamo',
        'leLegehida',
        'Raytu',
        'Seweyna',
        'Sinana'
      ],
      'East Shewa Zone': [
        'Adama',
        'Bishoftu',
        'Ada',
        'Adami Tullu and Jido Kombolcha',
        'Batu town',
        'Bora',
        'Boset',
        'Dugda',
        'Fentale',
        'Gimbichu',
        'Liben',
        'Lome',
        'Nannawa'
      ],
      'North Shewa Zone': [
        'Fiche Town',
        'Abichu',
        'Aleltu',
        'Degem',
        'Dera',
        'Gerar Jarso',
        'Hidabu Abote',
        'Jido',
        'Kembibit',
        'Kuyu',
        'Liban',
        'Wara Jarso',
        'Wuchale',
        'Yaya Gulele'
      ],
      'West Shewa': [
        'Ambo Town',
        'Abuna Ginde Beret',
        'Adda Berga',
        'Bako Tibe',
        'Cheliya',
        'Dano',
        'Dendi',
        'Dire Enchini',
        'Ejerie',
        'Elfata',
        'Ginde Beret',
        'Gurraacha Enchini',
        'Jeldu',
        'Jibat',
        'Meta Robi',
        'Midakegn',
        'Naannawa Ambo',
        'Nono',
        'Toke Kutaye'
      ],
      'Southwest Shewa Zone': [
        'Waliso',
        'Waliso Town',
        'Wanchi',
        'Amaya',
        'Becho',
        'Dawo',
        'Elu',
        'Goro',
        'Kersana Malima',
        'Seden Sodo',
        'Sodo Dacha',
        'Tole'
      ],
      'East Welega Zone': [
        'Nekemte',
        'Bonaya Boshe',
        'Diga',
        'Gida Kiremu',
        'Gobu Seyo',
        'Gudeya Bila',
        'Guto Gida',
        'Haro Limmu',
        'Ibantu',
        'Jimma Arjo',
        'Leka Dulecha',
        'Limmu',
        'Nunu Kumba',
        'Sasiga',
        'Sibu Sire',
        'Wama Hagalo',
        'Wayu Tuka'
      ],
      'West Welega Zone': [
        'Gimbi',
        'Gimbi Town',
        'Ayra',
        'Babo Gambela',
        'Begi',
        'Boji Chokorsa',
        'Boji Dirmaji',
        'Genji',
        'Guliso',
        'Haru',
        'Homa',
        'Jarso',
        'Kondala',
        'Kiltu Kara',
        'Lalo Asabi',
        'Mana Sibu',
        'Nejo',
        'Nole Kaba',
        'Sayo Nole',
        'Yubdo'
      ],
      'Horo Guduru Welega Zone': [
        'Shambu Town',
        'Abay Chomen',
        'Abe Dongoro',
        'Amuru',
        'Guduru',
        'Hababo Guduru',
        'Horo',
        'Jardega Jarte',
        'Jimma Genete',
        'Jimma Rare'
      ],
      'Kelam Welega Zone': [
        'Dembidolo Town',
        'Anfillo',
        'Dale Sedi',
        'Dale Wabera',
        'Gawo Kebe',
        'Gidami',
        'Hawa Gelan',
        'Jimma Horo',
        'Lalo Kile',
        'Sayo',
        'Yemalogi Welele'
      ],
      'Borena Zone': [
        'Moyale',
        'Arero',
        'Dillo',
        'Dire',
        'Gomole',
        'Miyu',
        'Teltele',
        'Yabelo'
      ],
      'East Borena Zone': [
        'Negele Borana',
        'Guji woreda',
        'Gumi Eldalo',
        'Harena Buluk',
        'Liben',
        'Meda Welabu',
        'Moyale',
        'Moyale woreda',
        'Oborso',
        'Wachile'
      ],
      'East Hararghe Zone': [
        'Babile',
        'Badeno',
        'Chinaksen',
        'Dadar',
        'Fedis',
        'Girawa',
        'Gola Oda',
        'Goro Gutu',
        'Gursum',
        'Haro Maya',
        'Jarso',
        'Kersa',
        'Kombolcha',
        'Kurfa Chele',
        'Malka Balo',
        'Meyumuluke',
        'Meta',
        'Midega Tola'
      ],
      'West Hararghe Zone': [
        'Chiro Town',
        'Badessa Town',
        'Boke',
        'Char char',
        'Daru labu',
        'Doba',
        'Gamachis',
        'Guba Koricha',
        'Habro',
        'Kuni',
        'Masela',
        'Mieso',
        'Nannawa Chiro',
        'Tulo'
      ],
      'Buno Bedele Zone': [
        'Bedele Zuria',
        'Bedele Town',
        'Borecha',
        'Chewaka',
        'Chora',
        'Dabo Hana',
        'Dega',
        'Didessa',
        'Gechi',
        'Mako'
      ],
      'Illubabor Zone': [
        'Metu Zuria',
        'Metu Town',
        'Ale',
        'Alge Sache',
        'Bicho',
        'Bilo Nopha',
        'Bure',
        'Darimu',
        'Didu',
        'Doreni',
        'Huka Halu',
        'Hurumu',
        'Nono Sele',
        'Supena Sodo',
        'Yayu'
      ],
      'Guji Zone': [
        'Adola',
        'Adola Town',
        'Ana Sora',
        'Bore',
        'Dima',
        'Girja',
        'Harenfema',
        'Odo Shakiso',
        'Uraga',
        'Wadera'
      ],
      'West Guji Zone': [
        'Bule Hora',
        'Bule Hora woreda',
        'Abaya',
        'Birbirsa Kojowa',
        'Dugda Dawa',
        'Hambela Wamena',
        'Kercha',
        'Gelana',
        'Malka Soda',
        'Suro Barguda'
      ],
      'Finfinne Zuria Zone': [
        'Burayu Town',
        'Holeta Town',
        'Akaki',
        'Bereh',
        'Koye Feche',
        'Mulo',
        'Sebeta Hawas',
        'Sendafa Town',
        'Sululta',
        'Walmara'
      ]
    },
    'Tigray': {
      'North Western Tigray Zone': [
        'Asgede Tsimbla',
        'Lailay Adiyabo',
        'Medebay Zana',
        'Sheraro',
        'Shire Inda Selassie',
        'Tahtay Adiyabo',
        'Tahtay Koraro',
        'Tselemti',
        'Tsimbla'
      ],
      'Central Tigray Zone': [
        'Mekelle',
        'Abergele',
        'Adwa',
        'Adwa Town',
        'Axum',
        'Enticho',
        'Kola Tembien',
        'Lailay',
        'Maychew',
        'Mereb Lehe',
        'Naeder Adet',
        'Tahtay Maychew',
        'Tanqua Millash',
        'Werie Lehe'
      ],
      'Western Tigray ZOne': ['Kafta Humera', 'Tsegede', 'Welkait'],
      ', '
          'Southern Tigray Zone': [
        'Alaje',
        'Alamata',
        'Endamekoni',
        'Korem',
        'Maychew',
        'Ofla',
        'Raya Azebo'
      ],
      'Eastern Tigray Zone': [
        'Adigrat',
        'Atsbi Wenberta',
        'Ganta Afeshum',
        'Gulomahda',
        'Hawzen',
        'Irob',
        'Kilte Awulaelo',
        'Saesi Tsaedaemba',
        'Wukro'
      ],
      'South Eastern Tigray Zone': [
        'Dogu',
        ' Tembien',
        'Enderta',
        'Hintalo Wajirat',
        'Saharti Samre'
      ]
    },
    'Somali': {
      'Sitti Zone': [
        'Adigala',
        'Afdem',
        'Ayesha',
        'Bike',
        'Dambel',
        'Erer',
        'Gablalu',
        'Mieso',
        'Shinile'
      ],
      'Jarar Zone': [
        'Araarso',
        'Awaare',
        'Bilcil buur',
        'Bir-qod',
        'Daroor',
        'Degehabur',
        'Dhagaxmadow',
        'Dig',
        'unagado',
        'Misraq Gashamo',
        'Yoocaale'
      ],
      'Afder Zone': [
        'Afder',
        'Bare',
        'Chereti',
        'Dolobay',
        'lekere',
        'GodGod',
        'Hargelle',
        'Iligdheere',
        'Mirab Imi',
        'Raaso',
        'Qooxle'
      ],
      'Dhawa Zone': ['Hudet', 'Moyale', 'Mubaarak', 'Qadhaadhumo'],
      'Dollo Zone': [
        'Boh',
        'Danot',
        'Daratole',
        'Gal-Hamur',
        'Geladin',
        'Lehel-Yucub',
        'Warder'
      ],
      'Erer Zone': [
        'Fiq',
        'Lagahida',
        'Mayaa-muluqo',
        'Qubi',
        'Salahad',
        'Waangaay',
        'Xamaro',
        'Yaxoob'
      ],
      'Fafan Zone': [
        'Jijiga',
        'Awbare',
        'Babille',
        'Goljano',
        'Gursum',
        'Harawo',
        'Haroorayso',
        'Harshin',
        'Kebri Beyah special woreda',
        'Qooraan/MullaShabeeley',
        'Wajale special woreda',
        'Tuli Guled'
      ],
      'Korahe Zone': [
        'Boodaley',
        'Ceel-Ogadeen',
        'Debeweyin',
        'Higloley',
        'Kebri Dahar special woreda',
        'Kudunbuur',
        'Laas-dhankayre',
        'Marsin',
        'Shekosh',
        'Shilavo'
      ],
      'Liben Zone': [
        'Bokolmayo',
        'Deka Softi',
        'Dolo Odo',
        'Filtu',
        'Goro Bekeksa',
        'Guradamole',
        'Kersa Dula'
      ],
      'Nogob Zone': [
        'Ayun',
        'Dihun',
        'Elweyne',
        'Gerbo',
        'Hararey/Xaraarey',
        'Hora-shagax',
        'Segeg'
      ],
      'Shabelle Zone': [
        'Abaaqoorow',
        'Adadle',
        'Beercaano',
        'Danan',
        'Elele',
        'Ferfer',
        'Gode special woreda',
        'Imiberi',
        'Kelafo',
        'Mustahil'
      ]
    },
    'Afar': {
      'Awsi Rasu (Zone 1)': [
        'Asayita',
        'Chifra',
        'Dubti',
        'Adaar',
        'Afambo',
        'Elidar',
        'Kori',
        'Mille'
      ],
      'Kilbet Rasu (Zone 2)': [
        'Abala',
        'Afdera',
        'Berhale',
        'Bidu',
        'Dallol',
        'Erebti',
        'Koneba',
        'Megale'
      ],
      'Gabi Rasu (Zone 3)': [
        'Amibara',
        'Awash Fentale',
        'Bure Mudaytu',
        'Dulecha',
        'Gewane'
      ],
      'Fantí Rasu (Zone 4)': ['Aura', 'Ewa', 'Gulina', 'Teru', 'Yalo'],
      'Hari Rasu (Zone 5)': [
        'Dalifage',
        'DeweHadele Ele',
        'Simurobi Gele',
        'alo',
        'Telalak'
      ],
      'Special Woreda': ['Argobba']
    },
    'Benishangul-Gumuz': {
      'Assosa Zone': [
        'Asosa',
        'Bambasi',
        'Komesha',
        'Kurmuk',
        'Menge',
        'Oda Buldigilu',
        'Sherkole'
      ],
      'Metekel Zone': [
        'Bulen',
        'Dangur',
        'Dibate',
        'Guba',
        'Mandura',
        'Wenbera'
      ],
      'Kamashi Zone': [
        'Agalo Mite',
        'Belo Jegon',
        'foy',
        'Kamashi',
        'Sirba Abbay',
        'Yaso'
      ],
      'Special woredas': ['Mao-Komo', 'Pawe']
    },
    'South Ethiopia Regional State': {
      'Wolayita Zone': [
        'Wolaita Sodo (city)',
        'Tebela (town)',
        'Sodo Zuria',
        'Abala Abaya',
        'Bayra Koysha',
        'Areka (town)',
        'Bale Hawassa (town)',
        'Boditi (town)',
        'Boloso Bombe',
        'Boloso Sore',
        'Damot Gale',
        'Damot Pulasa',
        'Damot Sore',
        'Damot Weyde',
        'Diguna Fango',
        'Gesuba (town)',
        'Gununo (town)',
        'Hobicha',
        'HumboKawo Koysha',
        'Kindo Didaye',
        'Kindo Koysha',
        'Offa'
      ],
      'Gamo Zone': [
        'Arba Minch (town)',
        'Arba Minch Zuria',
        'Bonke',
        'Boreda',
        'Chencha',
        'Deramalo',
        'Dita',
        'Garda Marta',
        'Geressie Zuria',
        'Gacho Baba',
        'Kamba Zuria',
        'Kucha',
        'Kucha Alfa',
        'Mirab Abaya',
        'Qogota',
        'Selamber (town)'
      ],
      'Gofa Zone': [
        'Bulki (town)',
        'Demba Gofa',
        'Gada',
        'Geze Gofa',
        'Melokoza',
        'Oyda',
        'Sawla (town)',
        'Uba Debretsehay',
        'Zala'
      ],
      'Ale Zone': ['Kolango (town)', 'Kolango Zuria'],
      'Kore Zone': ['Kelle (town)', 'Gorka', 'Sarmale'],
      'Ari Zone': [
        'Jinka (town)',
        'Bako Dawla Ari',
        'Debub Ari',
        'Gelila',
        'Semen Ari',
        'Woba Ari'
      ],
      'Basketo Zone': ['Laska (town)', 'Laska Zuria'],
      'Burji Zone': ['Soyama (town)', 'Soyama Zuria'],
      'Gardula Zone': ['Gidole (town)', 'Dirashe Woreda'],
      'Gedeo Zone': [
        'Dilla (town)',
        'Dila Zuria',
        'Yirgachefe',
        'Bule',
        'Gedeb',
        'Kochere',
        'Wenago'
      ],
      'Konso Zone': [
        'Karat Zuria',
        'Kena (woreda)',
        'Karati (town)',
        'Kolme',
        'Segen Zuria'
      ],
      'South Omo Zone': [
        'Turmi (town)',
        'Hamer',
        'Bako Gazer',
        'Bena Tsemay',
        'Dasenech',
        'Dimeka (town)',
        'Kuraz',
        'Male',
        'Nyangatom',
        'Selamago'
      ]
    },
    'Sidama': {
      'Hawassa': [
        'Addis ketema sub city',
        'Hayk dar sub city',
        'Mehal sub city',
        'Menahariya sub city',
        'Misrak sub city',
        'Tabor sub city',
        'Hawela tula sub city',
        'Bahil Adarash sub-city'
      ],
      'Central Sidama Zone': [
        'Irgalem (town)',
        'Arbegona',
        'Dale',
        'Darara',
        'Loko Abaya',
        'Shafamo',
        'Wensho'
      ],
      'Eastern Sidama Zone': [
        'Aroresa',
        'Bensa',
        'Bona Zuria',
        'Bura',
        'Chabe Gambeltu',
        'Chere',
        'Daela',
        'Daye (town)',
        'Hoko'
      ],
      'Northern Sidama Zone': [
        'Hawassa Zuria',
        'Wondo Genet',
        'Bilate Zuria',
        'Boricha',
        'Gorche',
        'Malga',
        'Shebedino'
      ],
      'Southern Sidama Zone': [
        'Aleta Wendo',
        'Aleta Wendo (town)',
        'Bursa',
        'Chuko',
        'Dara',
        'Dara Otilcho',
        'Hula',
        'Teticha'
      ]
    },
    'Central Ethiopia Regional State': {
      'East Gurage Zone': [
        'Butajira (town)',
        'Buee (town)',
        'East Meskane',
        'Enseno (town)',
        'Meskane',
        'North Soddo',
        'South Soddo'
      ],
      'Gurage Zone': [
        'Wolkite (town)',
        'Abeshge',
        'Cheha',
        'Endegagn',
        'Enemorina Eaner',
        'Ezha',
        'Geta',
        'Gumer',
        'Kokir Gedebano',
        'Muhor Na Aklil'
      ],
      'Hadiya Zone': [
        'Hosaena (town)',
        'Ana Lemo',
        'Duna',
        'Gibe',
        'Gomibora',
        'Lemo',
        'Mirab Badawacho',
        'Misha',
        'Misraq Badawacho',
        'Shashogo',
        'Soro'
      ],
      'Halaba Zone': ['Atoti Ullo', 'Kulito (town)', 'Wera'],
      'Kembata Zone': [
        'Adilo Zuria',
        'Angacha',
        'Damboya',
        'Doyogena',
        'Durame Town',
        'Hadero Tunto',
        'Kacha Bira',
        'Kedida Gamela'
      ],
      'Silte Zone': [
        'Silti',
        'Worabe (town)',
        'Alicho Werero',
        'Dalocha',
        'Lanfro',
        'Mirab Azernet Berbere',
        'Misraq Azernet Berbere',
        'Sankurra',
        'Wulbareg'
      ],
      'Yem Zone': ['Saja (town)', 'Deri Saja Zuria'],
      'Special woredas': [
        'Kebena Special Woreda',
        'Mareko Special Woreda',
        'Tembaro Special Woreda'
      ]
    },
    'Sour West Ethiopia Peoples Region': {
      'Keffa Zone': [
        'Bonga (town)',
        'Adiyo',
        'Awurada (town)',
        'Bita',
        'Chena',
        'Cheta',
        'Decha',
        'Deka (town)',
        'Gesha',
        'Gewata',
        'Ginbo',
        'Goba',
        'Menjiwo',
        'Sayilem',
        'Telo',
        'Shishinda (town)',
        'Shisho Ende',
        'Wacha (town)'
      ],
      'Bench Sheko Zone': [
        'Mizan Aman (town)',
        'Debub Bench',
        'Gidi Bench',
        'Guraferda',
        'Semien Bench',
        'Shay Bench',
        'Sheko',
        'Siz (town)',
        'Former woredas Bench',
        'Meinit'
      ],
      'Dawro Zone': [
        'Tarcha (town)',
        'Tarcha Zuria',
        'Disa',
        'Gena',
        'Isara',
        'Kechi',
        'Loma Bosa',
        'Mareka',
        'Mari Mansa',
        'Tocha',
        'Zaba Gazo',
        'Former woredas Isara Tocha',
        'Mareka Gena'
      ],
      'Konta Zone': [
        'Ameya (town)',
        'Ameya Zuria',
        'Ela Hanchano',
        'Konta Koysha'
      ],
      'Sheka Zone': [
        'Tepi (town)',
        'Anderacha',
        'Masha (town)',
        'Masha',
        'Yeki',
        'Former woredas Masha Anderacha'
      ],
      'West Omo Zone': [
        'Bachuma (town)',
        'Jemu (town)',
        'MajiSurma',
        'Bero',
        'Meinit Goldiya',
        'Meinit Shasha',
        'Gachit',
        'Gori Gesha'
      ]
    },
    'Gambela': {
      'Anyuak Zone': ['Gambela', 'Abwobo', 'Dimma', 'Gog', 'Jor'],
      'Nuer Zone': ['Akobo', 'Jikaw', 'Lare', 'Wentawo'],
      'Mezhenger Zone': ['Godere', 'Mengesh'],
      'Special woredas': ['Itang']
    },
    'Harari': {
      'Special Woredas': [
        'Amir-Nur Woreda',
        'Abadir Woreda',
        'Shenkor Woreda',
        'Jin',
        'Eala Woreda',
        'Aboker Woreda',
        'Hakim Woreda',
        'Sofi Woreda',
        'Erer Woreda',
        'Dire-Teyara Woreda'
      ],
      'Dire Dawa Special Zone': [
        'Dire Dawa',
        'Dhagaxbuur',
        'Deder',
        'Gursum',
        'Lebu'
      ]
    },
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController EPID_Number = TextEditingController();
  final TextEditingController names = TextEditingController();
  final TextEditingController first_name = TextEditingController();

  final TextEditingController last_name = TextEditingController();
  final TextEditingController phoneNo = TextEditingController();

  // final TextEditingController names = TextEditingController();

  final TextEditingController Date_of_birth = TextEditingController();

  final TextEditingController Province = TextEditingController();
  final TextEditingController District = TextEditingController();
  final _dateController = TextEditingController();

  final String _empId = '';
  final String _oId = '';
  String languge = "ccc";
  LanguageResources? resources;

  late DateTime currentDate;
  late String formattedDate;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _loadUserDetails();
    _loadLanguage45();
    currentDate = DateTime.now();
    formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    _loadLanguage().then((_) {
      setState(() {
        _selectedLanguage = languge;
        resources = LanguageResources(languge);
      });
    });
  }

  final TextEditingController _epidNumberController = TextEditingController();

  final currentDate56 = DateFormat('yyyy-MM-dd').format(DateTime.now());

  double latitude = 0.0;
  double longitude = 0.0;
  Future<void> getCurrentLocation() async {
    var locationPlugin = location.Location();

    try {
      location.PermissionStatus permission =
          await locationPlugin.hasPermission();
      if (permission == location.PermissionStatus.denied) {
        permission = await locationPlugin.requestPermission();
        if (permission != location.PermissionStatus.granted) {
          print('Location permission denied');
          return;
        }
      }

      location.LocationData locationData = await locationPlugin.getLocation();

      setState(() {
        latitude = locationData.latitude ?? 0.0;
        longitude = locationData.longitude ?? 0.0;
        print(latitude);
      });

      print('Latitude: $latitude, Longitude: $longitude');

      // getAddressFromLatLng();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedLanguage = prefs.getString('selectedLanguage') ?? 'none';
    if (mounted) {
      setState(() {
        languge = storedLanguage;
      });
    }
  }

  Future<void> _loadLanguage45() async {
    // Simulate language loading
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      resources = LanguageResources(languge); // or "English"
      resource12 = resources;
    });
  }

  Map<String, dynamic> userDetails = {};
  String xx = '';

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userDetails = {
        'email': prefs.getString('email') ?? 'N/A',
        'userType': prefs.getString('userType') ?? 'N/A',
        'firstName': prefs.getString('first_name') ?? 'N/A',
        'phoneNo': prefs.getString('phoneNo') ?? 'N/A',
        'zone': prefs.getString('zone') ?? 'N/A',
        'woreda': prefs.getString('woreda') ?? 'N/A',
        'id': prefs.getInt('id') ?? 'N/A',
        'selectedLanguage': prefs.getString('selectedLanguage') ?? 'N/A',
      };
    });

    setState(() {
      xx = userDetails['selectedLanguage'];
    });
  }

  bool isSubmitting = false;
  String epid_Number = "";
  Future<void> _submitForm() async {
    final url = Uri.parse('${baseUrl}clinic/prtientdemographi');

    final body = json.encode({
      'latitude': latitude,
      'longitude': longitude,
      'first_name': first_name.text,
      'last_name': last_name.text,
      'phoneNo': phoneNo.text,
      "gender": _selectedGender,
      "dateofbirth": Date_of_birth.text,
      "user_id": userDetails['id'],
      "region": _selectedRegion,
      "zone": _selectedZone,
      "woreda": _selectedWoreda
    });

    setState(() {
      isSubmitting = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        final responseBody =
            json.decode(response.body); // Decode the response body

        setState(() {
          epid_Number = responseBody['epid_number'];
        });
        print(epid_Number);
        print('Form submitted successfully!  ${responseBody}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully!')),
        );

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ClinicalHistoryForm(epid_Number: epid_Number),
            ));
      } else {
        print('Failed to submit form: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit form: ${response.body}')),
        );
      }
    } catch (error) {
      print('Error submitting form: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting form: $error')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: Drawer45(),
      appBar: AppBar(
        title: Text(
          resources?.patientDemographic()["Patientdemographic"] ?? '',
          style: GoogleFonts.splineSans(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(45.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                readOnly: true, // make it read-only
                controller: TextEditingController(text: latitude.toString()),
                decoration: ThemeHelper().textInputDecoration(
                    resources?.patientDemographic()["latitude"] ?? '',
                    resources?.patientDemographic()["latitude"] ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Longitude is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                readOnly: true, // make it read-only
                controller: TextEditingController(text: longitude.toString()),
                decoration: ThemeHelper().textInputDecoration(
                    resources?.patientDemographic()["longitude"] ?? '',
                    resources?.patientDemographic()["longitude"] ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Longitude is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: first_name,
                decoration: ThemeHelper().textInputDecoration(
                    resources?.patientDemographic()["First name"] ?? '',
                    resources?.patientDemographic()["First name"] ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an Patients Name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: last_name,
                decoration: ThemeHelper().textInputDecoration(
                    resources?.patientDemographic()["Last name"] ?? '',
                    resources?.patientDemographic()["Last name"] ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an Patients Name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: phoneNo,
                decoration: ThemeHelper().textInputDecoration(
                    resources?.patientDemographic()["Phone number"] ?? '',
                    resources?.patientDemographic()["Phone number"] ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (value.length != 10 ||
                      !RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                hint: Text(
                  languge == "Amharic" ? "ጾታ ምረጥ" : "Select Gender",
                ),
                value: _selectedGender,
                dropdownColor: Colors.white,
                items: ['Male', 'Female', 'Other'].map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                decoration: ThemeHelper().textInputDecoration(
                    resources?.patientDemographic()["gender"] ?? '',
                    resources?.patientDemographic()["gender"] ?? ''),
                validator: (value) {
                  if (value == null) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: Date_of_birth,
                readOnly: true,
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      Date_of_birth.text = pickedDate
                          .toString()
                          .split(' ')[0]; // Only the date part
                    });
                  }
                },
                decoration: ThemeHelper().textInputDecoration(
                    '${resources?.patientDemographic()["dateOfBirth"] ?? ''} ',
                    '${resources?.patientDemographic()["dateOfBirth"] ?? ''} '),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                hint: Text(
                  languge == "Amharic" ? "ክልል ምረጥ" : "Select Region",
                ),
                dropdownColor: const Color.fromARGB(255, 213, 144, 144),
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
                decoration: ThemeHelper().textInputDecoration(
                  languge == "Amharic" ? "ክልል ምረጥ" : "Select Region",
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a region';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              if (_selectedRegion != null)
                DropdownButtonFormField<String>(
                  hint: Text(
                    languge == "Amharic" ? "ዞን ምረጥ" : "Select Zone",
                  ),
                  value: _selectedZone,
                  dropdownColor: Colors.white,
                  items:
                      locationData[_selectedRegion!]!.keys.map((String zone) {
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
                  decoration: ThemeHelper().textInputDecoration(
                      resources?.patientDemographic()["Select Zone "] ?? '',
                      resources?.patientDemographic()["Select Zone"] ?? ''),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a zone';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16.0),
              if (_selectedZone != null)
                DropdownButtonFormField<String>(
                  hint: Text(
                    languge == "Amharic" ? "ወረዳ ምረጥ" : "Select Woreda",
                  ),
                  dropdownColor: Colors.white,
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
                  decoration: ThemeHelper().textInputDecoration(
                      resources?.patientDemographic()["Select Woreda "] ?? '',
                      resources?.patientDemographic()["Select Woreda"] ?? ''),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a woreda';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16.0),
              const SizedBox(height: 16.0),
              SizedBox(
                width: 370,
                child: ElevatedButton(
                  onPressed: () {
                    _submitForm();
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => ClinicalHistoryForm(
                    //               epid_Number: epid_Number,
                    //               // resources1: widget.resources1,
                    //               // first_name: first_name.text,
                    //               // last_name: last_name.text,
                    //               // phoneNo: phoneNo.text,
                    //               // latitude: latitude.toString(),
                    //               // longitude: longitude.toString(),
                    //               // epid_number: EPID_Number.text,
                    //               // name: names.text,
                    //               // gender: _selectedGender ?? '',
                    //               // dateofbirth: Date_of_birth.text,
                    //               // region: _selectedRegion.toString(),
                    //               // zone: _selectedZone.toString(),
                    //               // woreda: _selectedZone.toString(),
                    //             )));
                  },
                  //  isSubmitting ? Text('Saving...') : Text('Submit'),

                  //
                  // Text(
                  //     widget.resources1?.patientDemographic()["next"] ?? ''),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        CustomColors.testColor1, // Change the text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8.0), // Adjust the border radius
                    ),
                    elevation: 14, // Add elevation
                  ),
                  child: Text(
                    isSubmitting
                        ? (languge == "Amharic" ? 'ቀጣይ...' : 'Saving...')
                        : (languge == "Amharic" ? 'ቀጣይ' : 'Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
