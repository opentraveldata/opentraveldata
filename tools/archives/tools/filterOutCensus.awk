
#
BEGIN {
    isFirstLine = 0
}

# Filter the changes
# -ABL^^^Y^5879302^^Ambler^Ambler^67.08612^-157.85748^P^PPL^0.007663453895855982^^^^US^^United States^North America^AK^Alaska^Alaska^188^Northwest Arctic Borough^Northwest Arctic Borough^^^258^27^20^America/Anchorage^-9.0^-8.0^-9.0^2014-10-08^ABL^Ambler^ABL|5879302|Ambler|Ambler^ABL^AK^C^http://en.wikipedia.org/wiki/Ambler%2C_Alaska^post|99786|=en|Ambler|=|Ambler|=ar|أمبلير|=fa|امبلر، آلاسکا|=hi|ऐम्ब्लर|=ik|Ivisaappaat|=mrj|Амблер|=new|एम्ब्लर|=sr|Амблер|=uk|Амблер|=ru|Амблер|=zh|ååå|^1^Alaska^USD
#+ABL^^^Y^5879302^^Ambler^Ambler^67.08612^-157.85748^P^PPL^0.007663453895855982^^^^US^^United States^North America^AK^Alaska^Alaska^188^Northwest Arctic Borough^Northwest Arctic Borough^^^267^27^20^America/Anchorage^-9.0^-8.0^-9.0^2017-03-09^ABL^Ambler^ABL|5879302|Ambler|Ambler^ABL^AK^C^http://en.wikipedia.org/wiki/Ambler%2C_Alaska^post|99786|=en|Ambler|=|Ambler|=ar|أمبلير|=fa|امبلر، آلاسکا|=hi|ऐम्ब्लर|=ik|Ivisaappaat|=mrj|Амблер|=new|एम्ब्लर|=sr|Амблер|=uk|Амблер|=ru|Амблер|=zh|ååå|^1^Alaska^USD
#
function isCensusOnlyDifference(__icodLine1, __icodLine2) {
    orgLine = $0

    # Extract the census
    $0 = __icodLine1
    __icodeCensus1 = $29
    __icodCode1 = substr ($1, 2, 3)

    $0 = __icodeLine2
    __icodCensus2 = $29
    __icodCode2 = substr ($1, 2, 3)

    $0 = orgLine

    # DEBUG
    print ("[" __icodCode1 "][" __icodCode2 "] " __icodCensus1 " ==? " __icodeCensus2)

    return (__icodCensus1 == __icodCensus2)
}

#
/^[+-]/ {
    # IATA code
    iata_code = substr ($1, 2, 3)

    #
    isFirstLine = (isFirstLine + 1) % 2
    if (isFirstLine) {
	line1 = $0

    } else {
	line2 = $0

	isDiff = isCensusOnlyDifference(line1, line2)
    }
    
    # 
    print $0
}

