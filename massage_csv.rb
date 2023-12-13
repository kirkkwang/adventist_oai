require 'csv'
require 'byebug'

folder_path = './completed_csvs/issue/converted_headers'
headers_map = {
  "aark_id" => 'identifier.ark',
  "abstract" => 'description.abstract',
  "alternative_title" => 'title.alternative',
  "bibliographic_citation" => 'identifier.bibliographicCitation',
  "contributor" => 'contributor',
  "creator" => 'creator',
  "date_created" => 'date.other',
  "date_issued" => 'date',
  "description" => 'description',
  "edition" => 'title.release',
  "extent" => 'format.extent',
  "geocode" => 'geocode',
  "identifier" => "identifier",
  "issue_number" => 'relation.isPartOfIssue',
  "language" => 'language',
  "pagination" => 'format.extent',
  "part_of" => 'relation.isPartOf',
  "peer_reviewed" => 'peer_reviewed',
  "place_of_publication" => 'place_of_publication',
  "publisher" => 'publisher',
  "remote_url" => 'remote_url',
  "resource_type" => 'type',
  "rights_statement" => 'rights',
  "source" => 'source',
  "subject" => 'subject',
  "thumbnail_url" => 'thumbnail_url',
  "title" => 'title',
  "volume_number" => 'relation.isPartOfVolume',
  "work_type" => 'work_type'
}

def normalize_file(file)
  file_contents = File.read(file)
  sections = file_contents.split(/(".*?")/m).each_with_index.map do |section, index|
    if index.odd? # This is a quoted section
      section.gsub(/[\r\n]+/, '') # Remove newlines and carriage returns
    else
      section # This is an unquoted section, leave it as it is
    end
  end
  sections.join
end

Dir.glob("#{folder_path}/*.csv").each do |file|
  puts "Processing #{file}"
  # Normalize the CSV file (remove the return carriage)
  normalized_data = normalize_file(file)

  # Parse the CSV data
  csv_data = CSV.parse(normalized_data, headers: true)

  # Replace the "identifier" column with the data from the "aark_id" column
  csv_data.each do |row|
    row["identifier"] = row["aark_id"]
  end

  # Map the headers
  new_headers = csv_data.headers.map { |header| headers_map[header] || header }

  # Write the CSV file back with the new headers
  CSV.open(file, 'w') do |csv_object|
    csv_object << new_headers
    csv_data.each do |row|
      csv_object << row
    end
  end
end
