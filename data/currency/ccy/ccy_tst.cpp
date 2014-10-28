// Copyright (C) 2008 Remi Chateauneu
//
// This file is part of the CCY C++ Library.  This library is free
// software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the
// Free Software Foundation; either version 2, or (at your option)
// any later version.

// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

#include <cassert>
#include <map>
#include <set>
#include <vector>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <iterator>
#include <cstring>

#include "ccy.h"

using namespace std ;

// #ifndef _LCONV_DEFINED
#include "locale.h"

/// This checks that invalid chars are detected.
static void tstBad(void)
{
    ccy::code tmpCcy1;
    assert( tmpCcy1 == "" );

    do
    {
        static const char * invalidCcyName = "#'@;" ;
        try
        {
            ccy::code tmpCcy(invalidCcyName);
        }
        catch( const ccy::bad_name & refExc )
        {
            assert( std::string( invalidCcyName ) == refExc.what() );
            break ;
        };
        assert( ! "Exception was not thrown" );
    } while(false);

};

/// Currency names are case-insensitive,
/// so they are converted when creating a currency.
static void tstCmp(void)
{
    /// A set ensures the sorting order is OK.
    std::set< ccy::code > setCcy ;

    setCcy.insert( "USD" );
    setCcy.insert( "uSd" );
    setCcy.insert( "gBp" );
    setCcy.insert( "EuR" );
    setCcy.insert( "jpy" );
    setCcy.insert( "cHf" );

    std::ostringstream tmpStrm ;
    copy( setCcy.begin(), setCcy.end(),
        ostream_iterator< ccy::code >( tmpStrm, "," ) );

    cout << "tstCmp:" << tmpStrm.str() << "\n" ;

    /// This follows the alphabetical order.
    /// No localization here because ISO standard.
    static const char * expectedStr = "CHF,EUR,GBP,JPY,USD," ;
    assert( tmpStrm.str() == expectedStr );
};

/// This checks the reading of currency names from a stream.
static void tstRead(void)
{
    static const char * inBuf =
        " eur Eur gbp GBP usD" ;

    std::vector< ccy::code > vecCcy ;

    istringstream inStrm( inBuf );
    copy( istream_iterator< std::string >( inStrm )
        , istream_iterator< std::string >()
        , back_inserter( vecCcy ) );

    /// This is just for displaying the result.
    copy( vecCcy.begin(), vecCcy.end(),
        ostream_iterator< ccy::code >( std::cout, "," ) );
    std::cout << "\n" ;

    /// Checks the content of the vector.
    assert( vecCcy.size() == 5 );
    assert( vecCcy[0] == "EUR" );
    assert( vecCcy[1] == "EUR" );
    assert( vecCcy[2] == "GBP" );
    assert( vecCcy[3] == "GBP" );
    assert( vecCcy[4] == "USD" );
};

/// This reads only three consecutive letters.
/// If there are chars after the string, they are not
/// taken into account.
static void tstStrm(void)
{
    /// Very messy string from which currency names are read.
    static const char * inBuf =
        "  jpY Eur\tCadgbpGBP Vnd\rusd\nCHF==" ;

    std::vector< ccy::code > vecCcy ;

    istringstream inStrm( inBuf );
    copy( istream_iterator< ccy::code >( inStrm )
        , istream_iterator< ccy::code >()
        , back_inserter( vecCcy ) );

    /// Just for displaying.
    copy( vecCcy.begin(), vecCcy.end(),
        ostream_iterator< ccy::code >( std::cout, "," ) );
    std::cout << "\n" ;

    assert( vecCcy.size() == 8 );
    assert( vecCcy[0] == "JPY" );
    assert( vecCcy[1] == "EUR" );
    assert( vecCcy[2] == "CAD" );
    assert( vecCcy[3] == "GBP" );
    assert( vecCcy[4] == "GBP" );
    assert( vecCcy[5] == "VND" );
    assert( vecCcy[6] == "USD" );
    assert( vecCcy[7] == "CHF" );
};

/// Tests this it is convenient to init an array.
static void tstInit(void)
{
    static const ccy::code tmpCcy[] = { "IER", "GBP", "JPY" };
};

