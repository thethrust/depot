require 'rubygems'
require 'csv'
require 'json'


HOLD_PATH = "_data-hold/"
PATH = "_data/"
COMBINED_PATH = PATH + "ind-all.csv"
COMBINED_JSON = "site/data/ind-all.json"

# SUPPORTING DATA
TAGS      = PATH + "ind-col_tags.csv"
ORGS      = PATH + "ind-col_orgs.csv"
AUTHORS   = PATH + "ind-col_authors.csv"
ORG_TYPES = PATH + "ind-col_orgtypes.csv"
SECTIONS  = PATH + "ind-col_sections.csv"
SUBJECTS  = PATH + "ind-col_subjects.csv"
TOOLS     = PATH + "ind-col_tools.csv"


$combined_data = {
	"projects" => [],
	"meta" => {}
}


def make_csv 
	csvs = [
		csv_guardian      = HOLD_PATH + "Interactive News - guardian.csv", 
		csv_international = HOLD_PATH + "Interactive News - international.csv", 
		csv_national      = HOLD_PATH + "Interactive News - national.csv", 
		csv_nyt           = HOLD_PATH + "Interactive News - nyt.csv", 
		csv_other         = HOLD_PATH + "Interactive News - other.csv"
	]

	headers = CSV.read(csvs[0], headers:true).headers.map {|h| h.downcase.gsub(/\s/,"") } + [ "isbroken","notmobile" ]

	broken_flags = [
		"currently broken",
		"currently not working",
		"currently offline",
		"404",
		"not working"
	]

	unless File.exists?(COMBINED_PATH)
		CSV.open(COMBINED_PATH,'w', :write_headers => true, :headers => headers) do |csv|
			csvs.each do |csv_path|
				CSV.foreach(csv_path, headers: true) {|row| 
					row['Org Type'] = row['Org Type'].to_s
					row['Authors'] =  (row['Authors'].nil? || row['Authors'].length < 1) ? row['Org'].to_s : fix_authors(row['Authors'].to_s)
					row['Tags'] = row['Tags'].downcase.strip.split(",").map { |c| fix_tags(c.strip) }.join(", ") unless row['Tags'].nil?
					row['Tools Used'] = row['Tools Used'].downcase.strip.split(",").map { |c| fix_tools(c.strip) }.join(", ") unless row['Tools Used'].nil?
					row['isbroken'] = (broken_flags.include? row['Notes']) ? "y" : nil
					row['notmobile'] = nil
					csv << row unless row['Project'].nil? 
				}
			end
		end
	end
end


def get_values(data, target, col)

	values = []
	orgtype_values = ["international", "national", "other"]

	CSV.foreach(data, headers: true) {|row| 
		if row[col].nil? || row[col].length < 1
			row[col] = "unknown"
		end
		split_row =  row[col].downcase.strip.split(",").map { |c| (col == "tags") ? fix_tags(c.strip) : c.strip }.reject { |c| c.length < 1 }
		values << split_row
	}

	values = values.map{ |val| val.flatten }
	values = values.flatten.uniq.sort

	col_hsh = {
		col => values
	}

	col_hsh
end


def get_supporting_data
	values = [
		[ TAGS, tag_values = get_values(COMBINED_PATH, TAGS, "tags") ],
		[ ORGS, org_values = get_values(COMBINED_PATH, ORGS, "org") ],
		[ AUTHORS, author_values = get_values(COMBINED_PATH, AUTHORS, "authors") ],
		[ ORG_TYPES, orgtype_values = get_values(COMBINED_PATH, ORG_TYPES, "orgtype") ],
		[ SECTIONS, section_values = get_values(COMBINED_PATH, SECTIONS, "section") ],
		[ SUBJECTS, subject_values = get_values(COMBINED_PATH, SUBJECTS, "subject") ],
		[ TOOLS, tools_values = get_values(COMBINED_PATH, TOOLS, "toolsused") ]
	]

	# spits out size of each 
	puts "===================================="
	values.each do |v| 

		key = v[1].keys[0]
		vals = v[1].values.flatten.map { |vf| vf }.reject {|vf| vf.length < 1 }.uniq
		

		$combined_data["meta"][key] = vals


		puts "data: #{key}"
		puts "length: #{vals.length}"
		puts "-----------"

		# MAKE CSVS
		unless File.exists?(v[0])
			CSV.open(v[0],'w', :write_headers => true, :headers => key) do |csv|
				vals.each do |val|
					csv << [val]
				end
			end
		end
	end
end


def fix_tags(str)
	fixes = {
		"3-d" => "3d",
		"before/after slider" => "before/after",
		"crowd source" => "crowdsource",
		"doc viewer" => "document",
		"document viewer" => "document",
		"documents" => "document",
		"gifs" => "gif",
		"illustrations" => "illustration",
		"interactive" => "interactive feature",
		"interactive graphics" => "interactive graphic",
		"micro site" => "microsite",
		"narrated graphics" => "narrated graphic",
		"news app" => "news application",
		"slide show" => "slideshow",
		"pan" => "panorama",
		"quiz" => "game",
		"static maps" => "static map",
		"tree map" => "treemap",
		"vr" => "virtual reality"
	}

	words_to_remove = [
		"interactive ",
		"static "
	]

	# fix taxonomy errors and plurals... 
	str = fixes[str] || str

	# ... then remove meaningless words
	new_str = str.gsub(words_to_remove[0], "").gsub(words_to_remove[1], "")

	new_str
end


def fix_tools(str)
	fixes = {
		"bootstrap 3" => "bootstrap",
		"d3 jetpack" => "d3-jetpack",
		"doc cloud" => "documentcloud",
		"document cloud" => "documentcloud",
		"google spreadsheet" => "google sheets",
		"google spreadsheets" => "google sheets",
		"http://datadesk.github.io/python-elections/" => "python-elections (http://datadesk.github.io/python-elections)",
		"illustrator" => "adobe illustrator",
		"instagram" => "instagram api",
		"mapbox/tilemill" => "mapbox",
		"nasa landsat 8" => "landsat 8",
		"openstreet maps" => "openstreetmap",
		"openstreetmaps" => "openstreetmap",
		"photoshop" => "adobe photoshop",
		"propublica's stateface font" => "stateface font (propublica)",
		"propublica's timeline setter" => "timelinesetter (propublica)",
		"propublica's timelinesetter" => "timelinesetter (propublica)",
		"timeline" => "timelinejs",
		"twitter bootstrap" => "bootstrap"
	}
	str = (str.nil? || str.length < 1) ? str : str.gsub(".js", "").downcase.strip
	new_str = fixes[str] || str
	new_str
end


def fix_authors(str)
	# Check for instances of "and" or "&" 
	str = str.gsub(/[^0-9a-z]and[^0-9a-z]/i, ", ")
	new_str = (str.downcase != "roads & kingdoms") ? str.gsub(/[^0-9a-z]&[^0-9a-z]/i, ", ") : str
	new_str
end


def make_json

	cols_to_split = [
		"toolsused",
		"authors",
		"tags"
	]

	$combined_data["projects"] = CSV.open(COMBINED_PATH, :headers => true).map { |c| 

		cols_to_split.each do |col|
			c[col] = c[col].split(",").map { |s| s.strip }.flatten unless c[col].nil?
		end
		c.to_h
	}

	File.open(COMBINED_JSON, 'w') do |file|
		file.puts JSON.pretty_generate($combined_data)
	end
end




make_csv

get_supporting_data 


make_json










# -- 30 -- #