// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// STL
#include <string>
#include <exception>
// Opengeopp
#include "IPBlockRecord.hpp"
#include "DbaIPBlockRecord.hpp"

namespace soci {

  // //////////////////////////////////////////////////////////////////////
  void type_conversion<OPENGEOPP::IPBlockRecord_T>::
  from_base (values const& iIPBlockRecordValues, indicator /* ind */,
             OPENGEOPP::IPBlockRecord_T& ioIPBlockRecord) {
    /*
      ip_from, ip_to, registry, assigned_date,
      country_code_2, country_code_3, country_name
    */
    ioIPBlockRecord._ipFrom = iIPBlockRecordValues.get<int> ("ip_from");
    ioIPBlockRecord._ipTo = iIPBlockRecordValues.get<int> ("ip_to");
    ioIPBlockRecord._registry = iIPBlockRecordValues.get<std::string> ("registry");
    //const int lAssignedDate = iIPBlockRecordValues.get<int> ("assigned_date");
    //ioIPBlockRecord._dateAssigned = lAssignedDate;
    ioIPBlockRecord._country2Char = iIPBlockRecordValues.get<std::string> ("country_code_2");
    // The city code will be set to the default value (empty string)
    // when the column is null
    ioIPBlockRecord._country3Char = iIPBlockRecordValues.get<std::string> ("country_code_3", "");
    // The city code will be set to the default value (empty string)
    // when the column is null
    ioIPBlockRecord._country = iIPBlockRecordValues.get<std::string> ("country_name", "");
  }

  // //////////////////////////////////////////////////////////////////////
  void type_conversion<OPENGEOPP::IPBlockRecord_T>::
  to_base (const OPENGEOPP::IPBlockRecord_T& iIPBlockRecord,
           values& ioIPBlockRecordValues,
           indicator& ioIndicator) {
    const indicator lCountryCodeIndicator =
      iIPBlockRecord._country3Char.empty() ? i_null : i_ok;
    const indicator lCountryNameIndicator =
      iIPBlockRecord._country.empty() ? i_null : i_ok;
    ioIPBlockRecordValues.set ("ip_from", iIPBlockRecord._ipFrom);
    ioIPBlockRecordValues.set ("ip_to", iIPBlockRecord._ipTo);
    ioIPBlockRecordValues.set ("registry", iIPBlockRecord._registry);
    const int lAssignedDate = 1;
    // const int lAssignedDate = iIPBlockRecord._dateAssigned
    ioIPBlockRecordValues.set ("assigned_date", lAssignedDate);
    ioIPBlockRecordValues.set ("country_code2",
                               iIPBlockRecord._country2Char);
    ioIPBlockRecordValues.set ("country_code3",
                               iIPBlockRecord._country3Char,
                               lCountryCodeIndicator);
    ioIPBlockRecordValues.set ("country_name",
                               iIPBlockRecord._country,
                               lCountryNameIndicator);
    ioIndicator = i_ok;
  }

}

namespace OPENGEOPP {

}
