#include "ccy.h"


/// Must be usable from C-language too.

/* In 1973, the ISO Technical Committee 68 decided to develop codes
for the representation of currencies and funds for use in any application
of trade, commerce or banking. At the 17th session (February 1978)
of the related UN/ECE Group of Experts agreed that the three letter
alphabetic codes for International Standard ISO 4217,
"Codes for the representation of currencies and funds",
would be suitable for use in international trade.

Over time, new currencies are created and old currencies are discontinued.
Frequently, these changes are due to new governments (through war or a new constitution),
treaties between countries standardizing on a currency,
or revaluation of the currency due to excessive inflation.
As a result, the list of codes must be updated from time to time.
The ISO 4217 maintenance agency (MA), the British Standards Institution,
is responsible for maintaining the list of codes.*/

#include "ccy.h"

#ifdef __cplusplus

namespace ccy
{
#endif /* cplusplus */


    /* All the tables are pre-sorted and have the string key as first member.
    As if they were sorted with qsort( ..., ... ,...  cmp3way ).
    Therefore, it is possible to use:
    void * p = bsearch("GRD",tab,sizeof(tab)/size(tab[0]),sizeof(tab[0]),cmp3way )
    BEWARE: If several element match, they may be some before AND after. Must check. */


/* Originally "0.7" */
#define Z07 7

#define DOT (-1)

    static const official_t Officials[] =
    {
        { "AED","784",2,"United Arab Emirates dirham",{"United Arab Emirates",0} },
        { "AFN","971",2,"Afghani",{"Afghanistan",0} },
        { "ALL","008",2,"Lek",{"Albania",0} },
        { "AMD","051",2,"Armenian dram",{"Armenia",0} },
        { "ANG","532",2,"Netherlands Antillean guilder/florin",{"Netherlands Antilles",0} },
        { "AOA","973",2,"Kwanza",{"Angola",0} },
        { "ARS","032",2,"Argentine peso",{"Argentina",0} },
        { "AUD","036",2,"Australian dollar",{"Australia,","Australian Antarctic Territory,","Christmas Island,","Cocos (Keeling) Islands,","Heard and McDonald Islands,","Kiribati,","Nauru,","Norfolk Island,","Tuvalu",0} },
        { "AWG","533",2,"Aruban guilder",{"Aruba",0} },
        { "AZN","944",2,"Azerbaijanian manat",{"Azerbaijan",0} },
        { "BAM","977",2,"Convertible marks",{"Bosnia and Herzegovina",0} },
        { "BBD","052",2,"Barbados dollar",{"Barbados",0} },
        { "BDT","050",2,"Bangladeshi taka",{"Bangladesh",0} },
        { "BGN","975",2,"Bulgarian lev",{"Bulgaria",0} },
        { "BHD","048",3,"Bahraini dinar",{"Bahrain",0} },
        { "BIF","108",0,"Burundian franc",{"Burundi",0} },
        { "BMD","060",2,"Bermudian dollar (customarily known as Bermuda dollar)",{"Bermuda",0} },
        { "BND","096",2,"Brunei dollar",{"Brunei","Singapore",0} },
        { "BOB","068",2,"Boliviano",{"Bolivia",0} },
        { "BOV","984",2,"Bolivian Mvdol (funds code)",{"Bolivia",0} },
        { "BRL","986",2,"Brazilian real",{"Brazil",0} },
        { "BSD","044",2,"Bahamian dollar",{"Bahamas",0} },
        { "BTN","064",2,"Ngultrum",{"Bhutan",0} },
        { "BWP","072",2,"Pula",{"Botswana",0} },
        { "BYR","974",0,"Belarussian ruble",{"Belarus",0} },
        { "BZD","084",2,"Belize dollar",{"Belize",0} },
        { "CAD","124",2,"Canadian dollar",{"Canada",0} },
        { "CDF","976",2,"Franc Congolais",{"Democratic Republic of Congo",0} },
        { "CHE","947",2,"WIR euro (complementary currency)",{"Switzerland",0} },
        { "CHF","756",2,"Swiss franc",{"Switzerland","Liechtenstein",0} },
        { "CHW","948",2,"WIR franc (complementary currency)",{"Switzerland",0} },
        { "CLF","990",0,"Unidad de Fomento (funds code)",{"Chile",0} },
        { "CLP","152",0,"Chilean peso",{"Chile",0} },
        { "CNY","156",2,"Renminbi",{"Mainland China",0} },
        { "COP","170",2,"Colombian peso",{"Colombia",0} },
        { "COU","970",2,"Unidad de Valor Real",{"Colombia",0} },
        { "CRC","188",2,"Costa Rican colon",{"Costa Rica",0} },
        { "CUP","192",2,"Cuban peso",{"Cuba",0} },
        { "CVE","132",2,"Cape Verde escudo",{"Cape Verde",0} },
        { "CZK","203",2,"Czech koruna",{"Czech Republic",0} },
        { "DJF","262",0,"Djibouti franc",{"Djibouti",0} },
        { "DKK","208",2,"Danish krone",{"Denmark","Faroe Islands","Greenland",0} },
        { "DOP","214",2,"Dominican peso",{"Dominican Republic",0} },
        { "DZD","012",2,"Algerian dinar",{"Algeria",0} },
        { "EEK","233",2,"Kroon",{"Estonia",0} },
        { "EGP","818",2,"Egyptian pound",{"Egypt",0} },
        { "ERN","232",2,"Nakfa",{"Eritrea",0} },
        { "ETB","230",2,"Ethiopian birr",{"Ethiopia",0} },
        { "EUR","978",2,"Euro",{"Some European Union countries; see eurozone",0} },
        { "FJD","242",2,"Fiji dollar",{"Fiji",0} },
        { "FKP","238",2,"Falkland Islands pound",{"Falkland Islands",0} },
        { "GBP","826",2,"Pound sterling",{"United Kingdom","Crown Dependencies (the Isle of Man and the Channel Islands), certain British Overseas Territories (South Georgia and the South Sandwich Islands, British Antarctic Territory and British Indian","Ocean Territory)",0} },
        { "GEL","981",2,"Lari",{"Georgia",0} },
        { "GHS","936",2,"Cedi",{"Ghana",0} },
        { "GIP","292",2,"Gibraltar pound",{"Gibraltar",0} },
        { "GMD","270",2,"Dalasi",{"Gambia",0} },
        { "GNF","324",0,"Guinea franc",{"Guinea",0} },
        { "GTQ","320",2,"Quetzal",{"Guatemala",0} },
        { "GYD","328",2,"Guyana dollar",{"Guyana",0} },
        { "HKD","344",2,"Hong Kong dollar",{"Hong Kong Special Administrative Region",0} },
        { "HNL","340",2,"Lempira",{"Honduras",0} },
        { "HRK","191",2,"Croatian kuna",{"Croatia",0} },
        { "HTG","332",2,"Haiti gourde",{"Haiti",0} },
        { "HUF","348",2,"Forint",{"Hungary",0} },
        { "IDR","360",2,"Rupiah",{"Indonesia",0} },
        { "ILS","376",2,"Israeli new sheqel",{"Israel",0} },
        { "INR","356",2,"Indian rupee",{"Bhutan","India",0} },
        { "IQD","368",3,"Iraqi dinar",{"Iraq",0} },
        { "IRR","364",2,"Iranian rial",{"Iran",0} },
        { "ISK","352",2,"Iceland krona",{"Iceland",0} },
        { "JMD","388",2,"Jamaican dollar",{"Jamaica",0} },
        { "JOD","400",3,"Jordanian dinar",{"Jordan",0} },
        { "JPY","392",0,"Japanese yen",{"Japan",0} },
        { "KES","404",2,"Kenyan shilling",{"Kenya",0} },
        { "KGS","417",2,"Som",{"Kyrgyzstan",0} },
        { "KHR","116",2,"Riel",{"Cambodia",0} },
        { "KMF","174",0,"Comoro franc",{"Comoros",0} },
        { "KPW","408",2,"North Korean won",{"North Korea",0} },
        { "KRW","410",0,"South Korean won",{"South Korea",0} },
        { "KWD","414",3,"Kuwaiti dinar",{"Kuwait",0} },
        { "KYD","136",2,"Cayman Islands dollar",{"Cayman Islands",0} },
        { "KZT","398",2,"Tenge",{"Kazakhstan",0} },
        { "LAK","418",2,"Kip",{"Laos",0} },
        { "LBP","422",2,"Lebanese pound",{"Lebanon",0} },
        { "LKR","144",2,"Sri Lanka rupee",{"Sri Lanka",0} },
        { "LRD","430",2,"Liberian dollar",{"Liberia",0} },
        { "LSL","426",2,"Loti",{"Lesotho",0} },
        { "LTL","440",2,"Lithuanian litas",{"Lithuania",0} },
        { "LVL","428",2,"Latvian lats",{"Latvia",0} },
        { "LYD","434",3,"Libyan dinar",{"Libya",0} },
        { "MAD","504",2,"Moroccan dirham",{"Morocco,","Western Sahara",0} },
        { "MDL","498",2,"Moldovan leu",{"Moldova",0} },
        { "MGA","969",Z07,"Malagasy ariary",{"Madagascar",0} },
        { "MKD","807",2,"Denar",{"Former Yugoslav","Republic of Macedonia",0} },
        { "MMK","104",2,"Kyat",{"Myanmar",0} },
        { "MNT","496",2,"Tugrik",{"Mongolia",0} },
        { "MOP","446",2,"Pataca",{"Macau Special Administrative Region",0} },
        { "MRO","478",Z07,"Ouguiya",{"Mauritania",0} },
        { "MUR","480",2,"Mauritius rupee",{"Mauritius",0} },
        { "MVR","462",2,"Rufiyaa",{"Maldives",0} },
        { "MWK","454",2,"Kwacha",{"Malawi",0} },
        { "MXN","484",2,"Mexican peso",{"Mexico",0} },
        { "MXV","979",2,"Mexican Unidad de Inversion (UDI) (funds code)",{"Mexico",0} },
        { "MYR","458",2,"Malaysian ringgit",{"Malaysia",0} },
        { "MZN","943",2,"Metical",{"Mozambique",0} },
        { "NAD","516",2,"Namibian dollar",{"Namibia",0} },
        { "NGN","566",2,"Naira",{"Nigeria",0} },
        { "NIO","558",2,"Cordoba oro",{"Nicaragua",0} },
        { "NOK","578",2,"Norwegian krone",{"Norway",0} },
        { "NPR","524",2,"Nepalese rupee",{"Nepal",0} },
        { "NZD","554",2,"New Zealand dollar",{"Cook Islands","New Zealand","Niue","Pitcairn","Tokelau",0} },
        { "OMR","512",3,"Rial Omani",{"Oman",0} },
        { "PAB","590",2,"Balboa",{"Panama",0} },
        { "PEN","604",2,"Nuevo sol",{"Peru",0} },
        { "PGK","598",2,"Kina",{"Papua New Guinea",0} },
        { "PHP","608",2,"Philippine peso",{"Philippines",0} },
        { "PKR","586",2,"Pakistan rupee",{"Pakistan",0} },
        { "PLN","985",2,"Zloty",{"Poland",0} },
        { "PYG","600",0,"Guarani",{"Paraguay",0} },
        { "QAR","634",2,"Qatari rial",{"Qatar",0} },
        { "RON","946",2,"Romanian new leu",{"Romania",0} },
        { "RSD","941",2,"Serbian dinar",{"Serbia",0} },
        { "RUB","643",2,"Russian ruble",{"Russia,","Abkhazia,","South Ossetia",0} },
        { "RWF","646",0,"Rwanda franc",{"Rwanda",0} },
        { "SAR","682",2,"Saudi riyal",{"Saudi Arabia",0} },
        { "SBD","090",2,"Solomon Islands dollar",{"Solomon Islands",0} },
        { "SCR","690",2,"Seychelles rupee",{"Seychelles",0} },
        { "SDG","938",2,"Sudanese pound",{"Sudan",0} },
        { "SEK","752",2,"Swedish krona",{"Sweden",0} },
        { "SGD","702",2,"Singapore dollar",{"Singapore","Brunei",0} },
        { "SHP","654",2,"Saint Helena pound",{"Saint Helena",0} },
        { "SKK","703",2,"Slovak koruna",{"Slovakia",0} },
        { "SLL","694",2,"Leone",{"Sierra Leone",0} },
        { "SOS","706",2,"Somali shilling",{"Somalia",0} },
        { "SRD","968",2,"Surinam dollar",{"Suriname",0} },
        { "STD","678",2,"Dobra",{"São Tomé and Príncipe",0} },
        { "SYP","760",2,"Syrian pound",{"Syria",0} },
        { "SZL","748",2,"Lilangeni",{"Swaziland",0} },
        { "THB","764",2,"Baht",{"Thailand",0} },
        { "TJS","972",2,"Somoni",{"Tajikistan",0} },
        { "TMM","795",2,"Manat",{"Turkmenistan",0} },
        { "TND","788",3,"Tunisian dinar",{"Tunisia",0} },
        { "TOP","776",2,"Pa'anga",{"Tonga",0} },
        { "TRY","949",2,"New Turkish lira",{"Turkey",0} },
        { "TTD","780",2,"Trinidad and Tobago dollar",{"Trinidad and Tobago",0} },
        { "TWD","901",2,"New Taiwan dollar",{"Taiwan and other islands that are under the effective control of the Republic of China (ROC)",0} },
        { "TZS","834",2,"Tanzanian shilling",{"Tanzania",0} },
        { "UAH","980",2,"Hryvnia",{"Ukraine",0} },
        { "UGX","800",2,"Uganda shilling",{"Uganda",0} },
        { "USD","840",2,"US dollar",{"American Samoa,","British Indian Ocean Territory,","Ecuador","El Salvador","Guam","Haiti","Marshall Islands","Micronesia","Northern Mariana Islands","Palau","Panama","Puerto Rico","Timor-Leste","Turks and Caicos Islands","United States,","Virgin Islands",0} },
        { "USN","997",2,"United States dollar (next day) (funds code)",{"United States",0} },
        { "USS","998",2,"United States dollar (same day) (funds code) (one source claims it is no longer used, but it is still on the ISO 4217-MA list)",{"United States",0} },
        { "UYU","858",2,"Peso",{"Uruguayo","Uruguay",0} },
        { "UZS","860",2,"Uzbekistan som",{"Uzbekistan",0} },
        { "VEF","937",2,"Venezuelan bolívar fuerte",{"Venezuela",0} },
        { "VND","704",2,"Vietnamese dong",{"Vietnam",0} },
        { "VUV","548",0,"Vatu",{"Vanuatu",0} },
        { "WST","882",2,"Samoan tala",{"Samoa",0} },
        { "XAF","950",0,"CFA franc BEAC",{"Cameroon,","Central African Republic,","Congo,","Chad,","Equatorial Guinea,","Gabon",0} },
        { "XAG","961",DOT,"Silver (one troy ounce)",{0} },
        { "XAU","959",DOT,"Gold (one troy ounce)",{0} },
        { "XBA","955",DOT,"European Composite Unit (EURCO) (bond market unit)",{0} },
        { "XBB","956",DOT,"European Monetary Unit (E.M.U.-6) (bond market unit)",{0} },
        { "XBC","957",DOT,"European Unit of Account 9 (E.U.A.-9) (bond market unit)",{0} },
        { "XBD","958",DOT,"European Unit of Account 17 (E.U.A.-17) (bond market unit)",{0} },
        { "XCD","951",2,"East Caribbean dollar",{"Anguilla,","Antigua and Barbuda,","Dominica,","Grenada,","Montserrat,","Saint Kitts and Nevis,","Saint Lucia,","Saint Vincent and the Grenadines",0} },
        { "XDR","960",DOT,"Special Drawing Rights",{"International Monetary Fund",0} },
        { "XFU","Nil",DOT,"UIC franc (special settlement currency)",{"International","Union","of","Railways",0} },
        { "XOF","952",0,"CFA Franc BCEAO",{"Benin,","Burkina Faso,","Côte d'Ivoire,","Guinea-Bissau,","Mali,","Niger,","Senegal,","Togo",0} },
        { "XPD","964",DOT,"Palladium (one troy ounce)",{0} },
        { "XPF","953",0,"CFP franc",{"French Polynesia,","New Caledonia,","Wallis and Futuna",0} },
        { "XPT","962",DOT,"Platinum (one troy ounce)",{0} },
        { "XTS","963",DOT,"Code reserved for testing purposes",{0} },
        { "XXX","999",DOT,"No currency",{0} },
        { "YER","886",2,"Yemeni rial",{"Yemen",0} },
        { "ZAR","710",2,"South African rand",{"South Africa",0} },
        { "ZMK","894",2,"Kwacha",{"Zambia",0} },
        { "ZWD","716",2,"Zimbabwe dollar",{"Zimbabwe",0} },
        { NOCCY }
    };

#define ZERO "\0\0\0" 

