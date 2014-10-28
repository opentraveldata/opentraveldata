#ifndef __OPENGEOPP_DBA_DBAIPBLOCKRECORD_HPP
#define __OPENGEOPP_DBA_DBAIPBLOCKRECORD_HPP

// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// SOCI
#include <soci/soci.h>

// Forward declarations
namespace OPENGEOPP {
  struct IPBlockRecord_T;
}

namespace soci {

  /** Specify how the Place class can be converted to (resp. from) values
      stored into (resp. retrieved from) database, using the SOCI framework. */
  template <>
  struct type_conversion<OPENGEOPP::IPBlockRecord_T> {

    typedef values base_type;

    /** Fill an IPBlockRecord object from the database values. */
    static void from_base (values const& iPlaceValues,
                           indicator /* ind */,
                           OPENGEOPP::IPBlockRecord_T& ioIPBlockRecord);


    /** Fill the database values from an IPBlockRecord object. */
    static void to_base (const OPENGEOPP::IPBlockRecord_T& iIPBlockRecord,
                         values& ioPlaceValues,
                         indicator& ioIndicator);
  };
}
#endif // __OPENGEOPP_DBA_DBAIPBLOCKRECORD_HPP
