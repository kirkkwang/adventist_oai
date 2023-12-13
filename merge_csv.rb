require 'csv'

feed = 'obit'
folder_path = "./completed_csvs/#{feed}/converted_headers"
output_file = "full_oai_to_csv_#{feed}.csv"

merged_csv_data = []
headers = []

# Define a natural sort pattern to correctly sort filenames
natural_sort_pattern = /\d+/

# Use Dir.glob to get all CSV files and sort them naturally
sorted_files = Dir.glob("#{folder_path}/*.csv").sort_by { |file| file.scan(natural_sort_pattern).map(&:to_i) }

sorted_files.each do |file|
  puts "Processing #{file}"

  csv_data = CSV.read(file, headers: true)

  # Update the merged headers with new headers from the current file
  headers |= csv_data.headers

  # Add data rows
  csv_data.each do |row|
    merged_row = headers.map { |header| row[header] || '' }
    merged_csv_data << merged_row
  end
end

# Prepend the merged headers at the beginning
merged_csv_data.unshift(headers)

# Determine the maximum number of columns
max_columns = headers.size

# Write the merged CSV data to a temporary file
CSV.open("#{output_file}.tmp", 'w') do |csv_object|
  merged_csv_data.each do |row|
    # Pad the row with empty values to match the number of columns
    row.concat(Array.new(max_columns - row.size, ''))

    # Remove trailing empty values
    while row.last == ''
      row.pop
    end

    csv_object << row
  end
end

# Rename the temporary file to the final output file
File.rename("#{output_file}.tmp", output_file)
