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

// This library provides some support for manipulating currency names.
// It follows ISO 4217: Three letters curreny codes, etc...


#ifndef CCY_HPP_INCLUDED
#define CCY_HPP_INCLUDED


/// http://search.cpan.org/~neilb/Locale-Codes-2.07/lib/Locale/Currency.pod

/// http://www.iso.org/iso/iso_catalogue/catalogue_tc/catalogue_detail.htm?csnumber=23132
/// Codes for the representation of currencies and funds

#define SZ_CCY 4

/// Models an alpha-2 country code for ISO-3166.
struct alpha2
{
    char _code[3];
};

/* Matching between a three-letter currency and an integer.
BEWARE: Sorting based on the integer is NOT the alphabetical
order because of endianness. On the other hand, we provide
a comparison fucntion which is portable. */
union TmpU
{
    char m_chr[SZ_CCY] ;
    int  m_int ;
};

/* Fast comparison function for two currencies.
This assumes that they have three letters which is ISO.
Internal use only, equivalent to strncmp(,,3).
The order is the same whatever the endianness. */
static int cmp3way( const void * void1, const void * void2 )
{
    const char * val1 = ( const char * )void1;
    const char * val2 = ( const char * )void2;
    char tmpDiff ;
       ( tmpDiff = val1[0] - val2[0] )
    || ( tmpDiff = val1[1] - val2[1] )
    || ( tmpDiff = val1[2] - val2[2] );
    return tmpDiff ;
};



/* There is always an invalud currency at the end of each array,
to allow scanning. Therefore, the minus one. */
#define CCY_NB_ELEMS(Tab) ( sizeof(Tab)/sizeof(Tab[0]) - 1 )

#define CCY_BSEARCH( Ccy, Type, Tab, nbElems ) \
    ( const Type * )bsearch(Ccy,Tab,nbElems,sizeof(Tab[0]),cmp3way )

#define CCY_NEXT( p ) ( cmp3way( (p)->_code, (p+1)->_code ) ? 0 : (ptr + 1) )

/* This does not have to be sorted. */
#define NOCCY "***"

    /* The following is a list of active codes of official ISO 4217 currency names. */
    struct official_t
    {
        const char    _code[SZ_CCY] ;
        const char  * _num ;
        int           _e ;
        const char  * _currency ;
        const char  * _locations[20] ; /* If too small, the compiler will warn. */
    };


    struct ratio
    {
        int          _numerator ;
        int          _denominator ;
    #ifdef __cplusplus
        bool operator==( const ratio & refRat ) const
        {
            return ( _numerator   == refRat._numerator )
                && ( _denominator == refRat._denominator );
        };

        bool operator<( const ratio & refRat ) const
        {
            return ( _numerator   * refRat._denominator )
                 < ( _denominator * refRat._numerator   );
        };
    #endif /* cplusplus */
    };

    /* A number of territories are not included in ISO 4217, because their currencies
    are not per se an independent currency, but a variant of another currency. */
    struct dependent_t
    {
        const char   _code[SZ_CCY] ;
        const char * _description ;
        const char   _independant_code[SZ_CCY] ;
        ratio        _conversion_ratio ;
    };

    struct obsolete_t
    {
        const char   _code[SZ_CCY] ;
        int          _num ;
        const char * _currency ;
        const char   _replacing_currency[SZ_CCY] ;
        int          _year_end ;
    };

    struct symbol_t
    {
        const char           _code[SZ_CCY] ;
        char           _iso8859 ;
        const char         * _html ;
        const wchar_t        _unicode[5] ; /* Cannot be more that 4 chars. */
        const unsigned long  _utf8[5] ;
    };

    struct subunit_t
    {
        const char   _code[SZ_CCY] ;
        const char * _subunit ;
        ratio        _ratio ;
        int          _year_end ;
    };

    struct arab_t
    {
        const char   _code[SZ_CCY] ;
    };


#ifdef __cplusplus

#include <stdexcept>
#include <string>
#include <iostream>
#include <algorithm>

#include <locale>

namespace ccy
{
    /// Indicates that a currency is created with an invalid currency name.
    class bad_name : public std::exception
    {
    public:
        bad_name( const std::string & badStr )
            : m_msg(badStr) {};

        const char * what(void) const throw()
        {
            return m_msg.c_str();
        };

        virtual ~bad_name() throw() {};

    private:
        std::string m_msg ;
    };



    /// Based on ISO 4217
    /// It does not have a base class, so it can be initialised like an aggregate.
    class code
    {
    public:

