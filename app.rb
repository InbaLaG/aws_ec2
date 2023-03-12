require 'aws-sdk-core'
require 'aws-sdk'

# Define a Sinatra application
require 'sinatra'
require 'json'
require 'yaml'

# Set the AWS region(s) that the application will interact with
REGIONS_FILE_PATH = 'regions.txt'
# AWS_REGIONS = ['us-east-1', 'eu-west-1', 'ap-southeast-2']
AWS_REGIONS_FROM_FILE = File.read(REGIONS_FILE_PATH).split(',').map(&:strip) if File.exist?(REGIONS_FILE_PATH)

stub_response =  JSON.pretty_generate(YAML.load_file('ec2_stub.yml'))
Aws.config[:ec2] = { stub_responses: { describe_instances: stub_response } }


# Define a route to get a list of available regions
get '/regions' do
  content_type :json
  AWS_REGIONS_FROM_FILE.to_json
end

get '/instances:region_id' do 
  content_type :json
  region_id = params['region_id']
  if region_id.nil?
    ans = AWS_REGIONS_FROM_FILE.map{|r| list_instances(r)}
  else
    ans = list_instances(region_id)
  end
  ans.to_json
end

def list_instances(region)
    # Create an EC2 client
    ec2 = Aws::EC2::Client.new(region: region)
  
    # Describe all instances
    response = ec2.describe_instances()
    puts response
    # Extract instance data
    instances = response.reservations.flat_map(&:instances).map do |instance|
      {
        instance_id: instance.instance_id,
        launch_time: instance.launch_time.to_time
      }
    end
  
    # Sort instances by launch time
    instances.sort_by! { |instance| instance[:launch_time] }
  
    # Return instance data as JSON
    return instances.to_json
  end


# # Use the EC2 client to get a list of instances
# response = ec2_client.describe_instances
# instances = response.reservations.map(&:instances).flatten

# # Sort the instances by launch time
# def datetime_converter(datetime)
#   datetime.strftime('%Y-%m-%d %H:%M:%S')
# end

# instances.sort_by! { |i| datetime_converter(i.launch_time) }

# # Save the instances to a file in JSON format
# region = 'us-east-1'
# File.write("#{region}.json", JSON.pretty_generate(instances.map(&:to_h)))
