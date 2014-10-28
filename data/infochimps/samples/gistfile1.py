'''
python-infochimps

A simple python wrapper for the infochimps API, by geometrid

Based on python-klout

'''

from datetime import date, timedelta

import time
import urllib
import urllib2

try:
    import json
except ImportError:
    try:
        import simplejson as json
    except ImportError:
        try:
            from django.utils import simplejson as json
        except:
            raise 'Requires either Python 2.6 or above, simplejson or django.utils!'

RETRY_COUNT = 3
API_BASE_URL = 'http://api.infochimps.com'
DEBUG = True

TWITTER_VERBS = ['trstrank', 'wordbag', 'influence', 'strong_links', 'word_stats', 'conversation']
DIGITAL_ELEMENTS_VERBS = ['demographics', 'ip_census']

VERB_PARAMS = {
    'trstrank': [
        'screen_name', 
        'user_id'
    ],
    'wordbag': [
        'screen_name', 
        'user_id'
    ],
    'influence': [
        'screen_name', 
        'user_id'
    ],
    'strong_links': [
        'screen_name', 
        'user_id'
    ],
    'word_stats': [
        'tok'
    ],
    'conversation': [
        'user_a_sn', 
        'user_a_id',
        'user_b_sn', 
        'user_b_id',
    ],
    'demographics': [
        'ip'
    ],
    'ip_census': [
        'ip'
    ],
}

class InfochimpsError( Exception ):
    """
    Base class for Infochimps API errors.
    """
    @property
    def message( self ):
        """
        Return the first argument passed to this class as the message.
        """
        return self.args[ 0 ]
    
    
class InfochimpsAPI( object ):
    def __init__( self, api_key ):
        self.api_key = api_key
        self._urllib = urllib2
        
    def call( self, verb, **kwargs ):
        # build request
        request = self._buildRequest( verb, **kwargs )

        # fetch data
        result = self._fetchData( request )

        # return result
        return result
    
    def _buildRequest( self, verb, **kwargs ):
        # add API key to all requests
        params = [
            ( 'apikey', self.api_key ),
        ]

        # check params based on the given verb and build params
        for k, v in kwargs.iteritems():
            if k in VERB_PARAMS[ verb ]:
                params.append( ( k , v ) )
            else:
                raise InfochimpsError(
                        "Invalid API parameter %s for verb %s" % ( k, verb ) )

        # encode params
        encoded_params = urllib.urlencode( params )
        
        if verb in TWITTER_VERBS:
            base_path = '%s/soc/net/tw' % API_BASE_URL
        elif verb in DIGITAL_ELEMENTS_VERBS:
            base_path = '%s/web/an/de' % API_BASE_URL
        elif verb in IP_CENSUS_VERBS:
            base_path = '%s/web/an/ip_census' % API_BASE_URL
        else:
            raise InfochimpsError("Invalid API call.")

        # URL to API endpoint
        url = '%s/%s.json?%s' % ( base_path, verb.replace( '.', '/' ), 
            encoded_params )
       
        if DEBUG: print url
        # build request and return it
        request = urllib2.Request( url )
        return request
    
    def _fetchData( self, request ):
        counter = 0
        while True:
            try:
                if counter > 0:
                    time.sleep( counter * 0.5 )
                url_data = self._urllib.urlopen( request ).read()
                json_data = json.loads( url_data )
            except urllib2.HTTPError, e:
                if e.code == 400:
                    raise InfochimpsError(
                        "Infochimps sent status %i:\ndetails: %s" % (
                            e.code, e.fp.read() ) )
                counter += 1
                if counter > RETRY_COUNT:
                    raise InfochimpsError(
                        "Infochimps sent status %i:\ndetails: %s" % (
                            e.code, e.fp.read() ) )
            except ValueError:
                counter += 1
                if counter > RETRY_COUNT:
                    raise InfochimpsError(
                        "Infochimps did not return valid JSON data" )
            else:
                return json_data

