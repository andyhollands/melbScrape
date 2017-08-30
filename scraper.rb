require 'mechanize'
require 'scraperwiki'

agent = Mechanize.new
urlbase = 'https://www.domain.com.au/sale/?suburb=brunswick-vic-3056,brunswick-west-vic-3055,coburg-north-vic-3058,coburg-vic-3058,pascoe-vale-south-vic-3044&ptype=house,villa,town-house,semi-detached,terrace,duplex,new-home-designs,new-house-land&bedrooms=2-any&price=any-900000'

  p "page 1"
  page = agent.get(urlbase)
  
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
    agents = page2.at('#propertyStoryPartial > div > div > div > a:nth-child(3)').inner_text.strip
    pricetest = page2.at('#main > div > header > div > div.left-wrap > span').inner_text.strip.to_s
    low = ''
    high = ''
    lat = @lats[i]
    long = @longs[i]
    if pricetest.start_with? '$'
      price = pricetest.delete! '$ ,'
      if price.include? "-"
          low = price.partition('-').first
          high = price.partition('-').last
      else
          high = price
      end
    elsif page2.at('div:nth-child(1) > p.statement-of-information__data-point-value')
         low = page2.at('div:nth-child(1) > p.statement-of-information__data-point-value').inner_text.strip.delete! '$ ,'
         low = low.partition('-').first
         high = page2.at('div:nth-child(1) > p.statement-of-information__data-point-value').inner_text.strip.delete! '$ ,'
         high = high.partition('-').last
    end
     house = {
       address: address,
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
      p house 
      ScraperWiki.save_sqlite([:address], house)
     i += 1
  end
     
     pageurl = 2
    
 while pageurl <= 5 do
    url = urlbase + "&page=" +  pageurl.to_s
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
    agents = page2.at('#propertyStoryPartial > div > div > div > a:nth-child(3)').inner_text.strip
    pricetest = page2.at('#main > div > header > div > div.left-wrap > span').inner_text.strip.to_s
    low = ''
    high = ''
    lat = @lats[i]
    long = @longs[i]
    if pricetest.start_with? '$'
      price = pricetest.delete! '$ ,'
      if price.include? "-"
          low = price.partition('-').first
          high = price.partition('-').last
      else
          high = price
      end
    elsif page2.at('div:nth-child(1) > p.statement-of-information__data-point-value')
         low = page2.at('div:nth-child(1) > p.statement-of-information__data-point-value').inner_text.strip.delete! '$ ,'
         low = low.partition('-').first
         high = page2.at('div:nth-child(1) > p.statement-of-information__data-point-value').inner_text.strip.delete! '$ ,'
         high = high.partition('-').last
    end
     house = {
       address: address,
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
      p house 
     ScraperWiki.save_sqlite([:address], house)
     i += 1
  end
  pageurl += 1
  end
