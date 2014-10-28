// USAGE
// new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "demographics", "86.75.30.9");
// new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "trstrank",     "infochimps");
// new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "domain",       "86.75.30.9");
// new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "geo",          "86.75.30.9");
// new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "influence",    "infochimps");
// new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "conversation", "mbakrena",  "harlirusdi");
// new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "wordbag",      "infochimps");
// new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "word_stats",   "tintinnabulation");
// new InfochimpsAPICall("api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469", "combined",     "108.0.12.123");

package  {

  import flash.display.Sprite;
  import flash.events.Event;
  import flash.net.URLRequest ;
  import flash.net.URLLoader ;
  import flash.events.IOErrorEvent;
  // get JSON as3lib from http://thanksmister.com/resources/JSON.zip
  import com.serialization.json.JSON;
	
  public class InfochimpsAPICall extends Sprite {
    private var loader:URLLoader;
    private var request:URLRequest;
		
    private var key:String;
    private var call_name:String;
    private var api_url:String;
    private var api_parameters:String;
    private var value_1:String;
    private var value_2:String;
		
    private var err:String;
    private var apiTypes:Array;
		
    public function InfochimpsAPICall (key:String, call_name:String, value_1:String, value_2:String = null):void {
      this.key = key;
      this.call_name = call_name;
      this.value_1 = value_1;
      this.value_2 = value_2;

      selectAPIHandler();
      loader = new URLLoader();
      request = new URLRequest();
      request.url = "http://api.infochimps.com" + api_url + "?apikey=" + key + api_parameters;
      loader.load(request) ;

      loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);	
      loader.addEventListener(Event.COMPLETE, showDataHandler);
    }
		
    private function selectAPIHandler():void {
      var type_web = "/web/an/de";
      var type_ipCensus = "/web/an/ip_census/";
      var type_soc = "/soc/net/tw/";
			
      apiTypes = new Array();
      apiTypes.push(
        ["demographics", type_web, "ip"],
        ["domain", type_web, "ip"],
        ["geo", type_web, "ip"],
        ["combined", type_ipCensus, "ip"],
        ["influence", type_soc, "screen_name"],
        ["word_stats", type_soc, "tok"],
        ["wordbag", type_soc, "screen_name"],
        ["links", type_soc, "screen_name"],
        ["trstrank", type_soc, "screen_name", "", "0.2"],
        ["conversation", type_soc, "user_a_sn", "user_b_sn", "0.2"]
      );
						
      for (var index in apiTypes) {
        if (call_name == apiTypes[index][0]) {
          api_url =  apiTypes[index][1] + apiTypes[index][0] + ".json";
          api_parameters = "&" + apiTypes[index][2] + "=" + value_1;
          if (value_2 != null) {
            api_parameters += "&" + apiTypes[index][3] + "=" + value_2;
          }
          if (apiTypes[index][4] != null ) {
            api_parameters += "&" + "v=" + apiTypes[index][4];
          }
          err =  apiTypes[index][2];
        }
      }			
    }	
		
    private function showDataHandler (ev:Event):void {
      var loader:URLLoader = URLLoader(ev.target);
      var json_obj:Object = com.serialization.json.JSON.deserialize(loader.data);
      // print vars to screen
      printHumanReadable (json_obj);
    }
		
    private function printHumanReadable (obj:*, layer:int=0):void{
      var tab:String = "";
      for ( var i:int = 0 ; i < layer ; i++, tab += "\t" );
      for (var prop:String in obj){
        trace( tab + "[" + prop + "] -> " + obj[ prop ] );
        printHumanReadable ( obj[ prop ], layer + 1 );
      }
    }
		
    private function ioErrorHandler(ev:IOErrorEvent):void {
      trace("Monkey guess: maybe you have invalid " + err +"?");
    }
			
  }

}