    static const dependent_t Dependents[] = {
        { ZERO, "Faroese króna",         "DKK", {  1,  1} },
        { ZERO, "Scottish pound",        "GBP", {  1,  1} },
        { ZERO, "Northern Ireland",      "GBP", {  1,  1} },
        { ZERO, "Cook Islands dollar",   "NZD", {  1,  1} },
        { "CUC","Cuban convertible peso","USD", {108,100} },
        { "GGP","Guernsey pound",        "GBP", {  1,  1} },
        { "IMP","Isle of Man pound",     "GBP", {  1,  1} },
        { "JEP","Jersey pound",          "GBP", {  1,  1} },
        { "TVD","Tuvaluan dollar",       "AUD", {  1,  1} },
        { NOCCY, NULL, ZERO }
    };

    /*
    const dependent_t * dependent_of( const char * tmpCcy )
    {
        return CCY_BSEARCH(tmpCcy,dependent_t,Dependents) ;
    };
*/


#define NOYEAR 0

    static const obsolete_t Obsoletes[] = {
        { "ADF",DOT,"Andorran franc (1:1 peg to the French franc)","EUR",1999},
        { "ADP",020,"Andorran peseta (1:1 peg to the Spanish peseta)","EUR",1999},
        { "AFA",004,"Afghani","AFN",2003},
        { "ALK",DOT,"Albanian old lek","ALL",1965},
        { "AON",024,"Angolan new kwanza","AOR",1995},
        { "AOR",982,"Angolan kwanza readjustado","AOA",1999},
        { "ARA",DOT,"Argentine austral","ARS",1991},
        { "ARL",DOT,"Argentine peso ley","ARP",1983},
        { "ARM",DOT,"Argentine peso moneda nacional","ARL",1970},
        { "ARP",DOT,"Peso argentino","ARA",1985},
        { "ATS",040,"Austrian schilling","EUR",1999},
        { "AZM",031,"Azerbaijani manat","AZN",2006},
        { "BEC",993,"Belgian franc (convertible)","???", 2002},
        { "BEF",056,"Belgian franc (currency union with LUF)","EUR",1999},
        { "BEL",992,"Belgian franc (financial)",NOYEAR},
        { "BGJ",DOT,"Bulgarian lev A/52","BGK",1952},
        { "BGK",DOT,"Bulgarian lev A/62","BGL",1962},
        { "BGL",100,"Bulgarian lev A/99","BGN",1999},
        { "BOP",DOT,"Bolivian peso","BOB",1987},
        { "BRB",DOT,"Brazilian cruzeiro","BRC",1986},
        { "BRC",DOT,"Brazilian cruzado","BRN",1990},
        { "BRE",DOT,"Brazilian cruzeiro","BRR",1993},
        { "BRN",DOT,"Brazilian cruzado novo","BRE", 1993},
        { "BRR",DOT,"Brazilian cruzeiro real","BRL", 1994},
        { "BRY",DOT,"Brazilian real","BRZ", 1942}, /* BRY does not exist. */
        { "BRZ",DOT,"Brazilian cruzeiro","BRB", 1967},
        { "CFP",DOT,"Change Franc Pacifique","XPF", 1998},
        { "CNX",DOT,"Chinese People's Bank dollar","CNY", 1989},
        { "CSD",891,"Serbian dinar","RSD",2006},
        { "CSJ",DOT,"Czechoslovak koruna A/53","CSK",1953},
        { "CSK",200,"Czechoslovak koruna", "SKK",1993},
        { "CSK",200,"Czechoslovak koruna", "CZK",1993},
        { "CYP",196,"Cypriot pound","EUR",2008},
        { "DDM",278,"East German Mark of the GDR (East Germany)","DEM", 1990},
        { "DEM",276,"German mark","EUR",1999},
        { "ECS",218,"Ecuador sucre","USD",2000},
        { "ECV",983,"Ecuador Unidad de Valor Constante (funds code) (discontinued)","???",2000},
        { "EQE",DOT,"Equatorial Guinean ekwele","XAF", NOYEAR},
        { "ESA",996,"Spanish peseta (account A)","ESP"},
        { "ESB",995,"Spanish peseta (account B)","ESP"},
        { "ESP",724,"Spanish peseta","EUR",1999},
        { "FIM",246,"Finnish markka","EUR",1999},
        { "FRF",250,"French franc","EUR",1999},
        { "GHC",288,"Ghanaian cedi","GHS",2007},
        { "GNE",DOT,"Guinean syli","XOF", NOYEAR},
        { "GRD",300,"Greek drachma","EUR",2001},
        { "GWP",624,"Guinea peso","XOF"},
        { "IEP",372,"Irish pound (punt in Irish language)","EUR",1999},
        { "ILP",DOT,"Israeli lira","ILR",1980},
        { "ILR",DOT,"Israeli old sheqel","ILS",1985},
        { "ISJ",DOT,"Icelandic old krona","ISK",1981},
        { "ITL",380,"Italian lira","EUR",1999},
        { "LAJ",DOT,"Lao kip","LAK",1979},
        { "LUF",442,"Luxembourg franc (currency union with BEF)","EUR",1999},
        { "MAF",DOT,"Mali franc","XOF",1984},
        { "MCF",DOT,"Monegasque franc (currency union with FRF)","EUR",1999},
        { "MGF",450,"Malagasy franc","MGA", 2005},
        { "MKN",DOT,"Former Yugoslav Republic of Macedonia denar A/93","MKD",1993},
        { "MTL",470,"Maltese lira","EUR",2008},
        { "MVQ",DOT,"Maldive rupee","MVR",1981},
        { "MXP",DOT,"Mexican peso","MXN",1993},
        { "MZM",508,"Mozambican metical","MZN",2006},
        { "NLG",528,"Netherlands guilder/florin","EUR",1999},
        { "PEH",DOT,"Peruvian sol","PEI",1985},
        { "PEI",DOT,"Peruvian inti","PEN",1991},
        { "PLZ",616,"Polish zloty A/94","PLN",1995},
        { "PTE",620,"Portuguese escudo","EUR",1999},
        { "RON",DOT,"Romanian leu A/52","ROL",1952},
        { "ROL",642,"Romanian leu A/05","RON",2005},
        { "RUR",810,"Russian ruble A/97","RUB",1997},
        { "SDD",736,"Sudanese dinar","SDG",2007},
        { "SIT",705,"Slovenian tolar","EUR",2007},
        { "SML",DOT,"San Marinese lira (currency union with ITL and VAL)","EUR",1999},
        { "SRG",740,"Suriname guilder/florin","SRD",2004},
        { "SUR",DOT,"Soviet Union ruble","RUB",1991},
        { "SVC",222,"Salvadoran colón","USD",2001},
        { "TJR",762,"Tajikistan ruble","TJS",2000},
        { "TPE",626,"Portuguese Timorese escudo","IDR",1976},
        { "TRL",792,"Turkish lira A/05","TRY",2005},
        { "UAK",804,"Ukrainian karbovanets","UAH",1996},
        { "UGS",DOT,"Ugandan shilling A/87","UGX",1987},
        { "UYN",DOT,"Uruguay old peso","UYU",1993},
        { "VAL",DOT,"Vatican lira (currency union with ITL and SML)","EUR",1999},
        { "VEB",862,"Venezuelan bolívar","VEF",2008},
        { "VNC",DOT,"Vietnamese old dong","VND",1985},
        { "XEU",954,"European Currency Unit (1 XEU = 1 EUR)","EUR",1999},
        { "XFO",DOT,"Gold franc (special settlement currency)","XDR",2003},
        { "YDD",720,"South Yemeni dinar","YER",1990},
        { "YUS",DOT,"Serbian Dinar","YUF",1941},
        { "YUF",DOT,"Federation dinar","YUD",1965},
        { "YUD",DOT,"New Yugoslav dinar","YUM",1990},
        { "YUM",891,"Yugoslav dinar","YUN",2003},
        { "YUN",DOT,"Convertible dinar","YRU",1992},
        { "YUR",DOT,"Reformed dinar","YUO",1993},
        { "YUO",DOT,"October dinar","YUG",1993},
        { "YUG",DOT,"January dinar","CSD",1994},
        { "ZAL",991,"South African financial rand (funds code) (discontinued)","???", 1995},
        { "ZRN",180,"Zaïrean new zaïre","CDF", NOYEAR},
        { "ZRZ",DOT,"Zaïrean zaïre","ZRN",1997},
        { "ZWC",DOT,"Zimbabwe Rhodesian dollar","ZWD", NOYEAR},
        { NOCCY, DOT, NULL, ZERO }
    };

