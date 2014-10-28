<?php
// USAGE
//$apiCall = new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "demographics", "86.75.30.9");
//$apiCall = new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "trstrank",     "infochimps");
//$apiCall = new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "domain",       "86.75.30.9");
//$apiCall = new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "geo",          "86.75.30.9");
//$apiCall = new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "influence",    "infochimps");
//$apiCall = new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "conversation", "mbakrena",  "harlirusdi");
//$apiCall = new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "wordbag",      "infochimps");
//$apiCall = new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "word_stats",   "tintinnabulation");
//$apiCall = new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "combined",     "108.0.12.123");

  class InfochimpsAPICall {
	
    public function InfochimpsAPICall ($key, $call_name, $value_1, $value_2 = "") {
      $GLOBALS['key'] = $key;
      $GLOBALS['call_name'] = $call_name;
      $GLOBALS['value_1'] = $value_1;
      $GLOBALS['value_2'] = $value_2;
			
      $results = $this -> select_api();
      $query = file_get_contents("http://api.infochimps.com".$results);
      $json_result = json_decode($query);
      $this -> printHumanReadable ($json_result);
    }
		
    private function select_api () {
      $type_web = "/web/an/de/";
      $type_soc = "/soc/net/tw/";
      $type_ipCensus = "/web/an/ip_census/";
      $apiTypes = array(
        'demographics' => array($type_web, 'ip'),
        'domain' => array($type_web, 'ip'),
        'geo' => array($type_web, 'ip'),
        'combined' => array($type_ipCensus, 'ip'),
        'influence' => array($type_soc, 'screen_name'),
        'word_stats' => array($type_soc, 'tok'),
        'wordbag' => array($type_soc, 'screen_name'),
        'links' => array($type_soc, 'screen_name'),
        'trstrank' => array($type_soc, 'screen_name', '', '0.2'),
        'conversation' => array($type_soc, 'user_a_sn', 'user_b_sn', '0.2')
      );	
	
      foreach($apiTypes as $key => $value){
        if ($GLOBALS['call_name'] == $key) {	
          $params = $GLOBALS['api_url'] =  $value[0].$key.".json?apikey=".$GLOBALS['key']."&".$value[1]."=".$GLOBALS['value_1'];
	  if ($GLOBALS['value_2'] != "") $params += "&" . $value[2] . "=" . $GLOBALS['value_2'];
	  if ($value[3] != null ) $params += "&" . "v=" . $value[3];
	}
      }
      return $params;
    }
		
    private function printHumanReadable ($show) {
      echo "<pre>";
      var_dump($show);
      echo "</pre>";
    }
  }	
?>

