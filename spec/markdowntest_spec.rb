#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent
	
	libdir = basedir + 'lib'
	extdir = basedir + 'ext'
	
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

require 'rubygems'
require 'spec'
require 'bluecloth'

require 'spec/lib/helpers'
require 'spec/lib/constants'
require 'spec/lib/matchers'

require 'rbconfig'
require 'dl'


#####################################################################
###	C O N T E X T S
#####################################################################

describe BlueCloth, "-- MarkdownTest 1.0: " do
	include BlueCloth::TestConstants,
		BlueCloth::Matchers

	before( :all ) do
		soext = Config::CONFIG['LIBRUBY_SO'].sub( /.*\./, '' )
		@dlname = "libtidy.#{soext}"

		begin
			DL.dlopen( @dlname )
		rescue RuntimeError => err
			@have_libtidy = false
			@tidy_error = err.message
		else
			@have_libtidy = true
			@tidy_error = nil
		end
	end
	
	before( :each ) do
		pending( "These tests require #@dlname: #@tidy_error" ) unless @have_libtidy
	end
	
	
	markdowntest_dir = Pathname.new( __FILE__ ).dirname + 'data/markdowntest'
	Pathname.glob( markdowntest_dir + '*.text' ).each do |textfile|
		resultfile = Pathname.new( textfile.to_s.sub(/\.text/, '.html') )

		it textfile.basename( '.text' ) do
			markdown = textfile.read
			expected = resultfile.read
			options = { :smartypants => false }
		
			the_markdown( markdown, options ).should be_transformed_into_normalized_html( expected )
		end
	end

end