    /* Utiliser boost::bgl pour y mettre ce reseau avec des attributs a chaque arete.
    Ce sera encore le plus propre. */

    /* http://en.wikipedia.org/wiki/Non-decimal_currencies */
    /*
    German Gulden (of 60 Kreuzer) is 20 Kreuzer 
    Ancient Greece - 1 drachma = 6 obols 
    France - 1 livre = 20 sols = 240 deniers 
    German Coins 
    Frankfurt - 1 Reichstaler = 90 Kreuzer = 360 Pfennig OR 1 Reichsgulden = 60 Kreuzer = 240 Pfennig 
    Hannover - 1 Thaler = 36 Mariengroschen = 288 Pfennig 
    Hamburg - 1 Thaler = 3 Mark = 48 Schilling = 96 Pfennig 
    India - 1 rupee = 16 annas = 64 paise = 192 pies . Also, 1 gold mohur = 15 silver rupees 
    Japan - separate gold, silver, and copper currencies, but linked during the Edo period 
    Gold: 1 ry? = 4 bu = 16 shu 
    Silver: 1 momme = 10 fun = 100 rin (1 ry? = officially 50 momme, market rates
    fluctuated with supply and demand and the value of the metal minted see Japan's Currency at Marteau) 
    Copper: 1 kan = 1000 mon (1 ry? = 4000 mon; hence, 1 bu = 1 kan) 
    Netherlands - 1 gulden = 20 stuivers = 160 duit = 320 penningen 
    Ottoman Empire - 1 kuru? = 40 para = 120 akçe 
    Poland - 1 z?oty = 30 groschen 
    Roman Empire - 1 aureus = 25 denarii = 100 sestertii = 400 asses = 1600 quadrans 
    Siam (modern-day Thailand) - 1 tical = 4 salung = 8 fuang = 16 song phai = 32 phai = 64 att = 128 solot 
    Spanish Empire - 1 peso = 8 reales (de plata fuerte) = 680 maravedíes (the pesos are the "pieces of eight" often referred to in stories about pirates, such as Treasure Island, vellon means the coin minted of an alloy with a low silver content.) 
    Switzerland - 1 Gulden Rheinisch = 15 or 16 (later also 17 or 18) Batzen or = 20 Schilling; 1 Batzen = 4 Kreuzer; 1 Schilling = 6 Angster = 12 Heller 
    The United Kingdom and many countries formerly part of the British Empire - 1 pound = 20 shillings = 240 pence = 960 farthings - many named coins existed (see British coinage, but these were the units of account) 
    */

