#ifndef __OPENGEOPP_BOM_IPBLOCKRECORD_HPP
#define __OPENGEOPP_BOM_IPBLOCKRECORD_HPP

// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// STL
#include <map>
// Boost
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/date_time/gregorian/gregorian.hpp>

namespace OPENGEOPP {
  
  typedef unsigned int IPNumber_T;

  /** IP Block Record. */
  struct IPBlockRecord_T {
    // Attributes
    IPNumber_T _ipFrom;
    IPNumber_T _ipTo;
    std::string _registry;
    std::string _country2Char;
    std::string _country3Char;
    std::string _country;
    boost::gregorian::date _dateAssigned;
    //int _dateAssigned;
    
    /** Constructor. */
    IPBlockRecord_T();
    
    /** Display. */
    std::string toString() const;
    
    /** Staging Time. */
    long _itSeconds;
  };
  
  /** List of IPBlockRecord_T */
  typedef std::map<IPNumber_T, IPBlockRecord_T> IPBlockRecordList_T;
}
#endif // __OPENGEOPP_BOM_IPBLOCKRECORD_HPP

