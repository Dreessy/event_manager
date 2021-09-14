require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def zipcode_fixer(zipcode)
  zipcode.to_s.rjust(5,'0')[0..4]
end

def phone_fixer_number(homephone)
 homephone.gsub!(/[^\d]/,'')
if homephone.length == 11 && homephone[0] == '1'
  homephone[1..10]
elsif homephone.length == 10
  homephone
  else 
    homephone
  puts 'invalid number'
end
end
def legislators_by_zipcode(zip)
civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
    begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your rsepresentatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
 end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"
  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts 'Event Manager Initialized!'
contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
template_letter = File.read('/home/ciro/Scrivania/event_manager/form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  homephone = phone_fixer_number(row[:homephone])
  zipcode = zipcode_fixer(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)
   form_letter = erb_template.result(binding)
   save_thank_you_letter(id,form_letter)
   puts homephone
end