    /* http://www.ibm.com/developerworks/linux/library/l-linuni.html */

    #define NOW 9999

    /* World currency symbols:  http://www.xe.com/symbols.php */

    static const symbol_t Symbols[] =
    {
        { "AFN", 0, 0, { 0x60b, 0 }, 0 },
        { "ALL", 0, 0, { 0x4c, 0x65, 0x6b, 0 }, 0 },
        { "ANG", 0, 0, { 0x192, 0 }, 0 },
        { "ARS", 0, 0, { 0x24, 0 }, 0 }, /* Standard dollar sign is generally used to signify peso. */
        { "AUD", 0, 0, { 0x24, 0 }, 0 },
        { "AWG", 0, 0, { 0x192, 0 }, 0 },
        { "AZN", 0, 0, { 0x43c, 0x430, 0x43d, 0 }, 0 },
        { "BAM", 0, 0, { 0x4b, 0x4d, 0 }, 0 },
        { "BBD", 0, 0, { 0x24, 0 }, 0 },
        { "BGN", 0, 0, { 0x43b, 0x432, 0 }, 0 },
        { "BMD", 0, 0, { 0x24, 0 }, 0 },
        { "BND", 0, 0, { 0x24, 0 }, 0 },
        { "BOB", 0, 0, { 0x24, 0x62, 0 }, 0 }, /* Standard dollar sign is generally used for peso. */
        { "BRL", 0, 0, { 0x52, 0x24, 0 }, 0 }, /* Upper case "R" followed by standard dollar sign "$" */
        { "BSD", 0, 0, { 0x24, 0 }, 0 },
        { "BWP", 0, 0, { 0x50, 0 }, 0 },
        { "BYR", 0, 0, { 0x70, 0x2e, 0 }, 0 },
        { "BZD", 0, 0, { 0x42, 0x5a, 0x24, 0 }, 0 },
        { "CAD", 0, 0, { 0x24, 0 }, 0 },
        { "CHF", 0, 0, { 0x43, 0x48, 0x46, 0 }, 0 },
        { "CLP", 0, 0, { 0x24, 0 }, 0 }, /* Standard dollar sign generally used to signify peso.  */
        { "CNY", 0, 0, { 0x5143, 0 }, 0 },
        { "COP", 0, 0, { 0x24, 0 }, 0 },
        { "CRC", 0, 0, { 0x20a1, 0 }, 0 },
        { "CUP", 0, 0, { 0x20b1, 0 }, 0 },
        { "CZK", 0, 0, { 0x4b, 0x10d, 0 }, 0 },
        { "DKK", 0, 0, { 0x6b, 0x72, 0 }, 0 }, /* Lower case "k" followed by lower case "r".  */
        { "DOP", 0, 0, { 0x52, 0x44, 0x24, 0 }, 0 },
        { "EEK", 0, 0, { 0x6b, 0x72, 0 }, 0 },
        { "EGP", 0, 0, { 0xa3, 0 }, 0 },
        { "EUR", 0xA4, "&euro;", { 0x20AC, 0 }, 0 },
        { "FJD", 0, 0, { 0x24, 0 }, 0 },
        { "FKP", 0, 0, { 0xa3, 0 }, 0 },
        { "GBP", 0xa3, "£", { 0xa3, 0 }, { 0xa3, 0 } },
        { "GGP", 0, 0, { 0xa3, 0 }, 0 },
        { "GHC", 0, 0, { 0xa2, 0 }, 0 },
        { "GIP", 0, 0, { 0xa3, 0 }, 0 },
        { "GRD", 0, 0, { 0x20AF, 0 }, { 0xE282AF, 0 } },
        { "GTQ", 0, 0, { 0x51, 0 }, 0 },
        { "GYD", 0, 0, { 0x24, 0 }, 0 },
        { "HKD", 0, 0, { 0x48, 0x4b, 0x24, 0 }, 0 }, /* Standard dollar sign generally used except on banknotes (see below).  */
        { "HKD", 0, 0, { 0x5713, 0 }, 0 }, /* On banknotes issued by Bank of China (Hong Kong).  */
        { "HKD", 0, 0, { 0x5713, 0 }, 0 }, /* On banknotes issued by Standard Chartered Bank (Hong Kong).  */
        { "HKD", 0, 0, { 0x5143, 0 }, 0 }, /* On banknotes issued by The Hongkong and Shanghai Banking Corporation.  */
        { "HNL", 0, 0, { 0x4c, 0 }, 0 },
        { "HRK", 0, 0, { 0x6b, 0x6e, 0 }, 0 },
        { "HUF", 0, 0, { 0x46, 0x74, 0 }, 0 },
        { "IDR", 0, 0, { 0x52, 0x70, 0 }, 0 },
        { "ILS", 0, 0, { 0x20aa, 0 }, 0 },
        { "IMP", 0, 0, { 0xa3, 0 }, 0 },
        { "INR", 0, 0, { 0x20a8, 0 }, 0 }, /* Or "Rs" */
        { "IRR", 0, 0, { 0xfdfc, 0 }, 0 },
        { "ISK", 0, 0, { 0x6b, 0x72, 0 }, 0 },
        { "JEP", 0, 0, { 0xa3, 0 }, 0 },
        { "JMD", 0, 0, { 0x4a, 0x24, 0 }, 0 },
        { "JPY", 0xA5, "&yen;",  { 0x00A5, 0 }, 0 }, /* 'Y' with two bars. */
        { "KGS", 0, 0, { 0x43b, 0x432, 0 }, 0 },
        { "KHR", 0, 0, { 0x17db, 0 }, 0 },
        { "KPW", 0, 0, { 0x20a9, 0 }, 0 },
        { "KRW", 0, 0, { 0x20a9, 0 }, 0 },
        { "KYD", 0, 0, { 0x24, 0 }, 0 },
        { "KZT", 0, 0, { 0x43b, 0x432, 0 }, 0 },
        { "LAK", 0, 0, { 0x20ad, 0 }, 0 },
        { "LBP", 0, 0, { 0xa3, 0 }, 0 },
        { "LKR", 0, 0, { 0x20a8, 0 }, 0 },
        { "LRD", 0, 0, { 0x24, 0 }, 0 },
        { "LTL", 0, 0, { 0x4c, 0x74, 0 }, 0 },
        { "LVL", 0, 0, { 0x4c, 0x73, 0 }, 0 },
        { "MKD", 0, 0, { 0x434, 0x435, 0x43d, 0 }, 0 },
        { "MNT", 0, 0, { 0x20ae, 0 }, 0 },
        { "MUR", 0, 0, { 0x20a8, 0 }, 0 },
        { "MXN", 0, 0, { 0x24, 0 }, 0 }, /* Standard dollar sign generally used for peso.  */
        { "MYR", 0, 0, { 0x52, 0x4d, 0 }, 0 },
        { "MZN", 0, 0, { 0x4d, 0x54, 0 }, 0 },
        { "NAD", 0, 0, { 0x24, 0 }, 0 },
        { "NGN", 0, 0, { 0x20a6, 0 }, 0 },
        { "NIO", 0, 0, { 0x43, 0x24, 0 }, 0 },
        { "NOK", 0, 0, { 0x6b, 0x72, 0 }, 0 },
        { "NPR", 0, 0, { 0x20a8, 0 }, 0 },
        { "NZD", 0, 0, { 0x24, 0 }, 0 },
        { "OMR", 0, 0, { 0xfdfc, 0 }, 0 },
        { "PAB", 0, 0, { 0x42, 0x2f, 0x2e, 0 }, 0 },
        { "PEN", 0, 0, { 0x53, 0x2f, 0x2e, 0 }, 0 }, /* Upper case "S" followed by slash "/" followed by dot ".".  */
        { "PHP", 0, 0, { 0x50, 0x68, 0x70, 0 }, 0 },
        { "PKR", 0, 0, { 0x20a8, 0 }, 0 },
        { "PLN", 0, 0, { 0x7a, 0x142, 0 }, 0 },
        { "PYG", 0, 0, { 0x47, 0x73, 0 }, 0 },
        { "QAR", 0, 0, { 0xfdfc, 0 }, 0 },
        { "RON", 0, 0, { 0x6c, 0x65, 0x69, 0 }, 0 },
        { "RSD", 0, 0, { 0x414, 0x438, 0x43d, 0x2e, 0 }, 0 },
        { "RUB", 0, 0, { 0x440, 0x443, 0x431, 0 }, 0 }, /* Cyrillic characters forming Russian equivalent of "RUB". */
        { "SAR", 0, 0, { 0xfdfc, 0 }, 0 },
        { "SBD", 0, 0, { 0x24, 0 }, 0 },
        { "SCR", 0, 0, { 0x20a8, 0 }, 0 },
        { "SEK", 0, 0, { 0x6b, 0x72, 0 }, 0 }, /* Lower case "k" followed by lower case "r".  */
        { "SGD", 0, 0, { 0x24, 0 }, 0 },
        { "SHP", 0, 0, { 0xa3, 0 }, 0 },
        { "SOS", 0, 0, { 0x53, 0 }, 0 },
        { "SRD", 0, 0, { 0x24, 0 }, 0 },
        { "SVC", 0, 0, { 0x24, 0 }, 0 },
        { "SYP", 0, 0, { 0xa3, 0 }, 0 },
        { "THB", 0, 0, { 0xe3f, 0 }, 0 },
        { "TRL", 0, 0, { 0x20a4, 0 }, 0 },
        { "TRY", 0, 0, { 0x59, 0x54, 0x4c, 0 }, 0 },
        { "TTD", 0, 0, { 0x54, 0x54, 0x24, 0 }, 0 },
        { "TVD", 0, 0, { 0x24, 0 }, 0 },
        { "TWD", 0, 0, { 0x4e, 0x54, 0x24, 0 }, 0 }, /* Unconfirmed. */
        { "UAH", 0, 0, { 0x20b4, 0 }, 0 },
        { "USD", '$', "$", L"$", { '$', 0 } },
        { "UYU", 0, 0, { 0x24, 0x55, 0 }, 0 },
        { "UZS", 0, 0, { 0x43b, 0x432, 0 }, 0 },
        { "VEF", 0, 0, { 0x42, 0x73, 0 }, 0 },
        { "VND", 0, 0, { 0x20ab, 0 }, 0 },
        { "XCD", 0, 0, { 0x24, 0 }, 0 },
        { "YER", 0, 0, { 0xfdfc, 0 }, 0 },
        { "ZAR", 0, 0, { 0x52, 0 }, 0 },
        { "ZWD", 0, 0, { 0x5a, 0x24, 0 }, 0 },
        { NOCCY, 0, 0, { 0 }, 0 }
    };

