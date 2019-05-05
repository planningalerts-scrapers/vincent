require 'scraperwiki'
require 'mechanize'

url = "https://imagine.vincent.wa.gov.au/planning-consultations?page="

agent = Mechanize.new
page_number = 0
loop do
  page_number += 1
  page = agent.get("#{url}#{page_number}")

  puts "Parsing the results on page #{page_number}: #{url}#{page_number}"
  application_count = 0
  page.search('li.shared-content-block').each do |li|
    application_count += 1
    info_url = li.at('a')['href']
    details_page = agent.get(info_url)
    council_reference = details_page.at('div.truncated-description p')[1].inner_text.sub(/.*Serial Number:/, '').gsub("\r\n", "").squeeze(' ').strip
    record = {
      'council_reference' => council_reference,
      'address' => li.at('a').inner_text.gsub("\r\n", "").squeeze(' ').strip,
      'description' => li.at('div.truncated-description').inner_text.sub(/.*Development Details:/, '').gsub("\r\n", "").squeeze(' ').strip,
      'info_url' => info_url,
      'comment_url' => 'mailto:mail@vincent.wa.gov.au',
      'date_scraped' => Date.today.to_s,
      'on_notice_to' => li.search('div.truncated-description b')[1].inner_text.gsub("\r\n", "").squeeze(' ').strip.gsub(/\.$/, '')
    }
    puts "Saving page #{page_number} application #{application_count} record."
    puts "  council_reference: " + record['council_reference']
    puts "            address: " + record['address']
    puts "        description: " + record['description']
    puts "           info_url: " + record['info_url']
    puts "        comment_url: " + record['comment_url']
    puts "       date_scraped: " + record['date_scraped']
    puts "       on_notice_to: " + record['on_notice_to']
    ScraperWiki.save_sqlite(['council_reference'], record)
  end
  
  puts "Found #{application_count} application(s) on page #{page_number}."
  break if application_count == 0
end
puts "Complete."
