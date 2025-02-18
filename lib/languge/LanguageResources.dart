class LanguageResources {
  final String language;

  LanguageResources(this.language);

  Map<String, String> loginLanguage() {
    return {
      "welcomeMessage": language == "Amharic"
          ? "እንኳን ደህና ቆዩ"
          : language == "AfanOromo"
              ? "Baga nagaan deebitan"
              : "Welcome Back",
      "email": language == "Amharic"
          ? "እሜይል"
          : language == "AfanOromo"
              ? "Imeelii"
              : "Email",
      "forgetPassword": language == "Amharic"
          ? "ፓሥዎርድ እረስትተዋለ?"
          : language == "AfanOromo"
              ? "Jecha darbii irraanfattanii?"
              : "Forget Password?",
      "password": language == "Amharic"
          ? "ፓሥዎርድ"
          : language == "AfanOromo"
              ? "Jecha darbii"
              : "Password",
      "loginButton": language == "Amharic"
          ? "ግባ"
          : language == "AfanOromo"
              ? "Seenii"
              : "Login",
      "selectLanguage": language == "Amharic"
          ? "ቋንቋ ምረጥ"
          : language == "AfanOromo"
              ? "Afaan filadhu"
              : "Select Language",
    };
  }

  Map<String, String> homepage() {
    return {
      "appbar": language == "Amharic" ? 'ፖሊዮ ዳሽቦርድ' : 'Dashboard!',
      "welcomeMessage": language == "Amharic" ? 'ፖሊዮ ዳሽቦርድ' : 'Dashboard!',
      "polioOverview":
          language == "Amharic" ? 'ፖሊዮ አጠቃላይ እይታ' : 'Polio Overview!',
    };
  }

  Map<String, String> drawer() {
    return {
      "header": language == "Amharic"
          ? 'ፖሊዮ ዳሽቦርድ'
          : language == "AfanOromo"
              ? "Jalqaba"
                  'Polio Dashboard'
                  "title"
              : language == "Amharic"
                  ? 'ርዕስ'
                  : 'Title',
      "Create New petient ": language == "Amharic"
          ? 'አዲሰ ታካሚ መዝግብ'
          : language == "AfanOromo"
              ? "Ergaa"
              : 'Create New petient ',
      "image": language == "Amharic"
          ? 'አዲሰ ታካሚ መዝግብ'
          : language == "AfanOromo"
              ? "Odeeffannoon barbaachisu akka hin dhabamnetti suura qulqullina qabu kaasaa"
              : 'Please capture unblurred quality image without losing important information about the patient ',
      "video": language == "Amharic"
          ? 'አዲሰ ታካሚ መዝግብ'
          : language == "AfanOromo"
              ? "Viidiyoo waraabuun sekondii 10 booda kandhaabbatu ta&#39;a, qulqullinaan odeeffannoo barbaachisaa osoo hin dhabamssisin waraabaa"
              : 'The video recording will be stopped after 10 seconds, please be conscious and record it without missing essential information. ',
      "home": language == "Amharic"
          ? 'መነሻ'
          : language == "AfanOromo"
              ? "Jalqaba"
              : 'Home',
      "profile": language == "Amharic"
          ? 'የፕሮፋይል ገጽ'
          : language == "AfanOromo"
              ? "Piroofaayilii"
              : 'Profile',
      "Incomplete petient Records": language == "Amharic"
          ? ' የታካሚ መዝገቦች'
          : language == "AfanOromo"
              ? "Gosoota galtee"
              : 'Profile',
      "categories": language == "Amharic"
          ? 'ምድቦች'
          : language == "AfanOromo"
              ? "Gosoota galtee"
              : 'Categories',
      "patientDemographic":
          language == "Amharic" ? 'የታካሚ መረጃ' : 'Patient Demographic',
      "clinicalHistory": language == "Amharic"
          ? 'ክሊኒካዊ ታሪክ'
          : language == "AfanOromo"
              ? 'Seenaa Kiliinikaa'
              : 'Clinical History',
      "stoolSpecimen": language == "Amharic" ? 'የሰገራ ናሙና' : 'Stool Specimen',
      "followUp": language == "Amharic" ? 'የክትትል ምርመራ' : 'Follow Up',
      "environmentalMethodology":
          language == "Amharic" ? 'የአካባቢ አቀራረብ' : 'Environmental Methodology',
      "camera": language == "Amharic" ? 'ካሜራ' : 'Camera',
      "LaboratoryInformation": language == "Amharic"
          ? 'የላቦራቶሪ መረጃ / የመጨረሻ ምደባ'
          : 'LaboratoryInformation/Finalclassification',
      "video": language == "Amharic" ? 'ቪዲዮ' : 'Video',
      "setting": language == "Amharic"
          ? 'ቅንብር'
          : language == "AfanOromo"
              ? "Qindeessituu"
              : 'Setting',
      "logout": language == "Amharic"
          ? 'ውጣ'
          : language == "AfanOromo"
              ? "Ba’i"
              : 'Logout',
      "Voluntar Messages": language == "Amharic"
          ? 'የበጎ ፍቃደኛ መልዕክት'
          : language == "AfanOromo"
              ? "Voluntar Messages"
              : 'Voluntar Messages',
      "Create New Petient": language == "Amharic"
          ? 'አዲስ ታካሚ መዝግብ  '
          : language == "AfanOromo"
              ? "Create New Petient"
              : 'Create New Petient"',
    };
  }

  Map<String, String> patientDemographic() {
    return {
      "Patientdemographic": language == "Amharic"
          ? 'የታካሚ መረጃ መዝግብ'
          : language == "AfanOromo"
              ? "Odeeffannoo dhukkubsataa"
              : 'Patient Demographic',
      "latitude": language == "Amharic"
          ? 'ኬክሮስ'
          : language == "AfanOromo"
              ? 'Laatiituudii'
              : 'Latitude',
      "longitude": language == "Amharic"
          ? 'ኬንትሮስ'
          : language == "AfanOromo"
              ? 'Loongiituudii'
              : 'Longitude',
      "epidNumber": language == "Amharic" ? 'Epid ቁጥር' : 'Epid Number',
      "name": language == "Amharic"
          ? 'ስም አስገባ'
          : language == "AfanOromo"
              ? "Maqaa"
              : 'Enter Name',
      "First name": language == "Amharic"
          ? 'ስም '
          : language == "Maqaa"
              ? "Maqaa"
              : 'First name',
      "Last name": language == "Amharic"
          ? 'ያባት ስም '
          : language == "AfanOromo"
              ? "Maqaa abbaa"
              : 'Last name',
      "gender": language == "Amharic"
          ? 'ጾታ'
          : language == "AfanOromo"
              ? "Saala"
              : 'Gender',
      "Phone number": language == "Amharic"
          ? 'ስልክ ቁጥር'
          : language == "AfanOromo"
              ? "Lakkoofsa bilbilaa"
              : 'Phone number',
      "Select Region": language == "Amharic"
          ? 'ክልል ምረጥ'
          : language == "AfanOromo"
              ? "Naannoo"
              : 'Select Region',
      "Select Zone": language == "Amharic"
          ? 'ዞን ምረጥ'
          : language == "AfanOromo"
              ? "Zoonii"
              : 'Select Zone',
      "Select Woreda": language == "Amharic"
          ? 'ዎረዳ ምረጥ'
          : language == "AfanOromo"
              ? "Aanaa"
              : 'Select Woreda',
      "dateOfBirth": language == "Amharic"
          ? 'የተወለደበት ቀን'
          : language == "AfanOromo"
              ? "Guuyyaa dhalootaa"
              : 'Date of Birth',
      "province": language == "Amharic" ? 'ክፍለ ሀገር' : 'Province',
      "district": language == "Amharic" ? 'ዲስትሪክት' : 'District',
      "next": language == "Amharic"
          ? 'ቀጣይ'
          : language == "AfanOromo"
              ? "Itti aanee"
              : 'Next',
      "Region": language == "Amharic"
          ? 'ክልል'
          : language == "AfanOromo"
              ? "Naannoo"
              : 'Region',
      "Zone": language == "Amharic"
          ? 'ዞን'
          : language == "AfanOromo"
              ? "Zoonii"
              : 'Zone',
      "Woreda": language == "Amharic"
          ? 'ወረዳ'
          : language == "AfanOromo"
              ? "Aanaa"
              : 'woreda',
    };
  }

  Map<String, String> clinicalHistory() {
    return {
      "clinicalhistoryform": language == "Amharic"
          ? 'ክሊኒካዊ ታሪክ ቅጽ'
          : language == "AfanOromo"
              ? "Seenaa kiliinikaalaa"
              : 'clinical history form',
      "dateAfterOnset": language == "Amharic"
          ? 'ከተጀመረ በኋላ ቀናት'
          : language == "AfanOromo"
              ? "Guyyaa itti jalqabe"
              : 'Date of Onset',
      "selectDate": language == "Amharic"
          ? 'ቀን ይምረጡ'
          : language == "AfanOromo"
              ? "Guyyaa filadhu"
              : 'Select Date',
      "feverAtOnset": language == "Amharic"
          ? 'በመጀመሪያው የተነሳብል እንቅልፍ'
          : language == "AfanOromo"
              ? "Ho’a qaamaa guyyaa itti jalqabee"
              : 'Fever at Onset',
      "yes": language == "Amharic"
          ? 'አዎ'
          : language == "AfanOromo"
              ? "Eeyyee"
              : 'Yes',
      "no": language == "Amharic"
          ? 'አይደለም'
          : language == "AfanOromo"
              ? "Lakki"
              : 'No',
      "flaccidAndSuddenParalysis": language == "Amharic"
          ? 'ደካማ እና ድንገተኛ ፓራላይሲስ'
          : language == "AfanOromo"
              ? "Dadhabbii fi tasa laamsha’uu"
              : 'Flaccid and Sudden Paralysis',
      "paralysisProgressed": language == "Amharic"
          ? 'ፓራሎስ የተሻሻለ ቀን <=3'
          : language == "AfanOromo"
              ? "Jijjiirama laamsha’uu <= guyyaa 3"
              : 'Paralysis Progressed <=3 Day',
      "asymmetric": language == "Amharic"
          ? 'ያልተመጣጠነ'
          : language == "AfanOromo"
              ? "Walqixaafi walfakkaataa kan hin taane"
              : 'Asymmetric',
      "siteOfParalysis": language == "Amharic"
          ? 'የፓራሎስ ቦታ'
          : language == "AfanOromo"
              ? "Bakka laamsha’e"
              : 'Site of Paralysis',
      "leftArm": language == "Amharic"
          ? 'የግራ ክንድ'
          : language == "AfanOromo"
              ? "Harka bitaa"
              : 'Left Arm',
      "rightArm": language == "Amharic"
          ? 'የቀኝ ክንድ'
          : language == "AfanOromo"
              ? "Harka mirgaa"
              : 'Right Arm',
      "leftLeg": language == "Amharic"
          ? 'የግራ እግር'
          : language == "AfanOromo"
              ? "Bakka laamsha’e"
              : 'Left Leg',
      "rightLeg": language == "Amharic"
          ? 'የቀኝ እግር'
          : language == "AfanOromo"
              ? "Miilla mirgaa"
              : 'Right Leg',
      "EntertotalOPVdose": language == "Amharic"
          ? 'አጠቃላይ የ OPV መጠን ያስገቡ'
          : 'Enter total OPV dose',
      "totalOpvDoses": language == "Amharic"
          ? 'አጠቃላይ የ OPV መጠኖች'
          : language == "AfanOromo"
              ? "Doozi OPV waliigalaa"
              : 'Total OPV Doses',
      "admittedToHospital": language == "Amharic"
          ? 'ሆስፒታል ገብቷል'
          : language == "AfanOromo"
              ? "Hospitaala ciifsame"
              : 'Admitted To Hospital',
      "DateofAdmission": language == "Amharic"
          ? 'የመግቢያ ቀን'
          : language == "AfanOromo"
              ? "Guyyaa ciifsame"
              : 'Date of Admission',
      "MedicalRecordNo": language == "Amharic"
          ? 'የሕክምና መዝገብ ቁጥር'
          : language == "AfanOromo"
              ? "Lakkoofsa galmee yaalaa"
              : 'MedicalRecordNo',
      "FacilityName": language == "Amharic"
          ? 'የመገልገያ ስም'
          : language == "AfanOromo"
              ? "Maqaa dhaabbataa"
              : 'Facility Name',
      "next": language == "Amharic"
          ? 'ቀጣይ'
          : language == "AfanOromo"
              ? "Itti aanee"
              : 'Next',
    };
  }

  Map<String, String> stoolSpecimen() {
    return {
      "appbar": language == "Amharic"
          ? 'የሰገራ ናሙና ቅጽ'
          : language == "AfanOromo"
              ? "Saamuda sagaraa"
              : 'Stool Speciman Information',
      "dateStoolCollected": language == "Amharic"
          ? 'የሰገራ የተሰበሰበበት  ቀን '
          : language == "AfanOromo"
              ? "Guyyaa sagaraan itti fuudhame"
              : 'Date Stool Collected',
      "stool1": language == "Amharic"
          ? 'ሰገራ ናሙና 1'
          : language == "AfanOromo"
              ? "Sagaraa 1ffaa"
              : 'Stool 1',
      "stool2": language == "Amharic"
          ? 'ሰገራ ናሙና 2'
          : language == "AfanOromo"
              ? "Sagaraa 2ffaa"
              : 'Stool 2',
      "selectDate": language == "Amharic" ? 'ቀን ይምረጡ' : 'Select Date',
      "selectedDate": language == "Amharic" ? 'የተመረጠ ቀን' : 'Selected Date',
      "notSelected": language == "Amharic" ? 'አልተመረጠም' : 'Not Selected',
      "selectedDateStool1": language == "Amharic"
          ? 'የተመረጠ ቀን (ሰገራ 1)'
          : 'Selected Date (Stool 1)',
      "selectedDateStool2": language == "Amharic"
          ? 'የተመረጠ ቀን (ሰገራ 2)'
          : 'Selected Date (Stool 2)',
      "stoolSpecimenSentToLab": language == "Amharic"
          ? 'የሰገራ ናሙና ወደ ላቦ ተልኳል'
          : 'Stool Specimen Sent To Lab',
      "labName": language == "Amharic" ? 'የላቦ ስም' : 'Lab Name',
      "result": language == "Amharic" ? 'ውጤት' : 'Result',
      "Daysafteronset":
          language == "Amharic" ? 'ከመጀመሩ በኋላ ቀናት' : 'Days after onset',
      "positive": language == "Amharic" ? 'አዎንታዊ' : 'Positive',
      "CaseorContact":
          language == "Amharic" ? 'ኬዝ ወይም ኮንታክት' : 'Case or Contact',
      "case": language == "Amharic"
          ? 'ኬዝ '
          : language == "AfanOromo"
              ? "Taatee "
              : 'Case ',
      "contact": language == "Amharic"
          ? 'ኮንታክት '
          : language == "AfanOromo"
              ? "quunnamtii "
              : 'Contact ',
      "community": language == "Amharic" ? ' ማህበረሰብ' : 'community ',
      "good": language == "Amharic" ? ' ጥሩ' : 'Good ',
      "Specimenconditiononreceipt": language == "Amharic"
          ? '   በደረሰኝ ላይ የናሙና ሁኔታ'
          : 'Specimen condition on receipt ',
      "bad": language == "Amharic" ? ' መጥፎ' : 'Bad ',
      "DateSenttoLab": language == "Amharic"
          ? 'ወደ ቤተ ሙከራ የተላከበት ቀን'
          : language == "AfanOromo"
              ? "Guyyaa sgaraan gara laaboraatooriitti ergame"
              : 'Date Sent to Lab',
      "negative": language == "Amharic" ? 'አይደለም' : 'Negative',
      "pending": language == "Amharic" ? 'በመጠባበቅ ላይ' : 'Pending',
      "submit": language == "Amharic"
          ? 'አስገባ'
          : language == "AfanOromo"
              ? "Ergi"
              : 'Submit',
    };
  }

  Map<String, String> followUp() {
    return {
      "appbar": language == "Amharic"
          ? 'የክትትል ምርመራ'
          : language == "AfanOromo"
              ? "Qorannoo hordoffii "
              : 'Follow up Investigation',
      "patientRecovered":
          language == "Amharic" ? 'ታካሚው አገገማል' : 'Patient Recovered',
      "yes": language == "Amharic" ? 'አዎ' : 'Yes',
      "Losttofollowup": language == "Amharic"
          ? 'ለመከታተል ጠፋ'
          : language == "AfanOromo"
              ? "Hordoffiin addaan cite"
              : 'Lost to follow-up',
      "no": language == "Amharic" ? 'አይደለም' : 'No',
      "DateofDeath": language == "Amharic" ? 'የሞት ቀን' : 'Date of Death',
      "ResidualParalysis": language == "Amharic"
          ? 'ምረጥ'
          : language == "AfanOromo"
              ? "Laamshii haftee "
              : 'Residual Paralysis',
      "noResidualParalysis":
          language == "Amharic" ? 'ምንም ቀሪ ሽባ' : 'No Residual Paralysis',
      "recoveredDays":
          language == "Amharic" ? 'እንዴት አለ?' : 'Recovered in how many days?',
      "remainingParalysis":
          language == "Amharic" ? 'የቀረ ፓራላይሲስ' : 'Remaining Paralysis',
      "recovered":
          language == "Amharic" ? 'አለባበሱ እንዴት ነው?' : 'Recovered Status',
      "DateofFollowupExamination": language == "Amharic"
          ? "በክትትል ውስጥ ያሉ ግኝቶች"
          : language == "AfanOromo"
              ? "Ragaa qorannoo hordoffi"
              : 'Date of Follow-up',
      "FindingsatFollowup:": language == "Amharic"
          ? 'በክትትል ውስጥ ያሉ ግኝቶች'
          : 'Findings at Follow-up:',
      "leftArm": language == "Amharic" ? 'የግራ ክንድ' : 'Left Arm',
      "rightArm": language == "Amharic" ? 'የቀኝ ክንድ' : 'Right Arm',
      "leftLeg": language == "Amharic" ? 'ግራ እግር' : 'Left Leg',
      "rightLeg": language == "Amharic" ? 'የቀኝ እግር' : 'Right Leg',
      "submit": language == "Amharic"
          ? 'አስገባ'
          : language == "AfanOromo"
              ? "Ergi"
              : 'Submit',
    };
  }

  Map<String, String> environmentalMethodology() {
    return {
      "appbar": language == "Amharic"
          ? 'የአካባቢ አቀራረብ'
          : language == "AfanOromo"
              ? "Odeeffannoo meetirooloojii "
              : 'Environmental Methodology',
      "tempreture": language == "Amharic"
          ? '          የሙቀት መጠን'
          : language == "AfanOromo"
              ? "Ho’ina "
              : 'tempreture',
      "city": language == "Amharic" ? 'ከተማ' : 'City',
      "latitude": language == "Amharic" ? 'ኬክሮስ' : 'Latitude',
      "longitude": language == "Amharic" ? 'ኬንትሮስ' : 'Longitude',
      "humidity": language == "Amharic"
          ? 'እርጥበት'
          : language == "AfanOromo"
              ? "Jiidhina qilleensaa "
              : 'humidity',
      "snow": language == "Amharic" ? 'በረዶ' : 'Smow',
      "rainfall": language == "Amharic"
          ? 'ዝናብ'
          : language == "AfanOromo"
              ? "Rooba "
              : 'rainfall',
      "description": language == "Amharic" ? 'መግለጫ' : 'Description',
      "submit": language == "Amharic" ? 'አስገባ' : 'Submit',
    };
  }
}
