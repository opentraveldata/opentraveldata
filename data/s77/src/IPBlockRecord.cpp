// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// C
#include <assert.h>
// STL
#include <string>
#include <sstream>
// Boost (Extended STL)
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/date_time/gregorian/gregorian.hpp>
// OpenGeo++
#include <IPBlockRecord.hpp>

namespace OPENGEOPP {
  
  // //////////////////////////////////////////////////////////////////////
  IPBlockRecord_T::IPBlockRecord_T () {
  }

  // //////////////////////////////////////////////////////////////////////
  std::string IPBlockRecord_T::toString() const {
    std::ostringstream oStr;
    oStr << _ipFrom << " -> " << _ipTo
         << ", assigned by " << _registry
         << " on " << boost::gregorian::to_simple_string (_dateAssigned)
         << " in  " << _country2Char << " (" << _country3Char
         << ", " << _country << ")";
    return oStr.str();
  }

}