/// Operations with strings conversions to/from currency names.
static void tstStr(void)
{
    std::cout << "Testing strings operations\n" ;

    ccy::code tmpCcy( "GBP" );

    assert( tmpCcy == "gbP" );

    /// This string is too short, cannot be a currency.
    do
    {
        static const char * badCcyName = "xy" ;
        try
        {
            if( tmpCcy == badCcyName );
        }
        catch( const ccy::bad_name & refExc )
        {
            assert( std::string( badCcyName ) == refExc.what() );
            break ;
        };
        assert( ! "Exception was not thrown" );
    } while(false);

    assert( tmpCcy == std::string("gbP") );

    assert( tmpCcy < "uSd" );

    assert( tmpCcy < std::string("UsD") );

    std::string tmpAssign = tmpCcy ;
    assert( tmpAssign == "GBP" );

    std::string tmpConcat = tmpCcy + " is a currency" ;
    assert( tmpConcat == "GBP is a currency" );

    tmpConcat = "A currency is " + tmpCcy ;
    assert( tmpConcat == "A currency is GBP" );

    tmpConcat = tmpCcy + std::string(" is made of pence.");
    assert( tmpConcat == "GBP is made of pence." );

    tmpConcat = std::string("Pence and ") + tmpCcy ;
    assert( tmpConcat == "Pence and GBP" );
};

/* Each country has two standard currency symbols.
The local currency symbol is used commonly within the country,
while the international currency symbol is used internationally
to refer to that country's currency when it is necessary
to indicate the country unambiguously. 

For example, many countries use the dollar as their monetary unit,
and when dealing with international currencies
it's important to specify that one is dealing with (say)
Canadian dollars instead of U.S. dollars or Australian dollars.
But when the context is known to be Canada,
there is no need to make this explicit--dollar amounts
are implicitly assumed to be in Canadian dollars. 

char *currency_symbol 
The local currency symbol for the selected locale.
In the standard `C' locale, this member has a value of ""
(the empty string), meaning "unspecified".
The ANSI standard doesn't say what to do when you find this value;
we recommend you simply print the empty string as you would print
any other string found in the appropriate member. 

char *int_curr_symbol 
The international currency symbol for the selected locale.
The value of int_curr_symbol should normally consist of a three-letter
abbreviation determined by the international standard ISO 4217 Codes
for the Representation of Currency and Funds, followed by a one-character separator
(often a space). In the standard `C' locale, this member has a value of ""
(the empty string), meaning "unspecified".
We recommend you simply print the empty string as you would print
any other string found in the appropriate member. */

static const char * arrLocales[] = {
    // ls /usr/lib/locale /usr/share/locale
    "en_US.UTF-8",
    "ca_ES",
    "ca_ES@euro",
    "ca_ES.utf8",
    "ca_ES.utf8@euro",
    "sr_YU",
    "sr_YU@cyrillic",
    "sr_YU.utf8",
    "sr_YU.utf8@cyrillic",
    "sv_FI",
    "sv_FI@euro",
    "sv_FI.utf8",
    "sv_FI.utf8@euro",
    "sv_SE",
    "sv_SE.iso885915",
    "sv_SE.utf8",
    "de_LU",
    "de_LU@euro",
    "de_LU.utf8",
    "de_LU.utf8@euro",

    // Windows
    "American",
    "English",
    "English_Canada",
    "English_United States.1252",
    "English_United Kingdom",
    "French",
    "French_France.1252",
    "French_Switzerland.1252",
    "French_Canada.1252",
    "German",
    "German_Switzerland.1252",
    "German_Austria.1252",
    "Spanish",
    "Spanish_Chile",
    "Portuguese",
    "Portuguese_Portugal",
    "Arabic",
    "Greek",
    "Hebrew",
    "Japanese",
    "Korean",
    "Thai",
    "Vietnamese",
};


