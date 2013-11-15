class WorkerBee
  @queue = :batch_queue

  # parameters:
  # @input = input file
  # @output = output file

  def self.perform(input_file, output_file)
    input = input_file || 'sample_vins.txt'
    output = output_file || "output_#{input_file}"
    process(input, output)
  end

  private
  def self.process(input_file, output_file)

    logfile = "log_#{input_file}"

    #input = "#{Rails.root}/#{input}"
    s3 = AWS::S3.new
    bucket_name = ENV['S3_ROOT']
    bucket = s3.buckets[bucket_name]
    infile = bucket.objects["input/#{input_file}"]
    tmpfile = "#{Rails.root}/tmp/#{input_file}"
    # write file to temporary location to parse
    File.open(tmpfile, 'wb') do |file|
     infile.read do |chunk|
        file.write(chunk)
      end
    end
    output = "#{Rails.root}/tmp/#{output_file}"
    logfile = "#{Rails.root}/#{logfile}"

    # Open the input file for reads
    # Open the output file for writes
    # Open the log file for writes

    # Process:
    # For each line in the input file
    #   Decode the VIN
    #   Write the decoded information to the output file
    output_string = ''
    success_count = 0
    failure_count = 0
    puts "Processing file #{input_file} => #{output_file}"
    File.open(output, "w") do |outfile|
      File.open(tmpfile, 'r').each_line do |line|
        decode = Decode.new(vin: line.strip)
        # puts "vin: #{decode.vin}"
        if decode.save && decode.pattern.present? # It saved, meaning the VIN is decoded
          trims = decode.pattern.vehicles.map { |v| v.trim }.join('|')
          output_string += "#{decode.vin}, #{decode.pattern.year}, #{decode.pattern.make}, #{decode.pattern.series}, #{trims}, OK\n"
          puts "decoded: #{decode.vin}, #{decode.pattern.year}, #{decode.pattern.make}, #{decode.pattern.series}, #{trims}"
          success_count += 1
        else
          error = "#{decode.statuses.map { |s| s.name }.join('|')}"
          output_string += "#{decode.vin}, year, make, series, trim, #{error}\n"
          # puts "Failed to decode #{decode.vin}: #{error}"
          failure_count += 1
        end
      end
      # write out the string to the output filename
      File.open(output,'w').write(output_string)
      bucket.objects["output/#{output_file}"].write(:file => output)
      DT.p "Total count: success: #{success_count} failed: #{failure_count}"
      update_batch(input_file, success_count + failure_count + 1, success_count, output_file)
      # Send out an email stating the job was successful
      BatchEmail.success(batch_for_file(input_file), output)
      #return success_count + failure_count, success_count
    end
  end

  def self.batch_for_file(file)
    Batch.where("batch_file_file_name  = ?", file).first
  end

  def self.update_batch(file, total, successful, outfile)
    batch = batch_for_file(file)
    if batch.nil?
      DT.p "Could not find file #{file}"
    else
      # update the record with the totals
      DT.p "Updating file #{file}"
      batch.update_attributes(total: total, successful: successful, outfile: outfile, completed: true)

    end
  end
end