#!/usr/bin/env ruby

require 'net/http'
require 'option'
require 'ticker'

ticker = ARGV[0]
date = ARGV[1]

url = "http://finance.yahoo.com/q/op?s=" + ticker
if date then
    url += "&m=" + date
end

# Get the current yahoo options page
data = Net::HTTP.get_response(URI.parse(url)).body

#Current price is the first bolded number on the page
current_price =  data.scan(/<b><span.*?>([\d\.]{3,})<\/span><\/b>/)[0][0]
puts "Current Price: #{current_price}"

ticker = Ticker.new(ticker, current_price)

tables = data.scan(/\<table.*\<\/table>/)

#Call Options
if(tables.length > 4) then
    tables[4].scan(/\<tr\>.*?\<\/tr\>/).each do |row|
        strike = last = bid = ask = volume = nil
        cells = row.scan(/\<td.*?\<\/td\>/)
        if(cells[0] =~ /k=([\d\.]*)/) then
            strike = $1
        end
        
        #Last
        if(cells[2] =~ />([\d\.]{3,})/) then
            last = $1
        end

        #Bid
        if(cells[4] =~ />([\d\.]{3,})/) then
            bid = $1
        end
        
        #Ask
        if(cells[5] =~ />([\d\.]{3,})/) then
            ask = $1
        end

        #Volume
        if(cells[6] =~ />([\d\,]{1,})/) then
            volume = $1
        end

        if(strike) then
            ticker.add_call_option(strike, last, bid, ask, volume)
        end
    end
end

#Puts
if(tables.length > 5) then
    tables[5].scan(/\<tr\>.*?\<\/tr\>/).each do |row|
        strike = last = bid = ask = volume = nil
        cells = row.scan(/\<td.*?\<\/td\>/)
        if(cells[0] =~ /k=([\d\.]*)/) then
            strike = $1
        end
        
        #Last
        if(cells[2] =~ />([\d\.]{3,})/) then
            last = $1
        end

        #Bid
        if(cells[4] =~ />([\d\.]{3,})/) then
            bid = $1
        end
        
        #Ask
        if(cells[5] =~ />([\d\.]{3,})/) then
            ask = $1
        end

        #Volume
        if(cells[6] =~ />([\d\,]{1,})/) then
            volume = $1
        end

        if(strike) then
            ticker.add_put_option(strike, last, bid, ask, volume)
        end
    end
end

ticker.possibilities.each do |p| puts p end