        /// The first two letters of the code are the two letters
        /// of ISO 3166-1 alpha-2 country codes , also
        /// used as the basis for national top-level domains. 
        alpha2 country(void) const
        {
            alpha2 tmpAlpha ;
            tmpAlpha._code[0] = m_val[0];
            tmpAlpha._code[1] = m_val[1];
            return tmpAlpha;
        };

        code() { to_int() = 0 ; };

        code( const std::string & refStr )
        {
            init( refStr.c_str() );
        };

        code( const char * ptrChr )
        {
            init( ptrChr );
        };

        /// This costs an extra struct copy,
        /// but makes all the validation with a single function.
        code( char l0, char l1, char l2 )
        {
            const char tmpChr[SZ_CCY] = { l0, l1, l2, '\0' };
            init( tmpChr );
        };

        char * c_str(void)
        {
            return m_val ;
        };

        int to_int(void) const
        {
            return reinterpret_cast< const TmpU *>(this)->m_int ;
        };

        int & to_int(void)
        {
            return reinterpret_cast< TmpU *>(this)->m_int ;
        };

        /// Used for containers. Very fast.
        bool operator==( const code & refCcy ) const
        {
            return to_int() == refCcy.to_int();
        };

        bool operator!=( const code & refCcy ) const
        {
            return to_int() != refCcy.to_int();
        };

        /// Used for containers.
        bool operator<( const code & refCcy ) const
        {
            /// This would be faster if we applied only this integer
            /// comparisons, but it would not be aht ealphabetic order.
            // return to_int() < refCcy.to_int();
            return cmp3way( m_val, refCcy.m_val ) < 0 ;
        };

        operator std::string(void) const
        {
            return m_val[0] ? std::string( m_val, (SZ_CCY-1) ) : std::string();
        };

        friend std::ostream & operator << ( std::ostream & refOstrm, const code & refCode )
        {
            refOstrm << refCode.m_val ;
            return refOstrm ;
        };

        /// This reads only three consecutive letters.
        /// If there are chars after the string, they are not
        /// taken into account.
        friend std::istream & operator >> ( std::istream & refIstrm, code & refCode )
        {
            for( int idxChar = 0 ; idxChar < (SZ_CCY-1) ; )
            {
                char tmpC ;
                refIstrm.get( tmpC );
                if( isalpha( tmpC ) )
                {
                    refCode.m_val[ idxChar++ ] = toupper(tmpC) ;
                }
                else
                {
                    /// It is OK to read a space BEFORE the currency.
                    if( isspace( tmpC ) && ( idxChar == 0 ) )
                    {
                        continue ;
                    }
                    refIstrm.setstate(std::ios_base::failbit);
                    refCode.init(NULL);
                    break ;
                };
            }
            refCode.m_val[ SZ_CCY-1 ] = '\0' ;
            return refIstrm ;
        };

        /// So it behaves like a simple string.
        std::string operator+( const std::string & refStr ) const
        {
            return std::string(*this) + refStr ;
        };

        /// So it behaves like a simple string.
        friend std::string operator+( const std::string & refStr, const code & refCode )
        {
            return refStr + std::string(refCode);
        };

    private:

        /// Checks three characters and converts to upcase.
        /// TODO: Does the same when the input arg is a const char ptr.
        void init( const char * ptrStr )
        {
            if( ( ptrStr == NULL ) || ( ptrStr[0] == '\0' ) )
            {
                to_int() = 0 ;
                return ;
            }

            /// This assumes that sizeof(int) == 4.
            char * tmpChr = m_val;
            for( int idxStr = 0 ; idxStr < (SZ_CCY-1) ; idxStr++ )
            {
                char tmpC = ptrStr[idxStr];
                if( isalpha( tmpC ) )
                {
                    *tmpChr++ = toupper(tmpC) ;
                }
                else
                {
                    throw bad_name(ptrStr);
                };
            }
            /// Now the string is zero-terminated.
            *tmpChr = '\0' ;
        };

        /// Used for sorting. Independant of endianness.
        char m_val[SZ_CCY] ;
    };

    /// This has the attributes of a currency,
    /// but it allows type-checking too.
    /// On the other hand, it is impossible to change the content
    /// of the currency.
    template< char L0, char L1, char L2 >
    class type : public code
    {
    public:
        type() : code( L0, L1, L2 ) {};
    };

    /// Used for exchange rates and volatilities. http://www.investopedia.com/terms/c/currencypair.asp
    class pair : public std::pair< code, code >
    {
    public:
        pair( const code & ref1, const code & ref2 ) : std::pair< code, code >( ref1, ref2 ) {};

