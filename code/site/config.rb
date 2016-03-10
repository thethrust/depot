require 'rubygems'
require 'helpers/custom_helpers'
require 'date'

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###



###
# Blog settings
###

blog_site_title = "Depot"
blog_site_description = "Journalism & Machines"


set :site_title, blog_site_title
set :site_description, blog_site_description


activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  # blog.sources = "{year}-{month}-{day}-{title}.html"
  blog.taglink = "{tag}.html"
  # blog.layout = "layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"
  blog.default_extension = ".erb"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end


# static_pages = [
#   "tags",
#   "about",
#   "404"
# ]

# static_pages.each do |stat|
#   page "/entry/index.html", layout: "page_entry.html"
# end

# page "/entry.html", layout: "page_entry.html"

proxy "/entry/index.html", "page_entry.html", :locals => { :title => "HELLO!" }

$entries = data["ind-all"]["projects"]
$prox_sections = data["ind-all"].meta.keys
$meta_data = data["ind-all"].meta

# dates = data["ind-all"]["projects"].map {|p| p["published"] }

# dates.each do |dt|
#   if !dt.nil? 
#     if dt.match("/")
#       dt = dt.split("/").reverse
#       dt = dt.join("-")
#     else
#       dt = dt
#     end
#   else
#     dt = 'unknown'
#   end
#   puts dt
# end



# Generate nav pages 
$prox_sections.each do |tag|
  regPat = /[^a-zA-Z0-9_-]/
  slug = tag.downcase.strip.gsub(regPat,'-')
  proxy "/#{slug}/index.html", "page_section_level.html", :locals => { :tag => tag, :tag_name => tag, :page_setting => "section" }
end

# Generate detail pages 
$prox_sections.each do |tag|
  $meta_data[tag].each do |t|
    regPat = /[^a-zA-Z0-9_-]/
    slug = t.downcase.strip.gsub(regPat,'-')
    slug_tag = tag.downcase.strip.gsub(regPat,'-')
    proxy "/#{slug_tag}/#{slug}/index.html", "page_router.html", :locals => { :tag => tag, :tag_name => t, :page_setting => "detail #{slug}" }
  end
end

# $entries[0..2].each do |ent|
#   regPat = /[^a-zA-Z0-9_-]/
#   slug = ent.project.downcase.strip.gsub(regPat,'-')
#   proxy "/entry/index.html", "page_entry.html", :locals => { :tag => "entry", :tag_name => slug, :page_setting => "entry" }
# end


##########################
#  OLD TEST PROXY PAGES  #
##########################

# data["ind-all"].meta["tags"].each do |tag|
#   regPat = /[^a-zA-Z0-9_-]/
#   slug = tag.downcase.strip.gsub(regPat,'-')
#   proxy "/#{slug}.html", "page-layout.html", :locals => { :tag => "tags", :tag_name => tag }
# end

# data["ind-all"].meta["authors"].each do |auth|
#   regPat = /[^a-zA-Z0-9_-]/
#   slug = auth.downcase.strip.gsub(regPat,'-')
#   proxy "/#{slug}.html", "page-layout.html", :locals => { :tag => "authors", :tag_name => auth }
# end

#########
#  END  #
#########



page "/feed.xml", layout: false

activate :directory_indexes

# Google Drive connector (with test sheet)
# activate :google_drive, load_sheets: '0Ang1OfZPG6vydE1xR2FuQWx4RThCTmk0ZzVIYjZXd2c'


# Reload the browser automatically whenever files change
# configure :development do
#   activate :livereload
# end

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :asset_dir, 'assets'

# Build-specific configuration
configure :build do

  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript
end
