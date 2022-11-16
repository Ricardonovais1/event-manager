require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'


def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone)

    phone = phone.to_s.gsub(/([-() .])/, '')

    
    if phone.length == 11 && phone[0] == '1'
    phone = phone[1..-1].to_i   
    elsif phone.length == 11 && phone[0] != '1' 
    phone = 'Bad number'
    elsif phone.length < 10 || phone.length > 11
    phone = 'Bad number'
    end
    phone.to_i
end

def time_targeting(time)
    
    time = time.split(' ')[-1].split(':')[0]
    $times << time
    
end


def legislator_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        civic_info.representative_info_by_address(
            address: zip,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials

        legislators = legislators.officials
        legislator_names = legislators.map(&:name).join(', ')
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
end

def save_thank_you_letter(id, form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')

    filename = 'output/thanks_#{id}.html'

    File.open(filename, 'w') do |file|
        file.puts form_letter
    end
end

puts 'Event Manager Initialized!'

contents = CSV.open(
    '/home/ricardo1/rubyTOP/event_manager/event_attendees.csv', 
    headers: true,
    header_converters: :symbol
)

template_letter = File.read('/home/ricardo1/rubyTOP/event_manager/form_letter.erb')
erb_template = ERB.new template_letter


$times = []
def find_best_time(times)
    hash = times.reduce(Hash.new(0)) do |hour, how_many|
        hour[how_many] = times.count(how_many)
        hour
    end

    puts "The peak hours were as follows:"
    hash.each do |k, v|
     puts "#{v} people signed at #{k} hours"
    end

    # p times.map(&:to_i).group_by { |number| number }
   
end

contents.each do |row|
    id = row[0]
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])

    phone = clean_phone_number(row[:homephone])

    time = time_targeting(row[:regdate])
    $times << time
    
    legislators = legislator_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    save_thank_you_letter(id, form_letter)
end
$times.each do |ele|
    if ele.class == Array
        $times.delete(ele)
    end
end
find_best_time($times)





# puts File.exist?('/home/ricardo1/rubyTOP/event_manager/event_attendees.csv')

# constant = File.read('/home/ricardo1/rubyTOP/event_manager')

# lines = File.readlines('/home/ricardo1/rubyTOP/event_manager/event_attendees.csv')