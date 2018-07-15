# References
* This file on the [OpenTravelData project](http://github.com/opentraveldata/opentraveldata):
  https://github.com/opentraveldata/opentraveldata/tree/master/data/unlocode/README.md

* Wikipedia article: https://en.wikipedia.org/wiki/UN%2FLOCODE
* Official note, as of December 2017: http://www.unece.org/fileadmin/DAM/cefact/locode/2017-2_UNLOCODE_SecretariatNotes.pdf
* Latest data file: http://www.unece.org/cefact/codesfortrade/codes_index.html
  - December 2017: http://www.unece.org/fileadmin/DAM/cefact/locode/loc172csv.zip (2 MB)
* Online code list by country: http://www.unece.org/cefact/locode/service/location.html

# Details

## Function
Each defined function gets a classifier; the most important ones are:
* 1: port (for any kind of waterborne transport)
* 2: rail terminal
* 3: road terminal
* 4: airport
* 5: postal exchange office
* 6: Inland Clearance Depot – ICD or "Dry Port", "Inland Clearance Terminal", etc.
* 7: fixed transport functions (e.g. oil platform)"; the classifier "7" is reserved for this function. Noting that the description "oil pipeline terminal" would be more relevant, and could be extended to cover also electric power lines and ropeway terminals.
* B: Border crossing function
* 0: function not known, to be specified

## Status
Indicates the status of the entry by a 2-character code. The following codes are used at present:
* AA: Approved by competent national government agency
* AC: Approved by Customs Authority
* AF: Approved by national facilitation body
* AI: Code adopted by international organisation (IATA or ECLAC)
* AM: Approved by the UN/LOCODE Maintenance Agency
* AQ: Entry approved, functions not verified
* AS: Approved by national standardisation body
* RL: Recognised location - Existence and representation of location name confirmed by check against nominated gazetteer or other reference work
* RN: Request from credible national sources for locations in their own country
* RQ: Request under consideration
* UR: Entry included on user's request; not officially approved
* RR: Request rejected
* QQ: Original entry not verified since date indicated
* XX: Entry that will be removed from the next issue of UN/LOCODE


