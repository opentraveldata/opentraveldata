// C
#include <cassert>

// STL
#include <iostream>
#include <sstream>
#include <fstream>
#include <limits>
#include <string>
#include <map>
#include <set>
#include <vector>

// Boost (Extended STL)
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/date_time/gregorian/gregorian.hpp>

// Boost Spirit (Parsing)
// #define BOOST_SPIRIT_DEBUG
#include <boost/spirit/include/classic_core.hpp>
#include <boost/spirit/include/classic_attribute.hpp>
#include <boost/spirit/include/classic_functor_parser.hpp>
#include <boost/spirit/include/classic_loops.hpp>
#include <boost/spirit/include/classic_chset.hpp>
#include <boost/spirit/include/classic_confix.hpp>
#include <boost/spirit/include/classic_file_iterator.hpp>
#include <boost/spirit/include/classic_push_back_actor.hpp>
#include <boost/spirit/include/classic_assign_actor.hpp>

// SOCI
#include <soci/soci.h>
#include <soci/mysql/soci-mysql.h>

// OpenGeoPP
#include "IPBlockRecord.hpp"
#include "DbaIPBlockRecord.hpp"

// Type definitions
typedef char char_t;
//typedef char const* iterator_t;
typedef boost::spirit::classic::file_iterator<char_t> iterator_t;
typedef boost::spirit::classic::scanner<iterator_t> scanner_t;
typedef boost::spirit::classic::rule<scanner_t> rule_t;

namespace OPENGEOPP {

	/** Structure holding the list of IP Block Records. */
	struct IPBlockRecordHolder_T {
	  // Attributes
	  IPBlockRecordList_T _ipBlockRecordList;

	  /** Constructor. */
	  IPBlockRecordHolder_T () {}

	  /** Display. */
	  void display() const {
    	unsigned int idx = 0;
	    for (IPBlockRecordList_T::const_iterator itIPRecord =
    	       _ipBlockRecordList.begin();
        	 itIPRecord != _ipBlockRecordList.end(); ++itIPRecord, ++idx) {
	      const IPBlockRecord_T& lIPBlockRecord = itIPRecord->second;
    	  std::cout << "[" << idx << "]: " << lIPBlockRecord.toString()
	                << std::endl;
	    }
	  }

	  /** Staging IP Block Record. */
	  IPBlockRecord_T _ipBlockRecord;

	  /** Index. */
	  unsigned int _index;
	};

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Semantic actions
  //
  ///////////////////////////////////////////////////////////////////////////////

  /** Store the parsed assignment date. */
  struct store_date_assigned {
    store_date_assigned (IPBlockRecord_T& ioIPBlockRecord)
      : _ipBlockRecord (ioIPBlockRecord) {}

    void operator() (iterator_t iStr, iterator_t iStrEnd) const {
      // Define the UTC time Epoch (1970-01-01 00:00:00)
      const boost::gregorian::date lEpochDate (1970, 1, 1);
      const boost::posix_time::ptime lEpochTime (lEpochDate);
      
      // Retrieve the number of seconds since the UTC time Epoch
      const boost::posix_time::time_duration lTimeDuration =
        boost::posix_time::seconds (_ipBlockRecord._itSeconds);

      const long lDateDurationDays = lTimeDuration.hours()/24;
      const boost::gregorian::date_duration lDateDuration (lDateDurationDays);

      // Add up the two above quantities, in order to build up the date
      _ipBlockRecord._dateAssigned =
        boost::gregorian::date (lEpochDate + lDateDuration);
      
      // std::cout << "Assigned in: " << _ipBlockRecord._dateAssigned
      //       << " (" << _ipBlockRecord._itSeconds << ")" << std::endl;
    }
    
    IPBlockRecord_T& _ipBlockRecord;
  };
  
  /** Mark the end of the ip block record parsing. */
  struct do_end_record {
    do_end_record (IPBlockRecordHolder_T& ioIPBlockRecordHolder)
      : _ipBlockRecordHolder (ioIPBlockRecordHolder) {}
    