    const wchar_t * unicode( const char * tmpCcy )
    {
        const symbol_t * ptrSym = CCY_BSEARCH(tmpCcy,symbol_t,Symbols,CCY_NB_ELEMS(Symbols)) ;
        return ptrSym ? ptrSym->_unicode : 0 ;
    };

    /* The subunits are sorted by currency, then by decreasing value. */
    static const subunit_t SubUnits[] =
    {
        { "CNY", "Yuan",     {    1,  1}, NOW    },
        { "CNY", "Jiao",     {   10,  1}, NOW    },
        { "CNY", "Fen",      {  100,  1}, NOW    },
        { "DEM", "Mark",     {    1,  1}, NOW    },
        { "DEM", "Pfennig",  {  100,  1}, NOW    },
        { "EUR", "Euros",    {    1,  1}, NOW    },
        { "EUR", "Cent",     {  100,  1}, NOW    },
        { "FRF", "Francs",   {    1,  1}, NOYEAR },
        { "FRF", "Decime",   {   10,  1}, NOYEAR },
        { "FRF", "Centime",  {  100,  1}, NOW    },
        { "FRF", "Millime",  { 1000,  1}, NOYEAR },
        { "FRZ", "Sou",      {   20,  1}, NOYEAR },  /* Error: This cannot be the same FRF */
        { "FRZ", "Ecu blanc",{    1,  3}, NOYEAR },  /* Error: This cannot be the same FRF */
        { "FRZ", "Franc",    {    1,  1}, NOYEAR },  /* Error: This cannot be the same FRF */
        { "FRZ", "Denier",   {  240,  1}, NOYEAR },
        { "GBP", "Pound",    {    1,  1}, 1971   },
        { "GBP", "Shilling", {   20,  1}, 1971   },
        { "GBP", "Penny",    {  240,  1}, 1971   },
        { "GBP", "Farthing", {  960,  1}, 1971   },
        { "GBP", "Pound",    {    1,  1}, NOW    },
        { "GBP", "Penny",    {  100,  1}, NOW    },
        { "IRR", "Tomal",    {    1, 10}, NOW    },
        { "IRR", 0,          {    1,  1}, NOW    },
        { "JOD", 0,          {    1,  1}, NOW    },
        { "JOD", "dirham",   {   10,  1}, NOW    },
        { "JOD", "qirsh",    {  100,  1}, NOW    },
        { "JOD", "fils",     { 1000,  1}, NOW    },
        { "KRW", "Yang",     {    1,  5}, 1893   },
        { "KRW", 0,          {    1,  1}, 1893   },
        { "PLN", "Zloty",    {    1,  1}, NOW    },
        { "PLN", "Groschen", {   30,  1}, NOW    },
        { "RUB", 0,          {    1,  1}, NOW    },
        { "RUB", "Kopeck",   {  100,  1}, NOW    },
        { "SOU", 0,          {    1,  1}, NOYEAR },  /* Error: SOU is not ISO. */
        { "SOU", "Ecu quart",{   64,  1}, NOYEAR },  /* Error: SOU is not ISO. */
        { "TRL", "lira",     {    1,  1}, NOW    },
        { "TRL", "kuru",     {  100,  1}, NOW    },
        { "TRL", "para",     { 4000,  1}, NOW    },
        { "TRL", "akçe",     {12000,  1}, NOW    },
        { "USD", 0,          {    1,  1}, NOW    },
        { "USD", "Cent",     {  100,  1}, NOW    },
        { NOCCY }
    };

    /*
    Whereas most countries' currencies cannot settle on a Saturday and Sunday, 
    most Arab currencies cannot settle on a Friday and Saturday. 
    Market convention in the interbank market for Arab currencies 
    is that the spot date for Wednesday's trades is taken to be Monday. 
    For AED, BHD, EGP, KWD, OMR and QAR, the spot date for Thursday's 
    trades is also taken to be Monday, because this still leaves two 
    working days for each currency in the pair (i.e. Friday and Monday 
    for the USD, and Sunday and Monday for the Arab currency). 
    This means that Tuesday is never a spot date in these currencies 
    and can only be priced as a broken date. The exceptions to this 
    rule are SAR and JOD, where the spot date for Thursday's trades 
    is taken to be Tuesday, effectively making a three-day weekend 
    (Friday, Saturday, Sunday) for value date purposes. Some banks, 
    particularly Arab banks when trading with their customers, 
    use split settlement for USD/Arab currency pairs, with USD 
    settling on the Friday or Monday, and the Arab currency settling on the Sunday. 
    In such cases of split settlement, the USD payment is always to the bank's advantage, 
    whereby the bank receives USD on the Friday but would pay USD on the Monday. 
    */
    static const arab_t Arabs[] = {
        { "AED" },
        { "BHD" },
        { "EGP" },
        { "KWD" },
        { "OMR" },
        { "QAR" },
        { NOCCY }
    };

    bool is_arab( const char * tmpCcy )
    {
        return CCY_BSEARCH( tmpCcy, arab_t, Arabs, CCY_NB_ELEMS(Arabs) ); 
    };

    /* http://www.investopedia.com/terms/q/quotecurrency.asp */
    /*
    I am not sure whether there is an official definition of quote currencies.
    struct quote_t
    {
        const char   _code[SZ_CCY] ;
    };

    static const quote_t Quotes[] = {
    CAD
        { "CHF" },
    EUR
    GBP
    JPY
    USD
            };

    */

    /*
    Associer aussi une subunit avec un nom special, avec un multiple ou sous-multiple.
    Eventuellement utiliser la meme notation pour les billets et pieces, mais sans nom.
        { "FRF", NULL,  {  100, 10}, NOYEAR },
        { "FRF", NULL,  {  100, 20}, NOYEAR },
        { "FRF", NULL,  {  100, 50}, NOYEAR },
        { "FRF", NULL,  {    2,  1}, NOYEAR },
        { "FRF", NULL,  {   10,  1}, NOYEAR },
        { NOCCY }
    */

    /*
    Proposed subunit interface:
    Iterator on the begin and end.

    Algorithm for counting in subunits.
    Should work too for giving the coins number.

    On peut mettre le type d'entree en template (Ici une faction)
    et en sortie on ecrit des entiers dans un iterateur.

    On commence par le plus petit ou le plus gros ? ce serait bien aussi de mettre 
    un facteur repetitif (10) en boucle. Idem aussi, generer automatiquement
    1,2,5,10,20,50, etc... meme si le probleme est different. Mais enfin,
    raisonnablement, il n'y en a jamais tant que ca.

    Permettre de greffer facilement des donnees en plus sur une subunit:
    Info piece/billet, etc...
    */

    /*
    power-of-2 and the power-of-3 monetary denomination systems
    (MDS) widely studied in the literature by considering the class of the power-of-? MDS
    Bounie, David and Houy, Nicolas
    */

    struct country_definition
    {
        alpha2       _code;
        const char * _name ;
    };


