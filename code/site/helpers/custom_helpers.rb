# Storing helpers outside of config 
# Inspired by - https://github.com/voxmedia/verge-50/blob/master/helpers/custom_helpers.rb
require 'yaml'
require 'json'
require 'date'

module CustomHelpers


	def sluggify(str)
		regPat = /[^a-zA-Z0-9_-]/
		slug = str.downcase.strip.gsub(regPat,'-')
		slug
	end


	def get_list_of_projects(data)
		filtered_data = data["ind-all"]["projects"].select { |proj| proj[tag].map{ |p| p.downcase }.include? tag_name unless proj[tag].nil? }
			# if proj[tag].length > 1
			# 	proj[tag].map{ |p| p.downcase }.include? tag_name unless proj[tag].nil?
			# else
			# 	proj[tag][0].downcase.include? tag_name unless proj[tag].nil?
			# end
		# end

		filtered_data
	end

	def get_date(str)
		dte = str

		begin 
			dte = Date.strptime(str, "%d-%b-%y")
		rescue Exception=>e
			puts "Problem: #{e}"
		end

		dte
	end

	def get_current_year
		# Flip to false if its a new year and I haven't made a new project yet
		date_is_right = true 
		year = (date_is_right) ? Date.today.strftime("%Y") : "all"
		return year
	end


	def truncate_text(str)
		trunc_length = 150
		if str
			cut_off = str.length > trunc_length ? " <span class='arrow right'>→</span>" : ""
			return str[0...trunc_length] + cut_off
		else
			return ""
		end
	end


	def plural_text(num, singular = "entry", plural = "entries")
		text = (num < 2) ? singular : plural
		return "#{num} #{text}"
	end


	def nav_link(link_text, url, options = {})
		options[:class] ||= "button__link"
		options[:class] << " active" if "#{url}/" == current_page.url
		link_to(link_text, url, options)
	end


	def getData(obj, target)
		slug = obj.page.slug
		date = obj.page.date_path.split("/")
		obj['posts']["#{date[0]}"]["#{date[1]}"]["#{slug}"]["#{target}"]
	end


	def get_local_data(data, target)
		path = "#{root}/source/posts/#{data.date_path}/#{data.slug}/data/#{target}"
		path_data = File.read(path)
		data = JSON.parse(path_data)
	end


	def get_tag_list(tags, desc = nil)
		iterator = 0
		desc_array = []
		tags.each do |tag, articles|
			if iterator == blog.tags.length - 1
				desc_array << "and #{tag}."
			else
				desc_array << "#{tag}, "
			end
			iterator += 1
		end

		if desc == nil
			desc_list = desc_array.map do |d|
				d.gsub(/\.|,/,"").gsub("and","").strip
			end
			return desc_list
		else
			return "#{desc}#{desc_array.join("").downcase}"
		end
	end


	def get_favicon(tags)
		tag = tags.downcase.split(",")[0]
		root_path = "#{root}/source/images/emojis/#{tag}.png"
		tag_path = "/images/emojis/#{tag}.png"
		tag_default = "/images/emojis/default.png"
		
		if (File.exist? root_path)
			return tag_path
		else 
			return tag_default
		end
	end


	def get_promo_image(data, size)
		if data 
			extensions = ["png", "jpg", "jpeg", "gif"]
				outer_path = "#{root}/source/posts/#{data.date_path}/#{data.slug}/images"
				inner_path = "/#{data.slug}" # --> /#{data.date_path}/#{data.slug}
				extensions.each do |ext|
					tail = "promo-#{size}.#{ext}"
					root_path = "#{outer_path}/#{tail}"
					rel_path = "#{inner_path}/#{tail}"
					return rel_path if (File.exist? root_path)
				end
		end
		nil
	end


	def setNotes(item)
		itemArray = item.split("[")
		title = itemArray[0].strip
		addorg = (itemArray.length > 1) ? itemArray[1].split("|") : nil
		address1 = (addorg && addorg.length > 1) ? addorg[0].gsub("]","").strip : nil
		address2 = (addorg.length > 0 && addorg.length <2) ? itemArray[1].gsub("]","").strip : nil
		address = (address1 != nil) ? address1 : address2
		attrib = (addorg && addorg[1]) ? addorg[1].gsub("]","").strip : nil

		obj = {
			'title' => title,
			'address' => address,
			'attrib' => attrib
		}
	end


	def getYML(yml)
		#{}`cp #{root}/source/posts/#{yml} #{root}/data/this.yml`
		data = YAML.load_documents(File.read("#{root}/source/posts/#{yml}"))
		if data[0].length
			return data[0]
		else
			return nil
		end
	end
end