    // void operator() (char iChar) const {
    void operator() (iterator_t iStr, iterator_t iStrEnd) const {
      // std::cout << "End of IP Block Record " << std::endl;

      // IP Block Record
      const IPBlockRecord_T& lIPBlockRecord =
        _ipBlockRecordHolder._ipBlockRecord;
      
      // IP Block Record Key (IP From)
      const IPNumber_T lIPNumber = lIPBlockRecord._ipFrom;
      
      // List of IP Block Records
      IPBlockRecordList_T& lIPBlockRecordList =
        _ipBlockRecordHolder._ipBlockRecordList;

      // Add the IP Block Record to the Holder internal map (of such objects)
      const bool insertSucceeded = lIPBlockRecordList.
        insert (IPBlockRecordList_T::value_type (lIPNumber,
                                                 lIPBlockRecord)).second;

      if (insertSucceeded == false) {
        std::cerr << "Insertion failed for " << lIPBlockRecord.toString()
                  << std::endl;
        assert (insertSucceeded == true);
      }
      
      // Display the result
      // std::cout << _ipBlockRecordHolder._ipBlockRecord.toString()
      //          << std::endl;
      
      // Increment the index
      ++_ipBlockRecordHolder._index;

      // DEBUG
      if (_ipBlockRecordHolder._index % 10000 == 0) {
        std::cout << "Read " << _ipBlockRecordHolder._index
                  << " IP Block Records..." << std::endl;
      }
    }