    /* ISO 3166 alpha-2 codes in English. */
    static const country_definition CountriesEnglish[] = {
        { "AF", "AFGHANISTAN" },
        { "AX", "ÅLAND ISLANDS" },
        { "AL", "ALBANIA" },
        { "DZ", "ALGERIA" },
        { "AS", "AMERICAN SAMOA" },
        { "AD", "ANDORRA" },
        { "AO", "ANGOLA" },
        { "AI", "ANGUILLA" },
        { "AQ", "ANTARCTICA" },
        { "AG", "ANTIGUA AND BARBUDA" },
        { "AR", "ARGENTINA" },
        { "AM", "ARMENIA" },
        { "AW", "ARUBA" },
        { "AU", "AUSTRALIA" },
        { "AT", "AUSTRIA" },
        { "AZ", "AZERBAIJAN" },
        { "BS", "BAHAMAS" },
        { "BH", "BAHRAIN" },
        { "BD", "BANGLADESH" },
        { "BB", "BARBADOS" },
        { "BY", "BELARUS" },
        { "BE", "BELGIUM" },
        { "BZ", "BELIZE" },
        { "BJ", "BENIN" },
        { "BM", "BERMUDA" },
        { "BT", "BHUTAN" },
        { "BO", "BOLIVIA" },
        { "BA", "BOSNIA AND HERZEGOVINA" },
        { "BW", "BOTSWANA" },
        { "BV", "BOUVET ISLAND" },
        { "BR", "BRAZIL" },
        { "IO", "BRITISH INDIAN OCEAN TERRITORY" },
        { "BN", "BRUNEI DARUSSALAM" },
        { "BG", "BULGARIA" },
        { "BF", "BURKINA FASO" },
        { "BI", "BURUNDI" },
        { "KH", "CAMBODIA" },
        { "CM", "CAMEROON" },
        { "CA", "CANADA" },
        { "CV", "CAPE VERDE" },
        { "KY", "CAYMAN ISLANDS" },
        { "CF", "CENTRAL AFRICAN REPUBLIC" },
        { "TD", "CHAD" },
        { "CL", "CHILE" },
        { "CN", "CHINA" },
        { "CX", "CHRISTMAS ISLAND" },
        { "CC", "COCOS (KEELING) ISLANDS" },
        { "CO", "COLOMBIA" },
        { "KM", "COMOROS" },
        { "CG", "CONGO" },
        { "CD", "CONGO, THE DEMOCRATIC REPUBLIC OF THE" },
        { "CK", "COOK ISLANDS" },
        { "CR", "COSTA RICA" },
        { "CI", "CÔTE D'IVOIRE" },
        { "HR", "CROATIA" },
        { "CU", "CUBA" },
        { "CY", "CYPRUS" },
        { "CZ", "CZECH REPUBLIC" },
        { "DK", "DENMARK" },
        { "DJ", "DJIBOUTI" },
        { "DM", "DOMINICA" },
        { "DO", "DOMINICAN REPUBLIC" },
        { "EC", "ECUADOR" },
        { "EG", "EGYPT" },
        { "SV", "EL SALVADOR" },
        { "GQ", "EQUATORIAL GUINEA" },
        { "ER", "ERITREA" },
        { "EE", "ESTONIA" },
        { "ET", "ETHIOPIA" },
        { "FK", "FALKLAND ISLANDS (MALVINAS)" },
        { "FO", "FAROE ISLANDS" },
        { "FJ", "FIJI" },
        { "FI", "FINLAND" },
        { "FR", "FRANCE" },
        { "GF", "FRENCH GUIANA" },
        { "PF", "FRENCH POLYNESIA" },
        { "TF", "FRENCH SOUTHERN TERRITORIES" },
        { "GA", "GABON" },
        { "GM", "GAMBIA" },
        { "GE", "GEORGIA" },
        { "DE", "GERMANY" },
        { "GH", "GHANA" },
        { "GI", "GIBRALTAR" },
        { "GR", "GREECE" },
        { "GL", "GREENLAND" },
        { "GD", "GRENADA" },
        { "GP", "GUADELOUPE" },
        { "GU", "GUAM" },
        { "GT", "GUATEMALA" },
        { "GG", "GUERNSEY" },
        { "GN", "GUINEA" },
        { "GW", "GUINEA-BISSAU" },
        { "GY", "GUYANA" },
        { "HT", "HAITI" },
        { "HM", "HEARD ISLAND AND MCDONALD ISLANDS" },
        { "VA", "HOLY SEE (VATICAN CITY STATE)" },
        { "HN", "HONDURAS" },
        { "HK", "HONG KONG" },
        { "HU", "HUNGARY" },
        { "IS", "ICELAND" },
        { "IN", "INDIA" },
        { "ID", "INDONESIA" },
        { "IR", "IRAN, ISLAMIC REPUBLIC OF" },
        { "IQ", "IRAQ" },
        { "IE", "IRELAND" },
        { "IM", "ISLE OF MAN" },
        { "IL", "ISRAEL" },
        { "IT", "ITALY" },
        { "JM", "JAMAICA" },
        { "JP", "JAPAN" },
        { "JE", "JERSEY" },
        { "JO", "JORDAN" },
        { "KZ", "KAZAKHSTAN" },
        { "KE", "KENYA" },
        { "KI", "KIRIBATI" },
        { "KP", "KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF" },
        { "KR", "KOREA, REPUBLIC OF" },
        { "KW", "KUWAIT" },
        { "KG", "KYRGYZSTAN" },
        { "LA", "LAO PEOPLE'S DEMOCRATIC REPUBLIC" },
        { "LV", "LATVIA" },
        { "LB", "LEBANON" },
        { "LS", "LESOTHO" },
        { "LR", "LIBERIA" },
        { "LY", "LIBYAN ARAB JAMAHIRIYA" },
        { "LI", "LIECHTENSTEIN" },
        { "LT", "LITHUANIA" },
        { "LU", "LUXEMBOURG" },
        { "MO", "MACAO" },
        { "MK", "MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF" },
        { "MG", "MADAGASCAR" },
        { "MW", "MALAWI" },
        { "MY", "MALAYSIA" },
        { "MV", "MALDIVES" },
        { "ML", "MALI" },
        { "MT", "MALTA" },
        { "MH", "MARSHALL ISLANDS" },
        { "MQ", "MARTINIQUE" },
        { "MR", "MAURITANIA" },
        { "MU", "MAURITIUS" },
        { "YT", "MAYOTTE" },
        { "MX", "MEXICO" },
        { "FM", "MICRONESIA, FEDERATED STATES OF" },
        { "MD", "MOLDOVA, REPUBLIC OF" },
        { "MC", "MONACO" },
        { "MN", "MONGOLIA" },
        { "ME", "MONTENEGRO" },
        { "MS", "MONTSERRAT" },
        { "MA", "MOROCCO" },
        { "MZ", "MOZAMBIQUE" },
        { "MM", "MYANMAR" },
        { "NA", "NAMIBIA" },
        { "NR", "NAURU" },
        { "NP", "NEPAL" },
        { "NL", "NETHERLANDS" },
        { "AN", "NETHERLANDS ANTILLES" },
        { "NC", "NEW CALEDONIA" },
        { "NZ", "NEW ZEALAND" },
        { "NI", "NICARAGUA" },
        { "NE", "NIGER" },
        { "NG", "NIGERIA" },
        { "NU", "NIUE" },
        { "NF", "NORFOLK ISLAND" },
        { "MP", "NORTHERN MARIANA ISLANDS" },
        { "NO", "NORWAY" },
        { "OM", "OMAN" },
        { "PK", "PAKISTAN" },
        { "PW", "PALAU" },
        { "PS", "PALESTINIAN TERRITORY, OCCUPIED" },
        { "PA", "PANAMA" },
        { "PG", "PAPUA NEW GUINEA" },
        { "PY", "PARAGUAY" },
        { "PE", "PERU" },
        { "PH", "PHILIPPINES" },
        { "PN", "PITCAIRN" },
        { "PL", "POLAND" },
        { "PT", "PORTUGAL" },
        { "PR", "PUERTO RICO" },
        { "QA", "QATAR" },
        { "RE", "REUNION" },
        { "RO", "ROMANIA" },
        { "RU", "RUSSIAN FEDERATION" },
        { "RW", "RWANDA" },
        { "BL", "SAINT BARTHÉLEMY" },
        { "SH", "SAINT HELENA" },
        { "KN", "SAINT KITTS AND NEVIS" },
        { "LC", "SAINT LUCIA" },
        { "MF", "SAINT MARTIN" },
        { "PM", "SAINT PIERRE AND MIQUELON" },
        { "VC", "SAINT VINCENT AND THE GRENADINES" },
        { "WS", "SAMOA" },
        { "SM", "SAN MARINO" },
        { "ST", "SAO TOME AND PRINCIPE" },
        { "SA", "SAUDI ARABIA" },
        { "SN", "SENEGAL" },
        { "RS", "SERBIA" },
        { "SC", "SEYCHELLES" },
        { "SL", "SIERRA LEONE" },
        { "SG", "SINGAPORE" },
        { "SK", "SLOVAKIA" },
        { "SI", "SLOVENIA" },
        { "SB", "SOLOMON ISLANDS" },
        { "SO", "SOMALIA" },
        { "ZA", "SOUTH AFRICA" },
        { "GS", "SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS" },
        { "ES", "SPAIN" },
        { "LK", "SRI LANKA" },
        { "SD", "SUDAN" },
        { "SR", "SURINAME" },
        { "SJ", "SVALBARD AND JAN MAYEN" },
        { "SZ", "SWAZILAND" },
        { "SE", "SWEDEN" },
        { "CH", "SWITZERLAND" },
        { "SY", "SYRIAN ARAB REPUBLIC" },
        { "TW", "TAIWAN, PROVINCE OF CHINA" },
        { "TJ", "TAJIKISTAN" },
        { "TZ", "TANZANIA, UNITED REPUBLIC OF" },
        { "TH", "THAILAND" },
        { "TL", "TIMOR-LESTE" },
        { "TG", "TOGO" },
        { "TK", "TOKELAU" },
        { "TO", "TONGA" },
        { "TT", "TRINIDAD AND TOBAGO" },
        { "TN", "TUNISIA" },
        { "TR", "TURKEY" },
        { "TM", "TURKMENISTAN" },
        { "TC", "TURKS AND CAICOS ISLANDS" },
        { "TV", "TUVALU" },
        { "UG", "UGANDA" },
        { "UA", "UKRAINE" },
        { "AE", "UNITED ARAB EMIRATES" },
        { "GB", "UNITED KINGDOM" },
        { "US", "UNITED STATES" },
        { "UM", "UNITED STATES MINOR OUTLYING ISLANDS" },
        { "UY", "URUGUAY" },
        { "UZ", "UZBEKISTAN" },
        { "VU", "VANUATU" },
        { "VE", "VENEZUELA" },
        { "VN", "VIET NAM" },
        { "VG", "VIRGIN ISLANDS, BRITISH" },
        { "VI", "VIRGIN ISLANDS, U.S." },
        { "WF", "WALLIS AND FUTUNA" },
        { "EH", "WESTERN SAHARA" },
        { "YE", "YEMEN" },
        { "ZM", "ZAMBIA" },
        { "ZW", "ZIMBABWE" },
    };


