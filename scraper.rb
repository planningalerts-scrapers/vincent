require 'scraperwiki'
require 'mechanize'

url = "https://imagine.vincent.wa.gov.au/planning-consultations?page="

agent = Mechanize.new
page_number = 1
page = agent.get("#{url}#{page_number}")
page.search('li.shared-content-block').each do |i|  
  puts "Parsing the results on page #{page_number}"
  info_url = i.at('a')['href']
  record = {
    'council_reference' => info_url.split('/')[-2..-1].join('/'),
    'address' => i.inner_text.gsub("\r\n", "").squeeze(' ').strip,
    'description' => i.at('div.truncated-description').next_sibling.inner_text,
    'info_url' => info_url,
    'comment_url' => 'mailto:mail@vincent.wa.gov.au',
    'date_scraped' => Date.today.to_s,
    'on_notice_to' => i.at('div.truncated-description > p > strong').next_sibling.inner_text
  }
  puts "Saving record " + record['council_reference'] + ", " + record['address']
  ScraperWiki.save_sqlite(['council_reference'], record)
end
page_number += 1