    IPBlockRecordHolder_T& _ipBlockRecordHolder;
  };


///////////////////////////////////////////////////////////////////////////////
//
//  Our "IP to Country" grammar (using subrules)
//
///////////////////////////////////////////////////////////////////////////////
    /**
       IP FROM,      IP TO,        REGISTRY,  ASSIGNED,   CTRY, CNTRY, COUNTRY
       "1346797568", "1346801663", "ripencc", "20010601", "il", "isr", "Israel"
           
         Grammar:
         IP              ::= int
         IPBlockRecord   ::= IPFrom ',' IPTo ',' Registry ',' Date
                                ',' Country2Char
                                ',' Country3Char ',' Country
    */

using namespace boost::spirit::classic;

/** Grammar for the Flight-Period parser. */
struct IPBlockRecordParser : 
  public boost::spirit::classic::grammar<IPBlockRecordParser> {

  IPBlockRecordParser (IPBlockRecordHolder_T& ioIPBlockRecordHolder)
    : _ipBlockRecordHolder (ioIPBlockRecordHolder) {
  }

  template <typename ScannerT>
  struct definition {
    definition (IPBlockRecordParser const& self) {

      ip_block_record_list = *( boost::spirit::classic::comment_p("#")
                              | ip_block_record )
        ;
      
      ip_block_record = ip_from
        >> ',' >> ip_to
        >> ',' >> registry
        >> ',' >> date[store_date_assigned(self._ipBlockRecordHolder._ipBlockRecord)]
        >> ',' >> country_2char
        >> ',' >> country_3char
        >> ',' >> country
        >> ip_block_record_end[do_end_record(self._ipBlockRecordHolder)]
        ;

      ip_from = '"'
        >> uint_p[assign_a(self._ipBlockRecordHolder._ipBlockRecord._ipFrom)]
        >> '"'
        ;

      ip_to = '"'
        >> uint_p[assign_a(self._ipBlockRecordHolder._ipBlockRecord._ipTo)]
        >> '"'
        ;

      registry = '"'
        >> (repeat_p(2,20)[alpha_p])[assign_a(self._ipBlockRecordHolder._ipBlockRecord._registry)]
        >> '"'
        ;

      date =  '"'
        >> uint_p[assign_a(self._ipBlockRecordHolder._ipBlockRecord._itSeconds)]
        >> '"'
        ;

      country_2char = '"'
        >> (repeat_p(2)[chset_p("A-Z")])[assign_a(self._ipBlockRecordHolder._ipBlockRecord._country2Char)]
        >> '"'
        ;

      country_3char = '"'
        >> (repeat_p(0,3)[chset_p("A-Z")])[assign_a(self._ipBlockRecordHolder._ipBlockRecord._country3Char)]
        >> '"'
        ;

      country = '"'
        >> (repeat_p(0,50)[~ch_p('"')])[assign_a(self._ipBlockRecordHolder._ipBlockRecord._country)]
        ;

      ip_block_record_end =
        boost::spirit::classic::ch_p('"')
        ;
      
      
      BOOST_SPIRIT_DEBUG_NODE (ip_block_record_list);
      BOOST_SPIRIT_DEBUG_NODE (ip_block_record); 
      BOOST_SPIRIT_DEBUG_NODE (ip_block_record_end); 
      BOOST_SPIRIT_DEBUG_NODE (ip_from);
      BOOST_SPIRIT_DEBUG_NODE (ip_to);
      BOOST_SPIRIT_DEBUG_NODE (registry);
      BOOST_SPIRIT_DEBUG_NODE (date);
      BOOST_SPIRIT_DEBUG_NODE (country_2char);
      BOOST_SPIRIT_DEBUG_NODE (country_3char);
      BOOST_SPIRIT_DEBUG_NODE (country);
    }

    //         >> (repeat_p(0,50)[chset_p("a-zA-Z':;()-.")])[assign_a(self._ipBlockRecord._country)]
    
    boost::spirit::classic::rule<ScannerT> ip_block_record_list, ip_block_record,
      ip_block_record_end, ip_from, ip_to, registry, date, country_2char,
      country_3char, country;

    boost::spirit::classic::rule<ScannerT> const& start() const { return ip_block_record_list; }
  };

  IPBlockRecordHolder_T& _ipBlockRecordHolder;
};


// //////// MySQL database ///////
/** Fill the MySQL database table */
int fillTable (const IPBlockRecordHolder_T& iIPBlockRecordHolder) {

  // Database parameters
  const std::string lUserName ("geo");
  const std::string lPassword ("geo");
  const std::string lDBName ("geo_s77");
  const std::string lDBPort ("3306");
  const std::string lDBHost ("localhost");
  std::ostringstream oStr;
  oStr << "db=" << lDBName << " user=" << lUserName
       << " password=" << lPassword << " port=" << lDBPort
       << " host=" << lDBHost;
  const std::string lSociSessionConnectionString (oStr.str());
  
  // Instanciate a SOCI Session: nothing is performed at that stage
  soci::session lSociSession;
  
  try {
    
    // Open the connection to the database
    lSociSession.open (soci::mysql, lSociSessionConnectionString);
    
  } catch (std::exception const& lException) {
    std::cerr << "Error while opening a connection to database: "
              << lException.what() << std::endl;
  }
  
  soci::statement lInsertStatement (lSociSession);

  IPBlockRecord_T lIPBlockRecord;
  lInsertStatement =
    (lSociSession.prepare
     << "insert into ip_to_country (ip_from, ip_to, registry, assigned_date, "
     << "country_code_2, country_code_3, country_name) "
     << "values (:ip_block_record)", soci::use (lIPBlockRecord));
  
  const IPBlockRecordList_T& lIPBlockRecordList =
    iIPBlockRecordHolder._ipBlockRecordList;
  for (IPBlockRecordList_T::const_iterator itIPRecord =
         lIPBlockRecordList.begin();
       itIPRecord != lIPBlockRecordList.end(); ++itIPRecord) {

    // Execute the SQL insert statement
    lInsertStatement.execute();
  }
  
  return 0;
}

}