    /* ISO 3166 alpha-2 codes in French. */
    static const country_definition CountriesFrench[] = {
        { "AF", "AFGHANISTAN" },
        { "ZA", "AFRIQUE DU SUD" },
        { "AX", "ÅLAND, ÎLES" },
        { "AL", "ALBANIE" },
        { "DZ", "ALGÉRIE" },
        { "DE", "ALLEMAGNE" },
        { "AD", "ANDORRE" },
        { "AO", "ANGOLA" },
        { "AI", "ANGUILLA" },
        { "AQ", "ANTARCTIQUE" },
        { "AG", "ANTIGUA-ET-BARBUDA" },
        { "AN", "ANTILLES NÉERLANDAISES" },
        { "SA", "ARABIE SAOUDITE" },
        { "AR", "ARGENTINE" },
        { "AM", "ARMÉNIE" },
        { "AW", "ARUBA" },
        { "AU", "AUSTRALIE" },
        { "AT", "AUTRICHE" },
        { "AZ", "AZERBAÏDJAN" },
        { "BS", "BAHAMAS" },
        { "BH", "BAHREÏN" },
        { "BD", "BANGLADESH" },
        { "BB", "BARBADE" },
        { "BY", "BÉLARUS" },
        { "BE", "BELGIQUE" },
        { "BZ", "BELIZE" },
        { "BJ", "BÉNIN" },
        { "BM", "BERMUDES" },
        { "BT", "BHOUTAN" },
        { "BO", "BOLIVIE" },
        { "BA", "BOSNIE-HERZÉGOVINE" },
        { "BW", "BOTSWANA" },
        { "BV", "BOUVET, ÎLE" },
        { "BR", "BRÉSIL" },
        { "BN", "BRUNÉI DARUSSALAM" },
        { "BG", "BULGARIE" },
        { "BF", "BURKINA FASO" },
        { "BI", "BURUNDI" },
        { "KY", "ÎLES CAÏMANES" },
        { "KH", "CAMBODGE" },
        { "CM", "CAMEROUN" },
        { "CA", "CANADA" },
        { "CV", "CAP-VERT" },
        { "CF", "RÉPUBLIQUE CENTRAFRICAINE" },
        { "CL", "CHILI" },
        { "CN", "CHINE" },
        { "CX", "ÎLE CHRISTMAS" },
        { "CY", "CHYPRE" },
        { "CC", "ÎLES COCOS (KEELING)" },
        { "CO", "COLOMBIE" },
        { "KM", "COMORES" },
        { "CG", "CONGO" },
        { "CD", "LA RÉPUBLIQUE DÉMOCRATIQUE DU CONGO" },
        { "CK", "ÎLES COOK" },
        { "KR", "RÉPUBLIQUE DE CORÉE" },
        { "KP", "RÉPUBLIQUE POPULAIRE DÉMOCRATIQUE DE CORÉE" },
        { "CR", "COSTA RICA" },
        { "CI", "CÔTE D'IVOIRE" },
        { "HR", "CROATIE" },
        { "CU", "CUBA" },
        { "DK", "DANEMARK" },
        { "DJ", "DJIBOUTI" },
        { "DO", "RÉPUBLIQUE DOMINICAINE" },
        { "DM", "DOMINIQUE" },
        { "EG", "ÉGYPTE" },
        { "SV", "EL SALVADOR" },
        { "AE", "ÉMIRATS ARABES UNIS" },
        { "EC", "ÉQUATEUR" },
        { "ER", "ÉRYTHRÉE" },
        { "ES", "ESPAGNE" },
        { "EE", "ESTONIE" },
        { "US", "ÉTATS-UNIS" },
        { "ET", "ÉTHIOPIE" },
        { "FK", "ÎLES MALOUINES" },
        { "FO", "FÉROÉ, ÎLES" },
        { "FJ", "FIDJI" },
        { "FI", "FINLANDE" },
        { "FR", "FRANCE" },
        { "GA", "GABON" },
        { "GM", "GAMBIE" },
        { "GE", "GÉORGIE" },
        { "GS", "GÉORGIE DU SUD ET LES ÎLES SANDWICH DU SUD" },
        { "GH", "GHANA" },
        { "GI", "GIBRALTAR" },
        { "GR", "GRÈCE" },
        { "GD", "GRENADE" },
        { "GL", "GROENLAND" },
        { "GP", "GUADELOUPE" },
        { "GU", "GUAM" },
        { "GT", "GUATEMALA" },
        { "GG", "GUERNESEY" },
        { "GN", "GUINÉE" },
        { "GW", "GUINÉE-BISSAU" },
        { "GQ", "GUINÉE ÉQUATORIALE" },
        { "GY", "GUYANA" },
        { "GF", "GUYANE FRANÇAISE" },
        { "HT", "HAÏTI" },
        { "HM", "ÎLE HEARD ET ÎLES MCDONALD" },
        { "HN", "HONDURAS" },
        { "HK", "HONG-KONG" },
        { "HU", "HONGRIE" },
        { "IM", "ÎLE DE MAN" },
        { "UM", "ÎLES MINEURES ÉLOIGNÉES DES ÉTATS-UNIS" },
        { "VG", "ÎLES VIERGES BRITANNIQUES" },
        { "VI", "ÎLES VIERGES DES ÉTATS-UNIS" },
        { "IN", "INDE" },
        { "ID", "INDONÉSIE" },
        { "IR", "RÉPUBLIQUE ISLAMIQUE D'IRAN" },
        { "IQ", "IRAQ" },
        { "IE", "IRLANDE" },
        { "IS", "ISLANDE" },
        { "IL", "ISRAËL" },
        { "IT", "ITALIE" },
        { "JM", "JAMAÏQUE" },
        { "JP", "JAPON" },
        { "JE", "JERSEY" },
        { "JO", "JORDANIE" },
        { "KZ", "KAZAKHSTAN" },
        { "KE", "KENYA" },
        { "KG", "KIRGHIZISTAN" },
        { "KI", "KIRIBATI" },
        { "KW", "KOWEÏT" },
        { "LA", "RÉPUBLIQUE DÉMOCRATIQUE POPULAIRE DU LAO" },
        { "LS", "LESOTHO" },
        { "LV", "LETTONIE" },
        { "LB", "LIBAN" },
        { "LR", "LIBÉRIA" },
        { "LY", "JAMAHIRIYA ARABE LIBYENNE" },
        { "LI", "LIECHTENSTEIN" },
        { "LT", "LITUANIE" },
        { "LU", "LUXEMBOURG" },
        { "MO", "MACAO" },
        { "MK", "EX-RÉPUBLIQUE YOUGOSLAVE DE MACÉDOINE, L'" },
        { "MG", "MADAGASCAR" },
        { "MY", "MALAISIE" },
        { "MW", "MALAWI" },
        { "MV", "MALDIVES" },
        { "ML", "MALI" },
        { "MT", "MALTE" },
        { "MP", "MARIANNES DU NORD, ÎLES" },
        { "MA", "MAROC" },
        { "MH", "MARSHALL, ÎLES" },
        { "MQ", "MARTINIQUE" },
        { "MU", "MAURICE" },
        { "MR", "MAURITANIE" },
        { "YT", "MAYOTTE" },
        { "MX", "MEXIQUE" },
        { "FM", "MICRONÉSIE, ÉTATS FÉDÉRÉS DE" },
        { "MD", "MOLDOVA, RÉPUBLIQUE DE" },
        { "MC", "MONACO" },
        { "MN", "MONGOLIE" },
        { "ME", "MONTÉNÉGRO" },
        { "MS", "MONTSERRAT" },
        { "MZ", "MOZAMBIQUE" },
        { "MM", "MYANMAR" },
        { "NA", "NAMIBIE" },
        { "NR", "NAURU" },
        { "NP", "NÉPAL" },
        { "NI", "NICARAGUA" },
        { "NE", "NIGER" },
        { "NG", "NIGÉRIA" },
        { "NU", "NIUÉ" },
        { "NF", "NORFOLK, ÎLE" },
        { "NO", "NORVÈGE" },
        { "NC", "NOUVELLE-CALÉDONIE" },
        { "NZ", "NOUVELLE-ZÉLANDE" },
        { "IO", "OCÉAN INDIEN, TERRITOIRE BRITANNIQUE DE L'" },
        { "OM", "OMAN" },
        { "UG", "OUGANDA" },
        { "UZ", "OUZBÉKISTAN" },
        { "PK", "PAKISTAN" },
        { "PW", "PALAOS" },
        { "PS", "PALESTINIEN OCCUPÉ, TERRITOIRE" },
        { "PA", "PANAMA" },
        { "PG", "PAPOUASIE-NOUVELLE-GUINÉE" },
        { "PY", "PARAGUAY" },
        { "NL", "PAYS-BAS" },
        { "PE", "PÉROU" },
        { "PH", "PHILIPPINES" },
        { "PN", "PITCAIRN" },
        { "PL", "POLOGNE" },
        { "PF", "POLYNÉSIE FRANÇAISE" },
        { "PR", "PORTO RICO" },
        { "PT", "PORTUGAL" },
        { "QA", "QATAR" },
        { "RE", "RÉUNION" },
        { "RO", "ROUMANIE" },
        { "GB", "ROYAUME-UNI" },
        { "RU", "RUSSIE, FÉDÉRATION DE" },
        { "RW", "RWANDA" },
        { "EH", "SAHARA OCCIDENTAL" },
        { "BL", "SAINT-BARTHÉLEMY" },
        { "SH", "SAINTE-HÉLÈNE" },
        { "LC", "SAINTE-LUCIE" },
        { "KN", "SAINT-KITTS-ET-NEVIS" },
        { "SM", "SAINT-MARIN" },
        { "MF", "SAINT-MARTIN" },
        { "PM", "SAINT-PIERRE-ET-MIQUELON" },
        { "VA", "SAINT-SIÈGE (ÉTAT DE LA CITÉ DU VATICAN)" },
        { "VC", "SAINT-VINCENT-ET-LES GRENADINES" },
        { "SB", "SALOMON, ÎLES" },
        { "WS", "SAMOA" },
        { "AS", "SAMOA AMÉRICAINES" },
        { "ST", "SAO TOMÉ-ET-PRINCIPE" },
        { "SN", "SÉNÉGAL" },
        { "RS", "SERBIE" },
        { "SC", "SEYCHELLES" },
        { "SL", "SIERRA LEONE" },
        { "SG", "SINGAPOUR" },
        { "SK", "SLOVAQUIE" },
        { "SI", "SLOVÉNIE" },
        { "SO", "SOMALIE" },
        { "SD", "SOUDAN" },
        { "LK", "SRI LANKA" },
        { "SE", "SUÈDE" },
        { "CH", "SUISSE" },
        { "SR", "SURINAME" },
        { "SJ", "SVALBARD ET ÎLE JAN MAYEN" },
        { "SZ", "SWAZILAND" },
        { "SY", "SYRIENNE, RÉPUBLIQUE ARABE" },
        { "TJ", "TADJIKISTAN" },
        { "TW", "TAÏWAN, PROVINCE DE CHINE" },
        { "TZ", "TANZANIE, RÉPUBLIQUE-UNIE DE" },
        { "TD", "TCHAD" },
        { "CZ", "TCHÈQUE, RÉPUBLIQUE" },
        { "TF", "TERRES AUSTRALES FRANÇAISES" },
        { "TH", "THAÏLANDE" },
        { "TL", "TIMOR-LESTE" },
        { "TG", "TOGO" },
        { "TK", "TOKELAU" },
        { "TO", "TONGA" },
        { "TT", "TRINITÉ-ET-TOBAGO" },
        { "TN", "TUNISIE" },
        { "TM", "TURKMÉNISTAN" },
        { "TC", "TURKS ET CAÏQUES, ÎLES" },
        { "TR", "TURQUIE" },
        { "TV", "TUVALU" },
        { "UA", "UKRAINE" },
        { "UY", "URUGUAY" },
        { "VU", "VANUATU" },
        { "VE", "VENEZUELA" },
        { "VN", "VIET NAM" },
        { "WF", "WALLIS ET FUTUNA" },
        { "YE", "YÉMEN" },
        { "ZM", "ZAMBIE" },
        { "ZW", "ZIMBABWE" },
    };

