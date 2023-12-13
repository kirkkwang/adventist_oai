require 'csv'
require 'byebug'

# create a mapping hash from the second CSV file
mapping = {}
CSV.foreach("collections/SDAPI_periodical_collections_updated.csv", headers: true) do |row|
  mapping[row["title"]] = row["identifier"]
end

# read the first CSV file and replace `parents` with corresponding value from the second CSV
CSV.open("output.csv", "wb") do |csv|
  headers_written = false
  CSV.foreach("collections/articles_parent_child_relationships.csv", headers: true) do |row|
    if mapping.has_key?(row["parents"])
      row["parents"] = mapping[row["parents"]]
    end
    unless headers_written
      csv << row.headers
      headers_written = true
    end
    csv << row
  end
end
