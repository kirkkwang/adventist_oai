require 'byebug'
require 'csv'

csv_file_path = 'completed_csvs/article/sdapi_article.csv'

identifiers = [
  "13457012",
  "14785296",
  "14143783",
  "14785317",
  "13435919",
  "13420430",
  "13345109",
  "14785582",
  "13345464",
  "13344709",
  "13345146",
  "13344634",
  "13345604",
  "13345153",
  "13502474",
  "13408935",
  "13408798",
  "13345606",
  "13502692",
  "14785586",
  "13435919"
]

filtered_rows = []

CSV.foreach(csv_file_path, headers: true) do |row|
  filtered_rows << row if identifiers.include?(row['identifier'])
end

CSV.open('filtered.csv', 'w') do |csv|
  csv << filtered_rows.first.headers
  filtered_rows.each do |row|
    csv << row
  end
end
