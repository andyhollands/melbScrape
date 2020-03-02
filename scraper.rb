require 'mechanize'
require 'scraperwiki'
agent = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}
agent.user_agent_alias = 'Mac Safari'

urlbase = 'https://www.domain.com.au/sale/?suburb=melbourne-vic-3000&ptype='
filter = '&price=any-1500000&sort=dateupdated-desc'

types = ['house','villa','town-house','semi-detached','terrace','duplex','new-home-designs','new-house-land']

types.each do |proptype|
    
  p "page 1"
  page = agent.get(urlbase + proptype + filter)
  
  @propertyurls = Array.new
  @lats = Array.new
  @longs = Array.new
  page.search('.listing-result__standard-standard , .listing-result__standard-premium, .listing-result__standard-pp').each do |li|
    @propertyurls << li.at('.listing-result__left > a').attributes['href'].value
    @lats << li.at('a div meta:nth-child(1)').attributes['content'].value
    @longs << li.at('a div meta:nth-child(2)').attributes['content'].value
  end
  i = 0
  @propertyurls.each do |li|
    page2 = agent.get(li)
    address = page2.at('div.left-wrap > h1').inner_text.strip
    beds = page2.at('.listing-features.alt > span:nth-child(1) > span.copy > em').inner_text.strip
    baths = page2.at('.listing-features.alt > span:nth-child(2) > span.copy > em').inner_text.strip
    cars = page2.at('.listing-features.alt > span:nth-child(3) > span.copy > em').inner_text.strip
    agents = page2.at('#propertyStoryPartial > div > div > div').text.strip.partition('For more information on this property, contact ').last
    pricetest = page2.at('#main > div > header > div > div.left-wrap > span').inner_text.strip.to_s.gsub('K','000')
    low = ''
    high = ''
    lat = @lats[i]
    long = @longs[i]
    if pricetest.start_with? '$'
      price = pricetest.delete! '$ ,'
      if price.include? "-"
          low = price.partition('-').first
          high = price.partition('-').last
      elsif price.include? "to"
          low = price.partition('to').first
          high = price.partition('to').last
      elsif price.gsub(/\D/, '').length == 12
        low = url[0..5]
        high = url[6..12]
      else
          high = price.gsub(/\D/, '')
      end
    elsif page2.at('div:nth-child(1) > p.statement-of-information__data-point-value')
         low = page2.at('div:nth-child(1) > p.statement-of-information__data-point-value').inner_text.strip.delete! '$ ,'
         low = low.partition('-').first
         high = page2.at('div:nth-child(1) > p.statement-of-information__data-point-value').inner_text.strip.delete! '$ ,'
         high = high.partition('-').last
    end
     house = {
       address: address,
       propertytype: proptype,
       beds: beds,
       baths: baths,
       cars: cars,
       agent: agents,
       lowprice: low,
       highprice: high,
       lat: lat,
       long: long,
       link: li
     }   
    ScraperWiki.save_sqlite([:address], house)
     i += 1
  end
     
     pageurl = 2
     
 while pageurl <= 25 do
    url = urlbase + proptype + filter + "&page=" +  pageurl.to_s
    p "page " +  pageurl.to_s
    page = agent.get(url)
    @propertyurls.clear
    @lats.clear
    @longs.clear
    
    page.search('.listing-result__standard-standard , .listing-result__standard-premium, .listing-result__standard-pp').each do |li|
    @propertyurls << li.at('.listing-result__left > a').attributes['href'].value
    @lats << li.at('a div meta:nth-child(1)').attributes['content'].value
    @longs << li.at('a div meta:nth-child(2)').attributes['content'].value
  end
  i = 0
  @propertyurls.each do |li|
    page2 = agent.get(li)
    address = page2.at('div.left-wrap > h1').inner_text.strip
    beds = page2.at('.listing-features.alt > span:nth-child(1) > span.copy > em').inner_text.strip
    baths = page2.at('.listing-features.alt > span:nth-child(2) > span.copy > em').inner_text.strip
    cars = page2.at('.listing-features.alt > span:nth-child(3) > span.copy > em').inner_text.strip
    agents = page2.at('#propertyStoryPartial > div > div > div').text.strip.partition('For more information on this property, contact ').last
    pricetest = page2.at('#main > div > header > div > div.left-wrap > span').inner_text.strip.to_s.gsub('K','000')
    low = ''
    high = ''
    lat = @lats[i]
    long = @longs[i]
    if pricetest.start_with? '$'
      price = pricetest.delete! '$ ,'
      if price.include? "-"
          low = price.partition('-').first
          high = price.partition('-').last
      elsif price.include? "to"
          low = price.partition('to').first
          high = price.partition('to').last
      elsif price.gsub(/\D/, '').length == 12
        low = url[0..5]
        high = url[6..12]
      else
          high = price.gsub(/\D/, '')
      end
    elsif page2.at('div:nth-child(1) > p.statement-of-information__data-point-value')
         low = page2.at('div:nth-child(1) > p.statement-of-information__data-point-value').inner_text.strip.delete! '$ ,'
         low = low.partition('-').first
         high = page2.at('div:nth-child(1) > p.statement-of-information__data-point-value').inner_text.strip.delete! '$ ,'
         high = high.partition('-').last
    end
     house = {
       address: address,
       propertytype: proptype,
       beds: beds,
       baths: baths,
       cars: cars,
       agent: agents,
       lowprice: low,
       highprice: high,
       lat: lat,
       long: long,
       link: li
     }    
      ScraperWiki.save_sqlite([:address], house)
     i += 1
  end
  pageurl += 1
  end
  end
