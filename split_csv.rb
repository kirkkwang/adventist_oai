require 'csv'

input_file = 'completed_csvs/obit/full_oai_to_csv_obit.csv'
output_folder_path = '.'

# Read the large CSV file
puts "Reading #{input_file}..."
csv_data = CSV.read(input_file, headers: true)

batch_size = 50_000
num_batches = (csv_data.length.to_f / batch_size).ceil

num_batches.times do |i|
  # Calculate start and end indices for this batch
  start_index = i * batch_size
  end_index = start_index + batch_size - 1

  # Get the rows for this batch
  batch_data = csv_data[start_index..end_index]

  # Format the batch number to have 2 digits with leading zeros
  batch_num = "%02d" % (i + 1)

  # Write this batch to a new CSV file
  CSV.open("#{output_folder_path}/sdapi_oai_to_csv_obit_#{batch_num}.csv", 'w') do |csv_object|
    puts "Writing #{output_folder_path}/sdapi_oai_to_csv_obit_#{batch_num}.csv"
    csv_object << csv_data.headers
    batch_data.each do |row|
      csv_object << row
    end
  end
end
