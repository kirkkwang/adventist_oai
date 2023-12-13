require 'net/http'
require 'nokogiri'
require 'csv'
require 'byebug'

sets = [
  # 'adl:thesis',
  # 'adl:periodical',
  # 'adl:issue',
  # 'adl:image',
  # 'adl:book',
  # 'adl:other',
  # 'sdapi:article',
  # 'sdaoi:obit',
]

BASE_URL = 'https://oai.adventistdigitallibrary.org/OAI-script'
SET = sets.first

def fetch_data(resumption_token = nil)
  starting_page = resumption_token ? resumption_token.split('|').last.to_i : 1
  puts "===================== Fetching page #{starting_page} ====================="

  uri = URI(BASE_URL)
  params = {verb: 'ListRecords', metadataPrefix: 'oai_adl', set: SET}
  params['resumptionToken'] = resumption_token if resumption_token
  uri.query = URI.encode_www_form(params)

  response = Net::HTTP.get(uri)
  Nokogiri::XML(response).remove_namespaces!
end

def parse_record(record)
  record.xpath('*').each_with_object({}) do |node, hash|
    hash[node.name] = node.text
  end
end

def harvest_records(limit: nil, resumption_token: nil)
  records = []
  csv_index = 0

  loop do
    doc = fetch_data(resumption_token)
    doc.xpath('//record').each_with_index do |record, index|
      aark_id = record.xpath('metadata/oai_adl/aark_id').text
      title = record.xpath('metadata/oai_adl/title').text
      puts "Processing record #{index + 1}: #{aark_id} - #{title}"
      records << parse_record(record.xpath('metadata/oai_adl'))
      if limit && records.size >= limit
        write_to_csv(records, csv_index)
        return
      end
    end

    if records.size >= 10_000
      write_to_csv(records, csv_index)
      records = []
      csv_index += 1
    end

    resumption_token_element = doc.at_xpath('//resumptionToken')
    if resumption_token_element
      resumption_token = resumption_token_element.text
      cursor = resumption_token_element['cursor'].to_i
      complete_list_size = resumption_token_element['completeListSize'].to_i
      break if cursor >= complete_list_size
    else
      break
    end
  end

  unless records.empty?
    write_to_csv(records, csv_index)
  end
end

def write_to_csv(records, csv_index)
  headers = records.flat_map(&:keys).uniq
  CSV.open("#{SET.gsub(':', '_')}_oai_data_#{csv_index}.csv", 'wb') do |csv|
    csv << headers
    records.each do |record|
      csv << headers.map { |header| record[header] }
    end
  end
end

# You can specify the limit here. If no limit is specified, all records will be harvested.
# harvest_records(resumption_token: "#{SET}|4001")
harvest_records