// /////////////// M A I N /////////////////
int main (int argc, char* argv[]) {
  try {
    
    // File to be parsed
    std::string lFilename ("IpToCountry.csv");
    
    // Read the command-line parameters
    if (argc >= 1 && argv[1] != NULL) {
      std::istringstream istr (argv[1]);
      istr >> lFilename;
    }

    // Open the file
    iterator_t lFileIterator (lFilename);
    if (!lFileIterator) {
      std::cerr << "The file " << lFilename << " can not be open." << std::endl;
    }

    // Create an EOF iterator
    iterator_t lFileIteratorEnd = lFileIterator.make_end();
    
    // Instantiate the structure that will hold the result of the parsing.
    OPENGEOPP::IPBlockRecordHolder_T lIPBlockRecordHolder;
    OPENGEOPP::IPBlockRecordParser lIPBlockRecordParser (lIPBlockRecordHolder);
    boost::spirit::classic::parse_info<iterator_t> info =
      boost::spirit::classic::parse (lFileIterator, lFileIteratorEnd,
                            lIPBlockRecordParser, 
                            boost::spirit::classic::space_p);

    // DEBUG
    // std::cout << "IP Block Record List:" << std::endl;
    // lIPBlockRecordHolder.display();

    // Retrieves whether or not the parsing was successful
    const bool isParsingSuccessful = info.hit;
      
    const std::string hasBeenFullyReadStr = (info.full == true)?"":"not ";
    if (isParsingSuccessful == true) {
      std::cout << "Parsing of the file: " << lFilename
                << " succeeded: read " << info.length
                << " characters. The input file has " << hasBeenFullyReadStr
                << "been fully read. Stop point: " << info.stop << std::endl;
      
    } else {
      std::cerr << "Parsing of the file: " << lFilename
                << " did not succeed: read " << info.length
                << " characters. The input file has " << hasBeenFullyReadStr
                << "been fully read. Stop point: " << info.stop << std::endl;
    }

    
    // Read user input
    std::cout << "/////////////////////////////////////////////////////////"
              << std::endl;
    std::cout << "\t\tIP to Country Translator..." << std::endl;

    std::cout << "/////////////////////////////////////////////////////////"
              << std::endl;
    std::cout << "Type an IP...or [q or Q] to quit" << std::endl;
    
    std::string lUserInput;
    while (getline (std::cin, lUserInput)) {
      if (lUserInput.empty() || lUserInput[0] == 'q' || lUserInput[0] == 'Q') {
        break;
      }

      // Translate the string into a decimal IP Number
      const OPENGEOPP::IPNumber_T kIPNumberError = std::numeric_limits<OPENGEOPP::IPNumber_T>::max();
      OPENGEOPP::IPNumber_T lUserInputInt = kIPNumberError;
      std::istringstream iStr (lUserInput);
      iStr >> lUserInputInt;
      if (lUserInputInt == kIPNumberError) {
        std::cerr << lUserInput << " is not a decimal IP number" << std::endl;
        break;
      }
      
      // Get a handle on the list of IP Block Records
      const OPENGEOPP::IPBlockRecordList_T& lIPBlockRecordList =
        lIPBlockRecordHolder._ipBlockRecordList;
      
      // Find the IP Number
      OPENGEOPP::IPBlockRecordList_T::const_iterator itIPRecord =
        lIPBlockRecordList.lower_bound (lUserInputInt);

      if (itIPRecord != lIPBlockRecordList.end()) {
        const OPENGEOPP::IPNumber_T lIPFrom = itIPRecord->first;

        // As the lower_bound() function goes too far, we must go back from
        // 1 row
        if (lIPFrom != lUserInputInt) {
          --itIPRecord;
        }
        
        const OPENGEOPP::IPBlockRecord_T& lIPBlockRecord = itIPRecord->second;
        std::cout << "Record found: " << lIPBlockRecord.toString()
                  << std::endl;
      } else {
        std::cout << "Record " << lUserInputInt << " not found" << std::endl;
      }

    }
    
  } catch (const std::exception& stde) {
    std::cerr << "Standard exception: " << stde.what() << std::endl;
    return -1;
    
  } catch (...) {
    return -1;
  }
  
  return 0;
}