        pair( const std::pair< code, code > & refPair )
            : std::pair< code, code >( refPair )
        {
        };


        pair & operator=( const std::pair< code, code > & refPair )
        {
            std::pair< code, code >::operator=( refPair );
            return *this ;
        };

        /// GBPUSD, EURUSD etc...
        friend std::ostream & operator << ( std::ostream & refO, const pair & refPair )
        {
            return ( refO << refPair.first << refPair.second );
        };

        /// This can read 'USDGBP' or 'USD/GBP'.
        friend std::istream & operator >> ( std::istream & refI, pair & refPair )
        {
            refI >> refPair.first ;
            switch( refI.get() )
            {
            case '/':
            default : refI.unget();
            }
            return ( refI >> refPair.second );
        };

        pair operator !(void) const { return pair( second, first ); };

        /// http://www.investopedia.com/terms/c/crosscurrency.asp
        bool is_cross(void) const
        {
            return (first != "USD") && (second != "USD");
        };

    /// Synonyms.
        const code & base(void) const { return first ; };
        const code & primary(void) const { return first ; };

    /// Synonyms.
        const code & quote(void) const { return second ; };
        const code & counter(void) const { return second ; };
        const code & secondary(void) const { return second ; };
    };

    template< class Data >
    class facet
    {
        const Data * _ptr ;
        size_t       _size ;

        struct cmp
        {
            bool operator()( const code & refCode , const Data & refDat ) const
            {
                return code( refDat._code ) < refCode ;
            };

            bool operator()( const Data & refDat , const code & refCode ) const
            {
                return code( refDat._code ) < refCode ;
            };

            bool operator()( const Data & refDat1 , const Data & refDat2 ) const
            {
                return code( refDat1._code ) < code( refDat2._code ) ;
            };
        };
    public:
        facet( const Data * ptrDat, size_t tmpSz )
            : _ptr( tmpSz ? ptrDat : 0 ), _size( tmpSz ) {};

    size_t size(void) const { return _size ; }

        typedef Data * iterator ;
        typedef const Data * const_iterator ;

        static code to_code( const Data & refData )
        {
            return code( refData._code );
        };

        const_iterator begin(void) const
        {
            return _ptr ;
        };

        const_iterator begin( const code & refCod ) const
        {
            if( _size == 0 )
            {
                return end();
            };
            const Data * ptr = std::lower_bound( _ptr, _ptr + _size, refCod, cmp() );
            return refCod < to_code(*ptr) ? 0 : ptr;
        };

        const_iterator end(void) const
        {
            return _ptr + _size ;
        };

        const_iterator end( const code & refCod ) const
        {
            if( _size == 0 )
            {
                return end();
            };
            const Data * ptr = std::upper_bound( begin(), end(), refCod, cmp() );
            if( ptr == end() )
            {
                return end();
            }
            else
            {
                return refCod < to_code(*ptr) ? end() : ptr;
            }
        };

    };

    extern const facet< official_t >  official_facet ;
    extern const facet< dependent_t > dependent_facet;
    extern const facet< obsolete_t >  obsolete_facet ;
    extern const facet< symbol_t >    symbol_facet   ;
    extern const facet< subunit_t >   subunit_facet  ;
    extern const facet< arab_t >      arab_facet     ;


/*
Scientific units:
http://home.fnal.gov/~wb/units.html
http://www.aei.mpg.de/~peekas/dimnum/

Associate a unique datatype to each currency.
*/

};

/*
http://lists.boost.org/Archives/boost/2005/01/78540.php
http://lists.boost.org/Archives/boost/2005/01/78546.php
http://tinyurl.com/5l7tb
http://groups.google.com/group/comp.lang.c++.moderated/browse_thread/thread/5ce1d1d54cf5ab44/89b0c2f6bea7dd3bs
*/

/* Investigate:
std::moneypunct::do_curr_symbol
Returns a string to use as the currency symbol.
In the C locale, the function returns the empty string.
In named locales, the returned international string
(in other words, when intl == true) typically conforms to the ISO 4217 standard.
For example, the standard specifies that the US currency symbol for the Dollar is USD,
and that the Japanese currency symbol for the Yen is JPY.


DOC: This is not very convenient for financial application which requires 
to work with different 

Consider Reuters RIC, currency pairs for change rates.
*/


#endif /* __cplusplus */



#endif // CCY_HPP_INCLUDED