    /*
    http://londonfx.co.uk/valdates.html

    Introduction 

    Value dates are the dates on which FX trades settle, 
    i.e. the date that the payments of each currency are made. 
    The value dates for most FX trades are "spot", 
    which generally means two business days from the trade date (T+2). 
    The most notable exception to this rule is USD/CAD, 
    which has a spot date one business day from the trade date (T+1). 
    Spot dates for CAD crosses (e.g. GBP/CAD) normally take 
    the spot date of the crossed currency pair and are therefore T+2. 

    Forward trades 

    It is possible to settle trades on dates other than the spot date, 
    in which case the rate will be adjusted by forward points 
    to compensate for the interest rate differential between the two currencies being traded. 
    In addition to the spot date, there are many standard tenors (periods) 
    on which it is possible to settle an FX trade. These include “1 month”, 
    “tomorrow” (tom) and “6 months”. The post-spot tenors are calculated from 
    the spot date rather than from the trade date. It is also possible to settle 
    on any value date between any standard tenor. This is known as a “broken date”. 

    Value date roll-over 

    For all major currency pairs except NZD/USD, global market convention 
    is that value dates roll forward at 5pm New York time. Value dates for 
    NZD/USD roll forward at 7am Auckland time. This means that the local time 
    of the value date roll-over varies throughout the year, depending on 
    daylight savings time conventions, as follows: 

    With effect from Daylight Savings Time Time of value date rollover 
    London New York Auckland GMT
    non-NZD GMT NZD London non-NZD London NZD NY
    NZD Auckland non-NZD 
    2nd Sunday in March GMT EDT NZDT 21:00 18:00 21:00 18:00 14:00 10:00 
    Last Sunday in March BST EDT NZDT 21:00 18:00 22:00 19:00 14:00 10:00 
    1st Sunday in April BST EDT NZST 21:00 19:00 22:00 20:00 15:00 09:00 
    Last Sunday in September BST EDT NZDT 21:00 18:00 22:00 19:00 14:00 10:00 
    Last Sunday in October GMT EDT NZDT 21:00 18:00 21:00 18:00 14:00 10:00 
    1st Sunday in November GMT EST NZDT 22:00 18:00 22:00 18:00 13:00 11:00 


    Currency holidays 

    For most T+2 currency pairs, if T+1 is a USD holiday, then this does 
    not normally affect the spot date, but if a non-USD currency in the 
    currency pair has a holiday on T+1, then it will make the spot date 
    become T+3. If USD or either currency of a pair have a holiday on T+2, 
    then the spot date will be T+3. This means, for example, that crosses 
    such as EUR/GBP can never have a spot date on 4th July (although such 
    a date could be quoted as an outright). 

    USD/TRY spot date 

    The spot date for USD/TRY in the Turkish interbank market is T+0 (same day) 
    until 3:30pm Istanbul time, following which the spot date becomes T+1. 
    This means the value date rollover time is 3:30pm Istanbul instead of 5pm New York. 
    Reuters Dealing 3000 Spot Matching (D2) supports both T+0 and T+1. 
    However, it is normal for banks to quote their customers a spot date 
    of T+1 with a 5pm NY rollover. For customers, it is therefore similar to USD/CAD, 
    with the exception that for crosses (e.g. EUR/TRY, GBP/TRY etc), the spot date is also T+1. 

    USD/RUB spot date 

    USD/RUB is traded interbank as T+0, T+1 and T+2. Reuters Dealing 3000 
    Spot Matching (D2) supports T+0 and T+1 for USD/RUB. The most popular 
    of the three value dates is T+1, which could therefore be considered 
    as the spot date. 

    Latin American currencies 

    USD holidays normally affect the spot date only if T+2 is a USD holiday. 
    If T+1 is a USD holiday, this does not normally prevent T+2 from being 
    the spot date. Certain Latin American currencies (ARS, CLP and MXN) are 
    an exception to this. If T+1 is a USD holiday, then the spot date for 
    the affected currencies will be T+3. For example, if the trade date is 
    a Monday and a USD holiday falls on the Tuesday, then the spot date for 
    EUR/USD will be the Wednesday, but the spot date for USD/MXN will be the Thursday. 


    */



#ifdef __cplusplus
    const facet< official_t >  official_facet ( Officials,  CCY_NB_ELEMS(Officials) );
    const facet< dependent_t > dependent_facet( Dependents, CCY_NB_ELEMS(Dependents) );
    const facet< obsolete_t >  obsolete_facet ( Obsoletes,  CCY_NB_ELEMS(Obsoletes) );
    const facet< symbol_t >    symbol_facet   ( Symbols,  CCY_NB_ELEMS(Symbols) );
    const facet< subunit_t >   subunit_facet  ( SubUnits,  CCY_NB_ELEMS(SubUnits) );
    const facet< arab_t >      arab_facet     ( Arabs,  CCY_NB_ELEMS(Arabs) );

}; // namespace ccy
#endif /* cplusplus */