/* The only locale names you can count on finding on all operating systems
are these three standard ones: 
"C" This is the standard C locale. The attributes and behavior
it provides are specified in the ANSI C standard. When your program starts up,
it initially uses this locale by default. 
"POSIX"  This is the standard POSIX locale. Currently, it is an alias for the standard C locale. 
"" The empty name says to select a locale based on environment variables. */
static void tstLocale(void)
{

    char * old_locale = setlocale (LC_MONETARY, NULL);
    std::cout << "Current locale is:" << old_locale << "\n" ;

    /* Copy the name so it won't be clobbered by setlocale. */
#ifdef _MSC_VER
    char * saved_locale = _strdup (old_locale);
#else
    char * saved_locale = strdup (old_locale);
#endif
    if (old_locale == NULL)
    {
        abort();
    };

    /// This tries for each proposed locale, whether it is available or not.
    static const size_t nbLocs = sizeof(arrLocales) / sizeof(arrLocales[0]) ;
    for( int idxLoc = 0 ; idxLoc < nbLocs; ++idxLoc )
    {
        const char * newLocNam = arrLocales[idxLoc] ;

        const char * newLocaleCat = setlocale (LC_MONETARY, newLocNam );
        if( newLocaleCat == NULL )
        {
            continue ;
        };

        const lconv * tmpLconv = localeconv();

        /// This must be a three-digits string and should not throw any exception.
        ccy::code tmpInt = tmpLconv->int_curr_symbol;

        /// This can be any sign: '$', '£' etc...
        std::string tmpSym = tmpLconv->currency_symbol;

        std::cout
            << std::setw(30) << newLocNam
            << " => " << std::setw(30) << newLocaleCat
            << " " << tmpInt
            << " " << tmpSym
            << "\n" ;
    }

    /* Restore the original locale. */
    setlocale (LC_MONETARY, saved_locale);
    free (saved_locale);
};

/// It is possible to enforce a specific currency at compile-time.
static void tstTypes(void)
{
    std::cout << "Test of compile-time currencies\n" ;
    /// This currency is defined at compile-time.
    ccy::type< 'U', 'S', 'D' > typUSD ;

    assert( typUSD == "USD" );
};

static void tstPair(void)
{
    std::cout << "Test of currency pairs\n" ;
    ccy::pair myPair1("USD", "GBP");
    assert( myPair1.is_cross() == false );

    ccy::pair myPair2( ccy::code("EUR"), ccy::type<'G','B','P'>() );
    assert( myPair2.is_cross() == true );

    std::map< ccy::code, ccy::code > myMap ;
    myMap.insert( myPair1 );

    myPair2 = *myMap.find( myPair1.first );
    assert( myPair2.second == "GBP" );
};

static void tstArab(void)
{
    std::cout << "Test of Arab currencies nb=" << ccy::arab_facet.size() << "\n" ;
    std::stringstream strmArabs ;

    std::transform( ccy::arab_facet.begin( "OMR" ), ccy::arab_facet.end(),
        std::ostream_iterator< ccy::code >( strmArabs, "=" ),
        ccy::facet< arab_t >::to_code );

    std::transform( ccy::arab_facet.begin(), ccy::arab_facet.end(),
        std::ostream_iterator< ccy::code >( strmArabs, "+" ),
        ccy::facet< arab_t >::to_code );

    assert( strmArabs.str() == "OMR=QAR=AED+BHD+EGP+KWD+OMR+QAR+" );
};

//Attention a l'annee.
//Ajouter aussi le 1:1, evidemment.
static void tstSubUnits(void)
{
    std::cout << "Test of currencies sub-units\n" ;
    int amount = 12345 ;

    /// { "GBP", "Shilling", {   20,  1}, 1971   },

    for( ccy::facet< subunit_t >::const_iterator
            itBeg = ccy::subunit_facet.begin("GBP"),
            itEnd = ccy::subunit_facet.end("GBP");
        itBeg != itEnd ;
        ++itBeg )
        {
            int a = ( amount * itBeg->_ratio._numerator ) / itBeg->_ratio._denominator ;
            int rest = amount - ( a * itBeg->_ratio._denominator ) / itBeg->_ratio._numerator ;
            amount = rest ;

            std::cout << "Amount=" << amount
                << " Subunit=" << itBeg ->_subunit << "\n" ;
        };
};


int main(int argC, const char ** argV )
{
    try
    {
        tstBad();
        tstCmp();
        tstRead();
        tstStrm();
        tstInit();
        tstStr();
        tstLocale();
        tstTypes();
        tstPair();
        tstArab();
        tstSubUnits();
    }
    catch( const std::exception & refExc )
    {
        std::cerr << "Standard exception:" << refExc.what() << "\n" ;
        exit(EXIT_FAILURE);
    }
    catch(...)
    {
        std::cerr << "An unexpected exception was thrown...\n" ;
        exit(EXIT_FAILURE);
    }

    int i ; std::cin >> i ;
};

